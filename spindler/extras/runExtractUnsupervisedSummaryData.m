%% Extracts data for a particular collection
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
algorithms = {'cwta7', 'cwta8', 'sem'};
eventExts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summary';
metricName = 'fdr';
methodName = 'time';


%% Get the data files
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
           metrics(m) = allMetrics.(methodName).(metricName);
       end
       outName = [metricName '_' methodName '_' eventExts{n} '_' algorithms{k} '.mat'];
       save([summaryDir filesep outName], 'metrics', '-v7.3');
   end
end
           