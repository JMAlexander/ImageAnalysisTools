#!usr/bin/perl


#Sort Wiggle

##Call:  perl sort_wiggle.pl wig_file
##wig_file:  Should be in wiggle format.  Last line should have carriage return.
##chrxx	xxxxx	xxxxxxx	xxxxxxx
##Function:  Will sort based on column 2 (start position in wig format).  Important:  Wiggle file must already be sorted by chromosome!!!


open READFILE, $ARGV[0];
open WRITEFILE, ">$ARGV[0].sorted";

$prev_chr = "chr1";
@temp_bins = ();
print "Current chromosome:  $prev_chr\n";

while (<READFILE>){
	($chr, $start) = ($_ =~ /(chr\w+)\t(\d*)/);
	if (!($chr eq $prev_chr)){
		@sort_chr = sort {$bin_hash{$a} <=> $bin_hash{$b}} @temp_bins;
                %bin_hash = ();
		print WRITEFILE @sort_chr;
		@temp_bins = ();
		$prev_chr = $chr;
		%bin_hash = ();
		print "Current chromosome:  $prev_chr\n";
	}
	$bin_hash{$_} = $start;
	push (@temp_bins, $_);
	
}
@sort_chr = sort {$bin_hash{$a} <=> $bin_hash{$b}} @temp_bins;
%bin_hash = ();
print WRITEFILE @sort_chr;
@tempfile = ();
$prev_chr = $chr;
%bin_hash = ();

close READFILE;
close WRITEFILE;

exit;

