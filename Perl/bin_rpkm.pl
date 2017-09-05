#!usr/bin/perl

##Bin RPKM from NkxGFP RNAseq Data

#use warnings;

open IN,$ARGV[0];
@file = <IN>;
close IN;

@D0_RPKM;
@D4_RPKM;
@D5_3_RPKM;
@D10_RPKM;

$D0_1 = 0;
$D0_2 = 0;
$D0_3 = 0;
$D0_4 = 0;
$D4_1 = 0;
$D4_2 = 0;
$D4_3 = 0;
$D4_4 = 0;
$D5_3_1 = 0;
$D5_3_2 = 0;
$D5_3_3 = 0;
$D5_3_4 = 0;
$D10_1 = 0;
$D10_2 = 0;
$D10_3 = 0;
$D10_4 = 0;

foreach (@file){
	#print "$_\n";
	$_ =~ /\S*\s*([0-9|\.]*)\s*([0-9|\.]*)\s*([0-9|\.]*)\s*([0-9|\.]*)/;
	push (@D0_RPKM, $1);
	push (@D4_RPKM, $2);
	push (@D5_3_RPKM, $3);
	push (@D10_RPKM, $4);
}

foreach (@D0_RPKM){
	if ($_ < 10){
		$D0_1++;
	}
	elsif ($_ < 100){
		$D0_2++;
	}
	elsif ($_ < 1000){
		$D0_3++;
	}
	elsif ($_ >= 1000){
		$D0_4++;
	}
	else{
		print "Error!";
	}
}

foreach (@D4_RPKM){
	if ($_ < 10){
		$D4_1++;
	}
	elsif ($_ < 100){
		$D4_2++;
	}
	elsif ($_ < 1000){
		$D4_3++;
	}
	elsif ($_ >= 1000){
		$D4_4++;
	}
	else{
		print "Error!!\n";
	}
}

foreach (@D5_3_RPKM){
	if ($_ < 10){
		$D5_3_1++;
	}
	elsif ($_ < 100){
		$D5_3_2++;
	}
	elsif ($_ < 1000){
		$D5_3_3++;
	}
	elsif ($_ >= 1000){
		$D5_3_4++;
	}
	else{
		print "Error!!\n";
	}
}
foreach (@D10_RPKM){
	if ($_ < 10){
		$D10_1++;
	}
	elsif ($_ < 100){
		$D10_2++;
	}
	elsif ($_ < 1000){
		$D10_3++;
	}
	elsif ($_ >= 1000){
		$D10_4++;
	}
	else{
		print "Error!!\n";
	}
}

foreach (@D10_RPKM){
	print "$_\n";
}


print "Day 0 RPKM\t Day 4 RPKM\tDay 5.3 RPKM\tDay 10 RPKM\n";
print "0-10 RPKM\t$D0_1\t$D4_1\t$D5_3_1\t$D10_1\n";
print "10-100 RPKM\t$D0_2\t$D4_2\t$D5_3_2\t$D10_2\n";
print "100-1000 RPKM\t$D0_3\t$D4_3\t$D5_3_3\t$D10_3\n";
print ">1000 RPKM\t$D0_4\t$D4_4\t$D5_3_4\t$D10_4\n";

exit;
