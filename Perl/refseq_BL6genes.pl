#!usr/bin/perl

##Calculate Average Reads For Gene

open FILE, $ARGV[0];
@gene_list = <FILE>;
close FILE;

print "\n*Files read*\n\n";

foreach (@gene_list){
	if ($_ !~ /LOC/){
		if ($_ =~ /.*\t(\w{1,3})\t(\d{3,9})\t(\d{3,9})\t([+-]{1})\t.*\t[+-]{1}\t(\w*).*GENE\tC57BL\/6J/){
		push  (@parsed_list, $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\n");
		}
	}
}
open WRITE, ">refseq_BL6genes.dat";
print WRITE @parsed_list;
close WRITE;

exit;
