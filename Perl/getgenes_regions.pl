#!usr/bin/perl

####Intersect genelist with a second file

use Getopt::Long;


print "A perl script to extract a subset of genes from any given table.  Add a column with 0 if file genomic coordinates are found within gene list.\n\n";


### Initialize variables
$i = 0; ##Counter
$gene_list;
$search_column;
$file;
$file_column;
$output_file;
$add_column = '';
@genes;

GetOptions(
	"genes=s"=>\$gene_list,
	"file=s"=>\$file,
	"out=s"=>\$output_file);

$|++;
###Get gene names
open IN, $gene_list;
$filler_number = $search_column - 1;
while (<IN>){
	$_ =~ /(chr\S*)\t(\S*)\t(\S*)/;
	push (@genes, "$1\t$2\t$3");
}
$num_genes=scalar(@genes);
close IN;
print "Gene list read.  Identified $num_genes gene(s) in file.\n";

open IN2, $file;
@file = <IN2>;
close IN2;
$file_size = scalar(@file);
$filler_number = $file_column - 1;

open OUT, ">$output_file";
print "Scanning through query file.\n";
foreach $cur_line (@file){
	chomp($cur_line);
	$cur_line .= "\t0";
	$i++;
	if ($i > ($file_size / 20)){ ### Run feedback
		print ".";
		$i = 0;
	}
	($cur_chr, $cur_start, $cur_end) = $cur_line =~ /(chr\S*)\t(\S*)\t(\S*)/;
	foreach (@genes){
		($gene_chr, $gene_start, $gene_end) = $_ =~ /(chr\S*)\t(\S*)\t(\S*)/;
		if (($cur_chr eq $gene_chr) and ($cur_start eq $gene_start) and ($cur_end eq $gene_end)){
			chop($cur_line);
			$cur_line .= "1";
			$matched++;
		}
	}
print OUT "$cur_line\n";
}

print "Done.  $matched gene(s) matched\n\n";
exit;


