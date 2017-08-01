#!/bin/sh

#  Stack2ImageSequence.sh
#
#
#  Created by Jeffrey Alexander on 8/23/15.
#


#Denoised MRC File to Merged Tiff with 16-bit Depth
#Useful for taking denoised files produced by ndsafir and converting them into a viewer-friendly merged file in ImageJ.
#These tiff files are the input used for Juan Guan's particle tracking software.

die() {
    echo "$*" 1>&2
    exit 1
}

usage()  { echo "Usage: $0\n -d <path to image folder>\n -b <convert image to 16-bits>"; die; }

###Assign values from Flags
FILE_FOLDER=                    ### This is the path to the folder that has the denoised files.  It is assigned by the -d option. (e.g. Stack2Sequence.sh -d /path/to/images)

while getopts "d:b" o; do
case "${o}" in
        d)
FILE_FOLDER=${OPTARG}
            ;;
        b)
BITS=TRUE
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

if [[ $FILE_FOLDER =~ (.*)/$ ]]; then
    FILE_FOLDER=${FILE_FOLDER%?}
fi

if [ ! -d "$FILE_FOLDER" ]; then     # Make Denoise folder if it doesn't already exist
    die "File directory does not exist!"
fi

cd $FILE_FOLDER;

FILES=(*.mrc_dn); # List all files in directory
FILE_NAME_ARRAY=();
FILE_NAME_BASE="";

for i in ${FILES[*]}; do  # Loop through each file
    if [[ $i =~ (.*)c0+1.mrc_dn ]]; then
        FILE_NAME_BASE_ARRAY+=(${BASH_REMATCH[1]})
    fi
done;
for i in ${FILE_NAME_BASE_ARRAY[*]}; do
    FILES_TO_RUN=();
    for j in ${FILES[*]}; do
    if [[ $j =~ (${i}c0+[1-9].mrc_dn) ]]; then
        FILES_TO_RUN+=(${BASH_REMATCH[1]});

    fi
    done
    if [[ BITS == "TRUE" ]]; then
        /Applications/Fiji.app/Contents/MacOS/ImageJ-macosx -batch mrc_dnToMergedTiff_16bit.ijm "${FILES_TO_RUN[*]}";
    else
        /Applications/Fiji.app/Contents/MacOS/ImageJ-macosx -batch mrc_dnToMergedTiff.ijm "${FILES_TO_RUN[*]}"
    fi

done;

exit
