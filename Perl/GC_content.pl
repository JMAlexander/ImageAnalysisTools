#!usr/bin/perl

##GC Content for Stretch of DNA
open IN, $ARGV[0];

while (<IN>){
	$DNA .= $_;
}
close IN;

$start = 0;
$DNA_region = 20;
#$DNA = "ATGCCGCAATGGCACTGGAGCCCATGGGTAATTTACTGACGATTAGACCAGATA";
print "$DNA\n";
%GC_content = 0;
#print length($DNA);

until ($start > (length($DNA) - 1)){
	$DNA_part = substr($DNA, $start, $DNA_region);
#	print "$DNA_part\n";
	$GC_content{$start} = (map(/[G|C|g|c]/, split(//,$DNA_part))) / (length($DNA_part)) * 100;
	print "[$start]:$GC_content{$start}\n";
	$start += $DNA_region / 2;
}
#@keys = keys %GC_content;
#foreach (@keys){
#	print "[$_]:$GC_content{$_}\n";
#}
#foreach (@DNA_array){
#	if ($_ eq 'G' or $_ eq 'C'){
#		$GCs++;
#	}
#}

#print scalar(@DNA_array);
#$GC_percent = $GCs / scalar(@DNA_array);
#$start = 0;
#$end = $DNA_region;


exit;

