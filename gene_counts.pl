#!/usr/bin/perl -w
use strict;
use Getopt::Std;

usage() unless @ARGV;
my %opt;
getopts('hn:i:g:', \%opt);
usage() if $opt{h};

my @files      = split ",", $opt{i};
my @names      = split ",", $opt{n};
my $file_names = join " ", @files;
my $gtf        = get_path_to_gtf_file ( $opt{g} );
#my $refLink    = get_refLink_file ( $opt{g} );
my %genes;
sanity_checks ( \@files, \@names );

print "Generating flagstat files.\n";
system ( "parallel samtools flagstat {} '>' {}.flagstat ::: $file_names" );

$"="\n\t";
#$file_names = join " ", @files;
print "Generating counts for these alignments: \n\t@files\n\nUsing this gene track file (GTF): $gtf\n\n";
system ( "parallel coverageBed -abam {} -b $gtf '>' {}.counts ::: $file_names" );

for ( my $i = 0; $i < @files; $i++ )
{
    my $file   = $files[$i];
    my $name   = $names[$i];
    print "Generating gene-level counts for this (name: $name) file: $file.\n";
    open IN, "<$file.counts";
    while ( my $line = <IN> )
    {
        my @split    = split "\t", $line;
        my $chrom    = $split[0];
        my $IDs      = $split[8];
        my $coverage = $split[9];
        my $gene_len = $split[11];
        if ( $split[2] eq "exon" )
        {
            my ($p_id)          = $IDs =~ /p_id "([^"]+)"/; $p_id = "" unless $p_id;
            my ($tss_id)        = $IDs =~ /tss_id "([^"]+)"/;
            my ($gene_id)       = $IDs =~ /gene_id "([^"]+)"/;
            my ($transcript_id) = $IDs =~ /transcript_id "([^"]+)"/;
            my ($gene_name)     = $IDs =~ /gene_name "([^"]+)"/;
           #my ($gene_name)     = $refLink =~ /\t([^\t]+)\t$transcript_id\t/s;
            $gene_name = "" unless ($gene_name);
            my $key             = "$chrom\t$gene_id\t$gene_name\t$p_id\t$transcript_id\t$tss_id";
            if ( defined ( $genes{$key} ) )
            {
                if ( $i == 0 )
                {
                    my ($left,$right) = $genes{$key} =~ /^(\d+)(.+)/;
                    $left += $gene_len;
                    $genes{$key} = "$left$right";
                }
                    
                my @counts_so_far = split "\t", $genes{$key};
                if ( $#counts_so_far == ($i+1) )
                {
                    my $value            = $genes{$key};
                    my ($left)           = $value =~ /(.*?)\t*(?:\d+)$/;
                    my $updated_coverage = $coverage + $counts_so_far[$i+1];
                    $genes{$key} = "$left\t$updated_coverage";
                }
                else { $genes{$key} .= "\t$coverage"; }
            }
            else { $genes{$key} = "$gene_len\t$coverage"; }
        }
    }
    close IN;
}

open OUT, ">tmp_combined_counts.txt";
print OUT "chrom\tgene_id\tgene_name\tp_id\ttranscript_id\ttss_id\tgene_length\t";
for (my $i = 0; $i < @names; $i++ ) 
{ 
    ( $i == $#names ) ? print OUT "$names[$i] counts" : print OUT "$names[$i] counts\t"; 
} 
print OUT "\n";
while ( my ($key, $value) = each %genes ) { print OUT "$key\t$value\n"; }
close OUT;

# Get the number of reads aligned
my @reads_aligned;
foreach my $file ( @files )
{
    my $flagstat = `cat $file.flagstat`;
    my ($reads)  = $flagstat =~ /(\d+)\s\+.+?total/;
    push @reads_aligned, $reads;
}


print "Reads aligned: \n\t@reads_aligned\n";

my @counts = `cat tmp_combined_counts.txt`;

open OUT, ">combined_counts.txt";
for my $i ( 0..$#counts )
{
    my $line = $counts[$i];
    chomp ( my @split = split "\t", $line );
    # perform RPKM calculations
    for my $j ( 0..$#split )
    {
        print OUT "$split[$j]\t";
        print OUT "$split[$j] RPKM\t" if ($j > 6 and $i == 0 );
        if ( $j > 6 and $i )
        {
            my $RPKM = ($split[$j]/($split[6]/1_000))/($reads_aligned[$j - 7]/1_000_000);
            print OUT "$RPKM\t";
        }
    }
    print OUT "\n";
}
close OUT;
my $time = `date`;
print "Finished at $time.\n";
# clean up files - need the loop because the files are probably in different locations
foreach my $file ( @files ) { system ( "rm $file.counts" ); }
system ( "rm tmp_combined_counts.txt" );

sub get_path_to_gtf_file
{
    my $arg = shift;
    $arg = "" unless $arg;

    if    ( $arg eq "mm9"  ) { $arg = "/safer/genomes/Mus_musculus/UCSC/mm9/Annotation/Genes/genes.gtf";  }
    elsif ( $arg eq "hg19" ) { $arg = "/safer/genomes/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf"; }
    elsif ( $arg eq "hg18" ) { $arg = "/safer/genomes/Homo_sapiens/UCSC/hg18/Annotation/Genes/genes.gtf"; }
    else 
    { 
        print "Couldn't determine reference genome; using hg19 as the default.\n\n";
        $arg = "/safer/genomes/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf";
    }
    return $arg;
}

sub usage
{
    die <<OUT;

Usage: perl gene_counts.pl -i <file_1,file_2,...,file_n> -n <file_1_name,file_2_name,...,file_n_name> -g <hg18|hg19|mm9>

Flags: i - comma-separated bam files
       n - comma-separated names that are to be associated with the bam files
       g - reference genome to use (human reference hg18 and hg19, and mouse reference mm9 are supported)
       h - prints out this usage statement

Note : The input files _must_ be .bam files otherwise this script will not work.

OUT
}

sub sanity_checks
{
    my ($files, $names) = @_;
    die "ERROR: the number of files must match the number of names. Exiting.\n" if @$files != @$names;
    usage() unless @$files;
    for my $file ( @$files ) 
    { 
        die "ERROR: $file does not exist. Exiting." unless -e $file; 
    }
}

sub get_refLink_file
{
    my $arg = shift;
    $arg    = "" unless $arg;

    if    ( $arg eq "mm9"  ) { $arg = "/safer/genomes/Mus_musculus/UCSC/mm9/Annotation/Genes/refLink.txt";  }
    elsif ( $arg eq "hg19" ) { $arg = "/safer/genomes/Homo_sapiens/UCSC/hg19/Annotation/Genes/refLink.txt"; }
    elsif ( $arg eq "hg18" ) { $arg = "/safer/genomes/Homo_sapiens/UCSC/hg18/Annotation/Genes/refLink.txt"; }
    else 
    { 
        print "Couldn't determine the reference genome from the command line arguments; using hg19 as the default.\n\n";
        $arg = "/safer/genomes/Homo_sapiens/UCSC/hg19/Annotation/Genes/refLink.txt";
    }
    print "Using this refLink file:\n\t$arg\n";
    my $rval = `cat $arg`;
    return $rval;
}

