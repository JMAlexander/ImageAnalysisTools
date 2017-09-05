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
import matplotlib.pyplot as plt
import pandas as pd
import re
import argparse
from skimage import io
from matplotlib.ticker import Formatter, Locator, NullLocator, FixedLocator, NullFormatter
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib import gridspec
import matplotlib.patches as patches
from matplotlib.animation import FuncAnimation

global df;
global local_size;
global gauss_halfwidth;
global local_halfwidth;
global local_offset;


####Get Options Data #####

parser = argparse.ArgumentParser()
parser.add_argument('-d', dest="image", help='directory containing images to quantitate.  Images should be only one channel.', action='store');
parser.add_argument('-t', '--table', help='table that contains tracking data.  Should be tab-delimited for columns C1_Image\tC1_X Value (pixel)\tC1_Y Value (pixel)\tC1_T Value (pixel)');
parser.add_argument('-c', '--cutoff', type=int, default=15000, help='minimum value of Gaussian height required for Gaussian fit.');


args = parser.parse_args()

### Variables ####
image_dir = args.image
localization_table = args.table;
height_low_bound = args.cutoff;
os.chdir(image_dir);
image_list = glob.glob('*.tif');
df = pd.read_table(localization_table);
df = df.assign(Gaussian_Height = 0, Gaussian_Volume = 0, Background = 0, Norm_Height = 0);
pi = 3.14159
local_size = 15;
gauss_halfwidth = 5;
local_halfwidth = local_size / 2;
local_offset = local_halfwidth - gauss_halfwidth

output_dir = str(height_low_bound) + "_min_height/"
if not os.path.exists(output_dir):
    os.mkdir(output_dir);
else:
    print('Output directory ' + output_dir + ' already exists.');

os.chdir(output_dir);
#########ƒ
## Functions
#########



#define model function and pass independant variables x and y as a list
def twoD_Gaussian(x_data_tuple, amplitude, xo, yo, sigma_x, sigma_y, offset):
    (x, y) = x_data_tuple
    xo = float(xo)
    yo = float(yo)
    #print(xo);
    #print(yo);
    #print(offset);
    g = offset + amplitude*np.exp( - (((x-xo)/sigma_x)**2 + ((y-yo)/sigma_y)**2)/2)
            
    return g.ravel()

def update (frame_number):
    # Open Image
    global cntr;
    global locus_loc_y;
    global locus_loc_x;
    global loci
    global num_loci
    
    data = im[frame_number,:,:];
    implt.set_data(data);
    if 'cntr' in globals():
        try:
            for c in cntr.collections:
                c.remove()
        except RuntimeError:
            pass
        except ValueError:
            pass
    for n in range(0, num_loci):

        if (not df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (frame_number + 1)),'C1_Y Value (pixel)'].empty) and (not df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (frame_number + 1)),'C1_X Value (pixel)'].empty):
            locus_loc_y[n] = df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (frame_number + 1)),'C1_Y Value (pixel)'];
            locus_loc_x[n] = df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (frame_number + 1)),'C1_X Value (pixel)'];
        
        ########
        ## Gaussian Quantitation
        ########
        if (locus_loc_x[n] - local_halfwidth) < 0:
            local_x_min = 0;
            local_x_max = int(local_size)
        elif (locus_loc_x[n] + local_halfwidth) > x_size:
            local_x_min = int(x_size - local_size)
            local_x_max = x_size
        else:
            local_x_min = int(locus_loc_x[n] - local_halfwidth);
            local_x_max = int(locus_loc_x[n] + local_halfwidth);
        
        if (locus_loc_y[n] - local_halfwidth) < 0:
            local_y_min = 0;
            local_y_max = int(local_size)
        elif (locus_loc_y[n] + local_halfwidth) > y_size:
            local_y_min = int(y_size - local_size)
            local_y_max = y_size
        else:
            local_y_min = int(locus_loc_y[n] - local_halfwidth);
            local_y_max = int(locus_loc_y[n] + local_halfwidth);
                              
        local_data[frame_number,:,:] = data[local_y_min:local_y_max, local_x_min:local_x_max];
        local_max_value = local_data.max();
        local_data[frame_number,:,:] = data[local_y_min:local_y_max, local_x_min:local_x_max];
        cur_frame_local_data = local_data[frame_number, :, :];
        local_max_value = cur_frame_local_data.max();
        y_guess, x_guess = np.unravel_index(cur_frame_local_data.argmax(), cur_frame_local_data.shape);

                
        off_guess = np.median(cur_frame_local_data);
        amp_guess = local_max_value - off_guess;
        initial_guess = (amp_guess,x_guess,y_guess,1.0,1.0,off_guess);
        bound_tup = ([height_low_bound, local_offset, local_offset, 0, 0, 0], [+np.Inf, (local_size - local_offset), (local_size - local_offset), 1.6, 1.6, +np.Inf]);
        # Plot image
        roi[n].set_bounds(local_x_min, local_y_min, local_size, local_size);
        labels[n].set_position(np.stack(((local_x_min + 3), (local_y_min - 3))))

        try:
            popt, pcov = opt.curve_fit(twoD_Gaussian, (x_local,y_local), cur_frame_local_data.ravel(), p0 = initial_guess, bounds=bound_tup)
            calc_amp = popt[0]
            center_x[n] = popt[1] + local_x_min
            center_y[n] = popt[2] + local_y_min
            calc_sig_x = popt[3]
            calc_sig_y = popt[4]
            calc_offset = popt[5]
            signal = 2 * pi * calc_amp * calc_sig_x * calc_sig_y
            ### Plot contour of Gaussian

        except RuntimeError:
            center_x[n] = np.nan
            center_y[n] = np.nan

        except ValueError:
            center_x[n] = np.nan
            center_y[n] = np.nan
    
        scat_points = np.stack(([center_x], [center_y]), axis=-1)
        scat.set_offsets(scat_points)


