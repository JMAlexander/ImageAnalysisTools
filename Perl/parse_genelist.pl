#!usr/bin/perl



###Parse out MGI gene expression data from gene_list specified (Brg1_up or Brg1_down)

open IN, $ARGV[0];
@gene_list = <IN>;
close IN;

open IN2, "/Users/Jeff/Desktop/MGI_expression.txt";
@MGI_expression = <IN2>;
close IN2;

open OUT, ">$ARGV[0].MGI.txt";

#print @gene_list;
#print @MGI_expression;
foreach (@gene_list){
	$_ =~ /(\S*)\tENSMUSG/;
	$current_gene = $1;
	print "$current_gene\n";
	foreach $current_line (@MGI_expression){
		$current_line =~ /(\S*)\tMGI/;
		if ($1 eq $current_gene){
			print OUT $current_line;
		}
	}
}
close OUT;

exit;
 
