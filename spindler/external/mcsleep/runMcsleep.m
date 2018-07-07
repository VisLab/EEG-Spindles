%% Wrapper to call the Mcsleep algorithms proposed by Parekh et al.

%% Set up the default parameters
defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
paramsInit = processParameters('runMcsleep', 0, 0, struct(), defaults); 

%% Set up the directory for dreams
% stageDir = [];
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% channelLabelsFrontal = {'FP1-A1'};
% channelLabelsCentral = {'C3-A1', 'CZ-A1'};
% channelLabelsOccipital = {'O1-A1'};
% paramsInit.srateTarget = 0;
% paramsInit.mcsleepK = 200;
% paramsInit.mcsleepO = 100;
% paramsInit.mcsleepLambda0 = 0.3;
% paramsInit.mcsleepLambda1 = 7;
% paramsInit.mcsleepLambda2s = 20:50;
% paramsInit.mcsleepThresholds = 0.5:0.1:3.0;
% paramsInit.mcsleepMu = 0.5;
% paramsInit.mcSleepNit = 40;


% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_mcsleep_combined';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_mcsleep_combined';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_mcsleep_expert1';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_mcsleep_expert1';

% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\results_mcsleep_expert2';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\images_mcsleep_expert2';

%% MASS parameters
stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
channelLabelsFrontal = {'Fp1'};
channelLabelsCentral = {'Cz'};
channelLabelsOccipital = {'O1'};
paramsInit.srateTarget = 0;
paramsInit.mcsleepK = 256;
paramsInit.mcsleepO = 128;
paramsInit.mcsleepLambda0 = 0.6;
paramsInit.mcsleepLambda1 = 7;
paramsInit.mcsleepLambda2s = 20:50;
paramsInit.mcsleepThresholds = 0.5:0.1:3.0;
paramsInit.mcsleepMu = 0.5;
paramsInit.mcSleepNit = 40;

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_mcsleep_combined';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_mcsleep_combined';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_mcsleep_expert1';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_mcsleep_expert1';

% eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert2';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\images_mcsleep_expert2';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\results_mcsleep_expert2';

%% Bandpass filter & Teager operator parameters
paramsInit.mcsleepFiltOrder = 4;
paramsInit.mcsleepCalculateCost = false;
paramsInit.figureFormats = {'png', 'fig'};
paramsInit.figureClose = true;
%% Metrics to calculate and methods to use
paramsInit.metricNames = {'f1', 'f2', 'G', 'precision', 'recall', 'fdr'};
paramsInit.methodNames = {'count', 'hit', 'intersect', 'onset', 'time'};

%% Get the data and event file names and check that we have the same number
dataFiles = getFileListWithExt('FILES', dataDir, '.set');

%% Create the output and summary directories if they don't exist
if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end

%% Run the algorithm
for k = 1:length(dataFiles)
    params = paramsInit;    
    [~, theName, ~] = fileparts(dataFiles{k});
    params.name = theName;
 
    [dataCentral, srateOriginal, srate, channelNumber, channelLabel] = ...
        getChannelData(dataFiles{k}, channelLabelsCentral, params.srateTarget);
    [dataFrontal, ~, ~, channelNumberFrontal, channelLabelFrontal] = ...
        getChannelData(dataFiles{k}, channelLabelsFrontal, params.srateTarget);  
    [dataOccipital, ~, ~, channelNumberOccipital, channelLabelOccipital] = ...
        getChannelData(dataFiles{k}, channelLabelsOccipital, params.srateTarget);     
    if isempty(dataCentral) || isempty(dataFrontal) || isempty(dataOccipital)
        warning('Missing frontral, occipital or central data for %s\n', dataFiles{k});
        continue;
    end
    data = [dataFrontal; dataCentral; dataOccipital];
    %% Read events and stages if available 
    expertEvents = readEvents(eventDir, [theName '.mat']);
    stageEvents = readEvents(stageDir, [theName '.mat']);
    
    %% Use the longest stretch in the stage events
    [data, startFrame, endFrame, expertEvents] = ...
         getMaxStagedData(data, stageEvents, expertEvents, srate);
   
     %% Now call mcsleep
     [spindles, params, additionalInfo] =  ...
         mcsleepy(data, srate, expertEvents, imageDir, params);
     additionalInfo.srate = srate;
     additionalInfo.srateOriginal = srate;
     additionalInfo.channelNumber = channelNumber;
     additionalInfo.channelLabel = channelLabel;
     additionalInfo.channelNumberFrontal = channelNumberFrontal;
     additionalInfo.channelLabelFrontal = channelLabelFrontal;
     additionalInfo.channelNumberOccipital = channelNumberOccipital;
     additionalInfo.channelLabelOccipital = channelLabelOccipital;
     additionalInfo.startFrame = startFrame;
     additionalInfo.endFrame = endFrame;
     additionalInfo.stageEvents = stageEvents;
     theFile = [resultsDir filesep theName '.mat'];
     save(theFile, 'spindles', 'expertEvents', 'params', 'additionalInfo', '-v7.3');
end