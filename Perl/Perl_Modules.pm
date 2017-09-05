#!usr/bin/perl

#_Set of Perl modules for use_
# -- open_file --opens a file on name string input
# -- fasta_dna -- converts fasta formated file on name string input to string
# output

sub open_file {
	use strict;
	use warnings;

#Variables --
	my @file = '';
	my ($file_name) = @_;

#Body --
	unless (open (FILENAME , $file_name)){
	print STDERR "Cannot open file \"$filename\"\n\n";
	exit;
	}
	@file = <FILENAME>;
	
	close FILENAME;

	return @file;

sub fasta_DNA {
	use strict;
	use warnings;

#Variables --
	my (@fasta_dna) = @_;
	my $sequence = '';

#Body --
	foreach my $line (@fasta_dna){
		if ($line =~ /^\s*$/){
			next;
		}
		elsif($line =~ /^\s*#/){
			next;
		}
		elsif ($line =~ /^\s*>/){
			next;
		}
		else {
			$sequence .= $line;
		}
	}
	$sequence =~ s/\s//g;

	return $sequence;

sub extract_DNA {
	use strict;
	use warnings;

#Variables --
	my (@input_dna) = @_;
	my $sequence = '';

#Body --
	foreach my $line (@input_dna){
		if ($line =~ /^\s.*$/){
			next;
		}
		elsif($line =~ /\d*/){
			next;
		}
		elsif ($line =~ /bdefhijklmnopqrsuvwxyz/){
			next;
		}
		else {
			$sequence .= $line;
		}
	}
	$sequence =~ s/\s//g;

	return $sequence;

1;
#End--
