function figHan = showMetric(spindleParameters, metrics, metricName)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindles     spindle structure produced by extractSpindles
%     metricName   name of the metric to plot
%     datasetName  name of the dataset to use in figure title
%% Initialize the return parameters
figHan = [];

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
[~, minThreshInd] = min(baseThresholds);
[~, maxThreshInd] = max(baseThresholds);
eFractionAverage = spindleParameters.eFractionAverage;
spindleSTD = spindleParameters.spindleSTD;
diffSTD = spindleParameters.diffSTD;
upperAtomRange = spindleParameters.upperAtomRange;
eFractMaxInd = spindleParameters.eFractMaxInd;
diffAtoms = (atomsPerSecond(1:end-1) + atomsPerSecond(2:end))/2;
% spindleParameters.name = theName;
% spindleParameters.atomsPerSecond = atomsPerSecond;
% spindleParameters.bestAtomsPerSecond = bestAtomsPerSecond;
% spindleParameters.baseThresholds = baseThresholds;
% spindleParameters.bestThreshold = bestThreshold;
% spindleParameters.stdLimitInd = stdLimitInd;
% spindleParameters.upperAtomRange = upperAtomRange;
% spindleParameters.eFractionAverage = eFractionAverage;
% spindleParameters.eFractMaxInd = eFractMaxInd;
% spindleParameters.spindleSTD = spindleSTD;
% spindleParameters.diffSTD = diffSTD;
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
hitMetric = [hitMetric(:, minThreshInd), hitMetric(:, maxThreshInd)];
hitMetric = [hitMetric(:, 1), mean(hitMetric, 2), hitMetric(:, 2)];

intersectMetric = reshape(intersectMetric, numAtoms, numThresholds);
intersectMetric = [intersectMetric(:, minThreshInd), intersectMetric(:, maxThreshInd)];
intersectMetric = [intersectMetric(:, 1), mean(intersectMetric, 2), intersectMetric(:, 2)];

onsetMetric = reshape(onsetMetric, numAtoms, numThresholds);
onsetMetric = [onsetMetric(:, minThreshInd), onsetMetric(:, maxThreshInd)];
onsetMetric = [onsetMetric(:, 1), mean(onsetMetric, 2), onsetMetric(:, 2)];

timeMetric = reshape(timeMetric, numAtoms, numThresholds);
timeMetric = [timeMetric(:, minThreshInd), timeMetric(:, maxThreshInd)];
timeMetric = [timeMetric(:, 1), mean(timeMetric, 2), timeMetric(:, 2)];

%% Set up the legends
legendStrings = {'0', 'Mean', '1'};

%% set up the graphics
legendBoth = cell(1, 12);
for k = 1:3
    legendBoth{4*k - 3} = [legendStrings{k} ' H'];
    legendBoth{4*k - 2} = [legendStrings{k} ' T'];
    legendBoth{4*k - 1} = [legendStrings{k} ' O'];
    legendBoth{4*k} = [legendStrings{k} ' I'];
end
theTitle = [datasetName ': ' metricName ' vs atoms/second'];
figHan = figure('Name', theTitle);
hold on
newColors = [0, 0, 0.8; 0, 0.8, 0; 0.8, 0, 0];
for j = 1:3
    plot(atomsPerSecond, hitMetric(:, j), 'LineWidth', 2, ...
          'Color', newColors(j, :));
    plot(atomsPerSecond, timeMetric(:, j), 'LineWidth', 2, 'LineStyle', '-.', ...
        'Color', newColors(j, :));
    plot(atomsPerSecond, onsetMetric(:, j), 'LineWidth', 2, 'LineStyle', ':', ...
        'Color', newColors(j, :));
    plot(atomsPerSecond, intersectMetric(:, j), 'LineWidth', 2, 'LineStyle', '--', ...
        'Color', newColors(j, :));
end
plot(atomsPerSecond, eFractionAverage, 'LineWidth', 2, 'Color', [0, 0, 0]);
plot(atomsPerSecond, spindleSTD, 'LineWidth', 2, 'Color', [0.5, 0.5, 0.5]);
plot(diffAtoms, diffSTD, 'LineWidth', 2, 'Color', [0.8, 0.8, 0.8]);
xLimits = get(gca, 'XLim');
line(xLimits, [0, 0], 'Color', [0, 0, 0]);
ePos = atomsPerSecond(eFractMaxInd);
yLimits = [-0.25, 1];
line([ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);
line([min(atomsPerSecond), upperAtomRange], [-0.15, -0.15], ...
    'LineWidth', 4, 'Color', [0.4, 0.4, 0.8]);
legendSummary = {'eFracAv', 'spinSTD', 'diffStd'};

hold off
ylabel('Performance')
xlabel('Atoms/second')
title(theTitle, 'Interpreter', 'None');
legend([legendBoth, legendSummary], 'Location', 'SouthEast');
set(gca, 'YLim', yLimits);
box on;