#!usr/bin/perl

use warnings;
use strict;

my @Ill_read_txt = openfile($ARGV[0]);
my $wiggle = "track type=wiggle_0\n";
my $prevchrom = '';
my $prevlocat = '';
my $chromosome = 'blank';
my $tempstring = '';
my $read_count = 1;
my $loop_count = 0;
my $location = '';


foreach my $line (@Ill_read_txt){
	if ($line =~ /chr\S{2}/){
		$chromosome = $&;
	if ((not ($prevchrom eq $chromosome)) and $loop_count == 0){
	$wiggle .= "variableStep\tchrom=$chromosome\tspan=35\n";
	$prevchrom = $chromosome;	
	}
	$line =~ (/\d{6,}/);
	$location = $&;
	if (not ($location eq $prevlocat) and $loop_count == 0){
		$tempstring = $location;
		$prevlocat = $location;		
	}
	elsif ($location eq $prevlocat){
		$read_count++;
		$tempstring = $location;
		}
	elsif (not ($location eq $prevlocat)){
	 	$tempstring .= "\t$read_count\n";
		$wiggle .= $tempstring;
		$read_count = 1;
		$prevlocat = $location;
		$tempstring = $location;
		}
	if (not ($prevchrom eq $chromosome)){
	$wiggle .= "variableStep\tchrom=$chromosome\tspan=35\n";
	$prevchrom = $chromosome;	
	}

	$loop_count++;
	}
				
}
	$tempstring .= "\t$read_count\n";
	$wiggle .= $tempstring;

	print $wiggle;
	writefile ($wiggle, $ARGV[1]);

exit;
#----------

sub openfile 
{

use warnings;
use strict;
#Variables --
	my @file;
	my ($filename) = @_;
	
#Body --
	unless (open (FILENAME , $filename)){
	print "Cannot open file \"$filename\"\n\n";
	exit;
	}
	@file = <FILENAME>;
	
	close FILENAME;

	return @file;
		
}

sub writefile {

use warnings;
use strict;
#Variables --
	my ($string, $filename) = @_;
#Body --
	unless (open( FILENAME, ">$filename")){

	print "Cannot open file \"$filename\" to write to!!\n\n";
	exit;
	}
	print FILENAME $string;
	close(FILENAME);

	return;
} 
		
