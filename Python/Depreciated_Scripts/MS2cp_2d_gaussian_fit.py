# -*- coding: utf-8 -*-
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
from PIL import Image
from matplotlib.ticker import Formatter, Locator, NullLocator, FixedLocator, NullFormatter
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib import gridspec
from pims import ImageSequence

####Get Options Data #####

parser = argparse.ArgumentParser()
parser.add_argument('-d', dest="dir", help='directories containing folders with image sequences to quantitate', action='store')
    
args = parser.parse_args()

### Variables ####
image_dir = args.dir
image_dir = '/Users/Jeff/Desktop/Test/';
if not image_dir.endswith('/'):
	image_dir = image_dir + '/';
os.chdir(image_dir);
folder_list = filter(os.path.isdir, os.listdir(image_dir))
df = pd.DataFrame(columns=('Image_Name', 'T_Value (frame)', 'Gaussian_Height', 'Gaussian_Volume', 'Background', 'X_Loc (pixel)', 'Y_Loc (pixel)'))


for folder in folder_list:
    os.chdir(image_dir)
    os.chdir(folder)
    print(os.getcwd());
    file_header = re.search('Batch\d+_\d+_XY\d+_cropped_singlet\d+', folder).string
    pi = 3.14159


    
    #########
    ## Functions
    #########
    

    
    #Sort the given iterable in the way that humans expect.
    def sorted_nicely( l ): 
        convert = lambda text: int(text) if text.isdigit() else text 
        alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
        return sorted(l, key = alphanum_key)
    
    #define model function and pass independant variables x and y as a list
    def twoD_Gaussian(x_data_tuple, amplitude, xo, yo, sigma_x, sigma_y, offset):
        (x, y) = x_data_tuple
        xo = float(xo)
        yo = float(yo)    
        g = offset + amplitude*np.exp( - (((x-xo)/sigma_x)**2 + ((y-yo)/sigma_y)**2)/2)
    
        return g.ravel()
    
    try:
        os.stat('fit_images')
    except:
        os.mkdir('fit_images')
    im = ImageSequence('./*.tif')
    im_height, im_width = im[0].shape
    bound_tup = ([15, 5, 5, 0, 0, 0], [+np.Inf, (im_height - 5), (im_width - 5), 1.6, 1.6, +np.Inf])
    
    
    df_add = []
    
    min_pix = np.min(im)
    max_pix = np.max(im)
    
    
    for cur_frame in im:
        # Open Image
        print('Frame: ' + str(cur_frame.frame_no))
        data = cur_frame
        
        # Create x and y indices
        x_pixels, y_pixels = data.shape
        x = np.linspace(0, x_pixels - 1, x_pixels)
        y = np.linspace(0, y_pixels - 1, y_pixels)
        x,y = np.meshgrid(x, y)
        
        ########
        ## Gaussian Quantitation
        ########
        y_guess, x_guess = np.unravel_index(data.argmax(), data.shape)
        local_y_min = y_guess - 5
        if local_y_min < 0:
            local_y_min = 0
        local_y_max = y_guess + 5
        if local_y_max > data.shape[0]:
            local_y_max = data.shape[0]
        
        local_x_min = x_guess - 5
        if local_x_min < 0:
            local_x_min = 0
        local_x_max = x_guess + 5
        if local_x_max > data.shape[0]:
            local_x_max = data.shape[0]
            
        local_data = data[local_y_min:local_y_max, local_x_min:local_x_max]
        off_guess = np.median(local_data)
        amp_guess = np.max(data) - off_guess
        initial_guess = (amp_guess,x_guess,y_guess,1.5,1.5,off_guess)
    
        # Plot image
        
        fig, ax = plt.subplots(1, 1)
        plt.gca().set_axis_off()
        plt.subplots_adjust(top =1, bottom = 0, right =1, left = 0, hspace = 0, wspace = 0)
        plt.margins(0,0)
        plt.gca().xaxis.set_major_locator(NullLocator())
        plt.gca().yaxis.set_major_locator(NullLocator())    
        ax.hold(True)
        ax.set_axis_off()
        ax.imshow(data, cmap=plt.cm.jet, origin='top',
        extent=(x.min(), x.max(), y.min(), y.max()), vmin=min_pix, vmax=max_pix ) ##Change this to reflect image stack min max
        
        
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
            ax.contour(x, y, data_fitted.reshape(x_pixels, y_pixels), 8, colors='w')
           
        except RuntimeError:
            signal = 0
            calc_amp = np.nan
            center_x = np.nan
            center_y = np.nan
            calc_sig_x = np.nan
            calc_sig_y = np.nan
            calc_offset = np.nan
            
        except ValueError:
            signal = 0
            signal = 0
            calc_amp = np.nan
            center_x = np.nan
            center_y = np.nan
            calc_sig_x = np.nan
            calc_sig_y = np.nan
            calc_offset = np.nan
            
        
        #plt.show()
        fig.savefig('./fit_images/' + file_header + '_' + str(cur_frame.frame_no + 1) + '.tif', bbox_inches="tight", pad_inches=0, format="png")
        
        df2 = pd.DataFrame([[file_header, int(cur_frame.frame_no + 1), calc_amp, signal, calc_offset, center_x, center_y]], columns=('Image_Name', 'T_Value (frame)', 'Gaussian_Height', 'Gaussian_Volume', 'Background', 'X_Loc (pixel)', 'Y_Loc (pixel)'))    
        df = df.append(df2, ignore_index=True)
       
        
        
        #########
        ## Total Intensity Quantitation
        ########
        
        signal_add = np.mean(data[(local_y_min + 1):(local_y_max - 1), (local_x_min + 1):(local_x_max - 1)])
        df_add.append(signal_add)

    with PdfPages(file_header + '_MS2_signal.pdf') as pdf:

        graph = plt.figure()
        gs  = gridspec.GridSpec(1, 2)
        ax1 = graph.add_subplot(gs[0])
        ax1.plot(df_add)
        plt.title('Local Mean MS2cp Signal\n' + file_header)
        plt.xlabel('Time (frames)')
        plt.ylabel('MS2cp Signal (Mean Local Pixel Value Near Max)')
        plt.ylim(400, 525)
        for item in ([ax1.title, ax1.xaxis.label, ax1.yaxis.label] +
               ax1.get_xticklabels() + ax1.get_yticklabels()):
                   item.set_fontsize(8)
        ax2 = graph.add_subplot(gs[1])
        ax2.plot(df.loc[df.Image_Name == file_header, ['T_Value (frame)']], df.loc[df.Image_Name == file_header, ['Gaussian_Volume']])
        plt.title('Gaussian Estimate of MS2cp Signal\n' + file_header)
        plt.xlabel('Time (frames)')
        plt.ylabel('MS2cp Signal (Volume under Fit Gaussian (a.u.)')
        plt.ylim(0,1800)
        graph.subplots_adjust(left=0.1, right=0.95, top=0.75, bottom = 0.25, wspace=0.4)
        for item in ([ax2.title, ax2.xaxis.label, ax2.yaxis.label] +
               ax2.get_xticklabels() + ax2.get_yticklabels()):
                   item.set_fontsize(8)
        pdf.savefig()

out_file = image_dir + 'MS2cp-signaldata_2dgaussfit.txt';   
df.to_csv(out_file, sep='\t', na_rep='NA', index=False)
