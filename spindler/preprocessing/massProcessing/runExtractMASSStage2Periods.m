%% Read the annotation files for sleep stages

%% Set up the locations
inDir = 'D:\TestData\Alpha\spindleData\mass\events\stages20Seconds';
outDir = 'D:\TestData\Alpha\spindleData\mass\stage2Events';

%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the list of EYE filenames from level 0
fileNames = getFileListWithExt('FILES', inDir, '.mat');

%%
for k = 1%:length(fileNames)
    test = load(fileNames{k});
    expertEvents = test.expertEvents;
    expertEventTypes = test.expertEventTypes;
    events = getStageList(expertEvents, expertEventTypes, '2');
   
    %save([outDir filesep baseName '.mat'], 'expertEvents', 'srate', ...
     %                                      'expertEventTypes',  '-v7.3');
end