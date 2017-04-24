function figHan = sdarShowMetric(spindleParameters, metrics, metricName, imageDir, params)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindleParameters     structure from getSpindlerParameters
%     metrics               structure from getSpindlerPerformance
%     metricName            name of the metric to plot

%% Set up image directory if saving
defaults = concatenateStructs(getGeneralDefaults(), sdarGetDefaults());     
params = processParameters('showSdarMetric', nargin, 4, params, defaults);
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
name = params.name;
%% Make sure the metrics structure has all methods and specified metric
if ~isfield(metrics, 'timeMetrics') || ...
   ~isfield(metrics, 'hitMetrics') || ...
   ~isfield(metrics, 'intersectMetrics') || ...
   ~isfield(metrics, 'onsetMetrics') 
    warning('sdarShowMetric:MissingMethod', 'Performance method not available');
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
    warning('sdarShowMetric:MissingMetric', 'Performance metric not availale');
    return;
end

%% Figure out the thresholds to plot and calculate the mean
datasetName = params.name;
baseThresholds = cellfun(@double, {spindleParameters.baseThresholds});

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

%% Set up the legends
legendStrings = {'H', 'T', 'O', 'I'};
theTitle = [datasetName ': ' metricName ' vs baseThreshold'];
figHan = figure('Name', theTitle);
hold on
thresholdFraction = baseThresholds/max(baseThresholds);
plot(thresholdFraction, hitMetric, 'LineWidth', 2, ...
    'Color', [0, 0, 0.8]);
plot(thresholdFraction, timeMetric, 'LineWidth', 2, ...
    'LineStyle', '-.', 'Color', [0.8, 0, 0]);
plot(thresholdFraction, onsetMetric, 'LineWidth', 2, ...
    'LineStyle', ':', 'Color', [0, 0.8, 0]);
plot(thresholdFraction, intersectMetric, 'LineWidth', 2, ...
    'LineStyle', '--', 'Color', [0, 0, 0]);
set(gca, 'XLim', [0, 1], 'XLimMode', 'manual', ...
    'YLim', [0, 1], 'YLimMode', 'manual')
hold off
ylabel('Performance')
xlabel('Threshold fraction')
title(theTitle, 'Interpreter', 'None');
legend(legendStrings);
box on;

if ~isempty(imageDir)
    for k = 1:length(params.figureFormats)
       thisFormat = params.figureFormats{k};
       saveas(figHan, [imageDir filesep name '_Metric_' metricName '.' ...
            thisFormat], thisFormat);
    end
end
if params.figureClose
   close(figHan);
end