%% This compares the spindles computed in two reprsentations for dataset
%  
%
% 
%% Set up the data directories
dataDir1 = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_LARG\results\alpha';
dataDir2 = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_MARA\results\alpha';
freqType1 = 'alpha';
freqType2 = 'alpha';
compareDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\CompareMaraVsLargAlpha';
%% Get the spindle data files
dataFiles = getFileListWithExt('FILES', dataDir1, '.mat');

%% Create the output directory if it doesn't exist
if ~exist(compareDir, 'dir')
    fprintf('Creating comparison directory %s \n', compareDir);
    mkdir(compareDir);
end

%% Process the data
for k = 1%:length(dataFiles)
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
 
    meanTest = mean(eventMask, 2);
    
    %% Save the results
%     params = rmfield(params, {'channelNumber', 'channelLabel'});
%     [~, fileName, ~] = fileparts(dataFiles{k});
%     save([resultsDir filesep fileName, '_spindlerChannelResults.mat'],  ...
%          'params', 'spindleEvents', '-v7.3');
end
