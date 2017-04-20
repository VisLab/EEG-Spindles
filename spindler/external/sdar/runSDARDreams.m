dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';

%% Get the file names
numSubjects = 1;
outFiles = cell(numSubjects, 1);
eventFiles = cell(numSubjects, 1);
for subnum = 1:numSubjects
    outFiles{subnum}=[dataDir filesep 'excerpt' num2str(subnum) '.set'];
    eventFiles{subnum}=[eventDir filesep 'excerpt' num2str(subnum) '_labels.mat'];
end;

doPerformance = true;
freqBounds = [10, 16];
atomScales = [0.125, 0.25, 0.5];
numberAtoms = 200;
freqInc = 1;
atomFrequencies = freqBounds(1):freqInc:freqBounds(2);



%% Load the data
numDatasets = length(outFiles);
eventList = cell(numDatasets, 1);
spindleList = cell(numDatasets, 1);
srateList = cell(numDatasets, 1);
frameList = cell(numDatasets,  1);
numAtomsList = cell(numDatasets, 1);
maxAtoms = 0;
for k = 1:length(outFiles)
    EEG = pop_loadset(outFiles{k});
    load(eventFiles{k});
    EEG=pop_resample(EEG,128);
    
    if k>6
        
        channelList = 3;
        
    else
        channelList=1;
        
    end
    params.channelList=channelList;
    params.atomFrequencies=atomFrequencies;
    params.timeError=.1;    
    params.minLength=.25;
    params.minTime=.25;
    [events, spindles]=newSDAR(EEG, params, expert_events);

    %[events, spindles] = STAMP(EEG, channelList, numberAtoms, atomFrequencies, atomScales, expert_events);
    eventList{k} = events;
    spindleList{k} = spindles;
    srateList{k} = EEG.srate;
    frameList{k} = EEG.pnts;
    numAtomsList{k} = length(spindleList{k});
    maxAtoms = max(maxAtoms, length(spindleList{k}));
end
