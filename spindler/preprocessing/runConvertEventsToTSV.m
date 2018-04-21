inDir = 'D:\TestData\Alpha\spindleData\bcit\events';
outDir = 'D:\TestData\Alpha\spindleData\bcit\eventsTSV';
outDir2Col = 'D:\TestData\Alpha\spindleData\bcit\events2Col';

% inDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% outDir = 'D:\TestData\Alpha\spindleData\nctu\eventsTSV';
% outDir2Col = 'D:\TestData\Alpha\spindleData\nctu\events2Col';
%% Create the out directory
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
if ~exist(outDir2Col, 'dir')
    mkdir(outDir2Col);
end
%% Get the file names
fileNames = getFileListWithExt('FILES', inDir, '.mat');

%% Process the files
for k = 1:length(fileNames)
    test = load(fileNames{k});
    expert_events = test.expert_events;
    expertEvents = cell2mat(expert_events(:, 2:3));
    [thePath, theName, theExt] = fileparts(fileNames{k});
    newFileTSV = [outDir filesep theName, '.tsv'];
    fid = fopen(newFileTSV, 'w');
    for n = 1:length(expertEvents)
        fprintf(fid, '% 12.5f\t% 12.5f\n', expertEvents(n, 1), expertEvents(n, 2));
    end
    fclose(fid);
    newFileMAT = [outDir2Col filesep theName '.mat'];
    save(newFileMAT, 'expertEvents', '-v7.3');
end