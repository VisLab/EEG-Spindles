%% Read the expert ratings for mass spindles
% inDir = 'E:\MASS\SS2\annotations\spindle_e1_edf';
% outDir = 'D:\TestData\Alpha\spindleData\mass\spindlesE1';

inDir = 'E:\MASS\SS2\annotations\spindle_e2_edf';
outDir = 'D:\TestData\Alpha\spindleData\mass\spindlesE2';

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
    expertEvents = zeros(numberEvents, 2);
    expertEventTypes = cell(numberEvents, 1);
    srate = header.samplingrate;
    for n = 1:length(theEvents.TYP)
       expertEventTypes{n} = theEvents.TYP{n};
       expertEvents(n, 1) = double(theEvents.POS(n) - 1)./srate;
       expertEvents(n, 2) = ...
           double(theEvents.POS(n) + theEvents.DUR(n) - 1)./srate;
    end
    baseName = [theName(1:11) 'PSG.mat'];
    save([outDir filesep baseName '.mat'], 'expertEvents', 'srate', ...
                                           'expertEventTypes',  '-v7.3');
end