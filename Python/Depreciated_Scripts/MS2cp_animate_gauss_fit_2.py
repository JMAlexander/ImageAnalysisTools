# -*- coding: utf-8 -*-
get_ipython().magic('matplotlib')

"""
    Created on Wed Aug 24 20:38:36 2016
    
    @author: Jeff
    """

import os
import os.path
import glob
import scipy.optimize as opt
import scipy.integrate as integrate
import numpy as np
import pylab as plt
import pandas as pd
import re
import argparse
from skimage import io
from matplotlib.ticker import Formatter, Locator, NullLocator, FixedLocator, NullFormatter
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib import gridspec
from matplotlib.animation import FuncAnimation
from pims import ImageSequence

global df;


####Get Options Data #####

parser = argparse.ArgumentParser()
parser.add_argument('-d', dest="image", help='directory containing images to quantitate.  Images should be only one channel.', action='store');
parser.add_argument('-t', '--table', help='table that contains tracking data.  Should be tab-delimited for columns C1_Image\tC1_X Value (pixel)\tC1_Y Value (pixel)\tC1_T Value (pixel)');

args = parser.parse_args()

### Variables ####
image_dir = args.image
localization_table = args.table;
os.chdir(image_dir);
image_list = glob.glob('*.tif');
df = pd.read_table(localization_table);
df = df.assign(Gaussian_Height = 0, Gaussian_Volume = 0, Background = 0, Norm_Height = 0);

#########
## Functions
#########



#define model function and pass independant variables x and y as a list
def twoD_Gaussian(x_data_tuple, amplitude, xo, yo, sigma_x, sigma_y, offset):
    (x, y) = x_data_tuple
    xo = float(xo)
    yo = float(yo)
    g = offset + amplitude*np.exp( - (((x-xo)/sigma_x)**2 + ((y-yo)/sigma_y)**2)/2)
            
    return g.ravel()

