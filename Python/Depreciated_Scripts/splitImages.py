import sys
import os
import argparse
import glob
from skimage import io



parser = argparse.ArgumentParser();
parser.add_argument('-i', '--image', help='a directory that contains all the images for processing');
parser.add_argument('-c', '--channel', type=int, help='a value giving the number of channels expected for each image stack');

arg = parser.parse_args();

image_directory = arg.image;
channels = arg.channel;

print('Image directory:  ' + image_directory);
print('Number of Channels:  ' + str(channels));

out_dir = image_directory + '/Split_Images/';

os.chdir(image_directory);
try:
	os.mkdir(out_dir);
except OSError:
	print("Directory 'Split_Images' already exists.");
image_list = glob.glob("*.tif");


os.chdir(image_directory);
for i in image_list:
    cur_image = i;
    print(cur_image);
    imp = io.imread(cur_image);
    for c in range(0, channels):
        out_imp = imp[:, :, :, c];
        output_name = out_dir + 'C' + str(c + 1) + '-' + cur_image;
        io.imsave(output_name, out_imp);

