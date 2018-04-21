%% This script reads in and convert the EDF formats to EEG

%% Set up the locations
inDir = 'E:\MASS\SS2\version2015';
outDir = 'E:\MASS\SS2\level0A';

%% Make the output directory
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the list of EYE filenames from level 0
fileNames = getFileListWithExt('FILES', inDir, '.edf');

%% Now read the EEG files using edfread;
for k = 1:length(fileNames)
    fprintf('Processing %s...\n', fileNames{k});
    [EEG, hdr] = extractSleepEEG(fileNames{k});
    %% Now eliminate the channels that are empty from each dataset
    data = EEG.data;
    chans = EEG.chanlocs;
    dataIsnan = sum(~isnan(data) & data ~= 0, 2) ~= 0;
    data = data(dataIsnan, :);
    chans = chans(dataIsnan);
    samplingRates = round(hdr.samples(dataIsnan)./hdr.duration);
    EEGchans = strcmpi({chans.type}, 'EEG');
    EEG.chanlocs = chans;
    EEG.data = data;
    EEG.nbchan = length(chans);
    
    %% Now determine the actual size of the data based on EEG
    EEGdata = data(EEGchans, :);
    EEGNonZero = sum(abs(EEGdata));
    lastEEGIndex = find(EEGNonZero ~= 0, 1, 'last');
    if lastEEGIndex ~= length(EEGNonZero)
        warning('Truncating EEG at %d from frame %d\n', lastEEGIndex, ...
            length(EEGNonZero));
        EEG.data = EEG.data(:, 1:lastEEGIndex);
        EEG.times = EEG.times(1:lastEEGIndex);
        EEG.pnts = size(EEG.data, 2);
    end
    [thePath, theName, theExt] = fileparts(fileNames{k});
    EEG.setname = theName;
    save([outDir filesep theName '.set'], 'EEG', '-v7.3');
end

