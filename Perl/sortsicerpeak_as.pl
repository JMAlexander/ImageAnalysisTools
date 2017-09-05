#!usr/bin/perl

###Sort Sicer Peak (in ascending order)

###Call: perl sortsicerpeak_as.pl sicerpeakfile
###sicerpeakfile:  Should be in bed format.
###chrxx	xxxxx	xxxxx	xxxxx
###Function:  Reads input file and sorts input file in ascending order based on value of column 4 (final column).  Can have header, but header will be lost after run.

#Opens and reads input bed file. 
open FILENAME ,$ARGV[0];
@bedfile = <FILENAME>;
close FILENAME;


#Sorts in ascending numerical order.  Selects for sicer peak enrichment based on xx.xxxx numerical notation (other numbers should not have decimal)
@new_bedfile = sort {($a =~ /.*?(\d+\.\d*).*?/)[0] <=> ($b =~ /.*?(\d+\.\d*).*?/)[0]} @bedfile;

#Outputs sorted bed file
open WRITEFILE, ">$ARGV[0]sorted.dat";
print WRITEFILE @new_bedfile;
close WRITEFILE;

exit;
