#!/usr/bin/perl

## input is bed sorted by chr

use strict;
use warnings;

my @selected_regions = ();
my @sorted_regions = ();
my @chr = ();
my @start = ();
my @end = ();

######################### MAIN ######################
open READFILE, $ARGV[1];
while (<READFILE>){
	$_ = /(chr\w+)\t(\d*)\t(\d*)/;
	push (@chr, $1);
	push (@start, $2);
	push (@end, $3);
}



open (IN, $ARGV[0]);
open(OUT, ">$ARGV[2].regions");
for (my $i=0; $i < (scalar @chr); $i++){ 
	while(my $data = <IN>){
		my($c,$s,$e) = ($data =~ /^(\S+)\s+(\S+)\s+(\S+)/);
		if($c eq $chr[$i]){
			if($s >= $start[$i] && $s < $end[$i]){
				push (@selected_regions, $data);
			}
			if($s > $end[$i]){
				last;
			}
		}
	}
}

foreach (@selected_regions){
	print OUT $_;
}

close OUT;
close IN;
close READFILE;
exit;

############# EOF
