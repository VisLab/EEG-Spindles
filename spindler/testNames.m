dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
dataFiles = getFiles('FILES', dataDir, '.set');
eFiles = getFiles('FILES', eventDir, '.mat');

 [eventFiles, leftOvers] = matchFileNames(dataFiles, eFiles);