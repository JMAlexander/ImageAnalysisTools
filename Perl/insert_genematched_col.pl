#!usr/bin/perl


###Add Column Value Associated with Gene in Query Table into New Column Associated with Gene in Destination Table

use Getopt::Long;

GetOptions(
	"input_file=s"=>\$input_file,
	"input_genecol=s"=>\$input_genecol,
	"input_querycol=s"=>\$input_querycol,
	"output_file=s"=>\$output_file,
	"output_genecol=s"=>\$output_genecol,
	"output_querycol=s"=>\$output_querycol);

##Initialize variables
$inputgene_filler_number = $input_genecol - 1;
$inputquery_filler_number = $input_querycol - 1;
$out_filler_number = $output_genecol - 1;
$out_insert_number = $output_querycol - 1;
###Variable to track is a gene is found in input list
$found = 0;
$current_gene = "blank";

##Open Input File
open FILE_1, $input_file;
@input_file_array = <FILE_1>;
close FILE_1;

##Open Output File
open FILE_2, $output_file;
while (<FILE_2>){
	$input_current_gene;
	$input_current_query;
	$current_line = $_;
	$found = 0;
	$current_line =~ /^(\S*\t){$out_filler_number}(\S*)/;
	$current_gene = $2;
	###Search input file for current gene
	foreach $input_current_line (@input_file_array){
		$input_current_line  =~ /^(\S*\t){$inputgene_filler_number}(\S*)/;
		$input_current_gene = $2;
		$input_current_line  =~ /^(\S*\t){$inputquery_filler_number}(\S*)/;
		$input_current_query = $2;
		if ($input_current_gene eq $current_gene){
			$found = 1;
			last;
		}
	}
	if ($found == 1){
		($before_insert, $filler, $after_insert) = ($current_line =~ /^((\S*\t){$out_insert_number})(.*$)/);
		print "$before_insert$input_current_query\t$after_insert\n";
	}
	else{
		($before_insert, $filler, $after_insert) = ($current_line =~ /^((\S*\t){$out_insert_number})(.*$)/);
		print "$before_insert", "NA", "\t$after_insert\n";	
	}
}
close FILE_2;

exit;
