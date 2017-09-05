#!usr/bin/perl

###Call Enhancers/Remove TSS

use Getopt::Long;

##Initialize variable

$gene_database;
$enhancer_list;


$results = GetOptions(
		"genes=s" =>\$gene_database,
		"enhancer_list=s" =>\$enhancer_list,
		"feature=s" =>\$feature);

($db, $type) = $feature =~ /(\S*):(\S*)/;

open IN, $gene_database;
@gene_file=<IN>;
close IN;

###Fill gene hash
%genes;

print "Gene list must be in .gff3 format\n";
foreach (@gene_file){
	($chrom,$left_coord, $right_coord, $strand, $name)= $_ =~ /(chr\S*)\t$db\t$type\t(\d*)\t(\d*)\t\S\t([+-])\t\S\tName=(\S*?);/;
	if ($strand eq "+"){
		$genes{$name} = "$chrom:$left_coord";
	}
	elsif ($strand eq "-"){
		$genes{$name} = "$chrom:$right_coord";
	}
}
@keys = keys(%genes);

open IN, $enhancer_list;
@enhancer_list = <IN>;
close IN;

open OUT, ">$enhancer_list.trimmed.bed";

foreach $enhancer (@enhancer_list){
	$promoter = 0;
	($enh_chrom, $enh_left_coord, $enh_right_coord) = $enhancer =~ /(chr\S*)\t(\d*)\t(\d*)/;
	foreach (@keys){
		($cur_gene_chrom, $cur_gene_TSS) = $genes{$_} =~ /(chr\S*?):(\d*)/;
		if ($cur_gene_chrom eq $enh_chrom){
			$left_diff = abs($enh_left_coord - $cur_gene_TSS);
			$right_diff = abs($enh_right_coord - $cur_gene_TSS);
			if (($left_diff < 1000) or ($right_diff < 1000)){
				$promoter = 1;
				if(($enh_left_coord < $cur_gene_TSS) and ($enh_right_coord > $cur_gene_TSS)){
					if($left_diff > 5000){
						$new_coord = $cur_gene_TSS - 5000;
						push(@enhancer_list, "$enh_chrom\t$enh_left_coord\t$new_coord\n");
					}
					if($right_diff > 5000){
						$new_coord = $cur_gene_TSS + 5000;
						push(@enhancer_list, "$enh_chrom\t$new_coord\t$enh_right_coord\n");
					}
				}
			last;
			}
			elsif((($enh_left_coord < $cur_gene_TSS) and ($enh_right_coord > $cur_gene_TSS))){
				$promoter = 1;
				if(abs($left_diff) > 5500){
					$new_coord = $cur_gene_TSS - 5000;
					push(@enhancer_list, "$enh_chrom\t$enh_left_coord\t$new_coord\n");
				}
				if(abs($right_diff) > 5500){
					$new_coord = $cur_gene_TSS + 5000;
					push(@enhancer_list, "$enh_chrom\t$new_coord\t$enh_right_coord\n");
				}
				last;
			}
			else{
				### Enhancer passes for this gene
			}
		}
	}

	if ($promoter eq 0){
		print OUT $enhancer;
	}
}	

				


exit;
