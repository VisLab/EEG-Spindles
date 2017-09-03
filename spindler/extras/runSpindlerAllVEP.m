%% This script shows how to run the Spindler analysis for a data collection
% for all channels (assuming data is in EEGLAB EEG format with EEG channels
% designated). This script is designed to be unsupervised and does not use
% training data nor compute performance measures. It is designed to be run 
% on unlabeled data.
%  
% You must set up the following information (see examples below)
%   dataDir         path of directory containing EEG .set files to analyze
%   resultsDir      directory that Spindler uses to write its output
%   imageDirBase    directory that Spindler users to save images (or empty)
%   paramsInit      structure containing the parameter values
%                   (if an empty structure, Spindler uses defaults)
%   freqType        string with type of band -- used for creating names
%                   (this example only)
%
% 
%% Set up the directories
% dataDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG';
% resultsDir = 'D:\TestData\Alpha\spindleData\VEP_PREP_ICA_VEP2_LARG\results';
% imageDir = 'D:\TestData\Alpha\spindleData\VEP_PREP_ICA_VEP2_LARG\images';
% dataDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA';
% resultsDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_MARA\results';
% imageDirBase = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_MARA\images';
% 
% % paramsInit = struct('figureClose', true, 'figureLevels', 'basic', ...
% %                      'spindlerGaborFrequencies', 7:14);
% % freqType = 'alpha';
% paramsInit = struct('figureClose', true, 'figureLevels', 'basic', ...
%                      'spindlerGaborFrequencies', 4:7);
% freqType = 'theta';
dataDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG';
resultsDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_LARG\results';

% dataDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA';
% resultsDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_MARA\results';

imageDirBase = '';

% paramsInit = struct('spindlerGaborFrequencies', 7:14);
% freqType = 'alpha';

paramsInit = struct('spindlerGaborFrequencies', 4:7);
freqType = 'theta';

%% Get the EEG data files (example assumes all in one directory)
dataFiles = getFiles('FILES', dataDir, '.set');

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
for k = 13:length(dataFiles)
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
    
    %% Get the spindle events for this EEG dataset
    [spindleEvents, params] = spindlerAllChannels(EEG, imageDir, baseName, paramsInit);
    
    %% Save the spindle events and parameters
    [~, fileName, ~] = fileparts(dataFiles{k});
    save([resultTypeDir filesep fileName, '_', freqType '_spindlerChannelResults.mat'],  ...
         'params', 'spindleEvents', '-v7.3');
end
