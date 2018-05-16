function figHan = sdarShowMetric(spindleParameters, methods, ...
                                  metricName, imageDir, params)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindleParameters     structure from getSpindlerParameters
%     metrics               structure from getSpindlerPerformance
%     metricName            name of the metric to plot

%% Set up image directory if saving
defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());     
params = processParameters('sdarShowMetric', nargin, 5, params, defaults);
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
theName = params.name;

%% Make sure the metrics structure has all methods and specified metric
if ~isfield(methods, 'time') || ~isfield(methods, 'hit') || ...
   ~isfield(methods, 'intersect') || ~isfield(methods, 'count') || ...
   ~isfield(methods, 'onset') 
    warning('sdarShowMetric:MissingMethod', 'Performance method not available');
    return;
end


%% Get the metrics data
sCounts = {methods.count};
sHits = {methods.hit};
sIntersects = {methods.intersect};
sOnsets = {methods.onset};
sTimes = {methods.time};

if ~isfield(sCounts{1}, metricName) || ...
   ~isfield(sHits{1}, metricName) || ...
   ~isfield(sIntersects{1}, metricName) || ...
   ~isfield(sOnsets{1}, metricName) || ...
   ~isfield(sTimes{1}, metricName) 
    warning('sdarShowMetric:MissingMetric', 'Performance metric not availale');
    return;
end
%% Figure out the thresholds to plot and calculate the mean
thresholds = spindleParameters.thresholds;

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

%% Set up the legends
legendStrings = {'C', 'H', 'O', 'I', 'T'};
theTitle = [theName ': ' metricName ' vs baseThreshold'];
figHan = figure('Name', theTitle);
hold on
thresholdFraction = thresholds/max(thresholds);
hold on
newColors = [0.4, 0.5, 0.8; 0.8, 0.5, 0.4; 0.2, 0.8, 0.8; 0.0, 0.6, 0.0; 0.3, 0.3, 0.3];
plot(thresholdFraction, countMetric, 'LineWidth', 2, 'Color', newColors(1, :));
plot(thresholdFraction, hitMetric, 'LineWidth', 2, 'Color', newColors(2, :));
plot(thresholdFraction, intersectMetric, 'LineWidth', 2, ...
    'Color', newColors(3, :));
plot(thresholdFraction, onsetMetric, 'LineWidth', 2, ...
    'Color', newColors(4, :));
plot(thresholdFraction, timeMetric, 'LineWidth', 2, ...
    'Color', newColors(5, :));
hold off
ylabel(['Performance (' metricName ')'])
xlabel('Threshold fraction')
title(theTitle, 'Interpreter', 'None');
legend(legendStrings);
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