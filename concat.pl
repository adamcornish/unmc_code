#!/usr/bin/perl -w
use strict;

chomp ( my @files = `ls *fastq*` );

foreach my $file ( @files )
{
    my ($name) = $file =~ /(.+?L00\d_R\d)/;
    system ( "cat $file >> $name.fastq" );
}
