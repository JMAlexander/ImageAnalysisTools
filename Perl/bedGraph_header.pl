#!usr/bin/perl

###Concatenation of bedGraph Header Information

##Call: perl bedGraph_header.pl file
##file:  Should be file in bedGraph format.
##Function:  Concatenates a bedGraph header in front of a bedGraph formatted file.  Allows for upload of bedGraph file on the UCSC genome browser.  Does not prompt for all possible settings, but will make function header.
open (IN, $ARGV[0]);
@old_file= <IN>;
close IN;
print "track type=bedGraph\n";
print "name=";
chomp($name = <STDIN>);
print "visibility=";
chomp ($display_mode= <STDIN>);

$header = "track type=bedGraph name=\"$name\" visibility=$display_mode\n";
@header_file = ($header, @old_file);

open (OUT, ">$ARGV[0].bedgraph");
print OUT @header_file;
close OUT;

exit;
