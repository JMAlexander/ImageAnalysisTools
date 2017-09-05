#!usr/bin/perl

use Getopt::Long;

print "A perl script to extract a subset of features from a .gff3 table (e.g. exons corresponding to genes from a custom list.\n";

GetOptions(
	"genes=s" => \$gene_list,
	"genecol=s" => \$search_column,
	"file=s" => \$file,
	"feature=s" => \$feature,
	"out=s" => \$output_file
	);

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

open OUT, ">$output_file";
print "Scanning through query file.\n";
foreach $cur_line (@file){
	$i++;
	if ($i > $file_size / 20){ ###Run feedback
		print ".";
		$i = 0;
	}
	if ($cur_line =~ /^chr\S*\t\S*\t$feature\t/){
		($cur_gene) = $cur_line =~ /Name=(\S*?);/;
	}
	else{
		next;
	}
	foreach (@genes){
		if ($cur_gene eq $_){
			$matched++;
			print OUT $cur_line;
		}
	}
}

print "Done. $matched gene(s) matched\n\n";

exit;
	
