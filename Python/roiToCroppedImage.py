import sys
import os
import argparse
import glob
import time
import re
import gc
import java.util.HashMap
import java.lang.Runtime as Runtime

if Runtime.getRuntime().totalMemory() < 10000000000:
    print('Insufficient memory.  Please re-run by invoking jython10g -script.py');
    exit();


plugin_jars=os.listdir("/Applications/Fiji.app/plugins")
jarfold_jars=os.listdir("/Applications/Fiji.app/jars")

for i in plugin_jars:
	add_jar = "/Applications/Fiji.app/plugins/" + i
	sys.path.append(add_jar)

for i in jarfold_jars:
	add_jar = "/Applications/Fiji.app/jars/" + i
	sys.path.append(add_jar)


from ij.io import Opener
from ij import IJ, ImagePlus, ImageJ


parser = argparse.ArgumentParser();
parser.add_argument('-i', '--image', help='a directory that contains all the images for processing');
parser.add_argument('-r', '--roi', help='a directory that contains all annotated ROIs');
parser.add_argument('-c', '--cons', action='store_true', default=False, help='use conservative memory usage, opens fresh image for each ROI');
arg = parser.parse_args();

image_directory = arg.image;
roi_directory = arg.roi;
mem_conserve = arg.cons;
print('Image_directory:  ' + image_directory);
print('ROI_directory:  ' + roi_directory);
print('Use Conservative memory usage:  ' + str(mem_conserve));

crop_dir = image_directory + '/Cropped_Images/';

os.chdir(image_directory);
try:
	os.mkdir(crop_dir);
except OSError:
	print("Directory 'Cropped_Images' already exists.");
image_list = glob.glob("*.tif");

os.chdir(roi_directory);
roi_list = glob.glob("*.roi");

os.chdir(image_directory);
ImageJ();
for i in image_list:
    imp = [];
    match_roi = [];
    match_count = 1;
    m = re.search('(Batch\d+_\d+_XY\d{2}).*.tif', i);
    match = m.group(1);
        
    for j in roi_list:
        if re.search(match, j):
            match_roi.append(j);

    if not mem_conserve:
    	if len(match_roi) >= 1:
        	image_path = image_directory + '/' + i;
        	imp = IJ.openImage(image_path);
        	imp.show();
        	for k in match_roi:
            		IJ.selectWindow(i);
            		cur_match_roi = k;
            		m = re.search('(Batch\d+_\d+_XY\d{2}_cropped_singlet\d+).roi', cur_match_roi);
            		crop_name = m.group(1);
            		roi_path = roi_directory + '/' + cur_match_roi;
            		IJ.open(roi_path);
            		temp_str = 'title=' + crop_name + '.tif duplicate';
            		IJ.run('Duplicate...', temp_str);
            		imp_cropped = IJ.getImage();
            		save_name = crop_dir + '/' + crop_name + '.tif';
            		print(save_name);
            		IJ.saveAsTiff(imp_cropped, save_name);
        	IJ.run('Close All');
    		gc.collect();
    else:
	if len(match_roi) >= 1:
		for k in match_roi:
			image_path = image_directory + '/' + i;
			imp = IJ.openImage(image_path);
			imp.show();
			IJ.selectWindow(i);
			cur_match_roi = k;
			m = re.search('(Batch\d+_\d+_XY\d{2}_cropped_singlet\d+).roi', cur_match_roi);
			crop_name = m.group(1);
			roi_path = roi_directory + '/' + cur_match_roi;
			IJ.open(roi_path);
			IJ.run('Crop');
			imp_cropped = IJ.getImage();
			save_name = crop_dir + '/' + crop_name + '.tif';
			print(save_name);
			IJ.saveAsTiff(imp_cropped, save_name);
			IJ.run('Close All');
			gc.collect();
IJ.run('Close All');

exit();
