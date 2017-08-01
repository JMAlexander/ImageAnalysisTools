% Initialize Variables
addpath('/Users/Jeff/Scripts/MATLAB');
addpath('/Applications/Fiji.app/scripts');
javaaddpath(which('MatlabGarbageCollector.jar'));
Miji;


clc;
image_directory = 'PATH-TO-DIRECTORY';
base_name = '####';
output_text = '###.txt';
quality = 100;

C1_full_file_path = strcat(image_directory, '/C1_', output_text);
C1_fileID = fopen(C1_full_file_path, 'w');
fprintf(C1_fileID, 'C1_Image\tC1_SpotID\tC1_Position_X\tC1_Position_Y\tC1_Position_Z\tC1_FRAME\tRadius\tVisibility\n');

C2_full_file_path = strcat(image_directory, '/C2_', output_text);
C2_fileID = fopen(C2_full_file_path, 'w');
fprintf(C2_fileID, 'C2_Image\tC2_SpotID\tC2_Position_X\tC2_Position_Y\tC2_Position_Z\tC2_FRAME\tRadius\tVisibility\n');

C3_full_file_path = strcat(image_directory, '/C3_', output_text);
C3_fileID = fopen(C3_full_file_path, 'w');
fprintf(C3_fileID, 'C3_Image\tC3_SpotID\tC3_Position_X\tC3_Position_Y\tC3_Position_Z\tC3_FRAME\tRadius\tVisibility\n');


max_frames = 1;
radius_value = 5;


cd(image_directory);
mkdir('Track_Labels');
dir_images = dir('*.tif');
warning_file = strcat(image_directory,base_name,'_warnings.txt');
warning_fileID = fopen(warning_file, 'a');
fprintf(warning_fileID, 'Issues Warnings for Files in %s\n', image_directory);
fclose(warning_fileID);


%------- Set up Settings Object --------

diary_file = strcat(image_directory,base_name,'_matlab_log.txt');
diary on;
diary(diary_file);
settings = fiji.plugin.trackmate.Settings();

disp('--------------------------------------------------');
disp('----------Automated Trackmate Start---------------');
disp('--------------------------------------------------');
disp(strcat('Directory:  ', image_directory));
disp(strcat('Image Base Name:  ', base_name));
disp(strcat('Warning File:  ', image_directory,base_name,'_warnings.txt'));
disp(strcat('Log File:  ', image_directory, base_name,'_matlab_log.txt'));


settings.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
map = java.util.HashMap();
map.put('DO_SUBPIXEL_LOCALIZATION', true);
map.put('RADIUS', radius_value);
map.put('TARGET_CHANNEL', java.lang.Integer(1));
map.put('THRESHOLD', 0);
map.put('DO_MEDIAN_FILTERING', false);
settings.detectorSettings = map;
    
% Configure spot filters - Classical filter on quality
filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', quality, true);
settings.addSpotFilter(filter1) 

settings.trackerFactory = fiji.plugin.trackmate.tracking.oldlap.LAPTrackerFactory();
settings.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap();
   

jheapcl;

warning_fileID = fopen(warning_file, 'a');

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('');
disp('');
disp('-------------------');
disp('---TrackMate Run---');
disp('-------------------');
disp('');
disp('');

for count = 1:size(dir_images,1)
    file_name = dir_images(count).name;
    
imp = ij.IJ.openImage(strcat(image_directory,file_name));
imp.show();
ij.IJ.run('Make Composite');
map.put('TARGET_CHANNEL', java.lang.Integer(1));
settings.setFrom(imp);   
settings.detectorSettings = map;
disp(settings);


%----------------------------
% Create the model object now
%----------------------------
    
% Some of the parameters we configure below need to have
% a reference to the model at creation. So we create an
% empty model now.
model = fiji.plugin.trackmate.Model();
    
% Send all messages to ImageJ log window.
       
%--------------------
% Run Channel 1
%--------------------



%-------------------
% Instantiate plugin
%-------------------
    
trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
       
%--------
% Process
%--------
    
ok = trackmate.checkInput();
if ~ok
    display(trackmate.getErrorMessage())
end
 
ok = trackmate.process();
if ~ok
    display(trackmate.getErrorMessage())
end

% Echo results
image_stack = char(regexp(file_name, '\S*(?=\.tif)', 'match'));

spot_position_list = [];
ij.IJ.selectWindow(file_name);
ij.IJ.run('Z Project...', 'projection=[Max Intensity] all');
ij.IJ.run('Duplicate...', 'duplicate frames=1');
ij.IJ.run('RGB Color');
ij.IJ.save(strcat(image_directory, 'Track_Labels/', 'Max_', file_name));
ij.IJ.run('Close All');

