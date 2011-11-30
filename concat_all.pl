#!/usr/bin/perl -w
use strict;

chomp ( my @files = `ls *fastq*` );

foreach my $file ( @files )
{
    my ($name) = $file =~ /(.+?)_L00\d/;
    system ( "cat $file >> $name.fastq" );
}
