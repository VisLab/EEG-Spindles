%% Read the expert ratings for mass spindles
inDir = 'D:\TestData\Alpha\spindleData\massNew\eventsEDF\expert1';
outDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';

% inDir = 'D:\TestData\Alpha\spindleData\massNew\eventsEDF\expert2';
% outDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert2';

%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the list of EYE filenames from level 0
fileNames = getFileListWithExt('FILES', inDir, '.edf');

%%
for k = 1:length(fileNames)
    [data, header] = lab_read_edf1(fileNames{k});
    %% See if the file has events
    if ~isfield(header, 'events') || isempty(header.events)
        warning('%s has no events', fileNames{k});
        continue;
    end
    theEvents = header.events;
    %% Open the file to write the text
    [thePath, theName, theExt] = fileparts(fileNames{k});
    numberEvents = length(theEvents.POS);
    events = zeros(numberEvents, 2);
    eventTypes = cell(numberEvents, 1);
    srate = header.samplingrate;
    for n = 1:length(theEvents.TYP)
       eventTypes{n} = theEvents.TYP{n};
       events(n, 1) = double(theEvents.POS(n) - 1)./srate;
       events(n, 2) = ...
           double(theEvents.POS(n) + theEvents.DUR(n) - 1)./srate;
    end
    save([outDir filesep theName(1:11) 'PSG.mat'], 'events', '-v7.3');
end