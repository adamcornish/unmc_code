#!/usr/bin/perl
use warnings;
use strict;

if ( $#ARGV < 0 or $#ARGV > 2 or $ARGV[0] =~ /(?:-h|help)/ )
{
    die "\nProper usage: perl annotate.pl <isoform_exp.diff> <hg18|hg19|mm9>\n\n\tThe file to annotate must be the isoform output file from cuffdiff, otherwise this script will not work.\n\n";
}

system ( "cp /safer/tools/scripts/sorttable.js ./" ) unless -f "./sorttable.js";
my $file    = $ARGV[0];
my $refLink = get_refLink_file ($ARGV[1]);
my (@data, @rows);
open IN, "<$file";
while ( my $line = <IN> ) 
{ 
    my @split = split "\t", $line;
    # filter out unwanted data: anything that failed, is non-coding RNA, or has an expression level that is insignificant
    push @data, $line if ($line !~ /(?:NOTEST|FAIL|\tno|test_id)/ and ( $split[7] >= 3 or $split[8] >= 3 ) and $split[10] !~ /e/ ); 
}

open HTML, ">differentially_expressed_genes.htm";
print HTML <<HEAD;
<html>
<head>
<script src="sorttable.js"><\/script>
<style>
td, table.sortable {
    font-size: 10px;
    font-family: Verdana; }
table.sortable thead {
    background-color: #153E7E;
    color:#ccc;
    font-weight: bold;
    cursor: default; }
table { align: center; }
<\/style>
<body>
\t<table class="sortable">
\t\t<thead>
\t\t\t<tr>
\t\t\t\t<th>test_stat<\/th>
\t\t\t\t<th>Accession ID<\/th>
\t\t\t\t<th>Gene Symbol<\/th>
\t\t\t\t<th style="width:18%">Gene Name<\/th>
\t\t\t\t<th>Brain Atlas<\/th>
\t\t\t\t<th>Locus<\/th>
\t\t\t\t<th>Control FPKM<\/th>
\t\t\t\t<th>Experiment FPKM<\/th>
\t\t\t\t<th>ln(fold_change)<\/th>
\t\t\t\t<th>fold_change<\/th>
\t\t\t\t<th>p value<\/th>
\t\t\t\t<th>q value<\/th>
\t\t\t<\/tr>
\t\t<\/thead>
\t\t<tbody>
HEAD

print "There are ", $#data + 1, " significant hits in this comparison.\n";

foreach my $line ( @data )
{
    my @split = split "\t", $line;
    my %gene_info = ( accession_id => "$split[0]",
                      gene_symbol  => "$split[1]",
                      gene_name    => "",
                      brain_atlas  => "" );

    $gene_info{brain_atlas} = ($gene_info{gene_symbol} =~ /LOC/) ? "N/a" : "<a href='http://www.brain-map.org/search/index.html?query=$gene_info{gene_symbol}'>$gene_info{gene_symbol}<\/a>";
    ($gene_info{gene_name}) = $refLink =~ /$gene_info{gene_symbol}\t([^\t]+)\t$gene_info{accession_id}\t/s;
    $gene_info{gene_name}   = "UNKNOWN" if $gene_info{gene_name} eq "";

    print "Currently working on $line";
    print "\tAccession ID: $gene_info{accession_id}\n";
    print "\tGene Symbol : $gene_info{gene_symbol}\n";
    print "\tGene Name   : $gene_info{gene_name}\n";
    print "\tBrain Atlas : $gene_info{brain_atlas}\n\n\n";
    my $org         = ( $ARGV[1] eq "mm9" ) ? "Mouse" : "Human";
    my $fold_change = ($split[8] > $split[7] ) ? $split[8] / $split[7] : -1*($split[7] / $split[8]);
    my $table_row   = <<TABLE_ROW;
\t\t\t<tr>
\t\t\t\t<td>$split[10]<\/td>
\t\t\t\t<td><a href='http://www.ncbi.nlm.nih.gov/nuccore/$gene_info{accession_id}'>$gene_info{accession_id}<\/a><\/td>
\t\t\t\t<td>$gene_info{gene_symbol}<\/td>
\t\t\t\t<td>$gene_info{gene_name}<\/td>
\t\t\t\t<td>$gene_info{brain_atlas}<\/td>
\t\t\t\t<td><a href='http:\/\/genome.ucsc.edu\/cgi-bin\/hgTracks?org=$org&position=$split[3]'>$split[3]<\/a><\/td>
\t\t\t\t<td>$split[7]<\/td>
\t\t\t\t<td>$split[8]<\/td>
\t\t\t\t<td>$split[9]<\/td>
\t\t\t\t<td>$fold_change<\/td>
\t\t\t\t<td>$split[11]<\/td>
\t\t\t\t<td>$split[12]<\/td>
\t\t\t<\/tr>\n
TABLE_ROW
    push @rows, $table_row if $gene_info{accession_id} =~ /NM_/;
}
@rows = map { $_->[0] } sort { $a->[1] <=> $b->[1] } map { [$_, /tr>\s+<td>(.+?)</s] } @rows;
$"="\n";
print HTML @rows;

print HTML <<FOOTER;
\t\t<\/tbody>
\t\t<tfoot><\/tfoot>
\t<\/table>
<\/body>
<\/html>
FOOTER
close HTML;

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


