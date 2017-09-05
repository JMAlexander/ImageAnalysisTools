#!/usr/bin/perl

# expects bed files to be sorted by position

use strict;
use warnings;
use Getopt::Long;
use List::Util qw(max min sum);
# $foo = sum 0, @values;

############################# MAIN ###########################

my (@opt_bed, $opt_len, @opt_info, $opt_short);
$opt_short = 1;
GetOptions('bed:s' => \@opt_bed,
			'len:s' => \$opt_len,
			'short:f' => \$opt_short, # Default is 1, report only the overlap interval, Other option is 0, report the maximum interval
			'info:s' => \@opt_info);

unless (scalar @opt_bed == 2){
	usage();
}
$opt_len = 1 unless ( defined $opt_len && $opt_len >= 1 );
$opt_info[0] = "n" unless (defined $opt_info[0] && $opt_info[0] eq "y");
$opt_info[1] = "n" unless (defined $opt_info[1] && $opt_info[1] eq "y");

my (@chr1, @start1, @end1, @info1);
my (@chr2, @start2, @end2, @info2);

my $count = 0;
foreach my $bed (@opt_bed){
	open(BEDFILE,$bed) || die "Unable to open $bed: $!\n";
	while(my $data = <BEDFILE>){
	         if( $data =~ "START" ) { next; } # Skip over the header line
		($data =~ /^(\S+)\s+(\S+)\s+(\S+)\s*(.*)/);	# chr	start	end
		if($count){
			if($3-$2 > $opt_len){
				push(@chr2, $1);
				push(@start2, $2);
				push(@end2, $3);
				push(@info2, $4);
			}
		}
		else{
			if($3-$2 > $opt_len){
				push(@chr1, $1);
				push(@start1, $2);
				push(@end1, $3);
				push(@info1, $4);
			}
		}
	}
	$count++;
	close BEDFILE;
}

my ( %CH1TAKEN, %CH2TAKEN );
for(my $i=0; $i < scalar @chr1; $i++){
	for(my $j=0; $j < scalar @chr2; $j++){
		if($chr1[$i] eq $chr2[$j] || "chr".$chr1[$i] eq $chr2[$j] || $chr1[$i] eq "chr".$chr2[$j] ){
			my $minS = min($start1[$i], $start2[$j]);
			my $maxE = max($end1[$i], $end2[$j]);
			my $len1 = $end1[$i] - $start1[$i] + 1;
			my $len2 = $end2[$j] - $start2[$j] + 1;
			if($maxE-$minS <= $len1+$len2){	# overlap
				my $minS = min($start1[$i], $start2[$j]);
				my $maxS = max($start1[$i], $start2[$j]);
				my $minE = min($end1[$i], $end2[$j]);
				my $maxE = max($end1[$i], $end2[$j]);
				if( $minE-$maxS > $opt_len ){
				  $CH1TAKEN{$i} = 1;
				  $CH2TAKEN{$j} = 1;
				  if( $opt_short == 1 ){
				    print $chr1[$i], "\t", $maxS, "\t", $minE;
				  } elsif( $opt_short == 0 ){
				    print $chr1[$i], "\t", $minS, "\t", $maxE;
				  }
				  if($opt_info[0] eq "y"){ print "\t", $info1[$i]; }
				  if($opt_info[1] eq "y"){ print "\t", $info2[$j]; }
				  ### Added 8/8, I hope this doesn't screw anything up!
				  print "\t", $minE-$maxS, "\t", ($minE-$maxS)/$len1;
				  ###
				  print "\n";
				}
			}
			if($start2[$j] > $end1[$i]){ last; }
		}
	}
}

print keys(%CH1TAKEN) . " " . keys(%CH2TAKEN) . "\n";

exit;

###############################################################
# Sub: Usage
############################################################### 

sub usage {
	my $u = <<END;

intersect2beds.pl	
				-bed bedFile1
				-bed bedFile2
				-len [default 1] length of elements to keep
				-info [default n] y|n
				-info [default n] y|n
				
				REQUIRES SORTED BED FILES
				
END

 print $u;

 exit(1);
 
}



############################## EOF ########################################
