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

arg = parser.parse_args();

image_directory = arg.image;
print('Image_directory:  ' + image_directory);


out_dir = image_directory + '/Despeckled_Images/';

os.chdir(image_directory);
try:
	os.mkdir(out_dir);
except OSError:
	print("Directory 'Despeckled_Images' already exists.");
image_list = glob.glob("*.tif");


os.chdir(image_directory);
ImageJ();
for i in image_list:
    imp = [];
    image_path = image_directory + '/' + i;
    imp = IJ.openImage(image_path);
    imp.show();
    IJ.selectWindow(i);
    IJ.run('Despeckle', 'stack');
    mod_image = IJ.getImage();
    save_name = out_dir + '/' + i;
    print(save_name);
    IJ.saveAsTiff(mod_image, save_name);
    IJ.run('Close All');
    gc.collect();
    
IJ.run('Close All');

exit();
