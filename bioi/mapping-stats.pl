#!/usr/bin/perl
use warnings;
use strict;

my $file     = shift;
my ($name)   = $file =~ /(.+)\.bam/;
system ( "samtools index $file" ) unless ( -e "$file.bai" or -e "$name.bai" );
my @data     = split "\n", `samtools idxstats $file`;
my $mapped   = 0;
my $unmapped = 0;
foreach my $line ( @data )
{
    my ($m, $u) = $line =~ /\S+\s+(\S+)\s+(\S+)/;
    $mapped   += $m;
    $unmapped += $u;
}

print "File\t\t\tMapped\t\tUnmapped\t% Mapped\t\tTotal Reads\n";
print "$file:\t$mapped\t$unmapped\t",$mapped/($unmapped+$mapped) * 100, "\t", $mapped+$unmapped, "\n";
