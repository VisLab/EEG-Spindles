function figHan = showSpindlerMetric(spindleParameters, metrics, metricName, ...
                             imageDir, params)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindleParameters     structure from getSpindlerParameters
%     metrics               structure from getSpindlerPerformance
%     metricName            name of the metric to plot

%% Set up image directory if saving
defaults = concatenateStructs(getGeneralDefaults(), getSpindlerDefaults());     
params = processParameters('showMetric', nargin, 4, params, defaults);
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
theName = params.name;

%% Make sure the metrics structure has all methods and specified metric
if ~isfield(metrics, 'timeMetrics') || ...
   ~isfield(metrics, 'hitMetrics') || ...
   ~isfield(metrics, 'intersectMetrics') || ...
   ~isfield(metrics, 'onsetMetrics') 
    warning('showMetric:MissingMethod', 'Performance method not available');
    return;
end

%% Get the metrics data
sHits = {metrics.hitMetrics};
sIntersects = {metrics.intersectMetrics};
sOnsets = {metrics.onsetMetrics};
sTimes = {metrics.timeMetrics};

if ~isfield(sHits{1}, metricName) || ...
   ~isfield(sIntersects{1}, metricName) || ...
   ~isfield(sOnsets{1}, metricName) || ...
   ~isfield(sTimes{1}, metricName) 
    warning('showMetric:MissingMetric', 'Performance metric not availale');
    return;
end

%% Figure out the thresholds to plot and calculate the mean
datasetName = spindleParameters.name;
atomsPerSecond = spindleParameters.atomsPerSecond;
baseThresholds = spindleParameters.baseThresholds;
numAtoms = length(atomsPerSecond);
numThresholds = length(baseThresholds);
[~, minInd] = min(baseThresholds);
[~, maxInd] = max(baseThresholds);
spindleSTD = spindleParameters.spindleSTD;
eFractMaxInd = spindleParameters.eFractMaxInd;
bestInd = spindleParameters.bestThresholdInd;

%% Extract the values to plot
hitMetric = zeros(length(sHits), 1);
intersectMetric = zeros(length(sHits), 1);
onsetMetric = zeros(length(sHits), 1);
timeMetric = zeros(length(sHits), 1);

for k = 1:length(sHits)
    hitMetric(k) = sHits{k}.(metricName);
    intersectMetric(k) = sIntersects{k}.(metricName);
    onsetMetric(k) = sOnsets{k}.(metricName);
    timeMetric(k) = sTimes{k}.(metricName);
end
hitMetric = reshape(hitMetric, numAtoms, numThresholds);
hitMetricMean = mean([hitMetric(:, minInd), hitMetric(:, maxInd)], 2);
hitMetric = [hitMetric(:, minInd), hitMetric(:, maxInd),  ...
             hitMetricMean, hitMetric(:, bestInd)];

intersectMetric = reshape(intersectMetric, numAtoms, numThresholds);
intersectMetricMean = mean([intersectMetric(:, minInd), ...
                            intersectMetric(:, maxInd)], 2);
intersectMetric = [intersectMetric(:, minInd), intersectMetric(:, maxInd) ...
         intersectMetricMean, intersectMetric(:, bestInd)];

onsetMetric = reshape(onsetMetric, numAtoms, numThresholds);
onsetMetricMean = mean([onsetMetric(:, minInd), onsetMetric(:, maxInd)], 2);
onsetMetric = [onsetMetric(:, minInd), onsetMetric(:, minInd), ...
               onsetMetricMean, onsetMetric(:, bestInd)];

timeMetric = reshape(timeMetric, numAtoms, numThresholds);
timeMetricMean = mean([timeMetric(:, minInd), timeMetric(:, maxInd)], 2);
timeMetric = [timeMetric(:, minInd), timeMetric(:, maxInd), ...
              timeMetricMean, timeMetric(:, bestInd)];

%% Set up the legends
legendStrings = {'T_b=0', 'T_b=1', 'T_b center', ...
                 ['T_b=' num2str(spindleParameters.bestThreshold)]};

%% set up the graphics
legendBoth = cell(1, 16);
for k = 1:4
    legendBoth{4*k - 3} = ['H:' legendStrings{k}];
    legendBoth{4*k - 2} = ['T:' legendStrings{k}];
    legendBoth{4*k - 1} = ['O:' legendStrings{k}];
    legendBoth{4*k} = ['I:' legendStrings{k}];
end
theTitle = [datasetName ': ' metricName ' vs atoms/second'];
figHan = figure('Name', theTitle);
hold on
newColors = [0, 0, 0.8; 0.8, 0, 0; 0, 0.8, 0; 0, 0, 0];
for j = 1:4
    plot(atomsPerSecond, hitMetric(:, j), 'LineWidth', 2, ...
          'Color', newColors(j, :));
    plot(atomsPerSecond, timeMetric(:, j), 'LineWidth', 2, 'LineStyle', '-.', ...
        'Color', newColors(j, :));
    plot(atomsPerSecond, onsetMetric(:, j), 'LineWidth', 2, 'LineStyle', ':', ...
        'Color', newColors(j, :));
    plot(atomsPerSecond, intersectMetric(:, j), 'LineWidth', 3, 'LineStyle', '--', ...
        'Color', newColors(j, :));
end
plot(atomsPerSecond, spindleSTD, 'LineWidth', 2, 'Color', [0.5, 0.5, 0.5]);
ePos = atomsPerSecond(eFractMaxInd);
yLimits = [0, 1];
line([ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);
line(spindleParameters.atomRange, [0.1, 0.1], ...
    'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
plot(ePos, hitMetric(eFractMaxInd, 2), 'x', ...
    'LineWidth', 2.5, 'MarkerSize', 12, 'Color', [0, 0, 0]);
plot(ePos, timeMetric(eFractMaxInd, 2), 'x', ...
    'LineWidth', 2.5, 'MarkerSize', 12, 'Color', [0, 0, 0]);
plot(ePos, onsetMetric(eFractMaxInd, 2), 'x', ...
    'LineWidth', 2.5, 'MarkerSize', 12, 'Color', [0, 0, 0]);
plot(ePos, intersectMetric(eFractMaxInd, 2), 'x', ...
    'LineWidth', 2.5, 'MarkerSize', 12, 'Color', [0, 0, 0]);
hold off
ylabel('Performance')
xlabel('Atoms/second')
title(theTitle, 'Interpreter', 'None');
legend([legendBoth, 'STD spin/sec'], 'Location', 'eastoutside');
set(gca, 'YLim', yLimits);
box on;

if ~isempty(imageDir)
    for k = 1:length(params.figureFormats)
       thisFormat = params.figureFormats{k};
       saveas(figHan, [imageDir filesep theName '_Metric_' metricName '.' ...
            thisFormat], thisFormat);
    end
end
if params.figureClose
   close(figHan);
end