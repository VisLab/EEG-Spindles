inDir = 'D:\TestData\Alpha\DrivingSpindles\BCITSupervised';
%outFile = 'S1010SpindlesGroupNewC.mat';
outFile = 'S1015SpindlesGroupNewG.mat';
%outFile = 'S1010SpindlesGroupNewG.mat';
outDir = 'D:\TestData\Alpha\DrivingSpindles\BCITSupervisedImages';

%% Set the parameters
doPerformance = true;
analyzeSpindles([inDir filesep outFile], outDir, true);