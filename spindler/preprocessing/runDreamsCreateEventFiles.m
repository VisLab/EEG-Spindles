%% Converts the dreams event .txt files to .mat files
%% 
%% This function assumes that event and EEG files are named similarly
%  Spindler uses start and end times for event representations rather than
%  start and end times
%
%% Set up the locations
EEGDir = 'D:\TestData\Alpha\spindleData\dreams\data';
inDir = 'D:\TestData\Alpha\spindleData\dreams\annotations\expert1';
outDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert1';
% inDir = 'D:\TestData\Alpha\spindleData\dreams\annotations\expert2';
% outDir = 'D:\TestData\Alpha\spindleData\dreams\events\expert2';
%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end;

%% Get the list of EEG filenames 
EEGFiles = getFiles('FILES', EEGDir, '.set');
numFiles = length(EEGFiles);

%% Match expert event files with EEG files
for k = 1:numFiles
    [~, theName, ~] = fileparts(EEGFiles{k});
    filePath = [inDir filesep theName, '.txt'];
    if ~exist(filePath, 'file')
       warning('%d: %s does not exist', k, filePath);
       continue;
    end
    events = load(filePath);
    EEG = pop_loadset(EEGFiles{k});
    srate = EEG.srate;
    numFrames = size(EEG.data, 2);
    if ~isempty(events)
        events(:, 2) = events(:, 1) + events(:, 2);
    end
    save([outDir filesep theName '.mat'], 'events', 'srate', 'numFrames', '-v7.3');
end
