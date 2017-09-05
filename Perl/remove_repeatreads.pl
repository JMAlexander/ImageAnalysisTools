#!usr/bin/perl

#Remove Repeat Reads

##Call: perl remove_repeatreads.pl bed_file repeat_threshold
##bed_file: Should be in bed file format.  Bed file should be sorted by chromosome, then by start position.
##chrxx	xxxxx	xxxxx	xxxxx

##Function: Scans list and removes (or skips depending on how you look at it, entries that are identical at columns 1 and 2 (chromosome and start column) to more than the repeat threshold of previous entries.  

##Opens files
open READFILE, $ARGV[0];
@file = <READFILE>;
close READFILE;


@reads_repeatremoved;
$repeat_threshold = $ARGV[1];
$prevchr = ' ';
$prevstart = 0;
$count = 1;

#Scans file, matching current chromosome and start position to previous (stored entry).  If count reaches the repeat threshold, it will skip all subsequent reads until reset.

#Also, keeps a running of number of repeats of same read (start position) counted
foreach (@file){
	($chr, $start) = ($_ =~ /chr(\w+)\t(\d*)\t/);
	if (($chr eq $prevchr) and ($start eq $prevstart)){
		if ($count >= $repeat_threshold){
			$count++;
			next;
		}
		$count++;
		push (@reads_repeatremoved, $_);
	}
	else{
		push (@reads_repeatremoved, $_);
		$prevchr = $chr;
		$prevstart = $start;
		push (@counts, $count);
		$count = 1;
	}
}
##Determined largest value for repetitive read
foreach (@counts){
	if ($_ > $largest_count){
		$largest_count = $_;
	}
}
#Initialize array of size $largest_count, each filled with a zero.
@dist_count = ((0) x $largest_count);

#Counts frequency of repeats.
#i.e. How many times was a read found twice, three times, 20 times.
foreach (@counts){
	$dist_count[($_ - 1)]++;
}
$num_reads = 1;
foreach (@dist_count){
	print "Reads found ($num_reads) times:\t$_\n";
	$num_reads++;
}

#Opens and prints list with repeats removed.
open WRITEFILE, ">$ARGV[0].rp$ARGV[1]";
print WRITEFILE @reads_repeatremoved;
close WRITEFILE;


#Opens and prints list of counts for each unique read.
open WRITEFILE, ">$ARGV[0].counts";
	print WRITEFIlE "Counts for each read.  Listed as ordered in scanned document\n";
foreach (@counts){
	print WRITEFILE "$_\n";
}
close WRITEFILE;

exit;	
