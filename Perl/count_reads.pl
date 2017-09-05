#!usr/bin/perl

open READFILE, $ARGV[0];
@reads = <READFILE>;
close READFILE;

foreach (@reads){
	if ($_ =~ /chr/){
		$count++;
	}
}

print "Number of reads = $count\n\n";

exit; 
