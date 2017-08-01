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
parser.add_argument('-d', '--data', help='a file that contains tracking data files for the images to process.  Should have the follows columns: C1_Image\tC1_X Value (pixel)\tC1_Y Value (pixel)\tC1_T Value (frame)\tC2_Image\tC2_X Value (pixel)\tC2_Y Value (pixel)\tC2_Z Value (frame)\tCorrected XY_Distance (um)');
parser.add_argument('-f', '--frames', type=int, default=100, help='number of time frames in image stacks');
parser.add_argument('-t', '--time', type=int, default=20, help='time interval between frames. Default value: 20s')
parser.add_argument('-c', '--combined', action='store_true', default=False, help='graph multiple tracked pairs on image.  Images should be cropped to each ROI.');



arg = parser.parse_args();

data_file = arg.data;
num_frames = arg.frames;
time_interval = arg.time;
combined = arg.combined;

x = pd.read_table(data_file);


frame_number = 0;

singlets = x.C1_Image.unique();
print(singlets)

fig = plt.figure(figsize=(4,2), facecolor='black');
ax = fig.add_axes([0.15,0.15,0.7,0.7], xlim=(0,512), ylim=(512,0), facecolor='none');
plt.margins(0,0)
ax.set_xlim([0, num_frames * time_interval]);
ax.set_ylim([0, 1]);
ax.spines['bottom'].set_color('white')
ax.spines['left'].set_color('white')
ax.spines['top'].set_color('none')
ax.spines['right'].set_color('none')
ax.xaxis.label.set_color('white')
ax.set_ylabel('XY Distance (um)')
ax.yaxis.label.set_color('white')
ax.tick_params(axis='x', colors='white')
ax.tick_params(axis='y', colors='white')





num_singlets = singlets.size;
time = np.full(num_singlets, np.nan);
dist = np.full(num_singlets, np.nan);


for j in range(0,num_singlets):
    time[j] = frame_number * time_interval

    if not x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'Corrected XY_Distance (um)'].size == 0:
        dist[j] = x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'Corrected XY_Distance (um)']
    else:
        dist[j] = np.nan;
    
scat = ax.scatter([time], [dist], marker='o', c='#F4E85A');
x_line = np.full((num_singlets, num_frames), np.nan)
y_line = np.full((num_singlets, num_frames), np.nan)
lines = []
for j in range(0,num_singlets):
    lobj = ax.plot([], [], c='#F4EA9D', linewidth=0.75)[0];
    lines.append(lobj);


def update (frame_number):
    for j in range(0,num_singlets):
        time[j] = frame_number * time_interval
        if not x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'Corrected XY_Distance (um)'].size == 0:
            dist[j] = x.loc[(x['C1_T Value (frame)'] == (frame_number + 1)) & (x['C1_Image'] == singlets[j]), 'Corrected XY_Distance (um)'];
        else:
            dist[j] = np.nan;


    if not dist.size == 0:
        data = np.stack(([time], [dist]), axis=-1)
        scat.set_offsets(data);
        x_line[:, frame_number] = time;
        y_line[:, frame_number] = dist;

    for lnum, line in enumerate(lines):
        line.set_data(x_line[lnum, :frame_number + 1], y_line[lnum, :frame_number + 1]);
    return

m = re.search('(Batch\d+_.*_XY\d+.*)', singlets[0]);
match = m.group(1);
animation = FuncAnimation(fig, update, interval=frame_number);
animation.save(match + '.mp4', writer='ffmpeg', dpi=300, bitrate=15000, fps=14, savefig_kwargs={'facecolor':'black'});
plt.show();
