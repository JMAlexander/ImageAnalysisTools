#!usr/bin/perl

#Goals
#1) Extend reads by half average fragment size (user defined)
#2) Group read centers into x bp bins using a x bp sliding using given file with chromosome lengths
#3) Output readcounts per bin and read density per bin for upload to UCSC

open READFILE, $ARGV[0];
@reads = <READFILE>;
close READFILE;

open READFILE, $ARGV[1];
@chrom_size = <READFILE>;
close READFILE;

$read_length = $ARGV[2];
$bin_size = $ARGV[3];
$bin_mid = int($bin_size/2);
$window_size = $ARGV[4];
$half_window = int($window_size/2);
$num_reads = scalar @reads;
$read_per_million_factor = $num_reads / 1000000;
$total_reads_in_bins = 0;

if ((-e "$ARGV[5].midreads") or (-e "$ARGV[5].midreads_bin$ARGV[3]_win$ARGV[4]_counts") or (-e "$ARGV[5].midreads_bin$ARGV[3]_win$ARGV[4]_density")){
	print "File name already exists!!!\n\n" and die;
}
if (($half_window % 2) != 0){
	print "\n**Window size must be an even number**\n\n" and die;
}


print "Generating center of tags...\n";

# Extend reads
foreach (@reads){
	($chr, $start, $end, $strand) = ($_ =~ /chr(\w+)\t(\d*)\t(\d*).*([+-]{1})/);
	#print "$&\n$1\t$2\t$3\t$4\n$chr\t$start\t$end\t$strand\n\n";
	if ($strand eq  "+"){
		$readloc = $start + int($read_length / 2);
	}
	elsif ($strand eq "-"){
		$readloc = $end - int($read_length / 2);
	}
	push (@mid_read, "chr$chr\t$readloc\n");
}

print "Generating center of tags done\n\n";

#Sort mid_reads

print "Sorting tags based on middle of each read...\n";

foreach (@mid_read){
	($chr, $start) = ($_ =~ /chr(\w+)\t(\d*)/);
	if ($1 =~ /\d+/){
		$chr_num_cache1{$_} = $chr;
		$chr_num_cache2{$_} = $start;
		push (@chr_num, $_);
	}
	elsif ($1 =~/[X,Y,M]/){
		$chr_XYM_cache1{$_} = $chr;
		$chr_XYM_cache2{$_} = $start;
		push (@chr_XYM, $_);
	}
	else{
		print "Error!!";
	}
}

@sort_chrnum = sort {$chr_num_cache1{$a} <=> $chr_num_cache1{$b} || $chr_num_cache2{$a} <=> $chr_num_cache2{$b}} @chr_num;
@sort_chrXYM  = sort {$chr_XYM_cache1{$a} cmp $chr_XYM_cache1{$b} || $chr_XYM_cache2{$a} <=> $chr_XYM_cache2{$b}} @chr_XYM;


@sorted_midreads = (@sort_chrnum, @sort_chrXYM);

print "Sorting finished.\n\n";


#Create bins
foreach (@chrom_size){
	%genomic_bins_counts = ();
	%genomic_bins_density = ();
	$cur_location = 1;
	($chrom, $chrom_end) = ($_ =~ /chr(\w+)\t(\d*)/);
	while ($cur_location <= $chrom_end){
		$total_reads_in_bins += $bin_count;
		print "Current chromosome:  $chrom\tReads in bins:  $total_reads_in_bins\n";
		$bin_count = 0;
		if (($cur_location + $bin_size - 1) > $chrom_end){
			$reads_leftwindow = $cur_location + $bin_mid - $half_window + 1;
			$reads_rightwindow = $cur_location + $bin_mid + $half_window;
			foreach (@sorted_midreads){
				$_ =~ /chr(\w+)\t(\d*)/;
				if ($2 > $reads_rightwindow or $2 > $chrom_end or !($1 eq $chrom)){
					last;
				}
				if ($2 >= $reads_leftwindow){
					$bin_count++;
				}
			}
			$genomic_bins_counts{"chr$chrom\t$cur_location\t$chrom_end"} = $bin_count;
			$genomic_bins_density{"chr$chrom\t$cur_location\t$chrom_end"} = $bin_count/$read_per_million_factor;
			
		}
		else{
			$reads_leftwindow = $cur_location + $bin_mid - $half_window + 1;
                        $reads_rightwindow = $cur_location + $bin_mid + $half_window;
                        foreach (@sorted_midreads){
                                $_ =~ /chr(\w+)\t(\d*)/;
                                if ($2 > $reads_rightwindow or $2 > $chrom_end or !($1 eq $chrom)){
                                        last;
                                }
				if ($2 >= $reads_leftwindow){
                                	$bin_count++;
				}
                        }
			$bin_end = $cur_location + $bin_size -1;
			$genomic_bins_counts{"chr$chrom\t$cur_location\t$bin_end"} = $bin_count;
			$genomic_bins_density{"chr$chrom\t$cur_location\t$bin_end"} = $bin_count/$read_per_million_factor;
		}
		$cur_location += $bin_size;
		foreach (@sorted_midreads){
			$_ =~ /chr(\w+)\t(\d*)/;
			if (($1 eq $chrom) and ($2 < $reads_leftwindow)){
				shift(@sorted_midreads);
			}
			else{
				last;
			}
		}
		#print "Array size is now:  ", scalar @sorted_midreads, "\n";
		
			
	} 
		print "Writing counts to file...\n";
		open WRITEFILE, ">>$ARGV[5].midreads_bin$ARGV[3]_win$ARGV[4]_counts";
		@keys = keys(%genomic_bins_counts);
		foreach (@keys){
			print WRITEFILE "$_\t$genomic_bins_counts{$_}\n";
		}
		close WRITEFILE;

		print "Writing density to file...\n";open WRITEFILE, ">>$ARGV[5].midreads_bin$ARGV[3]_win$ARGV[4]_density";
		@keys = keys(%genomic_bins_density);
		foreach (@keys){
			print WRITEFILE "$_\t$genomic_bins_density{$_}\n";
		}
		close WRITEFILE;
}

print "Total reads processed:  $num_reads\n\n";
print "Total reads placed in genomic bins:  $total_reads_in_bins\n\n";

open WRITEFILE, ">$ARGV[5].midreads";
print WRITEFILE @sort_midreads;
close WRITEFILE;


exit;	

