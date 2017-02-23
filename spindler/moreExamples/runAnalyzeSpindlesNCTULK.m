% inDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p1';
% outDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p1Images';

inDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p2';
outDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p2Images';
outSuffix = '_0p1';

% inDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p05';
% outDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p05Images';
% outSuffix = '_0p05';

%% Read the files
fileList = getFiles('FILES', inDir, '.mat');

%% Set the parameters
doPerformance = false;
verbose = false;
for k = 1:length(fileList)
   analyzeSpindles(fileList{k}, outDir, outSuffix, doPerformance, verbose);
   close all
end