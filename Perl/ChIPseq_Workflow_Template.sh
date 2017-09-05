#!/bin/sh

# Whitehead_Workflow.sh
# 
#
# Created by Jeff Alexander on 1/24/13.
# Copyright 2013 __MyCompanyName__. All rights reserved.

#: <<'COMMENT'
cd #####;  ###!!!Change to directory with .sam file folders
FOLDERS=####; ## of `ls`
for i in ${FOLDERS[*]}; do echo $i; done;
for i in ${FOLDERS[*]}; do
	cd #####;  ###!!!Change to directory with .sam file folders
	echo $i;
	cd $i;
	mkdir ####!!! Change to directory where files will be copied/$i;
	FILES=`ls *.sam`;
	echo "Sam files in folder $i...";
	for j in ${FILES[*]}; do echo "$j"; done;
	for j in ${FILES[*]}; do
		echo "Copying file to local space....";
		cd ###!!!Change to directory with .sam file folders;
		cp $j ####!!! Change to directory where files will be copied/$i;
		cd ####!!! Change to directory where files will be copied/$i;
		echo "Working on $j..."
		##Convert to .bam
		echo "Converting to .bam format....";
		samtools view -S -b -o $j.bam $j;
		rm ####!!! Change to directory where files will be copied/${i}/$j;
	done;
	BAMS=(*.bam);  ###using ls makes this a variable and not an array
	echo "Bam files in folder $i are ${BAMS[*]}";
	echo "Merging .bam files...";
	samtools merge -h ${BAMS[0]} ${i}_combined.bam ${BAMS[*]};
	echo "Converting combined .bam file to .sam format...";
	samtools view -h -o ${i}_combined.sam ${i}_combined.bam;
#	rm *_bestmap.sam;
	rm *_bestmap.sam.bam;
done;
#COMMENT	

#: <<'COMMENT'

#####
cd ####!!!!Change to working directory; ####!!!!Change to working directory
for i in *; do
	cd ####!!!!Change to working directory; ####!!!!Change to working directory
	echo $i;
	cd $i;
	FILES=`ls *.sam`;
	echo "Sam files in folder $i...";
	for j in ${FILES[*]}; do echo "$j"; done
	
	###For each .sam file
	for j in ${FILES[*]}; do
	echo "Working on $j...";
	####Remove random chromosomes
	echo "Removing random chromosomes..."
	grep -v "random" $j >$j.NORAND;
	####Remove unmapped reads"
	echo "Removing unmapped reads";
	grep -P "chr" $j.NORAND >$j.NORAND.mapped;
	infile=$j.NORAND.mapped;
	outfile=$infile.wi;
	if [ -e $infile ]; then
		echo $infile;
		rm $j.NORAND;
		grep -P -v "^@" $infile | awk '{if($2==0){sign="+"}else{sign="-"} print $3,sign$4}' | perl -pi -e 's/chr//g' | sort -k 1,1 -k 2,2g >$outfile.temp;
		echo "#U0" > $outfile;
		echo $(awk '{print $1}' $outfile.temp | uniq);
		for chr in $(awk '{print $1}' $outfile.temp | uniq) ; do
			echo ">$chr";
			echo ">$chr" >>$outfile;
			grep -P "^$chr\s" $outfile.temp | awk '{print $2}' >>$outfile;
		done
		rm $outfile.temp;
		mv $outfile ####!!!!Change to working directory;  ###!!!!Change to Whitehead directory
	fi;
	done;
done;
	
#COMMENT
#: <<'COMMENT'	
	###Whitehead Algorithm
	echo "Running Whitehead algorithm...\n";
	cd ####!!!!Change to output file directory;  ####!!!!Change to output file directory
	param_files=###!!!!Change to parameter file directory/*;  ###!!!!Change to parameter file directory
	for i in $param_files; do
	echo $i;
	python ~/src/PipelineFiles/SOLEXA_ENRICHED_REGIONS.py $i;
	done;
#COMMENT

#: <<'COMMENT'	
###Make BigWig Files
	cd ####!!!!Change to output file directory;  ####!!!!Change to output file directory;
	for k in *; do
	cd ####!!!!Change to output file directory;  ####!!!!Change to output file directory;
	echo $k;
	cd ./$k;
	gunzip *.WIG.gz;
	perl /Users/Jeff/Scripts/parse_complex_wiggle.pl -i *.WIG -c /Users/Jeff/Desktop/ChIP_seq_Analysis_1_23_13/mm9.chromo.sizes;  ####Ensure these exist!!!!
	for l in *.wig; do
	wigToBigWig $l /Users/Jeff/Desktop/ChIP_seq_Analysis_1_23_13/mm9.chromo.sizes $l.bw;  ##Ensure .chromo.sizes exists!!!
	done;
	
done; 

#COMMENT
#: <<'COMMENT'
###Metagene Analysis
	database_folder="/Users/Jeff/Bioinformatics/Gene_Annotations/mm9/Databases/"; #####!!!!Change to reflect databases
	cd $database_folder;
	databases=`ls *`;  ###Don't use datbases=*.  That will make databases equal to whatever is in the current directory, and $databases will change when you cd!!
	
	cd ###!!!!Paste directory that has bigWig files; ###!!!!Paste directory that has bigWig files
	mkdir ./Metagene_score_mean;
	FILES="H3K27me3_THF_Combined.wig.bw";
	for i in ${FILES[*]}; do
	echo $i;
	#for j in $databases; do
	#echo $j;
	perl ~/src/biotoolbox/scripts/map_relative_data.pl --db $database_folder/mm9_refGene_upgene.sqlite --feature gene:refGene --out ./Metagene_score_mean/$i.$j --data $i --method sum --sum --value count --num 100;
	
	#done;
done;
	
	
#COMMENT