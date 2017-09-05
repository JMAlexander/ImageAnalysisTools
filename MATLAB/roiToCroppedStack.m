

%% roiToCroppedStacks

%%%% Converts a list of ROIs of singlets into a folder of cropped image
%%%% stacks ready for Trackmate analysis

addpath('/Users/Jeff/Scripts/MATLAB');
addpath('/Applications/Fiji.app/scripts');
javaaddpath(which('MatlabGarbageCollector.jar'));
Miji;

roi_folder = '/Users/Jeff/Desktop/05_27_16_Batch06/TrackMate/Batch06_cropped/';
image_folder = '/Users/Jeff/Desktop/05_27_16_Batch06/';

crop_dir = strcat(image_folder, '/Cropped_Images');
mkdir(crop_dir);

cd(roi_folder);
dir_list = dir('*.roi');
roi_list = {dir_list.name};

cd(image_folder);
dir_list=dir('*.tif');
image_list={dir_list.name};

for i = 1:size(image_list, 2)
    imp = [];
    jheapcl;
    match_roi = {};
    match_count = 1;
    cur_image = char(image_list(i));
    reg_tok = regexp(cur_image, '(Batch\d+_\d+_XY\d{2}).*.tif', 'tokens');
    match = char(reg_tok{:});
    
    for j = 1:size(roi_list, 2)
        cur_roi = roi_list(j);
        if strfind(char(cur_roi), match)
           match_roi(match_count) = cur_roi;
           match_count += 1;
           
        end
    end
    
    match_size = size(match_roi, 2);
    if (match_size >= 1)
        image_path = strcat(image_folder, '/', cur_image);
        imp = ij.io.Opener.openUsingBioFormats(image_path);
        imp.show();
        for k = 1:size(match_roi, 2)
            ij.IJ.selectWindow(cur_image);
            cur_match_roi = char(match_roi(k));
            reg_tok = regexp(cur_match_roi, '(Batch\d+_\d+_XY\d{2}_cropped_singlet\d+).roi', 'tokens');
            crop_name = char(reg_tok{:});
            roi_path =strcat(roi_folder, '/', cur_match_roi);
            ij.IJ.open(roi_path);
            temp_str = strcat('title=', crop_name, '.tif duplicate');
            ij.IJ.run('Duplicate...', temp_str);
            imp_cropped = ij.IJ.getImage();
            save_name = strcat(crop_dir, '/', crop_name, '.tif');
            ij.IJ.saveAsTiff(imp_cropped, save_name);
        end
        ij.IJ.run('Close All');
    end
 end
    
ij.IJ.run('Close All');