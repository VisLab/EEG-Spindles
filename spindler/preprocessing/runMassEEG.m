%% Convert expert event annotations from .edf format to .mat format

%% Set up the locations
EEGOriginalDir = 'E:\MASS\SS2\version2015';
%
%% Get the list of EYE filenames from level 0
fileNames = getFiles('FILES', EEGOriginalDir, '.edf');
numberFiles = length(fileNames);

%% Process the files
for k = 1%:numberFiles
    %[data, header] = lab_read_edf1(fileNames{k});
    [hdr, data] = edfread(fileNames{k});
%     
%     %% See if the file has events
%     if ~isfield(header, 'events') || isempty(header.events)
%         warning('%s has no spindles', fileNames{k});
%         continue;
%     end
%     theEvents = header.events;
%     %% Convert the events to an array
%     [thePath, theName, theExt] = fileparts(fileNames{k});
%     numberEvents = length(theEvents.POS);
%     srate = round(header.samplingrate);
%     startTimes = double(cell2mat({theEvents.POS}) - 1)./srate;
%     endTimes = startTimes + double(cell2mat({theEvents.DUR}))./srate;
%     expert_events = [startTimes(:), endTimes(:)];
%     EEGFile = [EEGDir filesep theName(1:11) 'PSG.set'];
%     if ~exist(EEGFile, 'file')
%         warning('%s does not have an EEG file', fileNames{k});
%         continue;
%     end
%     EEG = pop_loadset(EEGFile);
%     numFrames = size(EEG.data, 2);
%     save([outDir filesep theName '.mat'], 'expert_events', ...
%         'srate', 'numFrames', '-v7.3');
end