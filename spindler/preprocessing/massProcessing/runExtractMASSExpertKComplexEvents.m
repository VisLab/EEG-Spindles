%% Set up the locations
%inDir = 'E:\MASS\SS2\annotations\spindle_e1_edf';
%inDir = 'E:\MASS\SS2\annotations\spindle_e2_edf';
inDir = 'E:\MASS\SS2\annotations\complexes_e1';
outDir = 'E:\MASS\SS2\annotationsExtracted';
%eventType = 'sleepspindle';
eventType = 'kcomplex';
%% Get the list of EYE filenames from level 0
inList = dir(inDir);
names = {inList(:).name};
dirTypes = [inList(:).isdir];
fileNames = names(~dirTypes);
mark = true(size(fileNames));
for k = 1:length(fileNames)
    [myPath, myName, myExt] = fileparts(fileNames{k});
    if ~strcmpi(myExt, '.edf')
        mark(k) = false;
    end
end
fileNames = fileNames(mark);
numberFiles = length(fileNames);

%%
for k = 1:numberFiles
    pathName = [inDir filesep fileNames{k}];
    [data, header] = lab_read_edf1(pathName);
    
    %% See if the file has events
    if ~isfield(header, 'events') || isempty(header.events)
        warning('%s has no events', pathName);
        continue;
    end
    theEvents = header.events;
    %% Open the file to write the text
    [thePath, theName, theExt] = fileparts(pathName);
    numberEvents = length(theEvents.POS);
    expert_events = cell(numberEvents, 3);
    srate = round(header.samplingrate);
    for n = 1:length(theEvents.TYP)
       expert_events{n, 1} = eventType;
       expert_events{n, 2} = double(theEvents.POS(n) - 1)./srate;
       expert_events{n, 3} = ...
           double(theEvents.POS(n) + theEvents.DUR(n) - 1)./srate;
    end
    save([outDir filesep theName '.mat'], 'expert_events', 'srate', '-v7.3');
end