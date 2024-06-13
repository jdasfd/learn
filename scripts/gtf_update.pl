#!/usr/bin/perl -w
#
# Updating gtf to gtf2 format, that is the correct attribute col formatting.
#
# Author: Yuqian Jiang
# Created: 2024-06-10

use strict;
use warnings;
use autodie;

#----------------------------------------------------------#
# init
#----------------------------------------------------------#

my $expr;

if ($ARGV[0] =~ /\.gz$/) {
    $expr = "gzip -dc $ARGV[0] |";
}
else {
    $expr = "< $ARGV[0]";
}

open (my $fh, $expr) || die $!;

while ( <$fh> ) {
    chomp;
    next if /^#/;
    next if /^$/;
    my $line = $_;
    my @array = split/\t/, $line;
    $line =~ s/(.+)\t(.+?)$/$1/;
    if ($array[2] eq "gene") {
        my $attr="gene_id \"$array[8]\"";
        print "$line\t$attr\n";
    }
    else {
        my $attr="transcript_id \"$array[8].1\"; gene_id \"$array[8]\"";
        print "$line\t$attr\n"
    }
}

__END__
