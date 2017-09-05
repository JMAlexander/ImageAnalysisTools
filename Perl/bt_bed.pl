#!usr/bin/perl

#Bowtie_to_BED format conversion
#7-20-10 Originally from Alisha Holloway



foreach $file (@ARGV){
	`cut -f 2-4 $file | awk '{print $2"\t"$3"\t"$3+36"\tU0\t0\t"$1}' > ~/Desktop/$file.bed`;

}
end;
	
