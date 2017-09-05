

% Get currently selected image
% imp = ij.IJ.openImage('http://fiji.sc/samples/FakeTracks.tif')
imp = ij.io.Opener.openUsingBioFormats('/Users/Jeff/Desktop/Batch03_017_traj13.tif');
imp.show()
    
    
%----------------------------
% Create the model object now
%----------------------------
    
% Some of the parameters we configure below need to have
% a reference to the model at creation. So we create an
% empty model now.
model = fiji.plugin.trackmate.Model();
    
% Send all messages to ImageJ log window.
model.setLogger(fiji.plugin.trackmate.Logger.IJ_LOGGER)
       
%------------------------
% Prepare settings object
%------------------------
       
settings = fiji.plugin.trackmate.Settings();
settings.setFrom(imp);

       
% Configure detector - We use a java map
settings.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
map = java.util.HashMap();
map.put('DO_SUBPIXEL_LOCALIZATION', true);
map.put('RADIUS', 5);
map.put('TARGET_CHANNEL', java.lang.Integer(1));
map.put('THRESHOLD', 0);
map.put('DO_MEDIAN_FILTERING', false);
settings.detectorSettings = map;
    
% Configure spot filters - Classical filter on quality
filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', 150.0, true);
settings.addSpotFilter(filter1)
     
% Configure tracker - We want to allow splits and fusions
settings.trackerFactory = fiji.plugin.trackmate.tracking.oldlap.LAPTrackerFactory();
settings.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap(); % almost good enough
settings.trackerSettings.put('ALLOW_TRACK_SPLITTING', false);
settings.trackerSettings.put('ALLOW_TRACK_MERGING', false);
settings.trackerSettings.put('LINKING_MAX_DISTANCE', 10);
settings.trackerSettings.put('MAX_FRAME_GAP', int32(3));
    
% Configure track analyzers - Later on we want to filter out tracks 
% based on their displacement, so we need to state that we want 
% track displacement to be calculated. By default, out of the GUI, 
% not features are calculated. 
    
% The displacement feature is provided by the TrackDurationAnalyzer.
settings.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer())
    
% Configure track filters - We want to get rid of the two immobile spots at 
% the bottom right of the image. Track displacement must be above 10 pixels.
filter2 = fiji.plugin.trackmate.features.FeatureFilter('TRACK_DURATION', 80, true);
settings.addTrackFilter(filter2)
    
    
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
       
%----------------
% Display results
%----------------
     
selectionModel = fiji.plugin.trackmate.SelectionModel(model);
displayer =  fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selectionModel, imp);
displayer.render()
displayer.refresh()
    
% Echo results
display(model.toString())

export = fiji.plugin.trackmate.action.ExportAllSpotsStatsAction();
export.execute(trackmate);

%--------------------
settings.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
map = java.util.HashMap();
map.put('DO_SUBPIXEL_LOCALIZATION', true);
map.put('RADIUS', 5);
map.put('TARGET_CHANNEL', java.lang.Integer(1));
map.put('THRESHOLD', 0);
map.put('DO_MEDIAN_FILTERING', false);
settings.detectorSettings = map;
    
% Configure spot filters - Classical filter on quality
filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', 300.0, true);
settings.addSpotFilter(filter1)
     
% Configure tracker - We want to allow splits and fusions
settings.trackerFactory = fiji.plugin.trackmate.tracking.oldlap.LAPTrackerFactory();
settings.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap(); % almost good enough
settings.trackerSettings.put('ALLOW_TRACK_SPLITTING', false);
settings.trackerSettings.put('ALLOW_TRACK_MERGING', false);
settings.trackerSettings.put('LINKING_MAX_DISTANCE', 10);
settings.trackerSettings.put('MAX_FRAME_GAP', int32(3));

%Configure track analyzers - Later on we want to filter out tracks 
% based on their displacement, so we need to state that we want 
% track displacement to be calculated. By default, out of the GUI, 
% not features are calculated. 
    
% The displacement feature is provided by the TrackDurationAnalyzer.
settings.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer())
    
% Configure track filters - We want to get rid of the two immobile spots at 
% the bottom right of the image. Track displacement must be above 10 pixels.
filter2 = fiji.plugin.trackmate.features.FeatureFilter('TRACK_DURATION', 80, true);
settings.addTrackFilter(filter2)

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
       
%----------------
% Display results
%----------------
     
selectionModel = fiji.plugin.trackmate.SelectionModel(model);
displayer =  fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selectionModel, imp);
displayer.render()
displayer.refresh()
    
% Echo results
display(model.toString())

export = fiji.plugin.trackmate.action.ExportAllSpotsStatsAction();
export.execute(trackmate);