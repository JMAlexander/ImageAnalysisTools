#!usr/bin/perl

##List Reads Relative to Each Gene
##Designs for use with sorted refseq gene list


## $ARGV[0] and $ARGV[1] should be in the current directory.


use warnings;

print "#########\n\n";
print "Reading Refseq File.......";

open FILE, $ARGV[0] or die "Couldn't open:$!";
@refseq_genes = <FILE>;
close FILE;

#%genes_w_reads = ();

print "done.\n\n";

open FILE, $ARGV[1] or die "Couldn't open:$!";
@reads = <FILE>;
close FILE;


open WRITEFILE, ">matched_reads";


$gene_matched_reads = "";

$refseq_genes[0] =~ /\w{1,2}/;
$cur_chrom = $&;
foreach (@refseq_genes){
	$gene_matched_reads = "";

	$_ =~ /(\w{1,2})\t(\d{3,9})\t(\d{3,9})\t([+-]{1})\t(\w*)/;
	$gene_chr = $1;
	$gene_start = $2;
	$gene_end = $3;
	if (!($gene_chr eq $cur_chrom)){
		$cur_chrom = $gene_chr;
		do{
			$reads[0] =~ /chr(\w+)/;
			$array_chr = $1;
			if (!($1 eq $gene_chr)){
				shift (@reads);
			}
			print "$i++\n";
			
		}
		until (($array_chr eq $gene_chr) or (scalar @reads eq 0));

	}	 
	$gene_symbol = $5;
	$read_list = scalar @reads;
#	print "Current Chr: $cur_chrom\tCurrent gene:  $gene_symbol\t$read_list\n";
		foreach (@reads){
			$_ =~ /chr\w+\t(\d*)/;
		
			if ($1 > $gene_end + 10000){
				last;
			}
			elsif ($1 > ($gene_start - 10000)){
				$gene_matched_reads .= "$1 ";
			}
		}
		do{
			$reads[0] =~ /chr(\w+)\t(\d*)/;
			$array_chr = $1;
			$array_value = $2;
			if (($1 eq $cur_chrom) and ($2 < ($gene_start - 10000))){
				shift(@reads);
			}
		}
		while (($array_chr eq $cur_chrom) and ($array_value < ($gene_start - 10000)) and !(scalar @reads eq 0));

	$current_gene = $_;
	chomp ($current_gene);
	$gene_matched_reads =~ s/\s$//g;
	print WRITEFILE "$current_gene\t$gene_matched_reads\n";
	$gene_matched_reads = "";

}


##
close WRITEFILE;
 
exit;
