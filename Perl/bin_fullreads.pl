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

if (($half_window % 2) != 0){
	print "\n**Window size must be an even number**\n\n" and die;
}

#print "$bin_mid\n\n";

# Extend reads
foreach (@reads){
	($chr, $start, $end, $strand) = ($_ =~ /chr(\w+)\t(\d*)\t(\d*).*([+-]{1})/);
	#print "$&\n$1\t$2\t$3\t$4\n$chr\t$start\t$end\t$strand\n\n";
	if ($strand eq  "+"){
		$end = $start + $read_length;
	}
	elsif ($strand eq "-"){
		$start = $end -$read_length;
	}
	push (@mid_read, "chr$chr\t$start\t$end\n");
}

open WRITEFILE, ">$ARGV[0].midreads";
foreach (@mid_read){
	print WRITEFILE $_;
}
close WRITEFILE;

#print "Generate center of tags...done";


#Create bins
foreach (@chrom_size){
	$cur_location = 1;
	($chrom, $chrom_end) = ($_ =~ /chr(\w+)\t(\d*)/);
	while ($cur_location <= $chrom_end){
		$n = 0;
		$bin_count = 0;
		if (($cur_location + $bin_size) > $chrom_end){
			$reads_leftwindow = $cur_location + $bin_mid - $half_window + 1;
			$reads_rightwindow = $cur_location + $bin_mid + $half_window;
			foreach (@mid_read){
				$_ =~ /chr(\w+)\t(\d*)\t(\d*)/;
				if ($2 > $reads_rightwindow or $2 > $chrom_end or !($1 eq $chrom)){
					last;
				}
				if ($3 >= $reads_leftwindow){
					$bin_count++;
				}
				#print $bin_count, "\n";
			}
			$genomic_bins{"chr$chrom\t$cur_location\t$chrom_end"} = $bin_count;
			
		}
		else{
			$reads_leftwindow = $cur_location + $bin_mid - $half_window + 1;
                        $reads_rightwindow = $cur_location + $bin_mid + $half_window;
                        foreach (@mid_read){
				$_ =~ /chr(\w+)\t(\d*)\t(\d*)/;
                                if ($2 > $reads_rightwindow or $2 > $chrom_end or !($1 eq $chrom)){
                                        last;
                                }
                                if ($3 >= $reads_leftwindow){
                                        $bin_count++;
                                }
                                #print $bin_count, "\n";
                        }
			$bin_end = $cur_location + $bin_size;
			$genomic_bins{"chr$chrom\t$cur_location\t$bin_end"} = $bin_count;
		}
		print "Chr:  $chrom\tBin Left:  $cur_location\tWin Left:  $reads_leftwindow\tWin Right:  $reads_rightwindow\n";
		$cur_location += $bin_size;
		foreach (@mid_read){
			$_ =~ /chr(\w+)\t(\d*)\t(\d*)/;
			if (($1 eq $chrom) and ($3 < $reads_leftwindow)){
				shift(@mid_read);
			}
			else{
				last;
			}
		}
		print "Array size is now:  ", scalar @mid_read, "\n";
			
	} 
}
open WRITEFILE, ">$ARGV[5].genomicbins";
@keys = keys(%genomic_bins);
foreach (@keys){
	print WRITEFILE "$_\t$genomic_bins{$_}\n";
}
close WRITEFILE;

exit;	

