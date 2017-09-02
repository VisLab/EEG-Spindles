%% This script shows how to run the Spindler analysis for a data collection
% for all channels (assuming data is in EEGLAB EEG format with EEG channels
% designated. This script is designed to be unsupervised and no training 
% data 
%  
% You must set up the following information (see examples below)
%   dataDir         path of directory containing EEG .set files to analyze
%   eventDir        directory of labeled event files
%   resultsDir      directory that Spindler uses to write its output
%   imageDir        directory that Spindler users to save images
%   summaryFile     full path name of the file containing the summary analysis
%   channelLabels   cell array containing possible channel labels 
%                      (Spindler uses the first label that matches one in EEG)
%   paramsInit      structure containing the parameter values
%                   (if an empty structure, Spindler uses defaults)
%
% Spindler uses the input to run a batch analysis. If eventDir is not empty, 
% Spindler runs performance comparisons, provided it can match file names for 
% files in eventDir with those in dataDir.  Ideally, the event file names 
% should have the data file names as prefixes, although Spindler tries more
% complicated matching strategies as well.  Event files contain "ground truth"
% in text files with two columns containing the start and end times in seconds.
%
% 
%% Example 1: Setup for driving data
dataDir = 'D:\TestData\NCTURWN\raw_data';
resultsBaseDir = 'D:\TestData\NCTURWN\spindles\results';
statsDir = 'D:\TestData\NCTURWN\spindles\stats';
excludeLabels = {'EKG'; 'EKG1'};
roiLabels = {'frontal', 'mid', 'parietal', 'occipital'};
frontalChannels = {'Fp1', 'Fp2', 'Fpz', 'AF3', 'AF4', 'F1', 'F2', 'F3', ...
    'F4', 'F5', 'F6', 'F7', 'F8', 'Fz'};
midChannels = {'FT7', 'FT8', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'FCz', ...
    'T7', 'T8', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'Cz'};
parietalChannels = {'TP7', 'TP8', 'CP1', 'CP2', 'CP3', 'CP4', 'CP5', ...
    'CP6', 'CPz', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'Pz'};
occipitalChannels = {'PO3', 'PO4', 'PO5', 'PO6', 'PO7', 'PO8', 'POz', ...
     'O1', 'O2', 'Oz', 'CB1', 'CB2'};
roiDefs = {frontalChannels; midChannels; parietalChannels; occipitalChannels};
leftChannels = {'Fp1', 'AF3', 'F1', 'F3', 'F5','F7', 'FT7', 'FC1', ...
                'FC3', 'FC5', 'T7', 'C1', 'C3', 'C5', 'TP7', ...
                'CP1', 'CP3', 'CP5', 'P1', 'P3', 'P5', 'P7', ...
                'PO3', 'PO5', 'PO7', 'O1', 'CB1'};
rightChannels = {'Fp2', 'AF4', 'F2', 'F4', 'F6', 'F8', 'FT8', ...
    'FC2', 'FC4', 'FC6', 'T8', 'C2','C4', 'C6', 'TP8', 'CP2', 'CP4', ...
    'CP6', 'P2', 'P4', 'P6', 'P8', 'PO4', 'PO6','PO8', 'O2', 'CB2'};
centerChannels = {'Fpz', 'Fz', 'FCz', 'Cz', 'CPz', 'Pz', 'POz', 'Oz'};
hemiLabels = {'left', 'center', 'right'};
hemiDefs = {leftChannels; centerChannels; rightChannels};
freqType = 'alpha';

%% Get the spindle data files
dataFiles = getFiles('FILES', [resultsBaseDir filesep freqType], '.mat');

%% Create the output directory if it doesn't exist
if ~exist(statsDir, 'dir')
    fprintf('Creating stats directory %s \n', statsDir);
    mkdir(statsDir);
end;


%% Process the data
for k = 2%:length(dataFiles)
    test = load(dataFiles{k});
    params = test.params;
    srate = params.srate;
    totalFrames = params.frames;
    spindleEvents = test.spindleEvents;
    eventMask = zeros(length(spindleEvents), totalFrames);
    for n = 1:length(spindleEvents)
        events = spindleEvents(n).events;
        if isnan(events)
            continue;
        end
        eventFrames = round(events*srate) + 1;
        eventFrames = min(eventFrames, totalFrames);
        for m = 1:length(events)
            eventMask(n, eventFrames(m, 1): eventFrames(m, 2)) = 1;
        end       
    end
    overallFrac = mean(eventMask);
    channelLabels = {spindleEvents.channelLabel};
    roiNumbers = cell(length(roiLabels), 1);
    roiFracs = zeros(totalFrames, length(roiLabels));
    for n = 1:length(roiLabels)
        roiNumbers{n} = getChannelNumbersFromLabels(channelLabels, roiDefs{n});
        roiFracs(:, n) = mean(eventMask(roiNumbers{n}, :))';
    end
    hemiNumbers = cell(length(hemiLabels), 1);
    hemiFracs = zeros(totalFrames, length(hemiLabels));
    for n = 1:length(hemiLabels)
        hemiNumbers{n} = getChannelNumbersFromLabels(channelLabels, hemiDefs{n});
        hemiFracs(:, n) = mean(eventMask(hemiNumbers{n}, :))';
    end
    fprintf('Correlations:\n')
    for n = 1:length(roiLabels)
        for m = n+1:length(roiLabels)
           fprintf('  %s vs %s: %g\n', roiLabels{n}, roiLabels{m}, ...
                  corr(roiFracs(:, n), roiFracs(:, m)));
        end
    end
    for n = 1:length(hemiLabels)
        for m = n+1:length(hemiLabels)
           fprintf('  %s vs %s: %g\n', hemiLabels{n}, hemiLabels{m}, ...
                  corr(hemiFracs(:, n), hemiFracs(:, m)));
        end
    end
    meanTest = mean(eventMask, 2);
    
    %% Save the results
%     params = rmfield(params, {'channelNumber', 'channelLabel'});
%     [~, fileName, ~] = fileparts(dataFiles{k});
%     save([resultsDir filesep fileName, '_spindlerChannelResults.mat'],  ...
%          'params', 'spindleEvents', '-v7.3');
end
