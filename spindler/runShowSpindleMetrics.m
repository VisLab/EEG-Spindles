%% Show spindle performance metrics for a directory of datasets

%% Run the spindle parameter selection
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindler';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsImages';

% spindleDir = 'D:\TestData\Alpha\spindleData\nctu\spindles';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\images';

% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindler';

%% Make sure the outDir exists
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end

%% Process the metrics and save
metricNames = {'f1', 'f2', 'G'};
resultsFiles = getFiles('FILES', resultsDir, '.mat');
for k = 1:length(resultsFiles)
    results = load(resultsFiles{k});
    [~, theName, ~] = fileparts(resultsFiles{k});
    for n = 1:length(metricNames)
        figHan = showMetric(results.spindlerParameters, ...
                            results.metrics, metricNames{n});
        saveas(figHan, [imageDir filesep theName '_Metric_' metricNames{n} '.png'], 'png');
    end
end
