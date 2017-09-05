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
parser.add_argument('-d', '--data', help='a file that contains tracking data files for the images to process.  Should have the follows columns: C1_Image\tC1_X Value (pixel)\tC1_Y Value (pixel)\tC1_T Value (frame)\tC2_Image\tC2_X Value (pixel)\tC2_Y Value (pixel)\tC2_Z Value (frame)');
parser.add_argument('-f', '--frames', type=int, default=100, help='number of time frames in image stacks');
parser.add_argument('-t', '--time', type=int, default=20, help='time interval between frames. Default value: 20s')
parser.add_argument('-s', '--stamp', action='store_true', default=False, help='include time stamp on movie.');
parser.add_argument('-l', '--lines', action='store_true', default=False, help='include path trace on movie.');
parser.add_argument('-m', '--marks', action='store_true', default=False, help='include markers for localization data.');
parser.add_argument('-c', '--combined', action='store_true', default=False, help='graph multiple tracked pairs on image.  Images should be cropped to each ROI.');
parser.add_argument('-x', '--scale', type=float, default=1.0, help='if image has been scaled after tracking data was recorded, this is the scaling factor to apply to the data');
parser.add_argument('-b', '--scalebar', type=float, default=0, help='Annotate image with scale bar of user defined length (in um)');


arg = parser.parse_args();

image_dir = arg.image;
data_file = arg.data;
num_frames = arg.frames;
time_interval = arg.time;
paths = arg.lines;
marks = arg.marks;
combined = arg.combined;
scalebar = arg.scalebar;
stamp = arg.stamp;
sf = arg.scale;

data = pd.read_table(data_file);


frame_number = 1;
os.chdir(image_dir);
image_list = glob.glob('*.tif');
for i in image_list:
    cur_image = i;
    if combined:
        m = re.search('(Batch\d+_.*_XY\d+).*.tif', cur_image);
    else:
        m = re.search('(Batch\d+_.*_XY\d+_.*\d+).*.tif', cur_image);
    match = m.group(1);
    
    im = io.imread(cur_image)
    
    x = data[data.C1_Image.str.contains(match)];
    singlets = x.C1_Image.unique();
    
    fig = plt.figure(figsize=(5,5), frameon=False);
    ax = fig.add_axes([0,0,1,1], xlim=(0,512), ylim=(512,0), aspect='equal', frameon=False);
    ax.set_axis_off();
    plt.margins(0,0)
    ax.set_frame_on(False);
    ax.set_xlim([0, 512]);
    ax.set_ylim([512, 0]);
    
    num_singlets = singlets.size;
    x_location = np.full(num_singlets, np.nan);
    x2_location = np.full(num_singlets, np.nan);
    y_location = np.full(num_singlets, np.nan);
    y2_location = np.full(num_singlets, np.nan);
    
    im_now = im[frame_number, :, :, :];
    implt = plt.imshow(im_now);
    
    #### Manually include ROI data here if you want to box or highlight specific locations on image.
    roi_1 = patches.Rectangle((80,98), 42, 42, edgecolor="yellow", facecolor="none", linestyle="dashed");
    roi_2 = patches.Rectangle((406,278), 42, 42, edgecolor="yellow", facecolor="none", linestyle="dashed");
    ax.add_patch(roi_1);
    ax.add_patch(roi_2);
    
    for j in range(0,num_singlets):
        if not x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'C1_X Value (pixel)'].size == 0:
            x_location[j] = x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'C1_X Value (pixel)'] * sf;
            y_location[j] = x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'C1_Y Value (pixel)'] * sf;
        else:
            x_location[j] = np.nan;
            y_location[j] = np.nan;
        if not x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == singlets[j]), 'C2_X Value (pixel)'].size == 0:
            x2_location[j] = x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == singlets[j]), 'C2_X Value (pixel)'] * sf;
            y2_location[j] = x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == singlets[j]), 'C2_Y Value (pixel)'] * sf;
        else:
            x2_location[j] = np.nan;
            y2_location[j] = np.nan;

    if marks:
        if not x_location.size == 0:
            scat = ax.scatter([x_location], [y_location], marker='+', c='#D3D3D3', s=(60 * sf), linewidth=1.5);
        if not x2_location.size == 0:
            scat2 = ax.scatter([x2_location], [y2_location], marker='+', c='#A9A9A9', s=(60 * sf), linewidth=1.5);

    if stamp:
        frame_string = "Time: " + str(frame_number * time_interval) + " sec";
        frame_text = ax.text(x=10, y=30, s=frame_string, fontsize=16, weight='bold', color='white', fontname='Helvetica');
    
    if paths:
        x_line = np.full((num_singlets, num_frames), np.nan);
        y_line = np.full((num_singlets, num_frames), np.nan);
        x2_line = np.full((num_singlets, num_frames), np.nan);
        y2_line = np.full((num_singlets, num_frames), np.nan);
        lines_c1 = [];
        lines_c2 = [];

        for j in range(0,num_singlets):
            lobj = ax.plot([], [], c='0.9', linewidth=0.75)[0];
            lines_c1.append(lobj);
            lobj = ax.plot([], [], c='0.5', linewidth=0.75)[0];
            lines_c2.append(lobj);

    if scalebar != 0:
        pixel_len = (scalebar / 0.091) * sf;
        ax.hlines(10, (500 - pixel_len), 500, color='w')


    def update (frame_number):
        im_now = im[frame_number, :, :, :];
        implt.set_data(im_now);
        if stamp:
            frame_string = "Time: " + str(frame_number * 20) + " sec";
            frame_text.set_text(frame_string);
        for j in range(0,num_singlets):
            if not x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'C1_X Value (pixel)'].size == 0:
                x_location[j] = x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'C1_X Value (pixel)'] * sf;
                y_location[j] = x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'C1_Y Value (pixel)'] * sf;
            else:
                x_location[j] = np.nan;
                y_location[j] = np.nan;
            if not x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == singlets[j]), 'C2_X Value (pixel)'].size == 0:
                x2_location[j] = x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == singlets[j]), 'C2_X Value (pixel)'] * sf;
                y2_location[j] = x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == singlets[j]), 'C2_Y Value (pixel)'] * sf;
            else:
                x2_location[j] = np.nan;
                y2_location[j] = np.nan;

        if not x_location.size == 0:
            data = np.stack(([x_location], [y_location]), axis=-1)
            if marks:
                scat.set_offsets(data);
            if paths:
                x_line[:, frame_number - 1] = x_location;
                y_line[:, frame_number - 1] = y_location;

        if paths:
            if frame_number > 1:
                for lnum, line in enumerate(lines_c1):
                    line.set_data(x_line[lnum, :frame_number], y_line[lnum, :frame_number]);
        
        if not x2_location.size == 0:
            data2 = np.stack(([x2_location], [y2_location]), axis=-1)
            if marks:
                scat2.set_offsets(data2);
            if paths:
                x2_line[:, frame_number - 1] = x2_location;
                y2_line[:, frame_number - 1] = y2_location;

        if paths:
            if frame_number > 1:
                for lnum, line in enumerate(lines_c2):
                    line.set_data(x2_line[lnum, :frame_number], y2_line[lnum, :frame_number]);
        
        return

m = re.search('(Batch\d+_.*_XY\d+.*).tif', cur_image);
match = m.group(1);
animation = FuncAnimation(fig, update, interval=70, repeat=True);
animation.save(match + '.mp4', writer='ffmpeg', dpi=300, bitrate=15000, fps=14);
plt.show();
