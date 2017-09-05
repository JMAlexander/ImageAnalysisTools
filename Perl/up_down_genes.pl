#!usr/bin/perl

####Up and Down Genes
###Scans input file and counts lines that have at least one line with more than 10 reads and is changed by at least a specified fold change (on a log 2 scale) between the two conditions
open IN, $ARGV[0];
@file = <IN>;
close IN;

$down_xfold = 0;
$up_xfold = 0;

foreach (@file){
	$_ =~ /(\S*)\t(\S*)\t(\S*)\t(\S*)\t(\S*)/;
	if (($2 > 10) or ($3 > 10) or ($4 > 10) or ($5 > 10)){
		if ($1 <= -$ARGV[1]){
			$down_xfold++;
		}
		elsif ($1 >= $ARGV[1]){
			$up_xfold++;
		}
	}
}
#@down_xfold = grep(($_ <= -$ARGV[1]), @file);
#@up_xfold = grep(($_ >= $ARGV[1]),@file);


print "$down_xfold\t$up_xfold\n";

#foreach (@down_xfold){
#	print "$_\n";
#}
exit;
