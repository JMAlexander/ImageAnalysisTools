#!usr/bin/perl

##Average Gene Tag Density

if (scalar @ARGV < 5){
	die "Reread script of proper call";
}

use warnings;
open IN, $ARGV[0] or die "Couldn't open:$!";
@gene_matched_reads = <IN>;
close IN;

$upstream_region = $ARGV[1];
$upstream_binnumber = $ARGV[2];
$genebody_binpercent = $ARGV[3];

$upstream_binsize = $upstream_region / $upstream_binnumber;

open OUT, ">$ARGV[4].average_gene_density";
foreach (@gene_matched_reads){
        $_ =~ /(\d*)\t(\d*)\t([+-])\t(\S*)\t(.*)/;
        $gene_strand = $3;
        if ($gene_strand eq "+"){
                ($TSS,$TES) = ($1,$2);
        }
        else{
                ($TSS, $TES) = ($2,$1);
        }
        $gene_name = $4;
        $gene_length = abs ($TSS - $TES) + 1;
        $genebody_binsize = int ($gene_length * $genebody_binpercent);
	if ($genebody_binsize == 0){
		next;
	}
        print OUT "$gene_name: $TSS\t$TES\t$gene_length\t$gene_strand\n";
	print "Current gene: $gene_name\n";
	@current_reads = split (/\s/,$5);

	
	if ($gene_strand eq "+"){
                $bincount = 0;
		$last_read = 0;
                $cur_location = $TSS - $upstream_region;
               # while ($cur_location < $TSS){
	#		$i++;
	#		print "$i\n";
                        foreach (@current_reads){
                                if ($_ eq @current_reads[(scalar @current_reads - 1)]){
					$last_read = 1;
				}
				$active_read = $_;
                                if ($active_read < $cur_location){
                                        next;
                                }
                                elsif (($active_read >= $cur_location) and ($active_read < ($cur_location + $upstream_binsize))){
                           	             $bincount++;
                                }
                                elsif ($active_read >= ($cur_location + $upstream_binsize)){
                                       do{
					$bin_location = sprintf ("%.2f", ($cur_location - $TSS));
					$bincount = $bincount / $upstream_binsize;
                                        print OUT "$bin_location\t$bincount\n";
					$cur_location += $upstream_binsize;
					$bincount = 0;
					#$k++;
					#print "$k\n";
					}until ($last_read or ($active_read < ($cur_location + $upstream_binsize)) or $cur_location >= $TSS);
                                $bincount = 1;
				}
                                
				if ($active_read > $TSS){
					last;
				}
			}
	#	}
#####
		$cur_location = $TSS;
		$bin_location = 0;
	#	while ($cur_location <= $TES){
		     #	$j++;
	#		print "$j\n";
			foreach (@current_reads){
                                $active_read = $_;
                                #if ($_ eq @current_reads[(scalar @current_reads - 1)]){
                                 #       $last_read = 1;
                                #}
				if ($active_read < $cur_location){
                                        next;
                                }
                                elsif (($active_read >= $cur_location) and ($active_read <= ($cur_location + $genebody_binsize))){
                                                $bincount++;
                                }
                                elsif ($active_read > ($cur_location + $genebody_binsize)){
                                	do{
						#$bin_location = sprintf ("%.3f", (($cur_location - $TSS)/ $gene_length));
					#	$bin_location = ($cur_location - $TSS) / $gene_length;
						$bincount = $bincount / ($genebody_binpercent * $gene_length);
                                                print OUT "$bin_location\t$bincount\n";
						$cur_location += $genebody_binsize;
						$bin_location += $genebody_binpercent;
					#	print "$cur_location\t$genebody_binsize\n";
						$bincount = 0;
		#				$l++;
		#				print "$l\n";
					}until (($active_read < ($cur_location + $genebody_binsize)) or $cur_location > $TES);
                                $bincount = 1;
				}
				if ($active_read > $TES){
					$cur_location = $TES + 1;
					last;
				}
                        }
	}
	#	}
		elsif ($gene_strand eq "-"){
			#print @current_reads;
			#print "\n\n";
			@current_reads = sort {$b cmp $a} @current_reads;
			#print @current_reads;
			#print "\n\n";
                	$bincount = 0;
			$last_read = 0;
                	$cur_location = $TSS + $upstream_region;
               # while ($cur_location < $TSS){
	#		$i++;
	#		print "$i\n";
                        foreach (@current_reads){
                                if ($_ eq @current_reads[(scalar @current_reads - 1)]){
					$last_read = 1;
				}
				$active_read = $_;
                                if ($active_read > $cur_location){
                                        next;
                                }
                                elsif (($active_read <= $cur_location) and ($active_read > ($cur_location - $upstream_binsize))){
                           	             $bincount++;
                                }
                                elsif ($active_read <= ($cur_location - $upstream_binsize)){
                                       do{
					$bin_location = sprintf ("%.2f", ($TSS - $cur_location));
					$bincount = $bincount / $upstream_binsize;
                                        print OUT "$bin_location\t$bincount\n";
					$cur_location -= $upstream_binsize;
					$bincount = 0;
					#$k++;
					#print "$k\n";
					}until ($last_read or ($active_read > ($cur_location - $upstream_binsize)) or $cur_location <= $TSS);
                                $bincount = 1;
				}
                                
				if ($active_read < $TSS){
					last;
				}
			}
	#	}
#####
		$cur_location = $TSS;
		$bin_location = 0;
	#	while ($cur_location <= $TES){
		     #	$j++;
	#		print "$j\n";
			foreach (@current_reads){
                                $active_read = $_;
                                #if ($_ eq @current_reads[(scalar @current_reads - 1)]){
                                 #       $last_read = 1;
                                #}
				if ($active_read > $cur_location){
                                        next;
                                }
                                elsif (($active_read <= $cur_location) and ($active_read >= ($cur_location - $genebody_binsize))){
                                                $bincount++;
                                }
                                elsif ($active_read < ($cur_location - $genebody_binsize)){
                                	do{
						#$bin_location = sprintf ("%.3f", (($cur_location - $TSS)/ $gene_length));
					#	$bin_location = ($cur_location - $TSS) / $gene_length;
						$bincount = $bincount / ($genebody_binpercent * $gene_length);
                                                print OUT "$bin_location\t$bincount\n";
						$cur_location -= $genebody_binsize;
						$bin_location += $genebody_binpercent;
					#	print "$cur_location\t$genebody_binsize\n";
						$bincount = 0;
		#				$l++;
		#				print "$l\n";
					}until (($active_read > ($cur_location + $genebody_binsize)) or $cur_location < $TES);
                                $bincount = 1;
				}
				if ($active_read < $TES){
					$cur_location = $TES + 1;
					last;
				}
                        }
	#	}

        }
}

close OUT;
exit;
