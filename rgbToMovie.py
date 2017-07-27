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
import matplotlib.patches as patches
from matplotlib.animation import FuncAnimation



parser = argparse.ArgumentParser();
parser.add_argument('-i', '--image', help='a directory that contains all the images for processing');
parser.add_argument('-f', '--frames', type=int, default=100, help='number of time frames in image stacks');
parser.add_argument('-t', '--time', type=int, default=20, help='time interval between frames. Default value: 20s')
parser.add_argument('-s', '--stamp', action='store_true', default=False, help='include time stamp on movie.');
parser.add_argument('-b', '--scalebar', type=float, default=0, help='Annotate image with scale bar of user defined length (in um)');


arg = parser.parse_args();

image_dir = arg.image;
num_frames = arg.frames;
time_interval = arg.time;
scalebar = arg.scalebar;
stamp = arg.stamp;

frame_number = 1;
os.chdir(image_dir);
image_list = glob.glob('*.tif');
for i in image_list:
    cur_image = i;
    m = re.search('(Batch\d+_.*_XY\d+_.*\d+).*.tif', cur_image);
    match = m.group(1);
    
    im = io.imread(cur_image)
    
    fig = plt.figure(figsize=(5,5), frameon=False);
    ax = fig.add_axes([0,0,1,1], xlim=(0,512), ylim=(512,0), aspect='equal', frameon=False);
    ax.set_axis_off();
    plt.margins(0,0)
    ax.set_frame_on(False);
    ax.set_xlim([0, 512]);
    ax.set_ylim([512, 0]);

    
    im_now = im[frame_number, :, :, :];
    implt = plt.imshow(im_now);

    if stamp:
        frame_string = "Time: " + str(frame_number * time_interval) + " sec";
        frame_text = ax.text(x=10, y=30, s=frame_string, fontsize=16, weight='bold', color='white', fontname='Helvetica');



    if scalebar != 0:
        pixel_len = (scalebar / 0.091) * sf;
        ax.hlines(10, (500 - pixel_len), 500, color='w')
    
    
    def update (frame_number):
        im_now = im[frame_number, :, :, :];
        implt.set_data(im_now);
        if stamp:
            frame_string = "Time: " + str(frame_number * 20) + " sec";
            frame_text.set_text(frame_string);
        
        return

    m = re.search('(Batch\d+_.*_XY\d+.*).tif', cur_image);
    match = m.group(1);
    animation = FuncAnimation(fig, update, interval=70, repeat=True);
    animation.save(match + '.mp4', writer='ffmpeg', dpi=300, bitrate=15000, fps=14);
    plt.show();
