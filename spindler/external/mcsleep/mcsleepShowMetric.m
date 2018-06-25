function figHan = mcsleepShowMetric(allMetrics, metricName, ...
                                    imageDir, params)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindleParameters     structure from getSpindlerParameters
%     methods               structure from getSpindlerPerformance
%     metricName            name of the metric to plot

%% Set up image directory if saving
defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());     
params = processParameters('mcsleepShowMetric', nargin, 4, params, defaults);
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
theName = params.name;

%% Make sure the metrics structure has all methods and specified metric
if ~isfield(allMetrics(1, 1), 'time') || ~isfield(allMetrics(1, 1), 'hit') || ...
   ~isfield(allMetrics(1, 1), 'intersect') || ~isfield(allMetrics(1, 1), 'count') || ...
   ~isfield(allMetrics(1, 1), 'onset') 
    warning('mcsleepShowMetric:MissingMethod', 'Performance method not available');
    return;
end

if ~isfield(allMetrics(1, 1).count, metricName) || ...
   ~isfield(allMetrics(1, 1).hit, metricName) || ...
   ~isfield(allMetrics(1, 1).intersect, metricName) || ...
   ~isfield(allMetrics(1, 1).onset, metricName) || ...
   ~isfield(allMetrics(1, 1).time, metricName) 
    warning('spindlerShowMetric:MissingMetric', 'Performance metric not availale');
    return;
end

%% Figure out the thresholds to plot and calculate the mean
datasetName = params.name;
lambda2s = params.mcsleepLambda2s;
thresholds = params.mcsleepThresholds;
numLambda2s = length(lambda2s);
numThresholds = length(thresholds);

%% Extract the values to plot
countMetric = zeros(numLambda2s, numThresholds);
hitMetric = zeros(numLambda2s, numThresholds);
intersectMetric = zeros(numLambda2s, numThresholds);
onsetMetric = zeros(numLambda2s, numThresholds);
timeMetric = zeros(numLambda2s, numThresholds);

for n = 1:numLambda2s
    for m = 1:numThresholds
    countMetric(n, m) = allMetrics(n, m).count.(metricName);
    hitMetric(n, m) = allMetrics(n, m).hit.(metricName);
    intersectMetric(n, m) = allMetrics(n, m).intersect.(metricName);
    onsetMetric(n, m) = allMetrics(n, m).onset.(metricName);
    timeMetric(n, m) = allMetrics(n, m).time.(metricName);
    end
end

%% Set up the legends for plotting versus threshold
lambda2Display = params.mcsleepLambda2Display;
lambda2Pos = zeros(size(lambda2Display));
legendStrings = cell(1, length(lambda2Display));
for n = 1:length(lambda2Display)
    [~, lambda2Pos(n)] = min(abs(lambda2s - lambda2Display(n)));
    legendStrings{n} = ['\lambda_2 =' num2str(lambda2s(lambda2Pos(n)))];
end

legendBoth = cell(1, 5*length(lambda2Display));
for k = 1:length(lambda2Display)
    legendBoth{5*k - 4} = ['C:' legendStrings{k}];
    legendBoth{5*k - 3} = ['H:' legendStrings{k}];
    legendBoth{5*k - 2} = ['I:' legendStrings{k}];
    legendBoth{5*k - 1} = ['O:' legendStrings{k}];
    legendBoth{5*k} = ['T:' legendStrings{k}];
end

