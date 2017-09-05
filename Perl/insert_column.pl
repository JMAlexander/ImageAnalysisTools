#!usr/bin/perl


##Add column in a tab-delimited text file

open IN, $ARGV[0];
open IN2, $ARGV[1];
open OUT, ">$ARGV[2]";

$cut_column = $ARGV[3];

for ($i=1; $i<$cut_column; $i++){
	$search_cut = $search_cut . "\\S*\\t";
}
#print $search_cut;
$paste_column = $ARGV[4];
for ($i=1; $i < $paste_column; $i++){
	$search_paste = $search_paste . "\\S*\\t";
}
@cut_file = <IN>;
foreach (@cut_file){
	$_ =~ /$search_cut(\S*).*/;
	push(@insert_column, $1);
}
@paste_file = <IN2>;
$j = 0;
foreach (@paste_file){
	$_ =~ /($search_paste)(.*)/;
	print OUT "$1@insert_column[$j]\t$2\n";
	$j++;
}

close IN;
close IN2;
close OUT;
