%% This script creates a mask of a sleep stage for an EEG sleep file
EEGDir = 'E:\MASS\SS2\level0';
stageDir = 'D:\TestData\Alpha\spindleData\mass\annotations\stages';
maskDir = 'D:\TestData\Alpha\spindleData\mass\annotations\stage2Events';
stage = '2';

%% Make sure output directory exists
if ~exist(maskDir, 'dir')
    mkdir(maskDir);
end

%% Get the EEG file names
EEGFiles = getFiles('FILES', EEGDir, '.set');
numFiles = length(EEGFiles);

%% Process the files
compareString = ['Sleep_stage_' stage];
maxMinutes = zeros(numFiles, 1);
for k = 1:numFiles
    EEG = pop_loadset(EEGFiles{k});
    [~, theName, ~] = fileparts(EEGFiles{k});
    baseFile = [stageDir filesep theName(1:11) 'Base.mat'];
    if ~exist(baseFile, 'file')
        warning('%s does not exist', baseFile);
        continue;
    end
    numFrames = size(EEG.data, 2);
    srate = EEG.srate;
    stageMask = false(1, numFrames);

    test = load(baseFile);
    events = test.expert_events;
    startPos = 0;
    numEvents = size(events, 1);
    while startPos < numEvents
        startPos = startPos + 1;
        if ~strcmpi(events{startPos, 1}, compareString)
            continue;
        end
        endPos = startPos;
        while endPos < numEvents && ...
            strcmpi(events{endPos + 1, 1}, compareString) 
            endPos = endPos + 1;
        end
        startFrame = min(round(events{startPos, 2}*srate) + 1, numFrames);
        endFrame = min(round(events{endPos, 3}*srate) + 1, numFrames);
        stageMask(startFrame:endFrame) = true;
        startPos = endPos + 1;
    end
    stageEvents = getMaskEvents(stageMask, srate);
    maxMinutes(k) = max((stageEvents(:, 2) - stageEvents(:, 1))/60);
    save([maskDir filesep theName(1:11) 'Base.mat'], ...
         'stageMask', 'stageEvents', 'srate', '-v7.3');
end    