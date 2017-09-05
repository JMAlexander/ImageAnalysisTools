#!usr/bin/perl


#Sorts bed files based on chromosome first, then location value
open READFILE, $ARGV[0];
@file = <READFILE>;
close READFILE;


foreach (@file){
	($chr, $start) = ($_ =~ /chr(\w+)\t(\d*)\t/);
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


#------Sort------

@sort_chrnum = sort {$chr_num_cache1{$a} <=> $chr_num_cache1{$b} || $chr_num_cache2{$a} <=> $chr_num_cache2{$b}} @chr_num;
@sort_chrXYM  = sort {$chr_XYM_cache1{$a} cmp $chr_XYM_cache1{$b} || $chr_XYM_cache2{$a} <=> $chr_XYM_cache2{$b}} @chr_XYM;


@sorted_file = (@sort_chrnum, @sort_chrXYM);
print "\n",@sorted_file;

open WRITEFILE, ">$ARGV[0].sorted";
print WRITEFILE @sorted_file;
close WRITEFILE;

exit;

