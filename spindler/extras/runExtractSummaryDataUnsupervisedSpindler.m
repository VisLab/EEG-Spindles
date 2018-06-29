%% Extracts specified metrics for unsupervised spindler
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithm = 'spindler';
experts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
metricNames = {'f1', 'fdr'};
methodNames = {'time'};

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
numExperts = length(experts);
for n = 1:numExperts
    for j = 1:length(metricNames)
        metricName = metricNames{j};
        for i = 1:length(methodNames)
            methodName = methodNames{i};
            metrics = nan(numFiles, 1);
            dirName = [dataDir filesep 'results_' algorithm '_' experts{n}];
            for m = 1:numFiles
                fileName = [dirName filesep fileNames{m} '.mat'];
                if ~exist(fileName, 'file')
                    continue;
                end
                test = load(fileName);
                allMetrics = test.additionalInfo.allMetrics;
                atomInd = test.additionalInfo.spindlerCurves.bestEligibleAtomInd;
                threshInd = test.additionalInfo.spindlerCurves.bestEligibleThresholdInd;
                if isempty(allMetrics) || isempty(atomInd) || isempty(threshInd)
                    warning('Algorithm: %s file %s has no metrics', ...
                            algorithm, fileName);
                    continue;
                end
                theMetric = allMetrics(atomInd, threshInd);
                metrics(m) = theMetric.(methodName).(metricName);
            end
            outName = [collection '_' metricName '_' methodName ...
                '_' experts{n} '_' algorithm '.mat'];
            save([summaryDir filesep outName], 'metrics', '-v7.3');
        end
    end
end