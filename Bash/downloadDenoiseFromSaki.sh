#!/bin/sh

#  downloadDenoiseFromSaki
#
#
#  Created by Jeffrey Alexander on 07/20/16.
#


## Automated script to grab the appropriate files from the Saki server and deposit them to a folder of choice


die() {
    echo "$*" 1>&2
    exit 1
}

usage()  { echo "Usage: $0\n -d <path to image folder>"; die; }

###Assign values from Flags
FILE_FOLDER=                    ### This is the folder that are the stacks for processing are.  It is assigned by the -d option. (e.g. Stack2Sequence.sh -d /path/to/images
FILE_TYPE=                      ### This is the extension for the stacks.  All stacks should be a common extension.  It is assigned by the -e option. (e.g Stack2Sequence.sh -e .nd2)
SAKI_HOME_DIR=                  ### This is your home folder on the saki server.  It is assigned by the -s option. (e.g. Stack2Sequence -s Jeff)
BIOFORMATS=			### This options tells script which ImageJ macro to call, one that uses BioFormats to open or not.

while getopts "d:" o; do
case "${o}" in
        d)
FILE_FOLDER=${OPTARG}
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

if [ ! -d "$FILE_FOLDER" ]; then
    die "File directory does not exist!"
fi

cd $FILE_FOLDER;
if [ ! -d Com_Files ]; then
    mkdir ./Com_Files;
fi

if [ ! -d Log_Files ]; then
mkdir ./Log_Files;
fi

echo "Downloading Logs.........";
scp weinerlab@saki.ucsf.edu:Jeff/Denoise/MRC_Files/*.log ${FILE_FOLDER}/Log_Files;
echo "Downloading Com files....";
scp weinerlab@saki.ucsf.edu:Jeff/Denoise/MRC_Files/*.com ${FILE_FOLDER}/Com_Files;
echo "Downloading denoised images.....";
scp weinerlab@saki.ucsf.edu:Jeff/Denoise/MRC_Files/*.mrc_dn $FILE_FOLDER;

exit