theTitle = [datasetName ': ' metricName ' vs threshold'];
figHan = figure('Name', theTitle);
hold on
newColors = [0.4, 0.5, 0.8; 0.8, 0.5, 0.4; 0.2, 0.8, 0.8; 0.0, 0.6, 0.0; 0.3, 0.3, 0.3];
lineStyles = {':', '--', '-', '-.'};
for j = 1:length(lambda2Display)
    pos = lambda2Pos(j);
    plot(thresholds(:), countMetric(pos, :)', 'LineWidth', 2, ...
         'Color', newColors(1, :), 'LineStyle', lineStyles{j});
    plot(thresholds(:), hitMetric(pos, :)', 'LineWidth', 2, ...
         'Color', newColors(2, :), 'LineStyle', lineStyles{j});
    plot(thresholds(:), intersectMetric(pos, :)', 'LineWidth', 2, ...
        'LineStyle', lineStyles{j}, 'Color', newColors(3, :));
    plot(thresholds(:), onsetMetric(pos, :)', 'LineWidth', 2, ...
        'LineStyle', lineStyles{j}, 'Color', newColors(4, :));
    plot(thresholds(:), timeMetric(pos, :)', 'LineWidth', 2, ...
         'LineStyle', lineStyles{j}, 'Color', newColors(5, :));
end
hold off
ylabel('Performance')
xlabel('Threshold')
title(theTitle, 'Interpreter', 'None');
legend(legendBoth, 'Location', 'eastoutside');
set(gca, 'YLim', [0, 1]);
box on;

if ~isempty(imageDir)
    for k = 1:length(params.figureFormats)
       thisFormat = params.figureFormats{k};
       saveas(figHan, [imageDir filesep theName '_Metric_' metricName ...
           '_VsThreshold.' thisFormat], thisFormat);
    end
end
if params.figureClose
   close(figHan);
end    

%% Set up the legends for plotting versus lambda2
thresholdDisplay = params.mcsleepThresholdDisplay;
thresholdPos = zeros(size(thresholdDisplay));
legendStrings = cell(1, length(thresholdDisplay));
for n = 1:length(thresholdDisplay)
    [~, thresholdPos(n)] = min(abs(thresholds - thresholdDisplay(n)));
    legendStrings{n} = ['T = ' num2str(thresholds(thresholdPos(n)))];
end

legendBothT = cell(1, 5*length(thresholdDisplay));
for k = 1:length(thresholdDisplay)
    legendBothT{5*k - 4} = ['C:' legendStrings{k}];
    legendBothT{5*k - 3} = ['H:' legendStrings{k}];
    legendBothT{5*k - 2} = ['I:' legendStrings{k}];
    legendBothT{5*k - 1} = ['O:' legendStrings{k}];
    legendBothT{5*k} = ['T:' legendStrings{k}];
end

theTitle = [datasetName ': ' metricName ' vs Lambda2'];
figHan = figure('Name', theTitle);
hold on
newColors = [0.4, 0.5, 0.8; 0.8, 0.5, 0.4; 0.2, 0.8, 0.8; 0.0, 0.6, 0.0; 0.3, 0.3, 0.3];
lineStyles = {':', '--', '-', '-.'};
for j = 1:length(thresholdDisplay)
    pos = thresholdPos(j);
    plot(lambda2s', countMetric(:, pos), 'LineWidth', 2, ...
         'Color', newColors(1, :), 'LineStyle', lineStyles{j});
    plot(lambda2s', hitMetric(:, pos), 'LineWidth', 2, ...
         'Color', newColors(2, :), 'LineStyle', lineStyles{j});
    plot(lambda2s', intersectMetric(:, pos), 'LineWidth', 2, ...
        'LineStyle', lineStyles{j}, 'Color', newColors(3, :));
    plot(lambda2s', onsetMetric(:, pos), 'LineWidth', 2, ...
        'LineStyle', lineStyles{j}, 'Color', newColors(4, :));
    plot(lambda2s', timeMetric(:, pos), 'LineWidth', 2, ...
         'LineStyle', lineStyles{j}, 'Color', newColors(5, :));
end
hold off
ylabel('Performance')
xlabel('\lambda_2')
title(theTitle, 'Interpreter', 'None');
legend(legendBothT, 'Location', 'eastoutside');
set(gca, 'YLim', [0, 1]);
box on;

if ~isempty(imageDir)
    for k = 1:length(params.figureFormats)
       thisFormat = params.figureFormats{k};
       saveas(figHan, [imageDir filesep theName '_Metric_' metricName ...
           '_VsLambda2_.' thisFormat], thisFormat);
    end
end
if params.figureClose
   close(figHan);
end    
