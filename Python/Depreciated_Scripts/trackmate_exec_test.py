import sys
import os
import argparse
import glob
import time
import re
import java.util.HashMap

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
import fiji.plugin.trackmate.SelectionModel
import fiji.plugin.trackmate.visualization.AbstractTrackMateModelView
from ij import IJ, ImagePlus, ImageJ


parser = argparse.ArgumentParser();
parser.add_argument('-d', '--dir');
parser.add_argument('-b', '--batch');
arg = parser.parse_args();

image_directory = '/Users/Jeff/Desktop/test_dir/';
base_name = 'Batch14'
output_text = base_name + ".txt";
max_frames = 100;
start_quality_value_c1 = 50000;
start_quality_value_c2 = 50000;
track_filter_value = 15;
radius_value = 2.5;
spot_cutoff = 200;
linking_distance = 20.0;
gap_closing_distance = 30.0;
max_gap_closing_frames = 3;
true = java.lang.Boolean('true');
false = java.lang.Boolean('false');

## Create output files and initialize with headers
C1_full_file_path = image_directory + "C1_" + output_text;
C1_fileID = open(C1_full_file_path, 'w');
C1_fileID.write("C1_Image\tC1_TrackID\tC1_SpotID\tC1_Position_X\tC1_Position_Y\tC1_PositionZ\tC1_FRAME\tRadius\tVisibility\n");

C2_full_file_path = image_directory + "C2_" + output_text;
C2_fileID = open(C2_full_file_path, 'w');
C2_fileID.write("C2_Image\tC2_TrackID\tC2_SpotID\tC2_Position_X\tC2_Position_Y\tC2_PositionZ\tC2_FRAME\tRadius\tVisibility\n");


os.chdir(image_directory);
try:
	os.mkdir("Track_Labels");
except OSError:
	print("Directory \"Track_Labels\" already exists.");
dir_images = glob.glob("*.tif");

## Create file that report unusual results during tracking
warning_file = image_directory + base_name + "_warnings.txt";
warning_fileID = open(warning_file, 'w');
warning_fileID.write("Issues Warnings for Files in " + image_directory + "\n");

## Use this area to create a log file for tracking output of Trackmate
######
#####
####
###
##
#

## Create Settings Object
max_gap_closing_frames
settings_c1 = fiji.plugin.trackmate.Settings();
settings_c2 = fiji.plugin.trackmate.Settings();

settings_c1.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
map_c1 = java.util.HashMap();
map_c1.put('DO_SUBPIXEL_LOCALIZATION', true);
map_c1.put('RADIUS', radius_value);
map_c1.put('TARGET_CHANNEL', java.lang.Integer(1));
map_c1.put('THRESHOLD', 0.0);
map_c1.put('DO_MEDIAN_FILTERING', false);
settings_c1.detectorSettings = map_c1;

settings_c2.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
map_c2 = java.util.HashMap();
map_c2.put('DO_SUBPIXEL_LOCALIZATION', true);
map_c2.put('RADIUS', radius_value);
map_c2.put('TARGET_CHANNEL', java.lang.Integer(2));
map_c2.put('THRESHOLD', 0.0);
map_c2.put('DO_MEDIAN_FILTERING', false);
settings_c2.detectorSettings = map_c2;

# Configure tracker
settings_c1.trackerFactory = fiji.plugin.trackmate.tracking.sparselap.SparseLAPTrackerFactory();
settings_c1.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap(); 
settings_c1.trackerSettings.put('ALLOW_TRACK_SPLITTING', false);
settings_c1.trackerSettings.put('ALLOW_TRACK_MERGING', false);
settings_c1.trackerSettings.put('LINKING_MAX_DISTANCE', linking_distance);
settings_c1.trackerSettings.put('GAP_CLOSING_MAX_DISTANCE', gap_closing_distance);
settings_c1.trackerSettings.put('MAX_FRAME_GAP', max_gap_closing_frames);
penalty_link = java.util.HashMap();
penalty_link.put('QUALITY', 1.0);
penalty_link.put('POSITION_Z', 0.8);
settings_c1.trackerSettings.put('LINKING_FEATURE_PENALTIES', penalty_link);
penalty_gap = java.util.HashMap();
penalty_gap.put('QUALITY', 1.0);
penalty_gap.put('POSITION_Z', 0.8);
settings_c1.trackerSettings.put('GAP_CLOSING_FEATURE_PENALTIES', penalty_gap);

