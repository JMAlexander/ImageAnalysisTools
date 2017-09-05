#!usr/bin/perl

##Split reads by chromosome

open FILE, $ARGV[0];
@reads_file = <FILE>;
close FILE;

$reads_file[0] =~ /(chr\w{1,2})\t/;
$chr = $&;
$frag_len = 300;

foreach (@reads_file){
	$_ =~ /(chr\w{1,2})\t(\d{3,9})\t.*\t([+-]{1})/;
	#print $1, $2, $3, "\n";
	#print @chr_reads, "\n";
	if ($1 eq $chr){
		if ($3 eq "+"){
			push (@chr_reads, $2 + 150);
		}
		elsif ($3 eq "-"){
			push (@chr_reads, $2 - 150);
		}
		else{
			print "Error, invalid strand";
		}
	}
	else{	
		# print "Writing file....\t", $ARGV[0];
		$file_name = $chr.".".$ARGV[0].".reads";
		open WRITEFILE, ">$file_name";
		print WRITEFILE "@chr_reads\n";
		close WRITEFILE;
		$chr = $1;
		if ($3 eq "+"){
			@chr_reads = $2 + 150;
		}
		elsif ($3 eq "-"){
			@chr_reads = $2 - 150;
		}
	}
 }	

exit;
