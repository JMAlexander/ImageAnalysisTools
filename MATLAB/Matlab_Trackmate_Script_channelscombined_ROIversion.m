%% Puncta Tracking in Matlab using Fiji
%% Images should be cropped to containing 1-2 pairs of spots only.


% Initialize Variables
clc;
image_directory = '/Users/Jeff/Analysis_Box/08_01_2017_Batch54/Stacks/';            %% Set the image directory with the images with spots to track are
roi_folder = '/Users/Jeff/Desktop/Analysis_Box/08_01_2017_Batch54/Batch54_singlets/';                   %% Set the roi directory
base_name = 'Batch54';                                  %% Set the base name of the images that are common to all images.
output_text = 'Batch54.txt';                            %% Set the output text name
max_frames = 100;                                       %% Number of timepoints in movie.
allow_merging = false;


start_quality_value_c1 = 50000;                         %% Initialize quality cut-off.  Set high to allow all spots in initial run
track_filter_value = 10;                                %% Minimize size of track that will be reported in output text and corresponding image.
radius_value = 2.5;                                     %% Radius of spots in pixels
linking_distance = 20;
gap_closing_distance = 30;
max_gap_closing_frames = java.lang.Integer(3);

%% Configure Matlab and Start Fiji
addpath('/Users/Jeff/Box Sync/Scripts/MATLAB');
addpath('/Applications/Fiji.app/scripts');

%% Configure Scripts for Resetting Java Memory Heap
javaaddpath(which('MatlabGarbageCollector.jar'));
javaaddpath('/Applications/MATLAB_R2016a.app/java/jar/mij.jar');

Miji;

%% Run Trackmate through Miji
%% This script version with automatically set the quality filter values to pass no more than (number of frames + 20%) spots to track detection.

cd(image_directory);
spot_cutoff = max_frames + max_frames * 0.2;
cutoff_dir = strcat(int2str(spot_cutoff), '_spots');
mkdir(cutoff_dir);


%% Create output files and initialize with headers
C1_full_file_path = strcat(image_directory, cutoff_dir, '/', 'C1_', output_text);
C1_fileID = fopen(C1_full_file_path, 'w');
fprintf(C1_fileID, 'C1_Image\tC1_TrackID\tC1_SpotID\tC1_Position_X\tC1_Position_Y\tC1_Position_Z\tC1_FRAME\tRadius\tVisibility\n');
C2_full_file_path = strcat(image_directory, cutoff_dir, '/', 'C2_', output_text);
C2_fileID = fopen(C2_full_file_path, 'w');
fprintf(C2_fileID, 'C2_Image\tC2_TrackID\tC2_SpotID\tC2_Position_X\tC2_Position_Y\tC2_Position_Z\tC2_FRAME\tRadius\tVisibility\n');

%%

mkdir('Track_Labels');  %%% Create directory to deposit still images with track information during run
dir_images = dir('*.tif');



%% Create ROI list
cd(roi_folder);
dir_list = dir('*.roi');
roi_list = {dir_list.name};
cd(image_directory);
dir_list=dir('*.tif');
image_list={dir_list.name};



%% Create files that reports unusual results during tracking
warning_file = strcat(image_directory, cutoff_dir, '/', base_name,'_warnings.txt');
warning_fileID = fopen(warning_file, 'w');
fprintf(warning_fileID, 'Issues Warnings for Files in %s\n', image_directory);
fclose(warning_fileID);

%% Create log files to store run information
diary_file = strcat(image_directory, cutoff_dir, '/', base_name,'_matlab_log.txt');
diary on;
diary(diary_file);

%% Program Header in Matlab
disp('--------------------------------------------------');
disp('----------Automated Trackmate Start---------------');
disp('--------------------------------------------------');
disp(strcat('Directory:  ', image_directory));
disp(strcat('Cutoff:  ', spot_cutoff));
disp(strcat('Image Base Name:  ', base_name));
disp(strcat('Warning File:  ', image_directory,base_name,'_warnings.txt'));
disp(strcat('Log File:  ', image_directory, base_name,'_matlab_log.txt'));

for count = 1:size(dir_images,1)



file_name = dir_images(count).name;
match_roi = {};
match_count = 1;
cur_image = char(image_list(count));
reg_tok = regexp(cur_image, '(Batch.*_XY\d{2}).*.tif', 'tokens');
match = char(reg_tok{:});

