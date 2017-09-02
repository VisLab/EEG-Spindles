%% This script shows how to call spindlerAllChannels for the NCTU-RWN data

%% Set up for the NCTU data
dataDir = 'D:\TestData\NCTURWN\raw_data';
eventDir = [];
resultsDir = 'D:\TestData\NCTURWN\spindles\results';
imageDirBase = '';
%imageDirBase = 'D:\TestData\NCTURWN\spindles\images';
% paramsInit = struct('figureClose', true, 'figureLevels', 'basic', ...
%                      'spindlerGaborFrequencies', 7:14);
% freqType = 'alpha';
% paramsInit = struct('figureClose', true, 'figureLevels', 'basic', ...
%                      'spindlerGaborFrequencies', 4:7);
paramsInit = struct('spindlerGaborFrequencies', 4:7);
freqType = 'theta';
excludeLabels = {'EKG'; 'EKG1'};

%% Get the EEG data files
dataFiles = getFiles('FILES2', dataDir, '.set');

%% Create the output directories if they doesn't exist
if ~exist(resultsDir, 'dir')
    fprintf('Creating results directory %s \n', resultsDir);
    mkdir(resultsDir);
end;
resultTypeDir = [resultsDir filesep freqType];
if ~exist(resultTypeDir, 'dir')
    fprintf('Creating results directory %s \n', resultTypeDir);
    mkdir(resultTypeDir);
end;
if ~isempty(imageDirBase) && ~exist(imageDirBase, 'dir')
    fprintf('Creating image directory %s \n', imageDirBase);
    mkdir(imageDirBase);
end;


%% Process the data
for k = 1%:length(dataFiles)
    %% Read in the EEG and set up the names
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    baseName  = [theName '_' freqType];
    
    %% Find the image directory name for this EEG
    if ~isempty(imageDirBase)
        imageDir = [imageDirBase filesep theName];
    else
        imageDir = '';
    end 
    
    %% Remove non-EEG channels before proceeding
    EEG = removeChannels(EEG, true, excludeLabels, {});

    %% Get the spindle events for this EEG dataset
    [spindleEvents, params] = ...
                 spindlerAllChannels(EEG, imageDir, baseName, paramsInit);
    
    %% Save the spindle events and parameters
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultTypeDir filesep fileName, '_', freqType '_spindlerChannelResults.mat'],  ...
         'params', 'spindleEvents', '-v7.3');
end