with PdfPages('MS2_expression_plots.pdf') as pdf:
    
    
    for i in image_list:
        
        
        cur_image = i;
        print('Working on image:  ' + cur_image);
        im = io.imread(image_dir + cur_image);

        (frames, y_size, x_size) = im.shape;
        m = re.search('(Batch\d+_\d+_XY\d+).*.tif', cur_image);
        match = m.group(1);
        
        loci = df[df.C1_Image.str.contains(match)];
        uloci = loci.C1_Image.unique();
        num_loci = uloci.size;
        
        locus_ID = [None] * num_loci
        
        center_x = np.zeros(num_loci)
        center_y = np.zeros(num_loci)


        
        frame_number = 0;

        df_add = []
        roi = []
        labels = []
        global locus_loc_y;
        global locus_loc_x;
        locus_loc_y = np.zeros(num_loci);
        locus_loc_x = np.zeros(num_loci);
        local_data = np.zeros((frames, local_size, local_size), np.uint16);
        
        min_pix = np.min(im[np.nonzero(im)])
        max_pix = np.max(im[np.nonzero(im)])
        fig = plt.figure(figsize=(5,5), frameon=False);
        ax = fig.add_axes([0,0,1,1], xlim=(0,x_size), ylim=(y_size,0), aspect='equal', frameon=False);
        ax.set_axis_off();
        plt.margins(0,0)
        ax.set_frame_on(False);
        ax.set_xlim([0, x_size]);
        ax.set_ylim([y_size, 0]);
        
        
        data = im[frame_number,:,:];
        
        # Create x and y indices
        x_pixels, y_pixels = data.shape
        local_x_pixels = local_size;
        local_y_pixels = local_size;
        x_local = np.linspace(0, local_x_pixels - 1, local_x_pixels);
        x_global = np.linspace(0, x_pixels - 1, x_pixels);
        y_local = np.linspace(0, local_y_pixels - 1, local_y_pixels);
        y_global = np.linspace(0, y_pixels - 1, y_pixels);
        x_local,y_local = np.meshgrid(x_local, y_local);
        x_global,y_global = np.meshgrid(x_global, y_global);

        implt = ax.imshow(data, cmap=plt.cm.gray, vmin=min_pix, vmax=max_pix);
        for n in range(0, num_loci):
            m = re.search('Batch\d+_\d+_XY\d+_(\w+)', uloci[n])
            locus_ID[n] = m.group(1)
            
            if (df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (frame_number + 1)),'C1_Y Value (pixel)'].empty and df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (frame_number + 1)),'C1_Y Value (pixel)'].empty):
                for f in range(0, frames):
                    if (not df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (f + 1)),'C1_Y Value (pixel)'].empty) and (not df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (f + 1)),'C1_Y Value (pixel)'].empty):
                        locus_loc_y[n] = df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (f + 1)),'C1_Y Value (pixel)'];
                        locus_loc_x[n] = df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (f + 1)),'C1_X Value (pixel)'];
        
                        break
            else:
                locus_loc_y[n] = df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (frame_number + 1)),'C1_Y Value (pixel)'];
                locus_loc_x[n] = df.loc[(df['C1_Image'] == uloci[n]) & (df['C1_T Value (frame)'] == (frame_number + 1)),'C1_X Value (pixel)'];


            
            
            ########
            ## Gaussian Quantitation
            ########
            if (locus_loc_x[n] - local_halfwidth) < 0:
                local_x_min = 0;
                local_x_max = int(local_size)
            elif (locus_loc_x[n] + local_halfwidth) > x_size:
                local_x_min = int(x_size - local_size)
                local_x_max = x_size
            else:
                local_x_min = int(locus_loc_x[n] - local_halfwidth);
                local_x_max = int(locus_loc_x[n] + local_halfwidth);
    
            if (locus_loc_y[n] - local_halfwidth) < 0:
                local_y_min = 0;
                local_y_max = int(local_size)
            elif (locus_loc_y[n] + local_halfwidth) > y_size:
                local_y_min = int(y_size - local_size)
                local_y_max = y_size
            else:
                local_y_min = int(locus_loc_y[n] - local_halfwidth);
                local_y_max = int(locus_loc_y[n] + local_halfwidth);



            local_data[frame_number,:,:] = data[local_y_min:local_y_max, local_x_min:local_x_max];
            cur_frame_local_data = local_data[frame_number, :, :];
            local_max_value = cur_frame_local_data.max();
            y_guess, x_guess = np.unravel_index(cur_frame_local_data.argmax(), cur_frame_local_data.shape);
            
            off_guess = np.median(cur_frame_local_data);
            amp_guess = local_max_value - off_guess;
            initial_guess = (amp_guess,x_guess,y_guess,1.0,1.0,off_guess);
            bound_tup = ([height_low_bound, local_offset, local_offset, 0, 0, 0], [+np.Inf, (local_size - local_offset), (local_size - local_offset), 1.6, 1.6, +np.Inf]);
    
            temp_roi = ax.add_patch(patches.Rectangle((local_x_min, local_y_min), local_size, local_size, fill=False, ls='dotted', ec='yellow'));
            roi.append(temp_roi)
            temp_label = ax.text(x=(local_x_min + 3), y=(local_y_min - 3), s=locus_ID[n], color='y', fontsize=6)
            labels.append(temp_label)
            
            # Plot image
            
            try:
                popt, pcov = opt.curve_fit(twoD_Gaussian, (x_local,y_local), cur_frame_local_data.ravel(), p0 = initial_guess, bounds=bound_tup)
                calc_amp = popt[0]
                center_x[n] = popt[1] + local_x_min
                center_y[n] = popt[2] + local_y_min
                calc_sig_x = popt[3]
                calc_sig_y = popt[4]
                calc_offset = popt[5]
                signal = 2 * pi * calc_amp * calc_sig_x * calc_sig_y
                ### Plot contour of Gaussian
                
    
            except RuntimeError:
                signal = 0
                calc_amp = np.nan
                center_x[n] = np.nan
                center_y[n] = np.nan
                calc_sig_x = np.nan
                calc_sig_y = np.nan
                calc_offset = off_guess
            
            
            except ValueError:
                signal = 0
                calc_amp = np.nan
                center_x[n] = np.nan
                center_y[n] = np.nan
                calc_sig_x = np.nan
                calc_sig_y = np.nan
                calc_offset = off_guess

        scat = ax.scatter([center_x], [center_y], marker='o', facecolors = 'none', edgecolors='r', s=15, linewidth=0.5);



        animation = FuncAnimation(fig, update, frames=frames, interval=80, repeat=False);
        animation.save(cur_image + '.mp4', writer='ffmpeg', dpi=300, bitrate=24000, fps=14);
        plt.close('all');
       
        for l in uloci:

            locus_loc_y = 0;
            locus_loc_x = 0;
            local_data = np.zeros((frames, local_size, local_size), np.uint16);

            for f in range(0, frames):
                data = im[f,:,:];
                if (not df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'C1_Y Value (pixel)'].empty) and (not df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'C1_X Value (pixel)'].empty):
                    locus_loc_y = df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'C1_Y Value (pixel)'];
                    locus_loc_y = locus_loc_y.values[0];
                    locus_loc_x = df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'C1_X Value (pixel)'];
                    locus_loc_x = locus_loc_x.values[0];
                elif locus_loc_x == 0 and locus_loc_y == 0:
                    for count in range(0, frames):
                        if (not df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (count + 1)),'C1_Y Value (pixel)'].empty) and (not df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (count + 1)),'C1_Y Value (pixel)'].empty):
                            locus_loc_y = df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (count + 1)),'C1_Y Value (pixel)'];
                            locus_loc_y = locus_loc_y.values[0];
                            locus_loc_x = df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (count + 1)),'C1_X Value (pixel)'];
                            locus_loc_x = locus_loc_x.values[0];

                            break
                if df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),].empty:
                    df = df.append(pd.DataFrame([[l, np.nan, np.nan, (f + 1), 0, 0, 0, 0]], columns=('C1_Image', 'C1_X Value (pixel)', 'C1_Y Value (pixel)', 'C1_T Value (frame)', 'Gaussian_Height', 'Gaussian_Volume', 'Background', 'Norm_Height')));
                ########
                ## Gaussian Quantitation
                ########
                if (locus_loc_x - local_halfwidth) < 0:
                    local_x_min = 0;
                    local_x_max = int(local_size)
                elif (locus_loc_x + local_halfwidth) > x_size:
                    local_x_min = int(x_size - local_size)
                    local_x_max = x_size
                else:
                    local_x_min = int(locus_loc_x - local_halfwidth);
                    local_x_max = int(locus_loc_x + local_halfwidth);
                                                    
                if (locus_loc_y - local_halfwidth) < 0:
                    local_y_min = 0;
                    local_y_max = int(local_size)
                elif (locus_loc_y + local_halfwidth) > y_size:
                    local_y_min = int(y_size - local_size)
                    local_y_max = y_size
                else:
                    local_y_min = int(locus_loc_y - local_halfwidth);
                    local_y_max = int(locus_loc_y + local_halfwidth);
                                      

                local_data[f,:,:] = data[local_y_min:local_y_max, local_x_min:local_x_max];
                cur_frame_local_data = local_data[f,:,:];
                local_max_value = cur_frame_local_data.max();
                y_guess, x_guess = np.unravel_index(cur_frame_local_data.argmax(), cur_frame_local_data.shape);
                
                off_guess = np.median(cur_frame_local_data);
                amp_guess = local_max_value - off_guess;
                initial_guess = (amp_guess,x_guess,y_guess,1.0,1.0,off_guess);
                bound_tup = ([height_low_bound, local_offset, local_offset, 0, 0, 0], [+np.Inf, (local_size - local_offset), (local_size - local_offset), 1.6, 1.6, +np.Inf]);


                # Plot image
                
                try:
                    popt, pcov = opt.curve_fit(twoD_Gaussian, (x_local,y_local), cur_frame_local_data.ravel(), p0 = initial_guess, bounds=bound_tup)
                    calc_amp = popt[0]
                    center_x = popt[1]
                    center_y = popt[2]
                    calc_sig_x = popt[3]
                    calc_sig_y = popt[4]
                    calc_offset = popt[5]
                    signal = 2 * pi * calc_amp * calc_sig_x * calc_sig_y
                    ### Plot contour of Gaussian
                    data_fitted = twoD_Gaussian((x_local, y_local), *popt)

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
        
                df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'Gaussian_Height'] = calc_amp;
                df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'Gaussian_Volume'] = signal;
                df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'Background'] = calc_offset;
                signal_add = np.mean(data[(local_y_min + 1):(local_y_max - 1), (local_x_min + 1):(local_x_max - 1)])
                df_add.append(signal_add)
                    
            normalization_factor = np.median(local_data)
            for f in range(0, frames):
                df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'Norm_Height'] = (df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'Gaussian_Height'] + df.loc[(df['C1_Image'] == l) & (df['C1_T Value (frame)'] == (f + 1)),'Background']) / normalization_factor;
                
                
                #########
                ## Total Intensity Quantitation
                ########
                
            
            
            df.sort_values(['C1_Image', 'C1_T Value (frame)'], inplace=True);
            graph = plt.figure()
            gs  = gridspec.GridSpec(1, 2)
            ax1 = graph.add_subplot(gs[0])
            ax1.plot(df_add)
            plt.title('Local Mean MS2cp Signal\n' + match)
            plt.xlabel('Time (frames)')
            plt.ylabel('MS2cp Signal (Mean Local Pixel Value Near Max)')
            plt.ylim(5000, 50000)
            for item in ([ax1.title, ax1.xaxis.label, ax1.yaxis.label] +
                         ax1.get_xticklabels() + ax1.get_yticklabels()):
                            item.set_fontsize(8)
            ax2 = graph.add_subplot(gs[1])
            ax2.plot(df.loc[df.C1_Image == l, ['C1_T Value (frame)']], df.loc[df.C1_Image == l, ['Norm_Height']])
            plt.title('Gaussian Estimate of MS2cp Signal\n' + l)
            plt.xlabel('Time (frames)')
            plt.ylabel('MS2cp Signal (Height off Fit Gaussian (a.u.)')
            plt.ylim(0,5)
            graph.subplots_adjust(left=0.1, right=0.95, top=0.75, bottom = 0.25, wspace=0.4)
            for item in ([ax2.title, ax2.xaxis.label, ax2.yaxis.label] + ax2.get_xticklabels() + ax2.get_yticklabels()):
                item.set_fontsize(8)
            pdf.savefig(graph);
            plt.close('graph');



out_file = image_dir + '/' + output_dir + 'MS2cp-signaldata_2dgaussfit.txt';
df.to_csv(out_file, sep='\t', na_rep='NA', index=False);
pdf.close;