with PdfPages('MS2_signal_test.pdf') as pdf:
    
    
    for i in image_list:
        
        frame_number = 0;
        cur_image = i;
        print('Working on image:  ' + cur_image);
        im = io.imread(cur_image);
        normalization_factor = np.median(im);

        (frames, y_size, x_size) = im.shape;
        m = re.search('(Batch\d+_\d+_XY\d+.*\d+).*.tif', cur_image);
        match = m.group(1);
        pi = 3.14159
        
        bound_tup = ([12500, 11, 11, 0, 0, 0], [+np.Inf, (y_size - 11), (x_size - 11), 1.6, 1.6, +np.Inf])
        
        df_add = []
        
        min_pix = np.min(im[np.nonzero(im)])
        max_pix = np.max(im[np.nonzero(im)])
        fig = plt.figure(figsize=(5,5), frameon=False);
        ax = fig.add_axes([0,0,1,1], xlim=(0,x_size), ylim=(y_size,0), aspect='equal', frameon=False);
        ax.set_axis_off();
        plt.margins(0,0)
        ax.set_frame_on(False);
        ax.set_xlim([0, x_size]);
        ax.set_ylim([y_size, 0]);
        
        
        data = im[0,:,:];
        # Create x and y indices
        x_pixels, y_pixels = data.shape
        x = np.linspace(0, x_pixels - 1, x_pixels)
        y = np.linspace(0, y_pixels - 1, y_pixels)
        x,y = np.meshgrid(x, y)
        implt = plt.imshow(data, cmap=plt.cm.jet, vmin=min_pix, vmax=max_pix);
        blank_contour = np.ones((x_pixels, y_pixels))
        
        
        ########
        ## Gaussian Quantitation
        ########
        local_x_min = 11;
        local_x_max = x_size - 11;
        local_y_min = 11;
        local_y_max = y_size - 11;
        local_data = data[local_y_min:local_y_max, local_x_min:local_x_max]
        local_max_value = local_data.max();
        
        (max_y_place, max_x_place) = np.where(data == local_max_value);
        y_guess = max_y_place[0];
        x_guess = max_x_place[0];
        
        off_guess = np.median(local_data);
        amp_guess = local_max_value - off_guess;
        initial_guess = (amp_guess,x_guess,y_guess,1.0,1.0,off_guess);
        
        # Plot image
        
        try:
            popt, pcov = opt.curve_fit(twoD_Gaussian, (x,y), data.ravel(), p0 = initial_guess, bounds=bound_tup)
            calc_amp = popt[0]
            center_x = popt[1]
            center_y = popt[2]
            calc_sig_x = popt[3]
            calc_sig_y = popt[4]
            calc_offset = popt[5]
            signal = 2 * pi * calc_amp * calc_sig_x * calc_sig_y
            ### Plot contour of Gaussian
            data_fitted = twoD_Gaussian((x, y), *popt)
            cntr = ax.contour(x, y, data_fitted.reshape(x_pixels, y_pixels), 8, colors='w', linewidths=2)
        
        except RuntimeError:
            signal = 0
            calc_amp = np.nan
            center_x = np.nan
            center_y = np.nan
            calc_sig_x = np.nan
            calc_sig_y = np.nan
            calc_offset = off_guess
            cntr = ax.contour(x, y, blank_contour, 8, colors='w')
        
        
        
        except ValueError:
            signal = 0
            calc_amp = np.nan
            center_x = np.nan
            center_y = np.nan
            calc_sig_x = np.nan
            calc_sig_y = np.nan
            calc_offset = off_guess
            cntr = ax.contour(x, y, blank_contour, 8, colors='w')



        def update (frame_number):
            # Open Image
            global cntr
            
            data = im[frame_number,:,:];
            implt.set_data(data);
            
            
            try:
                for c in cntr.collections:
                    c.remove()
            except RuntimeError:
                print('No Gaussian match');
            except ValueError:
                print('No Gaussian match');
            ########
            ## Gaussian Quantitation
            ########
            local_x_min = 11;
            local_x_max = x_size - 11;
            local_y_min = 11;
            local_y_max = y_size - 11;
            local_data = data[local_y_min:local_y_max, local_x_min:local_x_max]
            local_max_value = local_data.max();
        
            (max_y_place, max_x_place) = np.where(data == local_max_value);
            y_guess = max_y_place[0];
            x_guess = max_x_place[0];
            local_y_min = y_guess - 5
        
            off_guess = np.median(local_data)
            amp_guess = local_max_value - off_guess
            initial_guess = (amp_guess,x_guess,y_guess,1.0,1.0,off_guess)
            
            # Plot image
            
            try:
                popt, pcov = opt.curve_fit(twoD_Gaussian, (x,y), data.ravel(), p0 = initial_guess, bounds=bound_tup)
                calc_amp = popt[0]
                center_x = popt[1]
                center_y = popt[2]
                calc_sig_x = popt[3]
                calc_sig_y = popt[4]
                calc_offset = popt[5]
                signal = 2 * pi * calc_amp * calc_sig_x * calc_sig_y
                ### Plot contour of Gaussian
                data_fitted = twoD_Gaussian((x, y), *popt)
                cntr = ax.contour(data_fitted.reshape(x_pixels, y_pixels), 8, colors='w', linewidths=2)

            except RuntimeError:
                signal = 0
                calc_amp = 0
                center_x = np.nan
                center_y = np.nan
                calc_sig_x = np.nan
                calc_sig_y = np.nan
                calc_offset = off_guess
            
            except ValueError:
                signal = 0
                calc_amp = 0
                center_x = np.nan
                center_y = np.nan
                calc_sig_x = np.nan
                calc_sig_y = np.nan
                calc_offset = off_guess
    
    
            return cntr
        
        animation = FuncAnimation(fig, update, frames=frames, interval=80, repeat=False);
        animation.save(match + '.mp4', writer='ffmpeg', dpi=300, bitrate=12000, fps=14);
        plt.close('all')
        for f in range(0, frames):
            
            if df.loc[(df['C1_Image'] == match) & (df['C1_T Value (frame)'] == (f + 1)),].empty:
                df = df.append(pd.DataFrame([[match, np.nan, np.nan, (f + 1), 0, 0, 0, 0]], columns=('C1_Image', 'C1_X Value (pixel)', 'C1_Y Value (pixel)', 'C1_T Value (frame)', 'Gaussian_Height', 'Gaussian_Volume', 'Background', 'Norm_Height')));
            
            data = im[f,:,:];
            
            ########
            ## Gaussian Quantitation
            ########
            local_x_min = 11;
            local_x_max = x_size - 11;
            local_y_min = 11;
            local_y_max = y_size - 11;
            local_data = data[local_y_min:local_y_max, local_x_min:local_x_max]
            local_max_value = local_data.max();
            
            (max_y_place, max_x_place) = np.where(data == local_max_value);
            y_guess = max_y_place[0];
            x_guess = max_x_place[0];
            
            off_guess = np.median(local_data)
            amp_guess = local_max_value - off_guess
            initial_guess = (amp_guess,x_guess,y_guess,1.0,1.0,off_guess)
            
            # Plot image
            
            try:
                popt, pcov = opt.curve_fit(twoD_Gaussian, (x,y), data.ravel(), p0 = initial_guess, bounds=bound_tup)
                calc_amp = popt[0]
                center_x = popt[1]
                center_y = popt[2]
                calc_sig_x = popt[3]
                calc_sig_y = popt[4]
                calc_offset = popt[5]
                signal = 2 * pi * calc_amp * calc_sig_x * calc_sig_y
                ### Plot contour of Gaussian
                data_fitted = twoD_Gaussian((x, y), *popt)

            except RuntimeError:
                signal = 0
                calc_amp = 0
                center_x = np.nan
                center_y = np.nan
                calc_sig_x = np.nan
                calc_sig_y = np.nan
                calc_offset = off_guess
            
            except ValueError:
                signal = 0
                calc_amp = 0
                center_x = np.nan
                center_y = np.nan
                calc_sig_x = np.nan
                calc_sig_y = np.nan
                calc_offset = off_guess
    
    
            df.loc[(df['C1_Image'] == match) & (df['C1_T Value (frame)'] == (f + 1)),'Gaussian_Height'] = calc_amp;
            df.loc[(df['C1_Image'] == match) & (df['C1_T Value (frame)'] == (f + 1)),'Gaussian_Volume'] = signal;
            df.loc[(df['C1_Image'] == match) & (df['C1_T Value (frame)'] == (f + 1)),'Background'] = calc_offset;
            df.loc[(df['C1_Image'] == match) & (df['C1_T Value (frame)'] == (f + 1)),'Norm_Height'] = (calc_amp + calc_offset) / normalization_factor;
            
            
            #########
            ## Total Intensity Quantitation
            ########
            
            signal_add = np.mean(data[(local_y_min + 1):(local_y_max - 1), (local_x_min + 1):(local_x_max - 1)])
            df_add.append(signal_add)
        
        df.sort_values(['C1_Image', 'C1_T Value (frame)'], inplace=True);
        graph = plt.figure()
        gs  = gridspec.GridSpec(1, 2)
        ax1 = graph.add_subplot(gs[0])
        ax1.plot(df_add)
        plt.title('Local Mean MS2cp Signal\n' + match)
        plt.xlabel('Time (frames)')
        plt.ylabel('MS2cp Signal (Mean Local Pixel Value Near Max)')
        plt.ylim(400, 525)
        for item in ([ax1.title, ax1.xaxis.label, ax1.yaxis.label] +
                     ax1.get_xticklabels() + ax1.get_yticklabels()):
                        item.set_fontsize(8)
        ax2 = graph.add_subplot(gs[1])
        print(match)
        print(df.loc[df.C1_Image == match, ['C1_T Value (frame)']])
        ax2.plot(df.loc[df.C1_Image == match, ['C1_T Value (frame)']], df.loc[df.C1_Image == match, ['Norm_Height']])
        plt.title('Gaussian Estimate of MS2cp Signal\n' + match)
        plt.xlabel('Time (frames)')
        plt.ylabel('MS2cp Signal (Height off Fit Gaussian (a.u.)')
        plt.ylim(0,5)
        graph.subplots_adjust(left=0.1, right=0.95, top=0.75, bottom = 0.25, wspace=0.4)
        for item in ([ax2.title, ax2.xaxis.label, ax2.yaxis.label] + ax2.get_xticklabels() + ax2.get_yticklabels()):
            item.set_fontsize(8)
        pdf.savefig(graph);
        plt.close('graph');



out_file = image_dir + 'MS2cp-signaldata_2dgaussfit.txt';   
df.to_csv(out_file, sep='\t', na_rep='NA', index=False);
pdf.close;

