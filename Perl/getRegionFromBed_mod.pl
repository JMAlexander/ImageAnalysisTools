#!/usr/bin/perl

## input is bed sorted by chr

use strict;
##use warnings;

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

close READFILE;


open (IN, $ARGV[0]);
open(OUT, ">$ARGV[2]");
for (my $i=0; $i < (scalar @chr); $i++){ 
	print "Current location:  $chr[$i]\t$start[$i]\t$end[$i]";
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

my $chr = "";
my $start = 0;
my @chr_num = ();
my @chr_XYM = ();
my %chr_num_cache1 = ();
my %chr_num_cache2 = ();
my %chr_XYM_cache1 = ();
my %chr_XYM_cache2 = ();
my @sorted_chrnum = ();
my @sorted_chrXYM = ();


foreach (@selected_regions){
	($chr, $start) = ($_ =~ /chr(\w+)\t(\d*)/);
	if ($1 =~ /\d+/){
		$chr_num_cache1{$_} = $chr;
		$chr_num_cache2{$_} = $start;
		push (@chr_num, $_);
	}
elsif ($1 =~/[X,Y,M]/){
		$chr_XYM_cache1{$_} = $chr;
		$chr_XYM_cache2{$_} = $start;
		push (@chr_XYM, $_);
	}
	else{
		print "Error!!";
	}
}


#------Sort------

@sorted_chrnum = sort {$chr_num_cache1{$a} <=> $chr_num_cache1{$b} || $chr_num_cache2{$a} <=> $chr_num_cache2{$b}} @selected_regions;
@sorted_chrXYM  = sort {$chr_XYM_cache1{$a} cmp $chr_XYM_cache1{$b} || $chr_XYM_cache2{$a} <=> $chr_XYM_cache2{$b}} @selected_regions;


@sorted_regions = (@sorted_chrnum, @sorted_chrXYM);
foreach (@sorted_regions){
	print OUT $_;
}

close OUT;
close IN;
exit;

############# EOF
