%% Compares the contents of two sets of event files that should be same

%% Set up the locations
% inDir1 = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
% inDir2 = 'D:\TestData\Alpha\spindleData\massNew\eventsOld\expert1';

inDir1 = 'D:\TestData\Alpha\spindleData\massNew\events\expert2';
inDir2 = 'D:\TestData\Alpha\spindleData\massNew\eventsOld\expert2';


%% Get the list of file names
fileNames = getFileListWithExt('FILES', inDir1, '.mat');
numberFiles = length(fileNames);

%% Process the files
for k = 1:numberFiles
   [~, theName, ~] = fileparts(fileNames{k});
   test1 = load(fileNames{k});
   test2 = load([inDir2 filesep theName '.mat']);
   
   %% Make sure both files contain events
   if ~isfield(test1, 'events') || ~isfield(test2, 'events')
       warning('%d (%s): At least one version is missing the events', k, theName);
       continue;
   end
    %% Find the maximum difference
    eventDiff = abs(test1.events - test2.events);
    fprintf('%d (%s): max diff is %g\n', k, theName, max(eventDiff(:)));
end
