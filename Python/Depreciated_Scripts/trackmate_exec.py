import sys
import os
import argparse
import glob
import time
import re
import java.util.HashMap
from PIL import Image

plugin_jars=os.listdir("/Applications/Fiji.app/plugins")
jarfold_jars=os.listdir("/Applications/Fiji.app/jars")

for i in plugin_jars:
	add_jar = "/Applications/Fiji.app/plugins/" + i
	sys.path.append(add_jar)

for i in jarfold_jars:
	add_jar = "/Applications/Fiji.app/jars/" + i
	sys.path.append(add_jar)


from ij.io import Opener
import fiji.plugin.trackmate
from ij import IJ, ImagePlus, ImageJ


parser = argparse.ArgumentParser()
parser.add_argument('-i', '—image_dir', help='a directory that contains all the images for processing)
parser.add_argument('-r', '—roi_dir', help='a directory that contains all annotated ROIs')
parser.add_argument('-f', '-frames', help='number of frames in image stacks to be analyzed')
parser.add_argument('-b', '-batch', help='current batch of files to be analyzed (e.g. Batch23).  Used to create basenames for output files.')
parser.add_argument('-m', '-merge', action='store_true', default=False, help='allow merge of tracks?')
arg = parser.parse_args();

##Initialize Variables
output_text = arg.batch + ".txt"
max_frames = arg.frames
start_quality_value = 50000
track_filter_value = 10
radius_value = 2.5
linking_distance = 20
gap_closing_distance = 30
max_gap_closing_frames = java.lang.Integer(3)
spot_cutoff = max_frames + max_frames * 0.2
allow_merging = arg.merge
image_directory = arg.image_dir;
roi_directory = arg.roi_dir;
print("Image Directory:  " + image_directory);
print("ROI Directory:  " + roi_directory);
print("Number of Frames:  " + max_frames);
print("Batch:  " + arg.batch)
print("Allow Track Merging:  " + allow_merging)

                    ## Create Settings Object
def fillTrackMateSettings(image, channel):

    ### Passed variables
    global track_filter_value
    global start_quality_value
    global allow_merging
    global gap_closing_distance
    global linking_distance
    global gap_closing_distance
    global max_gap_closing_frames


    settings = fiji.plugin.trackmate.Settings();
    settings.setFrom(image)
    settings.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
    map = java.util.HashMap();
    map.put('DO_SUBPIXEL_LOCALIZATION', true);
    map.put('RADIUS', radius_value);
    map.put('TARGET_CHANNEL', channel);
    map.put('THRESHOLD', 0.0);
    map.put('DO_MEDIAN_FILTERING', false);
    settings.detectorSettings = map;

    ### Feature Settings
    settings.clearSpotFilters()
    start_quality_filter = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', start_quality_value, true)
    settings.addSpotFilter(start_quality_filter)
    settings.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer())
    track_filter = fiji.plugin.trackmate.features.FeatureFilter('TRACK_DURATION', track_filter_value, true);
    settings.addTrackFilter(track_filter)

    ### Tracker Settings
    settings.trackerFactory = fiji.plugin.trackmate.tracking.sparselap.SparseLAPTrackerFactory();
    settings.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap();
    settings.trackerSettings.put('ALLOW_TRACK_SPLITTING', false);
    settings.trackerSettings.put('ALLOW_TRACK_MERGING', allow_merging);
    settings.trackerSettings.put('MERGING_MAX_DISTANCE', gap_closing_distance);
    settings.trackerSettings.put('LINKING_MAX_DISTANCE', linking_distance);
    settings.trackerSettings.put('GAP_CLOSING_MAX_DISTANCE', gap_closing_distance);
    settings.trackerSettings.put('MAX_FRAME_GAP', max_gap_closing_frames);
    penalty_link = java.util.HashMap();
    penalty_link.put('QUALITY', 1.0);
    penalty_link.put('POSITION_Z', 0.8);
    settings.trackerSettings.put('LINKING_FEATURE_PENALTIES', penalty_link);
    penalty_gap = java.util.HashMap();
    penalty_gap.put('QUALITY', 1.0);
    penalty_gap.put('POSITION_Z', 0.8);
    settings.trackerSettings.put('GAP_CLOSING_FEATURE_PENALTIES', penalty_gap);

    return settings


os.chdir(image_directory);
image_list = glob.glob("*.tif");

os.chdir(roi_directory);
roi_list = glob.glob("*.roi");

