#!usr/bin/perl

##Remove whitespace from file

##Call:  perl remove_whitespace.pl file
##file:  Any file format should work.
##Function: Outputs file.nospace that is original file with all blank spaces removed.  This is useful if trying to get tables in tab-delimited format from Excel and there is unwanted whitespace.

open (IN, $ARGV[0]);
open (OUT, ">$ARGV[0].nospace");
while (<IN>){
	$line = $_;
	$line =~ s/\ //g;
	print OUT $line;
}

close IN;
close OUT;





