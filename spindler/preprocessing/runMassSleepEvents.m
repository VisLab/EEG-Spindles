%% Convert expert event annotations from .edf format to .mat format

%% Set up the locations
EEGDir = 'D:\TestData\Alpha\spindleData\mass\data';
% inDir = 'E:\MASS\SS2\annotations\spindle_e1_edf';
% outDir = 'D:\TestData\Alpha\spindleData\mass\annotations\spindlesE1';
inDir = 'E:\MASS\SS2\annotations\spindle_e2_edf';
outDir = 'D:\TestData\Alpha\spindleData\mass\annotations\spindlesE2';

%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end;

%% Get the list of EYE filenames from level 0
fileNames = getFiles('FILES', inDir, '.edf');
numberFiles = length(fileNames);

%% Process the files
for k = 1:numberFiles
    [data, header] = lab_read_edf1(fileNames{k});
    
    %% See if the file has events
    if ~isfield(header, 'events') || isempty(header.events)
        warning('%s has no spindles', fileNames{k});
        continue;
    end
    theEvents = header.events;
    %% Convert the events to an array
    [thePath, theName, theExt] = fileparts(fileNames{k});
    numberEvents = length(theEvents.POS);
    srate = round(header.samplingrate);
    startTimes = double(cell2mat({theEvents.POS}) - 1)./srate;
    endTimes = startTimes + double(cell2mat({theEvents.DUR}))./srate;
    events = [startTimes(:), endTimes(:)];
    EEGFile = [EEGDir filesep theName(1:11) 'PSG.set'];
    if ~exist(EEGFile, 'file')
        warning('%s does not have an EEG file', fileNames{k});
        continue;
    end
    EEG = pop_loadset(EEGFile);
    numFrames = size(EEG.data, 2);
    save([outDir filesep theName '.mat'], 'events', 'srate', 'numFrames', '-v7.3');
end