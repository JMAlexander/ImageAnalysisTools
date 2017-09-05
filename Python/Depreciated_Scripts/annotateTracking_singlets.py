# coding: utf-8

get_ipython().magic('matplotlib')

import sys
import os
import argparse
import glob
import time
import re
import numpy as np
import scipy
import pandas as pd
import pims
from PIL import Image
from skimage import io
from skimage import color as col
import matplotlib.pyplot as plt
import matplotlib.lines as lines
from matplotlib.animation import FuncAnimation
from matplotlib.ticker import Formatter, Locator, NullLocator, FixedLocator, NullFormatter



parser = argparse.ArgumentParser();
parser.add_argument('-i', '--image', help='a directory that contains all the images for processing');
parser.add_argument('-d', '--data', help='a directory that contains tracking data files for the images to process');
parser.add_argument('-f', '--frames', help='integer value indicating the time spacing between frames.  Will annotate movie with time');

arg = parser.parse_args();

#image_dir = '/Users/Jeff/Downloads/Cropped_Images/Max_Proj/';
#data_dir = '/Users/Jeff/Downloads/Cropped_Images/120_spots/';
image_dir = arg.image;
data_dir = arg.data;
os.chdir(data_dir);
C1_data_file = glob.glob('C1*.txt');
C2_data_file = glob.glob('C2*.txt');
C1_data = pd.read_table(C1_data_file[0]);
C2_data = pd.read_table(C2_data_file[0]);
interval = arg.frames;


num_frames = 100;
frame_number = 1;
os.chdir(image_dir);
image_list = glob.glob('*.tif');
for i in image_list:
    cur_image = i;
    m = re.search('(Batch\d+_.*_XY\d+.*_singlet\d+).*.tif', cur_image);
    match = m.group(1);
    
    im = io.imread(cur_image);
    x_pix = im.shape[1];
    y_pix = im.shape[2];
    
    x = C1_data[C1_data.C1_Image.str.contains(match)];
    singlet_c1 = x.C1_Image.unique()[0];
    
    x2 = C2_data[C2_data.C2_Image.str.contains(match)];
    singlet_c2 = x2.C2_Image.unique()[0];
    
    
    fig = plt.figure(figsize=(5,5), frameon=False);
    ax = fig.add_axes([0,0,1,1], xlim=(0,x_pix), ylim=(y_pix,0), aspect='equal', frameon=False);
    ax.set_axis_off();
    plt.margins(0,0)
    ax.set_frame_on(False);
    ax.set_xlim([0, x_pix]);
    ax.set_ylim([y_pix, 0]);
    
    
    
    x_location = np.nan;
    x2_location = np.nan;
    y_location = np.nan;
    y2_location = np.nan;
    
    im_now = im[frame_number, :, :, :];
    
    #x_line = np.full((num_singlets, num_frames), np.nan);
    #y_line = np.full((num_singlets, num_frames), np.nan);
    #x2_line = np.full((num_singlets, num_frames), np.nan);
    #y2_line = np.full((num_singlets, num_frames), np.nan);
    
    
    implt = plt.imshow(im_now);
    
    
    if not x[(x.C1_FRAME == frame_number) & (x.C1_Image == singlet_c1)].C1_Position_X.values.size == 0:
        x_location = (x[(x.C1_FRAME == frame_number) & (x.C1_Image == singlet_c1)].C1_Position_X.values + 0.5) * 12.19;
        y_location = (x[(x.C1_FRAME == frame_number) & (x.C1_Image == singlet_c1)].C1_Position_Y.values + 0.5) * 12.19;
    else:
        x_location = np.nan;
        y_location = np.nan;
    if not x2[(x2.C2_FRAME == frame_number) & (x2.C2_Image == singlet_c1)].C2_Position_X.values.size == 0:
        x2_location = (x2[(x2.C2_FRAME == frame_number) & (x2.C2_Image == singlet_c1)].C2_Position_X.values + 0.5) * 12.19;
        y2_location = (x2[(x2.C2_FRAME == frame_number) & (x2.C2_Image == singlet_c1)].C2_Position_Y.values + 0.5) * 12.19;
    else:
        x2_location = np.nan;
        y2_location = np.nan;

    if x_location:
        scat = ax.scatter(x_location, y_location, marker='+', color='#D3D3D3', s=600, linewidth=3.5);
        text = ax.text(x=(x_location + 20),y=(y_location - 20), s='SCR', fontsize=25, weight='bold', color='#D3D3D3', fontname='Helvetica')
    if x2_location:
        scat2 = ax.scatter(x2_location, y2_location, marker='+', color='#A9A9A9', s=600, linewidth=3.5);
        text2 = ax.text(x=(x_location + 20),y=(y_location - 20), s='Sox2', fontsize=25, weight='bold', color='#A9A9A9', fontname='Helvetica')

    frame_string = "Time: " + str(frame_number * interval) + " sec";
    frame_text = ax.text(x=10, y=30, s=frame_string, fontsize=16, weight='bold', color='white', fontname='Helvetica');

    lines_c1 = [];
    lines_c2 = [];

    #lobj = ax.plot([], [], c='0.9', linewidth=0.5)[0];
    #lines_c1.append(lobj);
    #lobj = ax.plot([], [], c='0.5', linewidth=0.5)[0];
    #lines_c2.append(lobj);


