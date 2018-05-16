%% Runs the Prep pipeline for a directory .set files

%% Set up the directories for the container
% inDir = 'D:\TestData\Alpha\spindleData\bcit\dataChannelsRemoved';
% outDir = 'D:\TestData\Alpha\spindleData\bcit\dataLevel2';

inDir = 'D:\TestData\Alpha\spindleData\nctu\dataChannelsRemoved';
outDir = 'D:\TestData\Alpha\spindleData\nctu\dataLevel2';
%% Make the output directory
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the input files
fileNames = getFileListWithExt('FILES', inDir, '.set');

%% Make sure level1 container okay
paramsInit = struct();
paramsInit.detrendType = 'high pass';
paramsInit.detrendCutoff = 1;
paramsInit.referenceType = 'robust';
paramsInit.meanEstimateType = 'median';
paramsInit.interpolationOrder = 'post-reference';
paramsInit.removeInterpolatedChannels = false;
paramsInit.keepFiltered = false;
for k = 1:length(fileNames)
    [~, thisName, ~] = fileparts(fileNames{k});
    EEG = pop_loadset(fileNames{k}); 
    [EEG, params, computationTimes] = prepPipeline(EEG, paramsInit);
    params.name = thisName;
    fprintf('Computation times (seconds):\n   %s\n', ...
        getStructureString(computationTimes));
    fprintf('Post-process\n');
    EEG = prepPostProcess(EEG, params);
    fname = [outDir filesep thisName '.set'];
    save(fname, 'EEG', '-mat', '-v7.3'); 
end