# -*- coding: utf-8 -*-
"""
    Created on Thu Sep 22 08:40:34 2016
    
    @author: Jeff
    """

import sys
import os
import argparse
import glob
import time
import re
import numpy as np
import scipy
import pandas as pd
from PIL import Image
from skimage import io
import matplotlib as plt


parser = argparse.ArgumentParser();
parser.add_argument('-i', '--image', help='a directory that contains all the images for processing');
parser.add_argument('-t', '--table', help='table that contains tracking data.  Should be tab-delimited for columns Image_Name\tX_Value\tY_Value\tT_Value');
parser.add_argument('-d', '--dim', help='enter dimensions of tiff stacks. [xy|xyz|xyt|xyc|xytc|xyzc|xyzt|xyztc]');
parser.add_argument('-n', '--numchannel', type=int, help='number of channels in the image stack');

arg = parser.parse_args();

image_dir = arg.image;
output_folder = image_dir + 'Centered_Stacks/';
dim = arg.dim;
localization_table = arg.table;
num_chan = arg.numchannel
if num_chan == 3:
    print(num_chan);

print('Image Directory:  ' + image_dir);
print('Localization Table:  ' + localization_table);
print('Image Dimensions:  ' + dim);

if not image_dir.endswith('/'):
    image_dir = image_dir + '/';

os.chdir(image_dir);
try:
    os.stat(output_folder)
except:
    os.mkdir(output_folder)

image_list = glob.glob('*.tif');
df = pd.read_table(localization_table);
df.columns = ['C1_Image', 'C1_X Value (pixel)', 'C1_Y Value (pixel)', 'C1_T Value (frame)'];
x_start = 0;
y_start = 0;

for i in image_list:
    cur_image = i;
    print('Working on image:  ' + cur_image);
    im = io.imread(cur_image);
    m = re.search('(Batch\d+.*_XY\d+).*.tif', cur_image);
    match = m.group(1);
    
    if num_chan == 3:
        (x_size, y_size, slices, frames, channels) = (0, 0, 0, 0, 0);
        if dim == 'xy':
            (y_size, x_size) = im.shape;
        elif dim =='xyz':
            (slices, y_size, x_size) = im.shape;
        elif dim =='xyt':
             (frames, y_size, x_size) = im.shape;
        elif dim =='xyc':
            (y_size, x_size, channels) = im.shape;
        elif dim =='xytc':
            (frames, y_size, x_size, channels) = im.shape;
        elif dim =='xyzc':
            (slices, y_size, x_size, channels) = im.shape;
        elif dim =='xyzt':
            (frames, slices, y_size, x_size) = im.shape;
        elif dim =='xyztc':
            (frames, slices, y_size, x_size, channels) = im.shape;
        else:
            print('Dimensions flag passed in wrong format.  Avaiable options are [xy|xyz|xyt|xyc|xytc|xyzc|xyzt|xyztc]');
            exit();
    else:
        (x_size, y_size, slices, frames, channels) = (0, 0, 0, 0, 0);
        if dim == 'xy':
            (y_size, x_size) = im.shape;
        elif dim =='xyz':
            (slices, y_size, x_size) = im.shape;
        elif dim =='xyt':
            (frames, y_size, x_size) = im.shape;
        elif dim =='xyc':
            (channels, y_size, x_size) = im.shape;
        elif dim =='xytc':
            (frames, channels, y_size, x_size) = im.shape;
        elif dim =='xyzc':
            (slices, channels, y_size, x_size) = im.shape;
        elif dim =='xyzt':
            (frames, slices, y_size, x_size) = im.shape;
        elif dim =='xyztc':
            (frames, slices, channels, y_size, x_size) = im.shape;
        else:
            print('Dimensions flag passed in wrong format.  Avaiable options are [xy|xyz|xyt|xyc|xytc|xyzc|xyzt|xyztc]');
            exit();
    if slices > 0:
        ## Max Projection
        if num_chan == 3:
            max_im = np.zeros((frames, y_size, x_size, channels), np.float32);
            for i in range(0, channels):
                for j in range(0,frames):
                    for k in range(0, x_size):
                        for l in range(0, y_size):
                            max_im[j, l, k, i] = np.amax(im[j, :, l, k, i])
        else:
            max_im = np.zeros((frames, channels, y_size, x_size), np.float32);
            for i in range(0, channels):
                for j in range(0,frames):
                    for k in range(0, x_size):
                        for l in range(0, y_size):
                            max_im[j, i, l, k] = np.amax(im[j, :, i, l, k])
    else:
        max_im = im;
    regex = re.escape(match) + '.*';
    names = df[df.C1_Image.str.contains(regex)].C1_Image.unique();
    for n in names:
        x_start = None;
        y_start = None;
        df_i = df.query('C1_Image == @n');
        if num_chan == 3:
            cent_im = np.zeros((frames, 32, 32, channels), np.float32);
        else:
            cent_im = np.zeros((frames, channels, 32, 32), np.float32);
        if channels > 0:
            for c in range(0, channels):
                for t in range(0, frames):
                    cur_frame = t + 1;
                    print(cur_frame)
                    frame_coords = df_i.loc[(df_i['C1_T Value (frame)'] == cur_frame), ['C1_X Value (pixel)', 'C1_Y Value (pixel)']];
                    if not frame_coords.empty:
                        x_start = int(frame_coords['C1_X Value (pixel)'] - 16);
                        y_start = int(frame_coords['C1_Y Value (pixel)'] - 16);
                        
                        if x_start < 0:
                            x_start = 0;
                        elif x_start > (x_size - 32):
                            x_start = x_size - 32;
                        if y_start < 0:
                            y_start = 0;
                        elif y_start > (y_size - 32):
                            y_start = y_size - 32;
                        if num_chan == 3:
                            cent_im[t, :, :, c] = max_im[t, y_start:(y_start + 32), x_start:(x_start + 32), c];
                        else:
                            cent_im[t, c, :, :] = max_im[t, c, y_start:(y_start + 32), x_start:(x_start + 32)];
                    elif x_start and y_start:
                        if num_chan == 3:
                            cent_im[t, :, :, c] = max_im[t, y_start:(y_start + 32), x_start:(x_start + 32), c];
                        else:
                            cent_im[t, c, :, :] = max_im[t, c, y_start:(y_start + 32), x_start:(x_start + 32)];
        else:
            cent_im = np.zeros((frames, 32, 32), np.float32);
            
            for t in range(0, frames):
                cur_frame = t + 1;
                print(cur_frame);
                frame_coords = df_i.loc[(df_i['C1_T Value (frame)'] == cur_frame), ['C1_X Value (pixel)', 'C1_Y Value (pixel)']];
                if not frame_coords.empty:
                    x_start = int(frame_coords['C1_X Value (pixel)'] - 16);
                    y_start = int(frame_coords['C1_Y Value (pixel)'] - 16);
                    
                    if x_start < 0:
                        x_start = 0;
                    elif x_start > (x_size - 32):
                        x_start = x_size - 32;
                    if y_start < 0:
                        y_start = 0;
                    elif y_start > (y_size - 32):
                        y_start = y_size - 32;
                    
                    cent_im[t, :, :] = max_im[t, y_start:(y_start + 32), x_start:(x_start + 32)];
                elif x_start and y_start:
                    cent_im[t, :, :] = max_im[t, y_start:(y_start + 32), x_start:(x_start + 32)];

        output_image = output_folder + n + '_centered.tif';
        io.imsave(output_image, cent_im);


