#!/usr/bin/perl -w
use strict;

my $dir       = "/safer/ngs0_data/data/finished";
my $mm9_gtf   = "/safer/genomes/Mus_musculus/UCSC/mm9/Annotation/Genes/genes.gtf";
my $mm9_idx   = "/safer/genomes/Mus_musculus/UCSC/mm9/Sequence/BowtieIndex/genome";
my $hg19_gtf  = "/safer/genomes/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf";
my $hg19_idx  = "/safer/genomes/Homo_sapiens/UCSC/hg19/Sequence/BowtieIndex/genome";
my $gtf       = $hg19_gtf;
my $idx       = $hg19_idx;
my $is_paired = 1;

if ( $is_paired )
{
    for my $i ( 0..$#pair1 )
    {
        my $one = $pair1[$i];
        my $two = $pair2[$i];
        my ($sample_dir, $sample) = $one =~ /(.+)\/(.+)/;
        my ($name) = $sample =~ /(.+?)\./;
        print "one        : $one\n",
              "two        : $two\n",
              "name       : $name\n",
              "sample     : $sample\n",
              "sample_dir : $sample_dir\n";

        system ( "tophat -p 120 -G $gtf -o $dir/$sample_dir/tophat_$name -r 200 $idx $one $two" );
    }
}
else
{
    foreach my $item ( @single )
    {
        my ($sample_dir, $sample) = $item =~ /(.+)\/(.+)/;
        my ($name) = $sample =~ /(.+?)\./;

        system ( "tophat -p 120 -G $gtf -o $dir/$sample_dir/tophat_$name $idx $dir/$item" );
    }
}
