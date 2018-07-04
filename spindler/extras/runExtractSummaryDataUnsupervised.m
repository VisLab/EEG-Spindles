%% Extracts specified metrics from a collection for various methods
% collection = 'mass';
% dataDir = 'D:\TestData\Alpha\spindleData\massNew';
collection = 'dreams';
dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithms = {'cwta7', 'cwta8', 'sem'};
experts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
metricNames = {'f1', 'fdr'};
methodNames = {'time'};

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
for k = 1:numAlgorithms
    for n = 1:numExperts
        for j = 1:length(metricNames)
            metricName = metricNames{j};
            for i = 1:length(methodNames)
                methodName = methodNames{i};
                metrics = nan(numFiles, 1);
                dirName = [dataDir filesep 'results_' algorithms{k} '_' experts{n}];
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
                outName = [collection '_' metricName '_' methodName ...
                    '_' experts{n} '_' algorithms{k} '.mat'];
                save([summaryDir filesep outName], 'metrics', '-v7.3');
            end
        end
    end
end