#!usr/bin/perl

####Intersect genelist with a second file

use Getopt::Long;


print "A perl script to extract a subset of genes from any given table.\n\n";


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
	"genecol=s"=>\$search_column,
	"file=s"=>\$file,
	"filecol=s"=>\$file_column,
	"out=s"=>\$output_file);

$|++;
###Get gene names
open IN, $gene_list;
$filler_number = $search_column - 1;
while (<IN>){
	$_ =~ /(\S*\t){$filler_number}(\S*)/;
	push (@genes, $2);
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
	$i++;
	if ($i > ($file_size / 20)){ ### Run feedback
		print ".";
		$i = 0;
	}
	($filler, $cur_gene) = $cur_line =~ /(\S*\t){$filler_number}(\S*)/;
	foreach (@genes){
		if ($cur_gene eq $_){
			print OUT $cur_line;
			$matched++;
		}
	}
}

print "Done.  $matched gene(s) matched\n\n";
exit;


