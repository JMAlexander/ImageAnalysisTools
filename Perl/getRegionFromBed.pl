#!/usr/bin/perl

## input is bed sorted by chr

use strict;
use warnings;

######################### MAIN ######################
my $chr = $ARGV[1];
my $start = $ARGV[2];
my $end = $ARGV[3];

open (IN, $ARGV[0]);
my $out = $chr.".".$start.".".$end.".".$ARGV[0];
open(OUT, ">$out");
while(my $data = <IN>){
	my($c,$s,$e) = ($data =~ /^(\S+)\s+(\S+)\s+(\S+)/);
	if($c eq $chr){
		if($s >= $start && $s < $end){
			print OUT $data;
		}
		if($s > $end){
			last;
		}
	}
}
close OUT;
close IN;
exit;

############# EOF