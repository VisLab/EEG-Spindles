%inDir = 'D:\TestData\Alpha\DrivingSpindles\BCITSupervised';
inDir = 'D:\TestData\Alpha\DrivingSpindles\BCITSupervisedA';
%outFile = 'S1010SpindlesGroupNewC.mat';
outFile = 'S1015SpindlesGroupNewG.mat';
%outFile = 'S1010SpindlesGroupNewG.mat';
outDir = 'D:\TestData\Alpha\DrivingSpindles\BCITSupervisedImagesA';

%% Set the parameters
doPerformance = true;
analyzeSpindles([inDir filesep outFile], outDir, true, false);