settings_c2.trackerFactory = fiji.plugin.trackmate.tracking.sparselap.SparseLAPTrackerFactory();
settings_c2.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap();
settings_c2.trackerSettings.put('ALLOW_TRACK_SPLITTING', false);
settings_c2.trackerSettings.put('ALLOW_TRACK_MERGING', false);
settings_c2.trackerSettings.put('LINKING_MAX_DISTANCE', linking_distance);
settings_c2.trackerSettings.put('GAP_CLOSING_MAX_DISTANCE', gap_closing_distance);
settings_c2.trackerSettings.put('MAX_FRAME_GAP', max_gap_closing_frames);
penalty_link = java.util.HashMap();
penalty_link.put('QUALITY', 1.0);
penalty_link.put('POSITION_Z', 0.8);
settings_c2.trackerSettings.put('LINKING_FEATURE_PENALTIES', penalty_link);
penalty_gap = java.util.HashMap();
penalty_gap.put('QUALITY', 1.0);
penalty_gap.put('POSITION_Z', 0.8);
settings_c2.trackerSettings.put('GAP_CLOSING_FEATURE_PENALTIES', penalty_gap);


# Configure track analyzers
start_filter1_c1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', start_quality_value_c1, true);
settings_c1.addSpotFilter(start_filter1_c1);
start_filter1_c2 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', start_quality_value_c2, true);
settings_c2.addSpotFilter(start_filter1_c2);

# The displacement feature is provided by the TrackDurationAnalyzer
settings_c1.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer())
settings_c2.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer())

# Configure track filters
filter2 = fiji.plugin.trackmate.features.FeatureFilter('TRACK_DURATION', track_filter_value, true);
settings_c1.addTrackFilter(filter2);
settings_c2.addTrackFilter(filter2);

##Start ImageJ
ImageJ();

## Program Header
print('--------------------------------------------------');
print('----------Automated Trackmate Start---------------');
print('--------------------------------------------------');
print('Directory:  ' +  image_directory);
print('Image Base Name:  ' +  base_name);
print('Warning File:  ' + image_directory + base_name + '_warnings.txt');
print('Log File:  ' + image_directory + base_name + '_matlab_log.txt');

file_name = 'Batch17_04_XY02_cropped_singlet01.tif';
try:
	os.mkdir("Track_Labels/" + file_name);
except OSError:
	print("Directory \"Track_Labels\" already exists.");
quality_value = 0;
settings_c1.clearSpotFilters();
settings_c2.clearSpotFilters();
filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', start_quality_value_c1, true); 
settings_c1.addSpotFilter(filter1);
filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', start_quality_value_c2, true);
settings_c2.addSpotFilter(filter1);

print('#############################');
print('-----------------------------');
print('-------TrackMate Run---------');
print('-----------------------------');
print('\n')
print('-----Running Channel 1-------');	
print('Active Image:  ' + image_directory + file_name);
print('-----Settings----------------');
print(settings_c2);
	
open_image = java.lang.String(image_directory + file_name);
print(open_image);
imp = IJ.openImage(open_image);
imp.show();
IJ.run('Make Composite');
settings_c2.setFrom(imp);
print(settings_c2);	

model = fiji.plugin.trackmate.Model();
trackmate = fiji.plugin.trackmate.TrackMate(model, settings_c2);       
ok = trackmate.checkInput();

if not ok:
	print(trackmate.getErrorMessage());
	
ok = trackmate.process();
if not ok:
	print(trackmate.getErrorMessage());

m = re.search('(\S*).tif', file_name);
image_stack = m.group(1);
list_spots=model.getSpots();
# Get quality scores for spots
quality_scores = sorted(list_spots.collectValues('QUALITY', false)); 
quality_length = len(quality_scores);

