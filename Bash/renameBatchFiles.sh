#!/bin/bsh

#  renameBatchFiles.bsh
#
#
#  Created by Jeffrey Alexander on 7/2/17.
#

die() {
    echo "$*" 1>&2
    exit 1
}

usage()  { echo "Usage: $0\n -d <path to image folder>\n -b <Batch number>\n"; die;}

###Assign values from Flags
FILE_FOLDER=                    ### This is the folder that are the stacks for processing are.  It is assigned by the -d option. (e.g. Stack2Sequence.sh -d /path/to/images
BATCH=                      ### This is the desired Batch label (e.g. Batch06)


while getopts "d:b:" o; do
case "${o}" in
        d)
FILE_FOLDER=${OPTARG}
            ;;
        b)
BATCH=${OPTARG}  ### tif or nd2 for example
            ;;
	*)
usage
	    ;;
    esac
done


if [ $OPTIND -eq 1 ]; then
	usage;
	die;
fi

####################
    
cd $FILE_FOLDER;
ID_REGEX=".*_([0-9]+)";
POS_REGEX=".*_(XY[0-9]+)";

SUBFOLDERS=(*);                # List all files in directory
for i in ${SUBFOLDERS[*]}; do  # Loop through each file
    echo $i
    [[ $i =~ $ID_REGEX ]]
    GROUPID="${BASH_REMATCH[1]}"
    echo $GROUPID
    cd $i
    IMAGEFOLDERS=(*);
    for j in ${IMAGEFOLDERS[*]}; do
        echo $j
        [[ $j =~ $POS_REGEX ]]
        POS_ID=${BASH_REMATCH[1]}
        echo $POS_ID
        cd $j
        mv ./MMStack_Pos0.ome.tif ${FILE_FOLDER}/${BATCH}_${GROUPID}_${POS_ID}.tif
        cd ..
    done
    cd $FILE_FOLDER
done


exit