def update (frame_number):
    im_now = im[frame_number, :, :, :];
    implt.set_data(im_now);
    if not x[(x.C1_FRAME == frame_number) & (x.C1_Image == singlet_c1)].C1_Position_X.values.size == 0:
        x_location = (x[(x.C1_FRAME == frame_number) & (x.C1_Image == singlet_c1)].C1_Position_X.values + 0.5) * 12.19;
        y_location = (x[(x.C1_FRAME == frame_number) & (x.C1_Image == singlet_c1)].C1_Position_Y.values + 0.5) * 12.19;
    else:
        x_location = np.nan;
        y_location = np.nan;
    if not x2[(x2.C2_FRAME == frame_number) & (x2.C2_Image == singlet_c1)].C2_Position_X.values.size == 0:
        x2_location = (x2[(x2.C2_FRAME == frame_number) & (x2.C2_Image == singlet_c1)].C2_Position_X.values + 0.5) * 12.19;
        y2_location = (x2[(x2.C2_FRAME == frame_number) & (x2.C2_Image == singlet_c1)].C2_Position_Y.values + 0.5) * 12.19;
    else:
        x2_location = np.nan;
        y2_location = np.nan;
        
    if x_location:
        data = np.stack(([x_location], [y_location]), axis=-1);
        scat.set_offsets(data);
        text_data = np.stack(((x_location + 20),(y_location - 20)));
        text.set_position(text_data);
        #x_line[:, frame_number - 1] = x_location;
        #y_line[:, frame_number - 1] = y_location;

        #if frame_number > 1:
            #for lnum, line in enumerate(lines_c1):
                #line.set_data(x_line[lnum, :frame_number], y_line[lnum, :frame_number]);

    frame_string = "Time: " + str(frame_number * interval) + " sec";
    frame_text.set_text(frame_string);
    if x2_location:
        data2 = np.stack(([x2_location], [y2_location]), axis=-1)
        scat2.set_offsets(data2);
        text2_data = np.stack(((x2_location + 20),(y2_location - 20)));
        text2.set_position(text2_data);
        #x2_line[:, frame_number - 1] = x2_location;
        #y2_line[:, frame_number - 1] = y2_location;
        
        #if frame_number > 1:
            #for lnum, line in enumerate(lines_c2):
            #line.set_data(x2_line[lnum, :frame_number], y2_line[lnum, :frame_number]);
        
    return im_now
    
m = re.search('(Batch\d+_.*_XY\d+.*).tif', cur_image);
match = m.group(1);
animation = FuncAnimation(fig, update, frames=100, interval=80, repeat=True);
animation.save(match + '.mp4', writer='ffmpeg', dpi=300, bitrate=12000, fps=14);
plt.show();
