%% Removes channels 65:end from EEG dataset and saves in

%% Read in the file and set the necessary parameters
% inDir = 'D:\TestData\Alpha\spindleData\bcit\dataLevel2ICA';
% outDir = 'D:\TestData\Alpha\spindleData\bcit\dataMara';

inDir = 'D:\TestData\Alpha\spindleData\nctu\dataLevel2ICA';
outDir = 'D:\TestData\Alpha\spindleData\nctu\dataMara';

%% Create output directory
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the filelist
fileList = getFileListWithExt('FILES', inDir, '.set');

%% Run the pipeline
for k = 1:length(fileList)
    [~, thisName, ~] = fileparts(fileList{k});
    EEG = pop_loadset(fileList{k});
    [~, EEG, ~] = processMARA(EEG, EEG, 1, [0, 0, 0, 0, 1]);
    fname = [outDir filesep thisName '.set'];
    save(fname, 'EEG', '-mat', '-v7.3');
end