for j = 1:size(roi_list, 2)
cur_roi = roi_list(j);
if strfind(char(cur_roi), match)
match_roi(match_count) = cur_roi;
match_count = match_count + 1;

end
end

match_size = size(match_roi, 2);
mkdir(strcat('Track_Labels/', file_name));
mkdir(strcat('Track_Labels/', file_name, '/', cutoff_dir));
jheapcl;
quality_value = 0;

%% Tracking Run Header
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('-------------------');
disp('---TrackMate Run---');
disp('-------------------');
fprintf(' \n');
fprintf('------------------Running Channel 1 -----------------\n');
fprintf(' \n');
disp(strcat('Active Image:  ', image_directory, file_name));


%% Open image in Fiji
if (match_size >= 1)

imp = ij.io.Opener.openUsingBioFormats(strcat(image_directory,file_name));
imp.show();
ij.IJ.run('Make Composite');
ij.IJ.selectWindow(file_name);
ij.IJ.run('Z Project...', 'projection=[Max Intensity] all');
ij.IJ.run('Duplicate...', 'duplicate frames=1');
ij.IJ.setSlice(1);
ij.IJ.run('Enhance Contrast', 'saturated=0.05');
ij.IJ.setSlice(2);
ij.IJ.run('Enhance Contrast', 'saturated=0.05');
ij.IJ.run('RGB Color');
ij.IJ.save(strcat(image_directory, '/Track_Labels/', file_name, '/', cutoff_dir, '/Max_', file_name));

a = imread(strcat(image_directory, '/Track_Labels/', file_name, '/', cutoff_dir, '/Max_', file_name));
c1_fig = figure('Position', [200 200 612 612], 'Color', [0.5 0.5 0.5]);
set(gca, 'Units', 'Pixels', 'Position', [50 50 512 512]);
imshow(a);
hold on;

c2_fig = figure('Position', [200 200 612 612], 'Color', [0.5 0.5 0.5]);
set(gca, 'Units', 'Pixels', 'Position', [50 50 512 512]);
imshow(a);
hold on;

