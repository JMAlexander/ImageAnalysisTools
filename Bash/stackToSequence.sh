#!/bin/bsh

#  cropForTrackmate.bsh
#
#
#  Created by Jeffrey Alexander on 8/23/15.
#


#Crop for Trackmate Bash Script
#Takes a list of ROIs for a given batch and outputs cropped images corresponding to each ROI for the appropriate image stack.  This cropped stacks can be used as input for Trackmate tracking.


die() {
    echo "$*" 1>&2
    exit 1
}

usage()  { echo "Usage: $0\n -d <path to image folder>\n -e <extension of files -- .tif or .nd2>\n -s <folder name on Saki server>\n -b <open files using BioFormats>"; die; }

###Assign values from Flags
FILE_FOLDER=                    ### This is the folder that are the stacks for processing are.  It is assigned by the -d option. (e.g. Stack2Sequence.sh -d /path/to/images
FILE_TYPE=                      ### This is the extension for the stacks.  All stacks should be a common extension.  It is assigned by the -e option. (e.g Stack2Sequence.sh -e .nd2)
SAKI_HOME_DIR=                  ### This is your home folder on the saki server.  It is assigned by the -s option. (e.g. Stack2Sequence -s Jeff)
BIOFORMATS=			### This options tells script which ImageJ macro to call, one that uses BioFormats to open or not.
FIXED_NOISE_DIR=

while getopts "d:e:s:b" o; do
case "${o}" in
        d)
FILE_FOLDER=${OPTARG}
            ;;
        e)
FILE_TYPE=${OPTARG}  ### tif or nd2 for example
            ;;
        s)
SAKI_HOME_DIR=${OPTARG}
            ;;
	b)
BIOFORMATS=TRUE
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
REGEX="(.*_[0-9]+_XY[0-9]+)\\${FILE_TYPE}";
if [ ! -d "Denoise" ]; then     # Make Denoise folder if it doesn't already exist
mkdir ./Denoise;
fi

if [ ! -d "tmp" ]; then         # Make temporary folder if it doesn't already exist.
mkdir ./tmp;
fi

TOTAL_FILES=(*);                # List all files in directory

for i in ${TOTAL_FILES[*]}; do  # Loop through each file
cd $FILE_FOLDER;
NEW_DIRECTORY="";
if ([[ $i == *${FILE_TYPE} ]]); then        #Does it match the extension provided above
    [[ $i =~ $REGEX ]]
    NEW_DIRECTORY="${BASH_REMATCH[1]}";     #Compare the file name without the extension.  This will used to make a folder to store all the individual images from the stack.
    mkdir ./Denoise/${NEW_DIRECTORY};
    cd ./tmp;
if [[ $BIOFORMATS == "TRUE" ]]; then
    /Applications/Fiji.app/Contents/MacOS/ImageJ-macosx -batch Stack2Sequence_bioformats.ijm "${FILE_FOLDER}/${i}"   #Run ImageJ macro to convert stack into image sequence and save them in /tmp
else
    /Applications/Fiji.app/Contents/MacOS/ImageJ-macosx -batch Stack2Sequence.ijm "${FILE_FOLDER}/${i}"   #Run ImageJ macro to convert stack$    
fi
TEMP_FILES=(*);
        for b in ${TEMP_FILES[*]}; do #Move files to final directory
        mv $b ../Denoise/${NEW_DIRECTORY};
        done;

ZEROS="";
#####Organize files by Channel

    CHANNEL_FILES=(../Denoise/${NEW_DIRECTORY}/*.tif);
    for a in ${CHANNEL_FILES[*]}; do
        [[ $a =~ .*c(0+)[0-9].tif ]];
        ZEROS=${BASH_REMATCH[1]};
        if [ -z ${BASH_REMATCH[0]} ]; then
            [[ $a =~ (.*)\.tif ]]
            mv $a ${BASH_REMATCH[1]}_c01.tif
            ZEROS="0";
        fi
    done;
    COUNTER=1;
    while [ $COUNTER -lt 5 ]; do        ##Check for up to 5 channels
            CHANNEL_FILES=(../Denoise/${NEW_DIRECTORY}/*_c${ZEROS}${COUNTER}.tif)
            [[ ${CHANNEL_FILES} =~ ${NEW_DIRECTORY}_.*_c${ZEROS}${COUNTER}.tif ]]
                if [ ! -z ${BASH_REMATCH[0]} ]; then
                mkdir ${FILE_FOLDER}/Denoise/${NEW_DIRECTORY}/Channel${COUNTER};
                for c in ${CHANNEL_FILES[*]}; do
                mv $c ../Denoise/${NEW_DIRECTORY}/Channel${COUNTER};
                done;
            fi

	let COUNTER=COUNTER+1;
    done;
fi

done;
rm -r $FILE_FOLDER/tmp; ##Clean up

read -p "Transfer to Saki Server?<y/n>" -n 1 -r
echo
if [[  $REPLY =~ ^[Yy]$ ]]; then
	scp -qr $FILE_FOLDER/Denoise weinerlab@saki.ucsf.edu:${SAKI_HOME_DIR}  #Transfer files to server
elif [[ $REPLY =~ ^[Nn]$ ]]; then
	echo "Finished.  Images ready for transfer in ${FILE_FOLDER}/Denoise";
else
	echo "Invalid response.  Image ready for transfer in ${FILE_FOLDER}/Denoise"; 
fi

exit
