#!usr/bin/perl



opendir DIR, $ARGV[0] or die "Couldn't open: $!";
@files = readdir DIR;
close DIR;

foreach (@files){
	if ($_ =~ /.*\.genes.dat$/){
	push (@gene_files, $_);
	}
};
#print @gene_files;
#Read files one at a time
foreach (@gene_files){
	open READFILE, $_;
	@openfile = <READFILE>;
	close READFILE;
	#print @openfile;
#	foreach (@openfile){
#		$_ =~ /\d{3,}/;
#		print $&, "\n";
#	}
	@new_file = sort{($a =~ /.*\t(\d{3,})\t.*/)[0] <=> ($b =~ /.*\t(\d{3,})\t.*/)[0]} @openfile;
	open WRITEFILE, ">>$_.sorted";
	print WRITEFILE @new_file;
	close WRITEFILE;
} 

exit;