os.chdir(image_directory);
try:
    os.mkdir("Results");
except OSError:
    print("Directory \"Results\" already exists.");
                    
                    
## Create output files and initialize with headers
C1_full_file_path = image_directory + "Results/C1_" + output_text;
C1_fileID = open(C1_full_file_path, 'w');
C1_fileID.write("C1_Image\tC1_TrackID\tC1_SpotID\tC1_Position_X\tC1_Position_Y\tC1_PositionZ\tC1_FRAME\tTrack_Length\n");

C2_full_file_path = image_directory + "Results/C2_" + output_text;
C2_fileID = open(C2_full_file_path, 'w');
C2_fileID.write("C2_Image\tC2_TrackID\tC2_SpotID\tC2_Position_X\tC2_Position_Y\tC2_PositionZ\tC2_FRAME\tTrack_Length\n");
C2_fileID.close();



## Use this area to create a log file for tracking output of Trackmate
######
#####
####
###
##
#

                    
                    
                    
for i in image_list:
    ImageJ();
	imp = [];
	match_roi = [];
	match_count = 1;
	m = re.search('(Batch\d+_\d+_XY\d{2}).*.tif', i);
	match = m.group(1);
    quality_value = 0;

	
	for j in roi_list:
		if re.search(match, j):
			match_roi.append(j);
			
	
	if len(match_roi) >= 1:
        os.mkdir(image_directory + "Results/" + file_name);
		image_path = image_directory + '/' + i;
		imp = ij.io.Opener.openUsingBioFormats(image_path);
		imp.show();
        ij.IJ.run('Make Composite');
        ij.IJ.selectWindow(i);
        ij.IJ.run('Z Project...', 'projection=[Max Intensity] all');
        ij.IJ.run('Duplicate...', 'duplicate frames=1');
        ij.IJ.setSlice(1);
        ij.IJ.run('Enhance Contrast', 'saturated=0.05');
        ij.IJ.setSlice(2);
        ij.IJ.run('Enhance Contrast', 'saturated=0.05');
        ij.IJ.run('RGB Color');
        ij.IJ.save(strcat(image_directory, '/Results/', file_name, '/', '/Max_', file_name));
        
                    #a = imread(strcat(image_directory, '/Track_Labels/', file_name, '/', cutoff_dir, '/Max_', file_name));
                    #        c1_fig = figure('Position', [200 200 612 612], 'Color', [0.5 0.5 0.5]);
                    #        set(gca, 'Units', 'Pixels', 'Position', [50 50 512 512]);
                    #        imshow(a);
                    #        hold on;
        
                    #        c2_fig = figure('Position', [200 200 612 612], 'Color', [0.5 0.5 0.5]);
                    #        set(gca, 'Units', 'Pixels', 'Position', [50 50 512 512]);
                    #        imshow(a);
                    #        hold on;
		for k in match_roi:
			IJ.selectWindow(i);
			cur_match_roi = k;
			m = re.search('(Batch\d+_\d+_XY\d{2}_.*\d+).roi', cur_match_roi);
            image_name = m.group(1)
            m = re.search('Batch\d+_\d+_XY\d{2}_.*?(\d+).roi', cur_match_roi);
            locus_number = m.group(1)
            roi_path = roi_dir + cur_match_roi
            ij.IJ.open(roi_path);
            ij.IJ.run('Make Composite');
            imp_roi = ij.IJ.getImage();
            cur_roi = imp_roi.getRoi();
            m = re.search('[(.*),\sx=(\d+),\sy=(\d+),\swidth=(\d+),\sheight=(\d+)', cur_roi);
            roi_type = m.group(1)
            roi_x = m.group(2)
            roi_y = m.group(3)
            roi_width = m.group(4)
            roi_height = m.group(5)
                    
            settings = fillTrackMateSettings(imp_roi, 1)

            model = fiji.plugin.trackmate.Model();
            trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
            ok = trackmate.checkInput();
            if not ok:
                print(trackmate.getErrorMessage())
            ok = trackmate.process()
            if not ok:
                print(trackmate.getErrorMessage())
            
            list_spots = model.getSpots()
            quality_scores = sort(list_spots.collectValues('QUALITY', false))
            quality_length = len(quality_scores)
            if quality_length > spot_cutoff:
                    index = quality_length - spot_cutoff
                    quality_value = quality_scores[index]
                    mod_filter = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', quality_value, true);
                    list_spots = list_spots.filter(mod_filter)
            
            