for k = 1:size(match_roi, 2)

        %% ------- Set up Settings Object --------
        settings = fiji.plugin.trackmate.Settings();
        settings.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
        map = java.util.HashMap();
        map.put('DO_SUBPIXEL_LOCALIZATION', true);
        map.put('RADIUS', radius_value);
        map.put('TARGET_CHANNEL', java.lang.Integer(1));
        map.put('THRESHOLD', 0);
        map.put('DO_MEDIAN_FILTERING', false);
        settings.detectorSettings = map;

        % Configure tracker
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

        %Configure track analyzers
        settings.clearSpotFilters();
        start_filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', start_quality_value_c1, true);
        settings.addSpotFilter(start_filter1);
        settings.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer());

        % Configure track filters
        filter2 = fiji.plugin.trackmate.features.FeatureFilter('TRACK_DURATION', track_filter_value, true);
        settings.addTrackFilter(filter2);


            ij.IJ.selectWindow(file_name);
            cur_match_roi = char(match_roi(k));
            reg_tok = regexp(cur_match_roi, '(Batch.*_XY\d{2}_.*\d+).*.roi', 'tokens');
            image_name = char(reg_tok{:});
            reg_tok = regexp(cur_match_roi, 'Batch.*_XY\d{2}_.*?(\d+).*.roi', 'tokens');
            locus_number = char(reg_tok{:});
            roi_path =strcat(roi_folder, '/', cur_match_roi);
            ij.IJ.open(roi_path);
            ij.IJ.run('Make Composite');
            imp_roi = ij.IJ.getImage();
            cur_roi = imp_roi.getRoi();
            roi_name = char(cur_roi);
            reg_tok = regexp(roi_name, '[(.*),\sx=(\d+),\sy=(\d+),\swidth=(\d+),\sheight=(\d+)', 'tokens');
            roi_type = reg_tok{1}{1};
            roi_x = str2num(reg_tok{1}{2});
            roi_y = str2num(reg_tok{1}{3});
            roi_width = str2num(reg_tok{1}{4});
            roi_height = str2num(reg_tok{1}{5});
            
            settings.setFrom(imp_roi);
            disp(settings);
            
            
            
            %% Run TrackMate with Initial Config for Channel 1
            % Create TrackMate model object and TrackMate object
            
            model = fiji.plugin.trackmate.Model();
            trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
            ok = trackmate.checkInput();
            
            if ~ok
                display(trackmate.getErrorMessage())
            end
            
            ok = trackmate.process();
            if ~ok
                display(trackmate.getErrorMessage())
            end
            
            image_stack = char(regexp(file_name, '\S*(?=\.tif)', 'match'));
            
            list_spots=model.getSpots();
            quality_scores = sort(list_spots.collectValues('QUALITY', false)); %% Get quality scores for spots
            quality_length = size(quality_scores);
            if (quality_length(1) > spot_cutoff)   %% If there are some spots found than desired, find the appropriate QUALITY score to filter for the desired number of spots.
                quality_value = quality_scores(end - spot_cutoff);  %% Set the quality filter value
                
                %% Print header for Refined Analysis
                fprintf(' \n');
                fprintf(' \n');
                disp('---------------Refining analysis----------------');
                disp(['-Setting Quality Filter Value to ' num2str(quality_value)]);
                disp('-Rerun trackmate algorithm with modified filter values');
                fprintf(' \n');
                
                %% Rerun Trackmate with refined quality cutoff
                settings.clearSpotFilters();
                filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', quality_value, true);
                settings.addSpotFilter(filter1);
                disp(settings);
                model = fiji.plugin.trackmate.Model();
                trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
                
                ok = trackmate.checkInput();
                if ~ok
                    display(trackmate.getErrorMessage())
                end
                
                ok = trackmate.process();
                if ~ok
                    display(trackmate.getErrorMessage())
                end
                list_spots=model.getSpots();
            end
            
            %% Grab relevant variables for trackmate run
            visible_spots = list_spots.crop();
            track_model = model.getTrackModel();
            num_tracks = track_model.nTracks(true);
            trackID = track_model.trackIDs(true).toArray;
            track_position_list = [];
            
            %% Warning outputs
            if num_tracks > 1
                warning_fileID = fopen(warning_file, 'a');
                warning_blurb = 'WARNING: Multiple tracks passing thresholds were found in image C1_';
                fprintf(warning_fileID, '%s%s\n',warning_blurb, image_stack);
            end
            
            if num_tracks == 0
                warning_fileID = fopen(warning_file, 'a');
                warning_blurb = 'WARNING: No tracks passing thresholds were found in image C1_';
                fprintf(warning_fileID, '%s%s\n',warning_blurb, image_stack);
            end
            
            %% Generate a max projection of initialize timepoint of stack to annotate with discovered tracks.
            %% Enable annotation on top of image
            
            if size(trackID) > 0
                figure(c1_fig);
                if strcmp(roi_type, 'Rectangle')
                    rectangle('Position', [roi_x roi_y roi_width roi_height], 'EdgeColor', 'yellow');
                    text(roi_x + 5, roi_y - 5, locus_number, 'Color', 'yellow', 'FontSize', 14);
                elseif strcmp(roi_type, 'Freehand')
                    pol = cur_roi.getPolygon;
                    plot(pol.xpoints, pol.ypoints, 'Color', 'yellow');
                    text(roi_x - 7, roi_y - 4, locus_number, 'Color', 'yellow', 'FontSize', 14);
                end
                for i = 1:size(trackID)
                    %% Initialize variables
                    track_max_frame = 0;
                    min_frame = max_frames;
                    vis_track = trackID(i);
                    track_spots = track_model.trackSpots(java.lang.Integer(vis_track)).toArray;
                    track_length = size(track_spots);
                    %% Initialize spot feature table
                    track_spot_features_table = table(0, 0, 0, 0, 0, 0, 0, 0);
                    track_spot_features_table.Properties.VariableNames = {'VISIBILITY' 'RADIUS' 'QUALITY' 'POSITION_T' 'POSITION_X' 'POSITION_Y' 'FRAME' 'POSITION_Z'};
                    additional_row = track_spot_features_table;
                    
                    for j = 1:size(track_spots)
                        cur_spotID = track_spots(j).getName().toString();
                        cur_spotID_str = char(cur_spotID);
                        cur_IDnum = str2double(regexp(cur_spotID_str, '\d*', 'match'));
                        cur_spot = visible_spots.search(cur_IDnum);
                        cur_spot_features= cur_spot.getFeatures();
                        key_array = cur_spot_features.keySet.toArray;
                        C1_features_hash = containers.Map();
                        
                        for k = 1:size(key_array) %% Fill table with spot information
                            cur_key = key_array(k);
                            cur_value = cur_spot_features.get(cur_key);
                            C1_features_hash(cur_key) = cur_value;
                            track_spot_features_table(j,:).(cur_key) = cur_value;
                        end
                        %% Set Start and End frames for current track
                        if C1_features_hash('FRAME') < min_frame
                            min_frame = C1_features_hash('FRAME');
                        end
                        if C1_features_hash('FRAME') > track_max_frame
                            track_max_frame = C1_features_hash('FRAME');
                        end
                        %% Add row to table unless you've reached the end
                        if j ~= track_length(1)
                            track_spot_features_table = [track_spot_features_table; additional_row];
                        end
                        %% Print out values to output file
                        C1_fileID = fopen(C1_full_file_path, 'a');
                        fprintf(C1_fileID, '%s\t%d\t%s\t%5.2f\t%5.2f\t%5.2f\t%d\t%d\t%d\n', image_name, vis_track, cur_spotID_str, C1_features_hash('POSITION_X'), C1_features_hash('POSITION_Y'), C1_features_hash('POSITION_Z'), C1_features_hash('FRAME'), C1_features_hash('RADIUS'), C1_features_hash('VISIBILITY'));
                        fclose(C1_fileID);
                    end
                    color_value = ((rem((j + 3),3) * 2) / 10);
                    track_spot_features_table_sorted = sortrows(track_spot_features_table, 7);  %%Sort table by FRAME values
                    %% Annotate image with track information
                    for l = 2:size(track_spot_features_table, 1)
                        plot([(track_spot_features_table_sorted(l-1,:).POSITION_X), (track_spot_features_table_sorted(l,:).POSITION_X)] , [(track_spot_features_table_sorted(l-1,:).POSITION_Y), (track_spot_features_table_sorted(l,:).POSITION_Y)], 'Color', [1 color_value 0], 'LineWidth', 2);
                    end
                    message = strcat('C1# ', int2str(trackID(i)), '(', num2str(min_frame + 1), '-', num2str(track_max_frame + 1), ')');
                    text((track_spot_features_table_sorted(1,:).POSITION_X), (track_spot_features_table_sorted(1,:).POSITION_Y), message, 'Color', 'yellow', 'FontSize', 12);
                    message = strcat(num2str(track_max_frame + 1));
                    text((track_spot_features_table_sorted(size(track_spot_features_table, 1),:).POSITION_X), (track_spot_features_table_sorted(size(track_spot_features_table, 1),:).POSITION_Y), message, 'Color', 'yellow', 'FontSize', 12);
                    
                end
                
            end
            
            
            
            %--------------------
            % Run Channel 2
            %--------------------
            
            clear map;
            map = java.util.HashMap();
            map.put('DO_SUBPIXEL_LOCALIZATION', true);
            map.put('RADIUS', radius_value);
            map.put('TARGET_CHANNEL', java.lang.Integer(2));
            map.put('THRESHOLD', 0);
            map.put('DO_MEDIAN_FILTERING', false);
            settings.detectorSettings = map;

            settings.clearSpotFilters();
            start_filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', start_quality_value_c1, true);
            settings.addSpotFilter(start_filter1);
            settings.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer());

            ij.IJ.selectWindow(file_name);
            imp_roi = ij.IJ.getImage();
            settings.setFrom(imp_roi);
            
            fprintf(' \n');
            fprintf(' \n');
            fprintf('------------------Running Channel 2 -----------------\n');
            fprintf(' \n');
            disp(strcat('Active Image:  ', image_directory,file_name));
            disp(settings);
            
            
            %% Run TrackMate with Initial Config for Channel 1
            % Create TrackMate model object and TrackMate object
            
            model = fiji.plugin.trackmate.Model();
            trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
            ok = trackmate.checkInput();
            
            if ~ok
                display(trackmate.getErrorMessage())
            end
            
            ok = trackmate.process();
            if ~ok
                display(trackmate.getErrorMessage())
            end
            
            image_stack = char(regexp(file_name, '\S*(?=\.tif)', 'match'));
            
            list_spots=model.getSpots();
            quality_scores = sort(list_spots.collectValues('QUALITY', false)); %% Get quality scores for spots
            quality_length = size(quality_scores);
            if (quality_length(1) > spot_cutoff)   %% If there are some spots found than desired, find the appropriate QUALITY score to filter for the desired number of spots.
                quality_value = quality_scores(end - spot_cutoff);  %% Set the quality filter value
                
                %% Print header for Refined Analysis
                fprintf(' \n');
                fprintf(' \n');
                disp('---------------Refining analysis----------------');
                disp(['-Setting Quality Filter Value to ' num2str(quality_value)]);
                disp('-Rerun trackmate algorithm with modified filter values');
                fprintf(' \n');
                
                %% Rerun Trackmate with refined quality cutoff
                settings.clearSpotFilters();
                filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', quality_value, true);
                settings.addSpotFilter(filter1);
                disp(settings);
                model = fiji.plugin.trackmate.Model();
                trackmate = fiji.plugin.trackmate.TrackMate(model, settings);
                
                ok = trackmate.checkInput();
                if ~ok
                    display(trackmate.getErrorMessage())
                end
                
                ok = trackmate.process();
                if ~ok
                    display(trackmate.getErrorMessage())
                end
                list_spots=model.getSpots();
            end
            
            %% Grab relevant variables for trackmate run
            visible_spots = list_spots.crop();
            track_model = model.getTrackModel();
            num_tracks = track_model.nTracks(true);
            trackID = track_model.trackIDs(true).toArray;
            track_position_list = [];
            
            %% Warning outputs
            if num_tracks > 1
                warning_fileID = fopen(warning_file, 'a');
                warning_blurb = 'WARNING: Multiple tracks passing thresholds were found in image C2_';
                fprintf(warning_fileID, '%s%s\n',warning_blurb, image_stack);
            end
            
            if num_tracks == 0
                warning_fileID = fopen(warning_file, 'a');
                warning_blurb = 'WARNING: No tracks passing thresholds were found in image C2_';
                fprintf(warning_fileID, '%s%s\n',warning_blurb, image_stack);
            end
            
            %% Open annotated image to write Channel 2 data
            
            if size(trackID) > 0
                figure(c2_fig);
                if strcmp(roi_type, 'Rectangle')
                    rectangle('Position', [roi_x roi_y roi_width roi_height], 'EdgeColor', 'yellow');
                    text(roi_x + 5, roi_y - 5, locus_number, 'Color', 'yellow', 'FontSize', 14);
                elseif strcmp(roi_type, 'Freehand')
                    pol = cur_roi.getPolygon;
                    plot(pol.xpoints, pol.ypoints, 'Color', 'yellow');
                    text(roi_x - 7, roi_y - 4, locus_number, 'Color', 'yellow', 'FontSize', 14);
                end
                for i = 1:size(trackID)
                    %% Initialize variables
                    track_max_frame = 0;
                    min_frame = max_frames;
                    vis_track = trackID(i);
                    track_spots = track_model.trackSpots(java.lang.Integer(vis_track)).toArray;
                    track_length = size(track_spots);
                    %% Initialize spot feature table
                    track_spot_features_table = table(0, 0, 0, 0, 0, 0, 0, 0);
                    track_spot_features_table.Properties.VariableNames = {'VISIBILITY' 'RADIUS' 'QUALITY' 'POSITION_T' 'POSITION_X' 'POSITION_Y' 'FRAME' 'POSITION_Z'};
                    additional_row = track_spot_features_table;
                    
                    for j = 1:size(track_spots)
                        cur_spotID = track_spots(j).getName().toString();
                        cur_spotID_str = char(cur_spotID);
                        cur_IDnum = str2double(regexp(cur_spotID_str, '\d*', 'match'));
                        cur_spot = visible_spots.search(cur_IDnum);
                        cur_spot_features= cur_spot.getFeatures();
                        key_array = cur_spot_features.keySet.toArray;
                        C2_features_hash = containers.Map();
                        
                        for k = 1:size(key_array) %% Fill table with spot information
                            cur_key = key_array(k);
                            cur_value = cur_spot_features.get(cur_key);
                            C2_features_hash(cur_key) = cur_value;
                            track_spot_features_table(j,:).(cur_key) = cur_value;
                        end
                        %% Set Start and End frames for current track
                        if C2_features_hash('FRAME') < min_frame
                            min_frame = C2_features_hash('FRAME');
                        end
                        if C2_features_hash('FRAME') > track_max_frame
                            track_max_frame = C2_features_hash('FRAME');
                        end
                        %% Add row to table unless you've reached the end
                        if j ~= track_length(1)
                            track_spot_features_table = [track_spot_features_table; additional_row];
                        end
                        %% Print out values to output file
                        C2_fileID = fopen(C2_full_file_path, 'a');
                        fprintf(C2_fileID, '%s\t%d\t%s\t%5.2f\t%5.2f\t%5.2f\t%d\t%d\t%d\n', image_name, vis_track, cur_spotID_str, C2_features_hash('POSITION_X'), C2_features_hash('POSITION_Y'), C2_features_hash('POSITION_Z'), C2_features_hash('FRAME'), C2_features_hash('RADIUS'), C2_features_hash('VISIBILITY'));
                        fclose(C2_fileID);
                    end
                    color_value = ((rem((j + 3),3) * 2) / 10);
                    track_spot_features_table_sorted = sortrows(track_spot_features_table, 7);  %%Sort table by FRAME values
                    %% Annotate image with track information
                    for l = 2:size(track_spot_features_table, 1)
                        plot([(track_spot_features_table_sorted(l-1,:).POSITION_X), (track_spot_features_table_sorted(l,:).POSITION_X)] , [(track_spot_features_table_sorted(l-1,:).POSITION_Y), (track_spot_features_table_sorted(l,:).POSITION_Y)], 'Color', [(color_value + 0.2) (color_value + 0.2) (color_value + 0.2)], 'LineWidth', 2);
                    end
                    message = strcat('C2# ', int2str(trackID(i)), '(', num2str(min_frame + 1), '-', num2str(track_max_frame + 1), ')');
                    text((track_spot_features_table_sorted(1,:).POSITION_X), (track_spot_features_table_sorted(1,:).POSITION_Y), message, 'Color', 'white', 'FontSize', 12);
                    message = strcat(num2str(track_max_frame + 1));
                    text((track_spot_features_table_sorted(size(track_spot_features_table, 1),:).POSITION_X), (track_spot_features_table_sorted(size(track_spot_features_table, 1),:).POSITION_Y), message, 'Color', 'white', 'FontSize', 12);
                    
                    
                end
            end
            
        end
        
        
        
        %%%%%%%%
        
        same_image = true;
        fclose('all');
        jheapcl;
        
        figure(c1_fig);
        full_name = strcat(image_directory, '/Track_Labels/', file_name, '/', cutoff_dir,  '/C1_Max_', file_name);
        export_fig(full_name, '-nocrop');   %% Save image
        figure(c2_fig);
        full_name = strcat(image_directory, '/Track_Labels/', file_name, '/', cutoff_dir,  '/C2_Max_', file_name);
        export_fig(full_name, '-nocrop');   %% Save image
        
        figure('Units', 'Pixels', 'Position', [200 200 1224 612]);
        a = imread(strcat(image_directory, '/Track_Labels/', file_name, '/', cutoff_dir, '/C1_Max_', file_name));
        subplot('Position', [0 0 0.5 1]);
        imshow(a);
        
        b = imread(strcat(image_directory, '/Track_Labels/', file_name, '/', cutoff_dir, '/C2_Max_', file_name));
        subplot('Position', [0.5 0 0.5 1]);
        imshow(b);
        full_name = strcat(image_directory, '/Track_Labels/', file_name, '/', cutoff_dir,  '/C1C2_Max_', file_name);
        export_fig(full_name, '-nocrop');   %% Save image
        
    end
    same_image = false;
    
    clear a;
    clear b;
    clear c1_fig;
    clear c2_fig;
    clear trackID;
    clear track_spots;
    clear visible_spots;
    clear trackmate;
    clear model;
    clear track_model;
    clear list_spots;
    clear imp;
    clear imp_roi;
    clear ok;
    clear settings;
    ij.IJ.run('Close All');
    close('all');
    MIJ.exit;
    jheapcl;
    MIJ.start;
    
    
end

C1_table = readtable(C1_full_file_path, 'Delimiter', '\t');
sorted_C1 = sortrows(C1_table, [1 2 7]);
writetable(sorted_C1, C1_full_file_path, 'Delimiter', '\t');

C2_table = readtable(C2_full_file_path, 'Delimiter', '\t');
sorted_C2 = sortrows(C2_table, [1 2 7]);
writetable(sorted_C2, C2_full_file_path, 'Delimiter', '\t');


fclose('all');
