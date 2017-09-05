#!usr/bin/perl

###Call Enhancers/Remove TSS

use Getopt::Long;

##Initialize variable

$gene_database;
$enhancer_list;


$results = GetOptions(
		"genes=s" =>\$gene_database,
		"feature=s" =>\$feature,
		"out=s" => \$out_file);

($type, $db) = $feature =~ /(\S*):(\S*)/;

open IN, $gene_database;
@gene_file=<IN>;
close IN;

###Fill gene hash

open OUT, ">$out_file";

print "Gene list must be in .gff3 format\n";
foreach (@gene_file){
	($chrom,$left_coord, $right_coord, $strand, $name)= $_ =~ /(chr\S*)\t$type\t$db\t(\d*)\t(\d*)\t\S\t([+-])\t\S\tName=(\S*?);/;
	if ($strand eq "+"){
		$left_promoter = $left_coord - 5000;
		$right_promoter = $left_coord + 5000;
		print OUT $chrom,"\t",$left_promoter,"\t",$right_promoter,"\t",$name,"\tPromoter\n";
	}
	elsif ($strand eq "-"){
		$left_promoter = $right_coord - 5000;
		$right_promoter = $right_coord + 5000;
		print OUT $chrom,"\t",$left_promoter,"\t",$right_promoter,"\t",$name,"\tPromoter\n";
	}
}
exit;
