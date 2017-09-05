#!usr/bin/perl

##List Reads Relative to Each Gene
##Designed for use with sorted refseq gene list



print "#########\n\n";
print "Reading Refseq File.......";

open FILE, $ARGV[0];
@refseq_file = <FILE>;
close FILE;

%genes_w_reads = ();
@read_files;
$open_file;

print "done.\n\n";

print "Reading directory files.....";
opendir DIR, $ARGV[1] or die "Couldn't open:$!";
@files = readdir DIR;
close DIR;

print "done.\n\nFinding sorted read files.....";

foreach (@files){
	if ($_ =~ /chr.*.reads$/){
		push (@read_files, $_);
	}
}
print "done.\n\n";

$refseq_file[0] =~ /^(\w{1,2})\t/;
$cur_chr = $1;


foreach (@read_files){
	$_ =~ /chr$cur_chr\..*/;
	
	if ($& eq $_){
		$open_file = $&;
		last;
	} 

}

open FILE, $open_file or (die and print "Error: $!");
@active_reads = <FILE>;
close FILE;


foreach (@refseq_file){
	$gene_reads = "";

	$_ =~ /(\w{1,2})\t(\d{3,9})\t(\d{3,9})\t([+-]{1})\t(\w*)/;
	$gene_chr = $1;
	if (!($gene_chr eq $cur_chr)){
		$cur_chr = $gene_chr;
		foreach (@read_files){
			$_  =~ /chr$cur_chr.*/;
			if ($&  eq $_){
				$open_file = $&;
				last;
			}	
		} 
		open FILE, $open_file;
		@active_reads = <FILE>;
		close FILE;
	}	 
	$gene_symbol = $5;
	$gene_strand = $4;
	print "Current Chr: $cur_chr\tCurrent gene:  $gene_symbol\n";
	if ($gene_strand eq "+"){
		$gene_start = $2;
		$gene_end = $3;
		$pos_strand = 1;
	}
	elsif ($gene_strand eq "-"){
		$gene_start = $3;
		$gene_end = $2;
		$pos_strand = 0;
	}
	else{
		print "Invalid strand error" and die;
	}
	$gene_length = abs ($gene_start - $gene_end) + 1;
		if ($pos_strand){
		foreach (@active_reads){
			if ($_ > $gene_start + 500){
				last;
			}
			elsif ($_ > ($gene_start - 500) and  ($_ < $gene_start)){
				$rel_pos = $_ - $gene_start;
				$rel_pos = sprintf ("%.4f", $rel_pos);
				$gene_reads .= "$rel_pos ";
			}
			elsif ($_ >=  $gene_start){
				$rel_pos = $_ - $gene_start;
				$rel_pos = sprintf ("%.4f", $rel_pos);
				$gene_reads .= "$rel_pos ";
			}
		}
	}
	else {
		foreach (@active_reads){
			if ($_ > ($gene_start + 500)){
				last;
			}
			elsif (($_ > ($gene_start - 500)) and ($_ <= $gene_start)){
				$rel_pos = $gene_start - $_;
				$rel_pos = sprintf ("%.4f", $rel_pos);
				$gene_reads .= "$rel_pos ";
			}
			elsif ($_ > $gene_start){
				$rel_pos = $gene_start - $_;
				$rel_pos = sprintf ("%.4f", $rel_pos);
				$gene_reads .= "$rel_pos ";
			}
		}
	}
	$genes_w_reads{$gene_symbol} = $gene_reads;

}


@keys = keys(%genes_w_reads);
@sort_keys = sort {$a cmp $b} @keys;

print "Writing file.....";

open WRITEFILE, ">$ARGV[2]";
foreach (@sort_keys){
	print WRITEFILE "$_: $genes_w_reads{$_}\n";
}
close WRITEFILE;
 
exit;
