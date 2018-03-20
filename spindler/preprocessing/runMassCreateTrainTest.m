%% This script creates training and test data sets for MASS S2 as follows:
%  The two largest segments of stage 2 sleep are selected -- the largest
%  is train, the next is for test.
%
EEGDir = 'D:\TestData\Alpha\spindleData\mass\data';
stage2Dir = 'D:\TestData\Alpha\spindleData\mass\annotations\stage2Events';
expert1Dir = 'D:\TestData\Alpha\spindleData\mass\annotations\spindlesE1';
expert2Dir = 'D:\TestData\Alpha\spindleData\mass\annotations\spindlesE2';
EEGTestDir = 'D:\TestData\Alpha\spindleData\mass\dataTest';
EEGTrainDir = 'D:\TestData\Alpha\spindleData\mass\dataTrain';
eventTrainDir = 'D:\TestData\Alpha\spindleData\mass\eventsTrain';
eventTestDir = 'D:\TestData\Alpha\spindleData\mass\eventsTest';
%% Get the EEG file names
EEGFiles = getFiles('FILES', EEGDir, '.set');
numFiles = length(EEGFiles);

%% Process the files
maxMinutes = zeros(numFiles, 2);
for k = 1:numFiles
    EEG = pop_loadset(EEGFiles{k});
    [~, theName, theExt] = fileparts(EEGFiles{k});
    baseFile = [stage2Dir filesep theName(1:11) 'Base.mat'];
    if ~exist(baseFile, 'file')
        warning('%s does not exist', baseFile);
        continue;
    end
    numFrames = size(EEG.data, 2);
    srate = EEG.srate;
    EEGOriginal = EEG;
    base = load(baseFile);
    events = base.stageEvents;
    eventDurations = events(:, 2) - events(:, 1);
    [~, sortedIndices] = sort(eventDurations, 'descend');
    
    %% Save the training EEG set
    trainStartTime = events(sortedIndices(1), 1);
    trainEndTime = events(sortedIndices(1), 2);
    trainStartFrame = min(round(trainStartTime*srate) + 1, numFrames);
    trainEndFrame = min(round(trainEndTime*srate) + 1, numFrames);
    numTrainFrames = trainEndFrame - trainStartFrame + 1;
    EEG.data = EEG.data(:, trainStartFrame:trainEndFrame);
    EEG.pnts = size(EEG.data, 2);
    EEG.times = EEG.times(trainStartFrame:trainEndFrame);
    EEG.xmax = (EEG.pnts - 1)./srate;
    pop_saveset(EEG, 'filename', [theName theExt], ...
        'filepath', EEGTrainDir, 'version', '7.3', 'savemode', 'onefile');
    
    %% Save the test EEG set
    testStartTime = events(sortedIndices(2), 1);
    testEndTime = events(sortedIndices(2), 2);
    testStartFrame = min(round(testStartTime*srate) + 1, numFrames);
    testEndFrame = min(round(testEndTime*srate) + 1, numFrames);
    numTestFrames = testEndFrame - testStartFrame + 1;
    EEG = EEGOriginal;
    EEG.data = EEG.data(:, testStartFrame:testEndFrame);
    EEG.pnts = size(EEG.data, 2);
    EEG.times = EEG.times(testStartFrame:testEndFrame);
    EEG.xmax = (EEG.pnts - 1)./srate;
    pop_saveset(EEG, 'filename', [theName theExt], ...
        'filepath', EEGTestDir, 'version', '7.3', 'savemode', 'onefile');
    
    %% Save expert ratings
    expert1File = [expert1Dir filesep theName(1:11) 'SpindleE1.mat'];
    expert2File = [expert2Dir filesep theName(1:11) 'SpindleE2.mat'];
    numFrames = numTrainFrames; %#ok<NASGU>
    events = readEvents(expert1File, trainStartTime, trainEndTime);   
    if ~isempty(events)
        save([eventTrainDir filesep 'expert1' theName(1:11) 'SpindleE1.mat'], ...
              'events', 'srate', 'numFrames', '-v7.3');
    end
    events = readEvents(expert2File, trainStartTime, trainEndTime);   
    if ~isempty(events)
        save([eventTrainDir filesep 'expert2' theName(1:11) 'SpindleE2.mat'], ...
              'events', 'srate', 'numFrames', '-v7.3');
    end
    
    numFrames = numTestFrames;
    events = readEvents(expert1File, testStartTime, testEndTime);   
    if ~isempty(events)
        save([eventTestDir filesep 'expert1' filesep theName(1:11) 'SpindleE1.mat'], ...
              'events', 'srate', 'numFrames', '-v7.3');
    end
    events = readEvents(expert2File, testStartTime, testEndTime);   
    if ~isempty(events)
        save([eventTestDir filesep 'expert2' filesep theName(1:11) 'SpindleE2.mat'], ...
              'events', 'srate', 'numFrames', '-v7.3');
    end
end    