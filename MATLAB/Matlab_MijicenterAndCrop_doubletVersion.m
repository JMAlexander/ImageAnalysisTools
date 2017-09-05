%% Puncta Tracking in Matlab using Fiji
%% Images should be cropped to containing 1-2 pairs of spots only.


% Initialize Variables
clc;
image_directory = '/Users/Jeff/Desktop/Batch07_doublets/Cropped_Images/MaxProj/';  %% Set the image directory with the images with spots to track are
output_folder = strcat(image_directory, 'Centered_Stacks/');
localization_table ='/Users/Jeff/Desktop/Batch07_doublets/Cropped_Images/MaxProj/tracked_values.txt';  %% Should have columns C1_Image \t C2_X Value (pixel) \t C2_Y Value (pixel) \t C2_T Value (frame)\n
dat = readtable(localization_table);
dat.C2_TValue_frame_ = dat.C2_TValue_frame_
dat_images = unique(dat.C2_Image);
time_length = 100;

%% Configure Matlab and Start Fiji
addpath('/Users/Jeff/Scripts/MATLAB');
addpath('/Applications/Fiji.app/scripts')

%% Configure Scripts for Resetting Java Memory Heap
javaaddpath(which('MatlabGarbageCollector.jar'));
Miji;

%% Run Trackmate through Miji
%% This script version with automatically set the quality filter values to pass no more than 500 spots to track detection.
cd(image_directory);
mkdir(output_folder);
dir_images = dir('*.tif');
last_match = 1;


for count = 1:size(dir_images,1)
    file_name = dir_images(count).name;
    reg_tok = regexp(file_name, '(Batch\d+_\d+_XY\d{2}_doublet\d+)_MaxZProj.tif', 'tokens');
    match = char(reg_tok{:});

    for j = 1:size(dat_images,1)
        last_match = 1;
        cur_image = dat_images(j,:);
        if strfind(char(cur_image), match)

        
        imp = ij.IJ.openImage(strcat(image_directory,file_name));
        %imp = ij.io.Opener.openUsingBioFormats(strcat(image_directory,file_name));
        imp.show();
        %ij.IJ.run('Z Project...', 'projection=[Max Intensity] all');
        imp_max = ij.IJ.getImage();
        imp_max.show();
        dim = imp_max.getDimensions();
        height_pixels = dim(1,1);
        width_pixels = dim(2,1);
        nChannels = dim(3,1);
        nSlices = dim(4,1);
        nFrames = dim(5,1);
    
    
        if (nSlices ~= 1)
            disp('Use MaxZ Projections only!');
            return;
        end
        
        image_folder = strcat(output_folder, char(cur_image), '/');
        mkdir(image_folder);
        rows = strcmp(dat.C2_Image, cur_image);
                temp_table = dat(rows,:);
                for k = 1:time_length
                    if any(temp_table.C2_TValue_frame_==k)
                        for l = 1:size(temp_table,1)
                            if table2array(temp_table(l,'C2_TValue_frame_'))==k
                                last_match = l;
                                
                                %%%%%% Run ImageJ functions %%%%%
                                x_value = round(table2array(temp_table(l, 'C2_XValue_pixel_')) - 16);
                                if x_value < 0
                                   x_value = 0;
                                elseif x_value > (width_pixels - 32)
                                   x_value = width_pixels - 32;
                                end
                            
                                y_value = round(table2array(temp_table(l, 'C2_YValue_pixel_')) - 16);
                                if y_value < 1
                                   y_value = 1;
                                elseif y_value > (height_pixels - 32)
                                   y_value = height_pixels - 32;
                                end
                                
                                ij.IJ.makeRectangle(x_value, y_value, 32, 32);
                                cur_image_name = strcat(cur_image, '_z', num2str(k), '.tif');
                                duplicate_str = strcat('title=', cur_image_name, ' duplicate frames=', num2str(k));
                                %duplicate_str = strcat('title=', cur_image_name, ' duplicate range=', num2str(k), '-', num2str(k));
                                ij.IJ.run('Duplicate...', duplicate_str);
                                ij.IJ.saveAs('Tiff', strcat(image_folder , cur_image_name));
                                ij.IJ.run('Close');

                            end
                        end
                    else
                        x_value = round(table2array(temp_table(last_match, 'C2_XValue_pixel_')) - 16);
                        if x_value < 0
                           x_value = 0;
                        elseif x_value > (width_pixels - 32)
                           x_value = width_pixels - 32;
                        end
                        y_value = round(table2array(temp_table(last_match, 'C2_YValue_pixel_')) - 16);
                        if x_value < 0
                           x_value = 0;
                        elseif x_value > (width_pixels - 32)
                           x_value = width_pixels - 32;
                        end
                        ij.IJ.makeRectangle(x_value, y_value, 32, 32);
                        cur_image_name = strcat(cur_image, '_z', num2str(k), '.tif');
                        %duplicate_str = strcat('title=', cur_image_name, ' duplicate range=', num2str(k), '-', num2str(k));
                        duplicate_str = strcat('title=', cur_image_name, ' duplicate frames=', num2str(k));
                        ij.IJ.run('Duplicate...', duplicate_str);
                        ij.IJ.saveAs('Tiff', strcat(image_folder , cur_image_name));
                        ij.IJ.run('Close');
                    end
                end
        end
    end

ij.IJ.run('Close All');
jheapcl;
end