list_spots=model.getSpots();
blank_spot = fiji.plugin.trackmate.Spot(1,1,1,5,1000);
num_spots = list_spots.getNSpots(true);
spot_array = list_spots.getNClosestSpots(blank_spot, 0, num_spots, true).toArray();
for j = 1:size(spot_array)
    cur_spot = spot_array(j);
    cur_spot_features=cur_spot.getFeatures();
    cur_spotID = cur_spot.getName();
    key_array = cur_spot_features.keySet.toArray;
    cur_spotID_str = char(cur_spotID);
    cur_IDnum = str2double(regexp(cur_spotID_str, '\d*', 'match'));    
    spot_position_list(end + 1, 1) = cur_IDnum;
    spot_position_list(end, 2:3) = [1,1];

    C1_features_hash = containers.Map();
        for k = 1:size(key_array)
            cur_key = key_array(k);
            cur_value = cur_spot_features.get(cur_key);
            C1_features_hash(cur_key) = cur_value;
            
        end
    spot_position_list(end, 2:3) = [C1_features_hash('POSITION_X') C1_features_hash('POSITION_Y')];
        
    C1_fileID = fopen(C1_full_file_path, 'a');
    fprintf(C1_fileID, '%s\t%s\t%5.2f\t%5.2f\t%5.2f\t%d\t%d\t%d\n', image_stack, cur_spotID_str, C1_features_hash('POSITION_X'), C1_features_hash('POSITION_Y'), C1_features_hash('POSITION_Z'), C1_features_hash('FRAME'), C1_features_hash('RADIUS'), C1_features_hash('VISIBILITY'));
    fclose(C1_fileID);
    

end

a = imread(strcat(image_directory, 'Track_Labels/', 'Max_', file_name));
imshow(a, 'Border', 'tight');
hold on;

    for l = 1:size(spot_position_list,1);
        message = int2str(spot_position_list(l, 1));
        text((spot_position_list(l,2)) + 4, (spot_position_list(l,3)), message, 'Color', 'yellow', 'FontSize', 10); 
    end;

full_name = (strcat(image_directory, 'Track_Labels/', 'Max_C1', file_name));
export_fig(full_name);
close all;


%--------------------
% Run Channel 2
%--------------------

jheapcl;

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('');
disp('');
disp('-------------------');
disp('---TrackMate Run---');
disp('-------------------');
disp('');
disp('');

imp = ij.IJ.openImage(strcat(image_directory,file_name));
imp.show();
ij.IJ.run('Make Composite');
settings.setFrom(imp);
map.put('TARGET_CHANNEL', java.lang.Integer(2));
settings.detectorSettings = map;


%----------------------------
% Create the model object now
%----------------------------
    
% Some of the parameters we configure below need to have
% a reference to the model at creation. So we create an
% empty model now.
model = fiji.plugin.trackmate.Model();
    
% Send all messages to ImageJ log window.
       
%------------------------
% Prepare settings object
%------------------------
       


%-------------------
% Instantiate plugin
%-------------------
    
trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
       
%--------
% Process
%--------
    
ok = trackmate.checkInput();
if ~ok
    display(trackmate.getErrorMessage())
end
 
ok = trackmate.process();
if ~ok
    display(trackmate.getErrorMessage())
end

% Echo results

%selectionModel = fiji.plugin.trackmate.SelectionModel(model);
%displayer =  fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selectionModel, imp);
%displayer.render()
%displayer.refresh()


spot_position_list = [];

list_spots=model.getSpots();
blank_spot = fiji.plugin.trackmate.Spot(1,1,1,5,1000);
num_spots = list_spots.getNSpots(true);
spot_array = list_spots.getNClosestSpots(blank_spot, 0, num_spots, true).toArray();
for j = 1:size(spot_array)
    cur_spot = spot_array(j);
    cur_spot_features=cur_spot.getFeatures();
    cur_spotID = cur_spot.getName();
    cur_spotID_str = char(cur_spotID);
    cur_IDnum = str2double(regexp(cur_spotID_str, '\d*', 'match'));
    key_array = cur_spot_features.keySet.toArray;
        
    spot_position_list(end + 1, 1) = cur_IDnum;
    spot_position_list(end, 2:3) = [1,1];

    C2_features_hash = containers.Map();
        for k = 1:size(key_array)
            cur_key = key_array(k);
            cur_value = cur_spot_features.get(cur_key);
            C2_features_hash(cur_key) = cur_value;
            
        end
    spot_position_list(end, 2:3) = [C2_features_hash('POSITION_X') C2_features_hash('POSITION_Y')];
        
    C2_fileID = fopen(C2_full_file_path, 'a');
    fprintf(C2_fileID, '%s\t%s\t%5.2f\t%5.2f\t%5.2f\t%d\t%d\t%d\n', image_stack, cur_spotID_str, C2_features_hash('POSITION_X'), C2_features_hash('POSITION_Y'), C2_features_hash('POSITION_Z'), C2_features_hash('FRAME'), C2_features_hash('RADIUS'), C2_features_hash('VISIBILITY'));
    fclose(C2_fileID);
 end
     


