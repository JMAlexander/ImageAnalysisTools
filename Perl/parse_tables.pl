#!usr/bin/perl

####Script to search one file with a column heading for another

use Getopt::Long;

###Initialize variable

$gene_list;
$target_file;
$column; ###base 0 (first column is 0);
%genes;
$output_file;
$target_genecolumn;

$results = GetOptions(
		"genelist=s" =>\$gene_list,
		"targetfile=s" =>\$target_file,
		"genecol=s" =>\$column,
		"tarcol=s" =>\$target_genecolumn,
		"delim=s" =>\$delim,
		"out=s" =>\$output_file);

$search_header = "";
for ($i=0; $i < $column; $i++){
	$search_header .= "\\S*$delim";
}

open IN, $gene_list;
while (<IN>){
	($search_col) = $_ =~ /$search_header(\S*)/;
	if (exists $genes{$search_col}){
		next;
	}
	else{
		$genes{$search_col} = "";
	}
}
close IN;


$target_search_header = "";
for ($i=0; $i < $target_genecolumn; $i++){
		$target_search_header .= "\\S*$delim";
}

$search_col = "";

open IN, $target_file;
@target_list = <IN>;
foreach $cur_line (@target_list){
	if ($cur_line =~ /^#/){
		push (@header, $cur_line);
	}
	else
	{
	($search_col) = $cur_line =~ /$target_search_header(\S*)/;
	if (exists $genes{$search_col}){
		$genes{$search_col} = $cur_line;
	}
	else{
		next; 
	}
	}
}
close IN;
open OUT, ">$output_file";
foreach (@header){
	print OUT $_;
}

@keys = keys %genes;
foreach (@keys){
	print OUT $genes{$_};
}
close OUT;

exit;
