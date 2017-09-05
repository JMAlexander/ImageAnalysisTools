#!usr/bin/perl


open IN, $ARGV[0];
%values = ();

open OUT, ">average.gene.temp";
while (<IN>){
	if ($_ !~ /.+[+-]/){
		$_ =~ /(\S*)\t(\S*)/;
		if  ($values{$1}){
			$first = $values{$1};
			$first += $2;
			$values{$1} = ($first + $2);
		}
		else{
			$values{$1} = $2;
		}

		@keys = keys %values;
	}
                @keys = keys %values;
}
                foreach (@keys){
                        print OUT "$_\t$values{$_}\n";
		}

close IN;
close OUT;
exit;
