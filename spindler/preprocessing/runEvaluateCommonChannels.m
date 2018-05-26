%% Find the file names
inDir = 'D:\TestData\Alpha\spindleData\mass\data';

%% Get the list of EYE filenames from level 0
fileNames = getFileListWithExt('FILES', inDir, '.set');
numberFiles = length(fileNames);
%% Now find the common channels
theLabels = cell(numberFiles, 1);
allLabels = {};
for k = 1:numberFiles    
    EEG = pop_loadset(fileNames{k});
    theLabels{k} = {EEG.chanlocs.labels};
    allLabels = union(allLabels, theLabels{k});
end

labelIndex = true(length(allLabels), numberFiles);
commonLabels = {};
for k = 1:numberFiles
    [x, ia] = setdiff(allLabels, theLabels{k});
    labelIndex(ia, k) = false;
    if isempty(theLabels{k})
        continue;
    elseif isempty(commonLabels)
        commonLabels = theLabels{k};
    else
        commonLabels = intersect(commonLabels, theLabels{k});
    end
end

%
%% 
%save('theChannels.mat', 'theChannels');