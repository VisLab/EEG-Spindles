%% Extracts specified metrics from a collection for various methods
% collection = 'mass';
% dataDir = 'D:\TestData\Alpha\spindleData\massNew';
collection = 'dreams';
dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithms = {'spindler', 'mcsleep', 'spinky'};
experts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summarySupervised';
baseMetricName = 'f1';
metricNames = {'f1', 'fdr'};
methodName = 'time';
crossFraction = 0.5;

%% Make sure summary directory exists
if ~exist(summaryDir, 'dir')
    mkdir(summaryDir);
end

%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
fileNames = cell(numFiles, 1);
for k = 1:numFiles
    [~, fileNames{k}, ~] = fileparts(dataFiles{k});
end

%% Now extract the values
numAlgorithms = length(algorithms);
numExperts = length(experts);
crossInit(numFiles) = getCrossMetrics('');
for k = 1:numFiles
    crossInit(k) = crossInit(end);
end

for k = 1:numAlgorithms
    for n = 1:numExperts
        crossMetrics = crossInit;
        dirName = [dataDir filesep 'results_' algorithms{k} '_' experts{n}];
        for m = 1:numFiles
            fileName = [dirName filesep fileNames{m} '.mat'];
            crossMetrics(m) = getCrossMetrics(fileName, crossFraction, ...
                methodName, baseMetricName, metricNames);
        end
        outName = [collection '_' baseMetricName '_' methodName ...
            '_' experts{n} '_' algorithms{k} '.mat'];
        save([summaryDir filesep outName], 'crossMetrics', '-v7.3');
        
        
    end
end