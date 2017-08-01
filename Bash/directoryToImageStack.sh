#!/bin/sh

#directoryToImageStack.sh

die() {
	echo "$*" 1>&2
	exit 1
}

usage() { echo "Usage: $0\n -d <path to image directory>\n"; die; }

### Assign values from Flags
FILE_FOLDER=

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
cd $FILE_FOLDER;

SUB_DIR=`ls -d *`;
for i in ${SUB_DIR[*]}; do
    cd $FILE_FOLDER;
    cd ${FILE_FOLDER}/${i};
    FILES=`ls -d * | grep -v .tif`;

    for j in ${FILES[*]}; do
        cd ${FILE_FOLDER}/$i;
        if [[ $j =~ (.*)_(XY[0-9]+)_t([0-9]+)_1 ]]; then
            matched_folder = ${BASH_REMATCH[0]};
            base_name=${BASH_REMATCH[1]};
            position=${BASH_REMATCH[2]};
            t_value=${BASH_REMATCH[3]};
            if [ ! -d $position ]; then
                mkdir ./$position;
            fi
                mv $j ./$position;
        fi
	
        cd ./${position}/${j}/Pos0/;
       IMAGES=(*.tif);
       for k in ${IMAGES[*]}; do
           if [[ $k =~ .*Cy5_([0-9]+).tif ]]; then
               z_value=${BASH_REMATCH[1]};
                if [ ! -d ../../${base_name}_Cy5 ]; then
                mkdir ../../${base_name}_Cy5;
                fi
                mv $k ../../${base_name}_Cy5/${base_name}_Cy5_t${t_value}_z${z_value}.tif;
           elif [[ $k =~ .*GFP_([0-9]+).tif ]]; then
                z_value=${BASH_REMATCH[1]};
                if [ ! -d ../../${base_name}_GFP ]; then
                mkdir ../../${base_name}_GFP;
                fi
                mv $k ../../${base_name}_GFP/${base_name}_GFP_t${t_value}_z${z_value}.tif;
            elif [[ $k =~ .*RFP_([0-9]+).tif ]]; then
                z_value=${BASH_REMATCH[1]};
                if [ ! -d ../../${base_name}_RFP ]; then
                mkdir ../../${base_name}_RFP;
                fi
                mv $k ../../${base_name}_RFP/${base_name}_RFP_t${t_value}_z${z_value}.tif;
            else
                echo "Image Folder does not match pattern\n";
            fi
 #               if [ -d ${FILE_FOLDER}/${i}/${position}/${matched_folder} ]; then
 #               rm -r ${FILE_FOLDER}/${i}/${position}/${matched_folder};
 #           fi
       done


    done
done

#################
exit
