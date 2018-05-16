%% Example running ICA on prepped data (no ESS)

%% Read in the file and set the necessary parameters
prepDir = 'D:\TestData\Alpha\spindleData\bcit\dataLevel2';
outDir = 'D:\TestData\Alpha\spindleData\bcit\dataLevel2ICA';

prepDir = 'D:\TestData\Alpha\spindleData\nctu\dataLevel2';
outDir = 'D:\TestData\Alpha\spindleData\nctu\dataLevel2ICA';

%% Make the output directory
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the filelist
fileList = getFileListWithExt('FILES', prepDir, '.set');

%% Run the pipeline
for k = 1:length(fileList)
    [~, thisName, ~] = fileparts(fileList{k});
    EEG = pop_loadset(fileList{k});
    EEG = highPassAndICA(EEG, 'detrendCutoff', 1.0, ...
                        'icatype', 'runica', 'extended', 0);
    fname = [outDir filesep thisName '.set'];
    save(fname, 'EEG', '-mat', '-v7.3');
end
