%% Show spindle performance metrics for a directory of datasets

%% Run the spindle parameter selection
% spindleDir = 'D:\TestData\Alpha\spindleData\BCIT\spindles';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\images';

% spindleDir = 'D:\TestData\Alpha\spindleData\nctu\spindles';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\images';

spindleDir = 'D:\TestData\Alpha\spindleData\dreams\spindles';
imageDir = 'D:\TestData\Alpha\spindleData\dreams\images';

%% Make sure the outDir exists
if ~exist(imageDir, 'dir')
    mkdir(imageDir);
end

%% Process the metrics and save
metricNames = {'f1', 'f2', 'G'};
spindleFiles = getFiles('FILES', spindleDir, '.mat');
for k = 1%:length(spindleFiles)
    results = load(spindleFiles{k});
    [~, theName, ~] = fileparts(spindleFiles{k});
    for n = 1:length(metricNames)
        figHan = showMetric(results.spindles, metricNames{n}, theName);
        saveas(figHan, [imageDir filesep theName '_Metric_' metricNames{n} '.png'], 'png');
    end
end
