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
eventDir = [];
resultsDir = 'D:\TestData\NCTURWN\spindles\results';
imageDir = 'D:\TestData\NCTURWN\spindles\images';
% paramsInit = struct('figureClose', true, 'figureLevels', 'basic', ...
%                      'spindlerGaborFrequencies', 7:14);
% freqType = 'alpha';
paramsInit = struct('figureClose', true, 'figureLevels', 'basic', ...
                     'spindlerGaborFrequencies', 4:7);
freqType = 'theta';
excludeLabels = {'EKG'; 'EKG1'};
%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES2', dataDir, '.set');

%% Create the output directory if it doesn't exist
if ~exist(resultsDir, 'dir')
    fprintf('Creating results directory %s \n', resultsDir);
    mkdir(resultsDir);
end;
if  ~exist(imageDir, 'dir')
    fprintf('Creating image directory %s \n', imageDir);
    mkdir(imageDir);
end;

%% Process the data
spindleStructInit = struct('channelNumber', NaN, ...
                         'channelLabel', NaN,  'bestEligibleThreshold', NaN, ...
                         'bestEligibleAtomsPerSecond', NaN, ... 
                         'atomRateRange', NaN, 'spindleRateSTD', NaN, ...
                         'warningMsgs', NaN', 'events', NaN);

for k = 207:length(dataFiles)
    %% Read in the EEG and find the correct channel number
    EEG = pop_loadset(dataFiles{k});
    [~, theName, ~] = fileparts(dataFiles{k});
    thisImageDir = [imageDir filesep theName];
    if ~exist(thisImageDir, 'dir')
        mkdir(thisImageDir);
    end
    channelLabels = {EEG.chanlocs.labels};
    clear spindleEvents;
    spindleEvents(length(channelLabels)) = spindlerGetSpindlerEventsStruct();
    channelMask = true(length(channelLabels), 1);
    for n = 1:length(channelMask)
        spindleEvents(n) = spindleStructInit;
        spindleEvents(n).channelNumber = n;
        spindleEvents(n).channelLabel = channelLabels{n};
        if sum(strcmpi(excludeLabels, channelLabels{n})) > 0
            channelMask(n) = false;
            continue;
        end
        
        %% Calculate the spindle representations for a range of parameters
        [spindles, params] = spindlerExtractSpindles(EEG, n, paramsInit);
        params.name = [theName '_Ch_' channelLabels{n} '_' freqType];
        [spindlerCurves, warningMsgs,] = spindlerGetParameterCurves(spindles, thisImageDir, params);
        if spindlerCurves.bestEligibleLinearInd > 0
            events = spindles(spindlerCurves.bestEligibleLinearInd).events;
        end
        params.name = theName;
        spindleEvents(n).bestEligibleThreshold = spindlerCurves.bestEligibleThreshold;
        spindleEvents(n).bestEligibleAtomsPerSecond = ...
        spindlerCurves.bestEligibleAtomsPerSecond;
        spindleEvents(n).atomRateRange = spindlerCurves.atomRateRange;
        spindleEvents(n).spindleRateSTD = spindlerCurves.spindleRateSTD;
        spindleEvents(n).warningMsgs = warningMsgs;
        spindleEvents(n).events = events;
    end
    %% Save the results
    params = rmfield(params, {'channelNumber', 'channelLabel'});
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultsDir filesep freqType filesep fileName, '_', freqType '_spindlerChannelResults.mat'],  ...
         'params', 'spindleEvents', '-v7.3');
end
