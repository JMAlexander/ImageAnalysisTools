#!usr/bin/perl

#use warnings;

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

if ((-e "$ARGV[5].midreads") or (-e "$ARGV[5].midreads_bin$ARGV[3]_win$ARGV[4]_counts") or (-e "$ARGV[5].midreads_bin$ARGV[3]_win$ARGV[4]_density")){
        print "File name already exists!!!\n\n" and die;
}
$bin_count = 0;
$read_length = $ARGV[2];
$bin_size = $ARGV[3];
$bin_mid = int($bin_size/2);
$window_size = $ARGV[4];
$half_window = int($window_size/2);
$num_reads = scalar @reads;
$read_per_million_factor = $num_reads / 1000000;
$total_reads_in_bins = 0;

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
open WRITEFILE, ">$ARGV[5].midreads";
foreach (@sorted_midreads){
	print WRITEFILE $_;
}
close WRITEFILE;

print "Sorting finished.\n\n";

open WRITEFILE, ">>$ARGV[5].midreads_bin$ARGV[3]_win$ARGV[4]_density";
#Create bins
foreach (@chrom_size){
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
			$bin_density = $bin_count/$read_per_million_factor;
			print WRITEFILE "chr$chrom\t$cur_location\t$chrom_end\t$bin_density\n";
			
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
			$bin_density = $bin_count/$read_per_million_factor;
			print WRITEFILE "chr$chrom\t$cur_location\t$bin_end\t$bin_density\n";
		}
		$cur_location += $bin_size;
		do{
			$sorted_midreads[0] =~ /chr(\w+)\t(\d*)/;
			$array_chr = $1;
			$array_value = $2;
			if (($1 eq $chrom) and ($2 < $reads_leftwindow)){
				shift(@sorted_midreads);
			}
		}
		while (($array_chr eq $chrom) and ($array_value < $reads_leftwindow) and !(scalar @sorted_midreads eq 0));
	
	}	
	do{
		$sorted_midreads[0] =~ /chr(\w+)\t(\d*)/;
		$array_chr = $1;
		if ($array_chr eq $chrom){
			shift(@sorted_midreads);
		}
	}
	while (($array_chr eq $chrom) and !(scalar @sorted_midreads eq 0));
		
}


close WRITEFILE;
print "Total reads processed:  $num_reads\n\n";
print "Total reads placed in genomic bins:  $total_reads_in_bins\n\n";

exit;	

