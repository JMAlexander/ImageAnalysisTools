#!usr/bin/perl

###Trim Wiggle

###Call:  perl trim_wiggle.pl bed_file
###bed_file:  Should be in bed file format, which has been x bp bins of reads but can be any bed that you want to condense by merging neighboring entries
###chrxx	xxxxxxxx	xxxxxxx	xxxxxxx
###Function:  Reads input file and merges neighboring lines that have the same trailing value (last column value).
###For example, would merge
###chr1	100	150	1
###chr1	151	200	1
###chr1	201	250	2
###into
###chr1 100	200	1
###chr1	201	250	2


#Opens files
open READFILE, $ARGV[0];
open WRITEFILE, ">$ARGV[0].trimmed";

#Reads first line to initialize comparison values $act_chr, $start_bin, $value
$first_line = <READFILE>;
($act_chr, $start_bin, $value) = ($first_line =~ /(chr\w+)\t(\d*)\t\d*\t(.*)/);

#Output to update user on progress
print "Current chromosome:  $act_chr\n";

#Loop, makes comparison.  If $value not equal to the previous $value, prints a line into a new file with chromosome\t"original start loc"\t"Current location"\t"Previous value"
#Resets values after non-match
while (<READFILE>){
	$_ =~ /(chr\w+)\t(\d*)\t(\d*)\t(.*)/;
	if (!($1 eq $act_chr)){
		print "Current chromosome:  $act_chr\n";
	}
	if (!($1 eq $act_chr) or !($4 eq $value)){
		print WRITEFILE "$act_chr\t$start_bin\t$end_bin\t$value\n";
		($act_chr, $start_bin, $value) = ($1, $2, $4);
	}
	$end_bin = $3;
}

#Prints final line
print WRITEFILE "$act_chr\t$start_bin\t$3\t$value";

#Closes files
close READFILE;
close WRITEFILE;


exit;

