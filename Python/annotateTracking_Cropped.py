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
from PIL import Image
from skimage import io
from skimage import color as col
import matplotlib.pyplot as plt
import matplotlib.lines as lines
import matplotlib.patches as patches
from matplotlib.animation import FuncAnimation

### If image has been cropped compared to image where spots were tracked, subtract value for edge of ROI used for cropped from data table
def coords(s):
    try:
        x, y = map(int, s.split(','))
        return (x, y)
    except:
        raise argparse.ArgumentTypeError("Coordinates must be x,y")


parser = argparse.ArgumentParser();
parser.add_argument('-i', '--image', help='the image of be processed');
parser.add_argument('-d', '--data', help='a file that contains tracking data files for the image to process.  Should have the follows columns: C1_Image\tC1_X Value (pixel)\tC1_Y Value (pixel)\tC1_T Value (frame)\tC2_Image\tC2_X Value (pixel)\tC2_Y Value (pixel)\tC2_Z Value (frame)');
parser.add_argument('-f', '--frames', type=int, default=100, help='number of time frames in image stacks');
parser.add_argument('-t', '--time', type=int, default=20, help='time interval between frames. Default value: 20s')
parser.add_argument('-s', '--stamp', action='store_true', default=False, help='include time stamp on movie.');
parser.add_argument('-l', '--lines', action='store_true', default=False, help='include path trace on movie.');
parser.add_argument('-m', '--marks', action='store_true', default=False, help='include markers for localization data.');
parser.add_argument('-o', '--offset', type=coords, default=(0,0), help='location of the ROI used to cropped image from parent (ex. x_value, y_value)');
parser.add_argument('-x', '--scale', type=float, default=1.0, help='if image has been scaled after tracking data was recorded, this is the scaling factor to apply to the data');
parser.add_argument('-b', '--scalebar', type=float, default=0, help='Annotate image with scale bar of user defined length (in um)');


arg = parser.parse_args();

image = arg.image;
num_frames = arg.frames;
time_interval = arg.time;
marks = arg.marks;
paths = arg.lines;
stamp = arg.stamp;
offset = arg.offset;
scalebar = arg.scalebar;
sf = arg.scale;
data_file = arg.data;

data = pd.read_table(data_file);


frame_number = 0;
m = re.search('(Batch\d+_.*_XY\d+_.*\d+).*.tif', image);
match = m.group(1);
image_name = match;
im = io.imread(image)


x = data[data.C1_Image.str.contains(match)];

fig = plt.figure(figsize=(5,5), frameon=False);
ax = fig.add_axes([0,0,1,1], xlim=(0,512), ylim=(512,0), aspect='equal', frameon=False);
ax.set_axis_off();
plt.margins(0,0)
ax.set_frame_on(False);
ax.set_xlim([0, 512]);
ax.set_ylim([512, 0]);


im_now = im[frame_number, :, :, :];
implt = plt.imshow(im_now);

if not x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == image_name), 'C1_X Value (pixel)'].size == 0:
    x_location = (x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == image_name), 'C1_X Value (pixel)'] - offset[0]) * sf;
    y_location = (x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == image_name), 'C1_Y Value (pixel)'] - offset[1]) * sf;
else:
    x_location = np.nan;
    y_location = np.nan;
if not x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == image_name), 'C2_X Value (pixel)'].size == 0:
    x2_location = (x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == image_name), 'C2_X Value (pixel)'] - offset[0]) * sf;
    y2_location = (x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == image_name), 'C2_Y Value (pixel)'] - offset[1]) * sf;
else:
    x2_location = np.nan;
    y2_location = np.nan;

if stamp:
    frame_string = "Time: " + str(frame_number * time_interval) + " sec";
    frame_text = ax.text(x=10, y=30, s=frame_string, fontsize=16, weight='bold', color='white');
if marks:
    if not x_location.size == 0:
        scat = ax.scatter(x_location, y_location, marker='+', c='#D3D3D3', s=(60 * sf), linewidth=2.0);
    if not x2_location.size == 0:
        scat2 = ax.scatter([x2_location], [y2_location], marker='+', c='#A9A9A9', s=(60 * sf), linewidth=2.0);

if paths:
    x_line = np.full(num_frames, np.nan);
    y_line = np.full(num_frames, np.nan);
    x2_line = np.full(num_frames, np.nan);
    y2_line = np.full(num_frames, np.nan);
    lines_c1 = [];
    lines_c2 = [];
    
    
    lobj = ax.plot([], [], c='0.9', linewidth=0.75)[0];
    lines_c1.append(lobj);
    lobj = ax.plot([], [], c='0.5', linewidth=0.75)[0];
    lines_c2.append(lobj);
                   
if scalebar != 0:
    pixel_len = (scalebar / 0.091) * sf;
    ax.hlines(10, (500 - pixel_len), 500, color='w')


def update (frame_number):
    global image_name;
    
    im_now = im[frame_number, :, :, :];
    implt.set_data(im_now);
    if stamp:
        frame_string = "Time: " + str(frame_number * time_interval) + " sec";
        frame_text.set_text(frame_string);
    if not x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == image_name), 'C1_X Value (pixel)'].size == 0:
        x_location = (x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == image_name), 'C1_X Value (pixel)'] - offset[0]) * sf;
        y_location = (x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == image_name), 'C1_Y Value (pixel)'] - offset[1]) * sf;
    else:
        x_location = np.nan;
        y_location = np.nan;
    if not x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == image_name), 'C2_X Value (pixel)'].size == 0:
        x2_location = (x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == image_name), 'C2_X Value (pixel)'] - offset[0]) * sf;
        y2_location = (x.loc[(x['C2_T Value (frame)'] == (frame_number + 1)) & (x['C2_Image'] == image_name), 'C2_Y Value (pixel)'] - offset[1]) * sf;
    else:
        x2_location = np.nan;
        y2_location = np.nan;
                   
    if not x_location.size == 0:
        data = np.stack((x_location.values, y_location.values), axis=-1)
        if marks:
            scat.set_offsets(data);
        if paths:
            x_line[frame_number - 1] = x_location;
            y_line[frame_number - 1] = y_location;
                   
    if paths:
        if frame_number > 1:
            for lnum, line in enumerate(lines_c1):
                   line.set_data(x_line[:frame_number], y_line[:frame_number]);
                   
    if not x2_location.size == 0:
        data2 = np.stack((x2_location.values, y2_location.values), axis=-1)
        if marks:
            scat2.set_offsets(data2);
        if paths:
            x2_line[frame_number - 1] = x2_location;
            y2_line[frame_number - 1] = y2_location;
                   
    if paths:
        if frame_number > 1:
            for lnum, line in enumerate(lines_c2):
                line.set_data(x2_line[:frame_number], y2_line[:frame_number]);
    
    return
                   
m = re.search('(Batch\d+_.*_XY\d+.*).tif', image);
match = m.group(1);

animation = FuncAnimation(fig, update, frames=num_frames, interval=70, repeat=True);
animation.save(match + '.mp4', writer='ffmpeg', dpi=300, bitrate=15000, fps=14);
plt.show();
