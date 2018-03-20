%% This script does some renaming of mass event files to conform to spindler

%% Set up the directories
EEGDir = 'D:\TestData\Alpha\spindleData\mass\data';
expertDirs = {'D:\TestData\Alpha\spindleData\mass\annotations\spindlesE1'; ...
              'D:\TestData\Alpha\spindleData\mass\annotations\spindlesE2'};
expertOutDirs = {'D:\TestData\Alpha\spindleData\mass\events\spindlesE1'; ...
              'D:\TestData\Alpha\spindleData\mass\events\spindlesE2'};
suffixNames = {'SpindleE1', 'SpindleE2'};

          %% Create the output directories if it doesn't exist
for k = 1:length(expertOutDirs)
    if ~exist(expertOutDirs{k}, 'dir')
        mkdir(expertOutDirs{k});
    end
end

%% Get the EEG file names
EEGFiles = getFiles('FILES', EEGDir, '.set');
for k = 1:length(EEGFiles)
    [~, theName, ~] = fileparts(EEGFiles{k});
    for m = 1:length(expertDirs)
       eventInName = [expertDirs{m} filesep theName(1:11) suffixNames{m} '.mat'];
       if ~exist(eventInName, 'file')
           continue;
       end
       eventOutName = [expertOutDirs{m} filesep theName '.mat'];
       copyfile(eventInName, eventOutName);
    end
end