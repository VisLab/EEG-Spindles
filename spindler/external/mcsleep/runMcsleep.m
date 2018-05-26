%% Wrapper to call the Mcsleep algorithms proposed by Parekh et al.

%% Set up the default parameters
defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
paramsInit = processParameters('runMcsleep', 0, 0, struct(), defaults); 

%% Set up the parameters for BCIT
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% channelLabels = {'PO7'};
% defaults = concatenateStructs(getGeneralDefaults(), cwtGetDefaults());
% paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);     
% paramsInit.srateTarget = 100;
% paramsInit.cwtAlgorithm = 'a8';
% paramsInit.cwtSpindleFrequencies = 6:14;
% summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
%     'bcit_Cwt_' paramsInit.cwtAlgorithm '_Summary.mat'];
% resultsDir = ['D:\TestData\Alpha\spindleData\bcit\resultsCwt_' ...
%                paramsInit.cwtAlgorithm];

%% Set up for nctu
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% channelLabels = {'P3'};
% defaults = concatenateStructs(getGeneralDefaults(), cwtGetDefaults());
% paramsInit = processParameters('runCwt', 0, 0, struct(), defaults);     
% paramsInit.srateTarget = 100;
% paramsInit.cwtAlgorithm = 'a8';
% paramsInit.cwtSpindleFrequencies = 6:14;
% summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
%     'nctu_Cwt_' paramsInit.cwtAlgorithm '_Summary.mat'];
% resultsDir = ['D:\TestData\Alpha\spindleData\nctu\resultsCwt_' ...
%                paramsInit.cwtAlgorithm];

%% Set up the directory for dreams
% stageDir = [];
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% channelLabelsFrontal = {'FP1-A1'};
% channelLabelsCentral = {'C3-A1', 'CZ-A1'};
% channelLabelsOccipital = {'O1-A1'};
% paramsInit.srateTarget = 200;
% summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
%     'dreams_McsleepP_Summary.mat'];
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsMcsleepP';
% imagesDir = 'D:\TestData\Alpha\spindleData\dreams\imagesMcsleepP';
% params.lam1 = 0.3;
% params.lam2 = 6.5;
% params.lam3 = 36;
% params.mu = 0.5;
% params.Nit = 80;
% params.K = 200;
% params.O = 100;
% 
% Bandpass filter & Teager operator parameters
% params.f1 = 11;
% params.f2 = 17;
% params.filtOrder = 4;
% params.Threshold = 0.5; 
% 
% % Other function parameters
% % params.fs = 200;
% 
% paramsInit.mcsleepLambda1 = 0.6;
% % paramsInit.mcsleepLambda2 = 7;
% paramsInit.mcsleepLambda3 = 45;
% paramsInit.mcsleepMu = 0.5;
% paramsInit.mcSleepNit = 40;
%% MASS parameters
stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
eventDir = 'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion';
channelLabelsFrontal = {'Fp1'};
channelLabelsCentral = {'Cz'};
channelLabelsOccipital = {'O1'};
paramsInit.srateTarget = 0;
paramsInit.mcsleepK = 256;
paramsInit.mcsleepO = 128;

summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
    'massNew_McsleepR_Summary.mat'];
imageDir = 'D:\TestData\Alpha\spindleData\massNew\imagesMcSleep';
resultsDir = 'D:\TestData\Alpha\spindleData\massNew\resultsMcsleep';
paramsInit.mcsleepLambda0 = 0.6;
paramsInit.mcsleepLambda1 = 7;
paramsInit.mcsleepLambda2s = 20:50;
paramsInit.mcsleepThresholds = 0.5:0.1:3.0;
paramsInit.mcsleepMu = 0.5;
paramsInit.mcSleepNit = 40;

% summaryFile = ['D:\TestData\Alpha\spindleData\ResultSummary\' ...
%     'massNew_Mcsleep_SummaryD.mat'];
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\mcsleepImagesD';
% resultsDir = 'D:\TestData\Alpha\spindleData\massNew\resultsMcsleepD';
% paramsInit.mcsleepLambda1 = 0.3;
% paramsInit.mcsleepLambda3 = 36;
% paramsInit.mcsleepMu = 0.5;
% paramsInit.mcSleepNit = 80;

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
% [summaryDir, ~, ~] = fileparts(summaryFile);
% if ~isempty(summaryDir) && ~exist(summaryDir, 'dir')
%     fprintf('Creating summary directory %s \n', summaryDir);
%     mkdir(summaryDir);
% end


%% Run the algorithm
for k = 1%:length(dataFiles)
    params = paramsInit;    
    [~, theName, ~] = fileparts(dataFiles{k});
    params.name = theName;
 
    [dataCentral, params.srateOriginal, params.channelNumber, params.channelLabel] = ...
        getChannelData(dataFiles{k}, channelLabelsCentral, params.srateTarget);
    [dataFrontal, params.srateOriginal, params.channelNumberFrontal, ...
        params.channelLabelFrontal] = getChannelData(dataFiles{k}, ...
        channelLabelsFrontal, params.srateTarget);  
    [dataOccipital, params.srateOriginal, params.channelNumberOccipital, ...
        params.channelLabelOccipital] = getChannelData(dataFiles{k}, ...
        channelLabelsOccipital, params.srateTarget);     
    if isempty(dataCentral) || isempty(dataFrontal) || isempty(dataOccipital)
        warning('Missing frontral, occipital or central data for %s\n', dataFiles{k});
        continue;
    end
    params.srate = params.srateOriginal;
    data = [dataFrontal; dataCentral; dataOccipital];
    %% Read events and stages if available 
    expertEvents = [];
    if ~isempty(eventDir)
        expertEvents = readEvents([eventDir filesep theName '.mat']);
    end
    
    %% Use the longest stetch in the stage events
    stageEvents = [];
    if ~isempty(stageDir)
        stageStuff = load([stageDir filesep theName '.mat']);
        stageEvents = stageStuff.stage2Events;
        stageLengths = stageEvents(:, 2) - stageEvents(:, 1);
        [maxLength, maxInd] = max(stageLengths);
        eventMask = stageEvents(maxInd, 1) <= expertEvents(:, 1) & ...
                    expertEvents(:, 1) <= stageEvents(maxInd, 2);
        expertEvents = expertEvents(eventMask, :) - stageEvents(maxInd, 1);
        startFrame = max(1, round(stageEvents(maxInd, 1)*params.srate));
        endFrame = min(length(data), round(stageEvents(maxInd, 2)*params.srate));
        data = data(:, startFrame:endFrame);    
    end
   
    %% Now call mcsleep
    [spindles, allMetrics, additionalInfo, params] =  ...
                              mcsleepy(data, expertEvents, imageDir, params); 
    additionalInfo.stageEvents = stageEvents;
    theFile = [resultsDir filesep theName '_mcsleep.mat'];
    save(theFile, 'spindles', 'expertEvents', 'allMetrics', ...
        'params', 'additionalInfo', '-v7.3');
end   