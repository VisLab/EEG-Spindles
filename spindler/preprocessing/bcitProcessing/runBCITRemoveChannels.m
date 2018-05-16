%% Removes channels 65:end from EEG dataset and saves in

%% Read in the file and set the necessary parameters
inDir = 'D:\TestData\Alpha\spindleData\bcit\data';
outDir = 'D:\TestData\Alpha\spindleData\bcit\dataChannelsRemoved';

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
    EEG.data = EEG.data(1:64, :);
    EEG.nbchan = 64;
    EEG.chanlocs = EEG.chanlocs(1:64);
    EEG.icawinv = [];
    EEG.icasphere = [];
    EEG.icaweights = [];
    EEG.icachansind = [];
   
    fname = [outDir filesep thisName '.set'];
    save(fname, 'EEG', '-mat', '-v7.3');
end
