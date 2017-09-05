#!usr/bin/perl

##Chromosome Parse File

##Call: perl chrom_parse_file.pl file output_file_trailer
##file:  Should be file sorted with chromosome and additional fields.  File should be sorted by chromosome.  Designed for refseq lists but should work with any file that needs to be parsed by chromosome.
##File should have format…
##….chrxxx…..	
##output_file_trailer:  Should be what you want file name to be after chromosome number
##Function:Outputs multiple files containing all lines with the same chromosome, given that the list has been previously sorted by chromosome.
open FILENAME ,$ARGV[0];
@bedfile = <FILENAME>;
close FILENAME;

$tempchr = ' ';
$chr = ' ';
open WRITEFILE, " ";
foreach (@bedfile){
	$_ =~ /chr(\w+)/;
	$tempchr = $1;
		if (!($chr eq $tempchr)){
			close WRITEFILE;
			$chr = $tempchr;
			print "Current chromosome: $chr\n";
			open WRITEFILE, ">>chr$chr.$ARGV[1]";
	 	}
	print WRITEFILE $_;
}

exit;

