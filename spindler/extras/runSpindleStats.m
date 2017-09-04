%% This script calculates basic spindle stats for results files in a directory
% You must specify the results directory and the full path of stats file
%
%% Set up the directories for saving the stats
% resultsDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_MARA\results\alpha';
% statsFile = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\stats\VEP_PREP_ICA_VEP2_MARA_alpha.mat';

resultsDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_MARA\results\theta';
statsFile = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\stats\VEP_PREP_ICA_VEP2_MARA_theta.mat';
%% Get the spindle data files and initialize the structure
dataFiles = getFiles('FILES', resultsDir, '.mat');
numFiles = length(dataFiles);
spindleStats(numFiles) = struct('fileName', NaN, 'chanlocs', NaN, ...
       'srate', NaN, 'timeFraction', NaN, ...
       'spindleRate', NaN, 'spindleLength', NaN,  'spindleFraction', NaN);

%% Process the data
for k = 1:length(dataFiles)
    test = load(dataFiles{k});
    spindleStats(k) = spindleStats(end);
    spindleStats(k).fileName = dataFiles{k};
    params = test.params;
    srate = params.srate;
    spindleStats(k).srate = srate;
    totalFrames = params.frames;
    spindleStats(k).chanlocs = params.chanlocs;
    spindleEvents = test.spindleEvents;
    
    numChans = length(spindleEvents);
    spindleLength = nan(numChans, 1);
    spindleRate = nan(numChans, 1);
    spindleFraction = nan(numChans, 1);
    eventMask = zeros(numChans, totalFrames);
    totalSeconds = (totalFrames - 1)/srate;
    totalMinutes = totalSeconds/60;
    for n = 1:numChans
        events = spindleEvents(n).events;
        if isnan(events)
            continue;
        end
        numEvents = size(events, 1);
        spindleLength(n) = mean(events(:, 2) - events(:, 1));
        eventFrames = round(events*srate) + 1;
        eventFrames = min(eventFrames, totalFrames);
        spindleRate(n) = numEvents/totalMinutes;
        spindleFraction(n) = spindleLength(n)*numEvents./totalSeconds;
        for m = 1:numEvents
            eventMask(n, eventFrames(m, 1): eventFrames(m, 2)) = 1;
        end       
    end
    spindleStats(k).spindleRate = spindleRate;
    spindleStats(k).spindleLength = spindleLength;
    spindleStats(k).spindleFraction = spindleFraction;
    spindleStats(k).timeFraction = mean(eventMask);
end

%% Save the results
save(statsFile, 'spindleStats', '-v7.3');
