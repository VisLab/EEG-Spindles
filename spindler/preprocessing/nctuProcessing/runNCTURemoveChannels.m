%% Removes non-EEG channels and adds channel locations

%% Read in the file and set the necessary parameters
inDir = 'D:\TestData\Alpha\spindleData\nctu\data';
inDirLARG = 'D:\TestData\Alpha\spindleData\nctu\dataCleanedLARG';
outDir = 'D:\TestData\Alpha\spindleData\nctu\dataChannelsRemoved';

%% Create output directory
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the filelist
fileList = getFileListWithExt('FILES', inDir, '.set');

%% Run the pipeline
for k = 1:length(fileList)
    [~, theName, ~] = fileparts(fileList{k});
    EEG = pop_loadset(fileList{k});
    EEGLARG = pop_loadset([inDirLARG filesep theName '.set']);
    locsLARG = EEGLARG.chanlocs;
    theseLocs = EEG.chanlocs;
    thisMask = false(size(theseLocs));
    theseLabels = {theseLocs.labels};
    for n = 1:length(theseLabels)
        thisLabel = theseLabels{n};
        if strcmpi(thisLabel(1), 'v')
            thisMask(n) = true;
        end
    end
    if sum(thisMask) > 0
        fprintf('Removing %d vehicle channels\n', sum(thisMask));
    end
    theseLocs(thisMask) = [];
    if length(theseLocs) ~= length(locsLARG)
        warning('%d: number of channels does not match', k);
        continue;
    end
    chanMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    for n = 1:length(locsLARG) 
       chanMap(lower(locsLARG(n).labels)) = locsLARG(n);
    end
    newLocs = locsLARG;
    for n = 1:length(newLocs)
        if ~isKey(chanMap, lower(newLocs(n).labels))
            error('%d %d: could not find matching channel', k, n);
        else
            newLocs(n) = chanMap(lower(newLocs(n).labels));
        end
    end
    EEG.chanlocs = newLocs;
    EEG.data(thisMask, :) = [];
    EEG.nbchan = length(newLocs);
    
    %% Now fix mastoids
    newLabels = {newLocs.labels};
    newMask = strcmpi(newLabels, 'a1') | strcmpi(newLabels, 'a2');
    fprintf('Removing %d more channels\n', sum(newMask));
    EEG.chanlocs(newMask) = [];
    EEG.nbchan = length(EEG.chanlocs);
    EEG.data(newMask, :) = [];
       
    fname = [outDir filesep theName '.set'];
    save(fname, 'EEG', '-mat', '-v7.3');
end
