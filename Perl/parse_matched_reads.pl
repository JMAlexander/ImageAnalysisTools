#!usr/bin/perl

open FILE, $ARGV[0];
@file = <FILE>;
close FILE;

foreach (@file){
	$_  =~ /.*:\s{1}/;
	$line = $';
	chomp ($line);
	$line = $line . " ";
	push (@reads, $line);
	
}


open WRITEFILE, ">input.BL6genes_matched.histo.reads";
print WRITEFILE @reads;
close WRITEFILE;

exit;
	
	
