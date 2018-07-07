function figHan = spinkyShowMetric(thresholds, allMetrics, metricName, ...
                             imageDir, params)
%% Plot the specified spinky metric for the different evaluation methods
%
%  Parameters:
%     thresholds     array of threshold values
%     allMetrics     structure with metrics for different match methods
%     metricName     name of the metric to plot
%     imageDir             directory to save images
%     params               structure containing figure defaults and name
%
% Written by Kay Robbins, UTSA 2017-2018
%
%% Set up image directory if saving
defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());     
params = processParameters('showSpindlerMetric', nargin, 5, params, defaults);
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
theName = params.name;

%% Make sure the metrics structure has all methods and specified metric
if ~isfield(allMetrics, 'time') || ~isfield(allMetrics, 'hit') || ...
   ~isfield(allMetrics, 'intersect') || ~isfield(allMetrics, 'count') || ...
   ~isfield(allMetrics, 'onset') 
    warning('showSpindlerMetric:MissingMethod', 'Performance method not available');
    return;
end

%% Get the metrics data
sCounts = {allMetrics.count};
sHits = {allMetrics.hit};
sIntersects = {allMetrics.intersect};
sOnsets = {allMetrics.onset};
sTimes = {allMetrics.time};

if ~isfield(sCounts{1}, metricName) || ...
   ~isfield(sHits{1}, metricName) || ...
   ~isfield(sIntersects{1}, metricName) || ...
   ~isfield(sOnsets{1}, metricName) || ...
   ~isfield(sTimes{1}, metricName) 
    warning('spindlerShowMetric:MissingMetric', 'Performance metric not availale');
    return;
end

%% Figure out the thresholds to plot and calculate the mean
datasetName = params.name;

%% Extract the values to plot
countMetric = zeros(length(sHits), 1);
hitMetric = zeros(length(sHits), 1);
intersectMetric = zeros(length(sHits), 1);
onsetMetric = zeros(length(sHits), 1);
timeMetric = zeros(length(sHits), 1);

for k = 1:length(sHits)
    countMetric(k) = sCounts{k}.(metricName);
    hitMetric(k) = sHits{k}.(metricName);
    intersectMetric(k) = sIntersects{k}.(metricName);
    onsetMetric(k) = sOnsets{k}.(metricName);
    timeMetric(k) = sTimes{k}.(metricName);
end

%% set up the graphics
theTitle = [datasetName ': ' metricName ' vs atoms/second'];
figHan = figure('Name', theTitle);
hold on
newColors = [0.4, 0.5, 0.8; 0.8, 0.5, 0.4; 0.2, 0.8, 0.8; 0.0, 0.5, 0.0; 0.3, 0.3, 0.3];
    plot(thresholds(:), countMetric(:), 'LineWidth', 2, ...
         'Color', newColors(1, :), 'LineStyle', '-');
    plot(thresholds(:), hitMetric(:), 'LineWidth', 2, ...
         'Color', newColors(2, :), 'LineStyle', '-');
    plot(thresholds(:), intersectMetric(:), 'LineWidth', 2, ...
         'Color', newColors(3, :), 'LineStyle', '-');
    plot(thresholds(:), onsetMetric(:), 'LineWidth', 2, ...
        'Color', newColors(4, :), 'LineStyle', '-');
    plot(thresholds(:), timeMetric(:), 'LineWidth', 2, ...
         'Color', newColors(5, :), 'LineStyle', '-');

hold off
ylabel('Performance')
xlabel('Threshold')
title(theTitle, 'Interpreter', 'None');
legend({'Count', 'Hit', 'Intersect', 'Onset', 'Time'}, ...
       'Location', 'eastoutside');
set(gca, 'YLim', [0, 1], 'YLimMode', 'manual');
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