%% Extracts data for a particular collection of unsupervised algorithms
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithmsUnsupervised = {'spindler', 'cwta7', 'cwta8', 'sem'};
algorithmsSupervised = {'spindler', 'mcsleep', 'spinky'};
experts = {'expert1', 'expert2'};
baseMetricName = 'f1';
methodName = 'time';
metricNames = {'f1', 'fdr'};
summaryDirUnsupervised = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
summaryDirSupervised = 'D:\TestData\Alpha\spindleData\summarySupervised';
supervisedFileBase = ...
    [summaryDirSupervised filesep collection '_' baseMetricName '_' methodName '_'];


%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
numMetrics = length(metricNames);
numExperts = length(experts);
baseFile = [summaryDirUnsupervised filesep collection '_properties_'];
test1 = load([baseFile experts{1} '.mat']);
events1 = test1.eventSummary{1};
test2 = load([baseFile experts{2} '.mat']);
events2 = test2.eventSummary{1};
totalTime = test2.totalTimes(1);
params = struct();
params.srate = test2.samplingRates(1);

metrics1 = ...
        getPerformanceMetrics(events1, events2,  totalTime, params);
