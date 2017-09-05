#!usr/bin/perl

###Converts Tab-delimited files from Excel to Usable Files
###Converts returns ^M, which appear in text files converted by Excel into \n returns which are need for a lot of computing functions.

open IN, $ARGV[0];
open OUT, ">$ARGV[1]";
while (<IN>){
	$_ =~ s//\n/g;
	print OUT $_;
}

close IN;
close OUT;

exit;
