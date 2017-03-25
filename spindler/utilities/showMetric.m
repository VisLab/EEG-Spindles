function figHan = showMetric(spindles, metricName, datasetName)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindles     spindle structure produced by extractSpindles
%     metricName   name of the metric to plot
%     datasetName  name of the dataset to use in figure title
%% Initialize the return parameters
figHan = [];

%% Make sure the spindles structure has all methods and specified metric
if ~isfield(spindles, 'metricsTimes') || ...
   ~isfield(spindles, 'metricsHits') || ...
   ~isfield(spindles, 'metricsIntersects') || ...
   ~isfield(spindles, 'metricsOnsets') 
    warning('showMetric:MissingMethod', 'Performance method not available');
    return;
end

%% Get the metrics data
sHits = {spindles.metricsHits};
sIntersects = {spindles.metricsIntersects};
sOnsets = {spindles.metricsOnsets};
sTimes = {spindles.metricsTimes};

if ~isfield(sHits{1}, metricName) || ...
   ~isfield(sIntersects{1}, metricName) || ...
   ~isfield(sOnsets{1}, metricName) || ...
   ~isfield(sTimes{1}, metricName) 
    warning('showMetric:MissingMetric', 'Performance metric not availale');
    return;
end

%% Figure out the thresholds to plot and calculate the mean
atomsPerSecond = unique(cellfun(@double, {spindles.atomsPerSecond}));
baseThresholds = unique(cellfun(@double, {spindles.baseThreshold}));
numAtoms = length(atomsPerSecond);
numThresholds = length(baseThresholds);
[~, minThreshInd] = min(baseThresholds);
[~, maxThreshInd] = max(baseThresholds);

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

%% Get the spindle hits and best threshold
spindleHits = cellfun(@double, {spindles.numberSpindles});
spindleHits = reshape(spindleHits, numAtoms, numThresholds);
eFraction = cellfun(@double, {spindles.eFraction});
eFraction = reshape(eFraction, numAtoms, numThresholds);
eFractionAverage = (eFraction(:, minThreshInd) + eFraction(:, maxThreshInd))/2;
eFractionMax = max(eFraction(:));
eFractionAverage = eFractionAverage./eFractionMax;
spindleSTD = std(spindleHits, 0, 2)';
stdMax = max(spindleSTD(:));
spindleSTD = spindleSTD./stdMax;
diffSTD = diff(spindleSTD);
diffSTDMax = max(abs(diffSTD(:)));
diffSTD = diffSTD./diffSTDMax;
diffAtoms = (atomsPerSecond(1:end-1) + atomsPerSecond(2:end))/2;

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
legendSummary = {'eFracAv', 'spinSTD', 'diffStd'};
% for j = 1:numThresholds
%     plot(atomsPerSecond, eFraction(:, j), 'LineWidth', 1, 'Color', [0, 0, 0]);
% end
% plot(atomsPerSecond', xMeanRatio, 'LineWidth', 3, 'Color', [0.6, 0.6, 0.6]);
% legend(legendBoth, 'Location', 'SouthEast');
% line([iMeanMaxAtoms, iMeanMaxAtoms], [0, 1], 'Color', [0, 0, 0]);
hold off
ylabel('Performance')
xlabel('Atoms/second')
title(theTitle, 'Interpreter', 'None');
legend([legendBoth, legendSummary], 'Location', 'SouthEast');
set(gca, 'YLim', [0, 1]);
box on;