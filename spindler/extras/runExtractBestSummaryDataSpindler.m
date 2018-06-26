%% Extract the values of metric metricName based on best baseMetricName
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithms = {'spindler'};
eventExts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summary';
baseMetricName = 'f1';
metricName = 'fdr';
methodName = 'time';

%% Make summary directory if it doesn't exist
if ~exist(summaryDir, 'dir')
    mkdir(summaryDir);
end

%% Now read the data files and find the file parts
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
fileNames = cell(numFiles, 1);
for k = 1:numFiles
    [~, fileNames{k}, ~] = fileparts(dataFiles{k});
end

%% Now extract the values
numAlgorithms = length(algorithms);
numExperts = length(eventExts);
for k = 1:numAlgorithms
   for n = 1:numExperts
       metrics = nan(numFiles, 1);
       dirName = [dataDir filesep 'results_' algorithms{k} '_' eventExts{n}];
       atomInd = nan(numFiles, 1);
       threshInd = nan(numFiles, 1);
       for m = 1:numFiles
           fileName = [dirName filesep fileNames{m} '.mat'];
           if ~exist(fileName, 'file')
               continue;
           end
           test = load(fileName);
           allMetrics = test.additionalInfo.allMetrics;
           if isempty(allMetrics)
               warning('Algorithm: %s file %s has no metrics', ...
                   algorithms{k}, fileName);
               continue;
           end
           theMetric = getMetric(allMetrics, baseMetricName);
           theMetric = theMetric.(methodName);
           [a, aInd] = max(theMetric, [], 2);
           [b, atomInd(m)] = max(a);
           threshInd(m) = aInd(atomInd(m));
           thisMetric = getMetric(allMetrics, metricName);
           thisMetric = thisMetric.(methodName);
           metrics(m) = thisMetric(atomInd(m), threshInd(m));
       end
       outName = [collection '_best_' baseMetricName '_' metricName '_' methodName '_' eventExts{n} '_' algorithms{k} '.mat'];
       %save([summaryDir filesep outName], 'metrics', '-v7.3');
   end
end
           