if quality_length > spot_cutoff:
	quality_value = quality_scores[quality_length - spot_cutoff];


	print('\n');
	print('\n');
	print('########Refining analysis##########');
	banner = '-Setting Quality Filter Value to ' + str(quality_value);
	print(banner);
	print('-Rerun trackmate algorithm with modified filter values');
	print('\n');

	## Rerun Trackmate with refined quality cutoff
    	settings_c2.clearSpotFilters();
    	filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', quality_value, true);
    	settings_c2.addSpotFilter(filter1);
    	print(settings_c2);
    	model = fiji.plugin.trackmate.Model();
    	trackmate = fiji.plugin.trackmate.TrackMate(model, settings_c2);
    
    	ok = trackmate.checkInput();
    	if not ok:
		print(trackmate.getErrorMessage())
 
    	ok = trackmate.process();
    	if not ok:
		print(trackmate.getErrorMessage())

	list_spots=model.getSpots();

## Grab relevant variables for trackmate run
visible_spots = list_spots.crop();
track_model = model.getTrackModel();
num_tracks = track_model.nTracks(true);
trackID = track_model.trackIDs(true).toArray();
track_position_list = [];

if num_tracks > 1:
	warning_blurb = 'WARNING: Multiple tracks passing thresholds were found in image C1_';
	warning_fileID.write(warning_blurb + image_stack + "\n");

if num_tracks == 0:
	warning_blurb = 'WARNING: No tracks passing thresholds were found in image C1_';
	warning_fileID.write(warning_blurb + image_stack + "\n");
	
IJ.selectWindow(file_name);
IJ.run('Z Project...', 'projection=[Max Intensity] all');
IJ.run('Duplicate...', 'duplicate frames=1');
IJ.setSlice(1);
IJ.run('Enhance Contrast', 'saturated=0.05');
IJ.setSlice(2);
IJ.run('Enhance Contrast', 'saturated=0.05');
IJ.run('RGB Color');
imp_max = IJ.getImage();
save_filename = image_directory + 'Track_Labels/' + file_name + '/Max_' + file_name;
IJ.save(save_filename);

if len(trackID) > 0:
	for i in trackID:
    		## Initialize variables
    		track_max_frame = 0;
    		min_frame = max_frames;
    		vis_track = i;
    		track_spots = track_model.trackSpots(java.lang.Integer(vis_track)).toArray();
    		track_length = len(track_spots);
    		## Initialize spot feature table
    		##track_spot_features = {0, 0, 0, 0, 0, 0, 0, 0};
    		##track_spot_features_table.Properties.VariableNames = {'VISIBILITY' 'RADIUS' 'QUALITY' 'POSITION_T' 'POSITION_X' 'POSITION_Y' 'FRAME' 'POSITION_Z'};
    		#additional_row = track_spot_features_table;

		for j in track_spots:
			cur_spotID = str(j.getName());
			m = re.search('ID(\d*)', cur_spotID);
			cur_IDnum = int(m.group(1))
			cur_spot = visible_spots.search(cur_IDnum);
			cur_spot_features = cur_spot.getFeatures();
			outrow = list();
			outrow.append(image_stack);
			outrow.append(i);
			outrow.append(j);
			outrow.append(cur_spot_features['POSITION_X']);
			outrow.append(cur_spot_features['POSITION_Y']);
			outrow.append(cur_spot_features['POSITION_Z']);
			outrow.append(cur_spot_features['FRAME']);
			outrow.append(cur_spot_features['RADIUS']);
			outrow.append(cur_spot_features['VISIBILITY']);
			C2_fileID.write('\t'.join(map(str, outrow)))
			
			if cur_spot_features['FRAME'] < min_frame:
				min_frame = cur_spot_features['FRAME'];
			if cur_spot_features['FRAME'] > track_max_frame:
				track_max_frame = cur_spot_features['FRAME'];


track_factory = fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayerFactory();
selection_model = fiji.plugin.trackmate.SelectionModel(model);
hsdisplayer = fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selection_model, imp_max);
track_modelview = track_factory.create(model, settings_c2, selection_model);
#spot_overlay.setSpotSelection(list_spots);
hs_displayer_settings = hsdisplayer.getDisplaySettings();
hsdisplayer.render();