b = imread(strcat(image_directory, 'Track_Labels/', 'Max_', file_name));
imshow(b, 'Border', 'tight');
hold on;

    for l = 1:size(spot_position_list,1);
        message = int2str(spot_position_list(l, 1));
        text((spot_position_list(l,2)) + 4, (spot_position_list(l,3)), message, 'Color', 'yellow', 'FontSize', 10); 
    end;

full_name = (strcat(image_directory, 'Track_Labels/', 'Max_C2', file_name));
export_fig(full_name);
close all;

ij.IJ.run('Close All');
jheapcl;


%--------------------
% Run Channel 3
%--------------------

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('');
disp('');
disp('-------------------');
disp('---TrackMate Run---');
disp('-------------------');
disp('');
disp('');

imp = ij.IJ.openImage(strcat(image_directory,file_name));
imp.show();
ij.IJ.run('Make Composite');
map.put('TARGET_CHANNEL', java.lang.Integer(3));
settings.setFrom(imp);
settings.detectorSettings = map;


%----------------------------
% Create the model object now
%----------------------------
    
% Some of the parameters we configure below need to have
% a reference to the model at creation. So we create an
% empty model now.
model = fiji.plugin.trackmate.Model();
    
% Send all messages to ImageJ log window.
       
%------------------------
% Prepare settings object
%------------------------
       


%-------------------
% Instantiate plugin
%-------------------
    
trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
       
%--------
% Process
%--------
    
ok = trackmate.checkInput();
if ~ok
    display(trackmate.getErrorMessage())
end
 
ok = trackmate.process();
if ~ok
    display(trackmate.getErrorMessage())
end

% Echo results

%selectionModel = fiji.plugin.trackmate.SelectionModel(model);
%displayer =  fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selectionModel, imp);
%displayer.render()
%displayer.refresh()


spot_position_list = [];

list_spots=model.getSpots();
blank_spot = fiji.plugin.trackmate.Spot(1,1,1,5,1000);
num_spots = list_spots.getNSpots(true);
spot_array = list_spots.getNClosestSpots(blank_spot, 0, num_spots, true).toArray();
for j = 1:size(spot_array)
    cur_spot = spot_array(j);
    cur_spot_features=cur_spot.getFeatures();
    cur_spotID = cur_spot.getName();
    cur_spotID_str = char(cur_spotID);
    cur_IDnum = str2double(regexp(cur_spotID_str, '\d*', 'match'));
    key_array = cur_spot_features.keySet.toArray;
        
    spot_position_list(end + 1, 1) = cur_IDnum;
    spot_position_list(end, 2:3) = [1,1];

    C3_features_hash = containers.Map();
        for k = 1:size(key_array)
            cur_key = key_array(k);
            cur_value = cur_spot_features.get(cur_key);
            C3_features_hash(cur_key) = cur_value;
            
        end
    spot_position_list(end, 2:3) = [C3_features_hash('POSITION_X') C3_features_hash('POSITION_Y')];
        
    C3_fileID = fopen(C3_full_file_path, 'a');
    fprintf(C3_fileID, '%s\t%s\t%5.2f\t%5.2f\t%5.2f\t%d\t%d\t%d\n', image_stack, cur_spotID_str, C3_features_hash('POSITION_X'), C3_features_hash('POSITION_Y'), C3_features_hash('POSITION_Z'), C3_features_hash('FRAME'), C3_features_hash('RADIUS'), C3_features_hash('VISIBILITY'));
    fclose(C3_fileID);
 end
     


c = imread(strcat(image_directory, 'Track_Labels/', 'Max_', file_name));
imshow(c, 'Border', 'tight');
hold on;

    for l = 1:size(spot_position_list,1);
        message = int2str(spot_position_list(l, 1));
        text((spot_position_list(l,2)) + 4, (spot_position_list(l,3)), message, 'Color', 'yellow', 'FontSize', 10); 
    end;

full_name = (strcat(image_directory, 'Track_Labels/', 'Max_C3', file_name));
export_fig(full_name);
close all;

ij.IJ.run('Close All');

end
fclose('all');
jheapcl;
