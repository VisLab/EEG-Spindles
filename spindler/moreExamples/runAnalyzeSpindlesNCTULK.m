inDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p1';
outDir = 'D:\TestData\Alpha\DrivingSpindles\NCTULK80_MinTime0p1Images';
fileList = getFiles('FILES', inDir, '.mat');

%% Set the parameters
doPerformance = false;
verbose = false;
for k = 1:length(fileList)
   analyzeSpindles(fileList{k}, outDir, doPerformance, verbose);
   close all
end

%%
for k = 1:80
  fprintf('%d:%s\n', k, fileList{k});
end