EEGDir = 'D:\TestData\Alpha\spindleData\mass\data';
%% Get the EEG file names
EEGFiles = getFiles('FILES', EEGDir, '.set');
numFiles = length(EEGFiles);

for k = 1:numFiles
    EEG = pop_loadset(EEGFiles{k});
    EEG.setname = EEG.name;
    EEG.filename = EEG.fileName;
    EEG = rmfield(EEG, {'name', 'fileName'});
    [thePath, theName, theExt] = fileparts(EEGFiles{k});
    
    pop_saveset(EEG, 'filename', [theName theExt], 'filepath', thePath, ...
        'version', '7.3');
end
