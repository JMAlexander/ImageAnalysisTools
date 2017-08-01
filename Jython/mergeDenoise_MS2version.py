import sys
import os
import argparse
import glob
import time
import re
import gc
import java.util.HashMap
import java.lang.Runtime as Runtime

jy_path = glob.glob("/Users/Jeff/Source/jython*/javalib/")[0]

sys.path.append(jy_path + 'bioformats_package.jar')
sys.path.append(jy_path + 'mdbtools-java.jar')
sys.path.append(jy_path + 'ome-xml.jar')

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

import loci.formats
import loci.plugins.BF as BF
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
	os.mkdir('MaxZProj');
except OSError:
	print("Directory 'MaxZProj' already exists.");
try:
    os.mkdir('Stacks');
except OSError:
    print("Directory 'Stacks' already exists.");
image_list = glob.glob("*.mrc_dn");

image_basenames = [];
for i in image_list:
    m = re.search('(Batch\d+_\d+_XY\d+).*.mrc_dn', i)
    match = m.group(1)
    image_basenames.append(match)

image_basenames = list(set(image_basenames))
print(image_basenames)
ImageJ()
for i in image_basenames:
    print(i)
    cur_images = [];
    for j in image_list:
        m = re.search(i, j)
        if m:
            cur_images.append(j)

#    imp_c1 = IJ.openImage(cur_images[0])
#    imp_c2 = IJ.openImage(cur_images[1])
    image_path = image_directory + cur_images[2]
    imp_c3 = Opener.openUsingBioFormats(image_path)
    imp_c3.show()
    save_name = image_directory + '/Stacks/' + i + 'merged.tif'
    IJ.saveAsTiff(imp_c3, save_name)
#    merge_string = "c1=" + cur_images[0] + " c2=" + cur_images[1] + " create";
#    IJ.run("Merge Channels...", merge_string)
    IJ.run('Z Project...', 'projection=[Max Intensity] all')
    IJ.run('Enhance Contrast...', 'saturated=0.05')
    max_im = IJ.getImage()
    save_name = image_directory + '/MaxZProj/' + i + 'MaxZProj.tif'
    IJ.saveAsTiff(max_im, save_name)
    IJ.run('Close All');
    gc.collect();

IJ.run('Close All');


exit();
