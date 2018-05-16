function figHan = spindlerShowMetric(spindleParameters, methods, metricName, ...
                             imageDir, params)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindleParameters     structure from getSpindlerParameters
%     methods               structure from getSpindlerPerformance
%     metricName            name of the metric to plot

%% Set up image directory if saving
defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());     
params = processParameters('spindlerShowMetric', nargin, 5, params, defaults);
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
theName = params.name;

%% Make sure the metrics structure has all methods and specified metric
if ~isfield(methods, 'time') || ~isfield(methods, 'hit') || ...
   ~isfield(methods, 'intersect') || ~isfield(methods, 'count') || ...
   ~isfield(methods, 'onset') 
    warning('spindlerShowMetric:MissingMethod', 'Performance method not available');
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
    warning('spindlerShowMetric:MissingMetric', 'Performance metric not availale');
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
spindleRateSTD = spindleParameters.spindleRateSTD;
bestEligibleAtomInd = spindleParameters.bestEligibleAtomInd;
bestEligibleThresholdInd = spindleParameters.bestEligibleThresholdInd;
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
countMetric = reshape(countMetric, numAtoms, numThresholds);
% hitMetricMean = mean([hitMetric(:, minInd), hitMetric(:, maxInd)], 2);
countMetric = [countMetric(:, minInd), countMetric(:, maxInd),  ...
               countMetric(:, bestEligibleThresholdInd)];
         
hitMetric = reshape(hitMetric, numAtoms, numThresholds);
% hitMetricMean = mean([hitMetric(:, minInd), hitMetric(:, maxInd)], 2);
hitMetric = [hitMetric(:, minInd), hitMetric(:, maxInd),  ...
             hitMetric(:, bestEligibleThresholdInd)];

intersectMetric = reshape(intersectMetric, numAtoms, numThresholds);
% intersectMetricMean = mean([intersectMetric(:, minInd), ...
%                             intersectMetric(:, maxInd)], 2);
intersectMetric = [intersectMetric(:, minInd), intersectMetric(:, maxInd) ...
                   intersectMetric(:, bestEligibleThresholdInd)];

onsetMetric = reshape(onsetMetric, numAtoms, numThresholds);
%onsetMetricMean = mean([onsetMetric(:, minInd), onsetMetric(:, maxInd)], 2);
onsetMetric = [onsetMetric(:, minInd), onsetMetric(:, maxInd), ...
              onsetMetric(:, bestEligibleThresholdInd)];

timeMetric = reshape(timeMetric, numAtoms, numThresholds);
%timeMetricMean = mean([timeMetric(:, minInd), timeMetric(:, maxInd)], 2);
timeMetric = [timeMetric(:, minInd), timeMetric(:, maxInd), ...
              timeMetric(:, bestEligibleThresholdInd)];

%% Set up the legends
legendStrings = {'T_b=0', 'T_b=1', ...
                 ['T_b=' num2str(spindleParameters.bestEligibleThreshold)]};

%% set up the graphics
legendBoth = cell(1, 15);
for k = 1:3
    legendBoth{5*k - 4} = ['C:' legendStrings{k}];
    legendBoth{5*k - 3} = ['H:' legendStrings{k}];
    legendBoth{5*k - 2} = ['I:' legendStrings{k}];
    legendBoth{5*k - 1} = ['O:' legendStrings{k}];
    legendBoth{5*k} = ['T:' legendStrings{k}];
end
theTitle = [datasetName ': ' metricName ' vs atoms/second'];
figHan = figure('Name', theTitle);
hold on
newColors = [0.4, 0.5, 0.8; 0.8, 0.5, 0.4; 0.5, 0.8, 0.8; 0.4, 0.8, 0.5; 0.3, 0.3, 0.3];
lineWidths = [2, 2, 2, 3];
lineStyles = {':', '--', '-'};
for j = 1:3
    plot(atomsPerSecond, countMetric(:, j), 'LineWidth', lineWidths(j), ...
         'Color', newColors(1, :), 'LineStyle', lineStyles{j});
    plot(atomsPerSecond, hitMetric(:, j), 'LineWidth', lineWidths(j), ...
         'Color', newColors(2, :), 'LineStyle', lineStyles{j});
    plot(atomsPerSecond, intersectMetric(:, j), 'LineWidth', lineWidths(j), ...
        'LineStyle', lineStyles{j}, 'Color', newColors(3, :));
    plot(atomsPerSecond, onsetMetric(:, j), 'LineWidth', lineWidths(j), ...
        'LineStyle', lineStyles{j}, 'Color', newColors(4, :));
    plot(atomsPerSecond, timeMetric(:, j), 'LineWidth', lineWidths(j), ...
         'LineStyle', lineStyles{j}, 'Color', newColors(5, :));
end
plot(atomsPerSecond, spindleRateSTD/max(spindleRateSTD(:)), ...
    'LineWidth', 2, 'Color', [0.7, 0.7, 0.7]);
%ePos = atomsPerSecond(bestAtomInd);
yLimits = [0, 1];
%line([ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);
line(spindleParameters.atomRateRange, [0.1, 0.1], ...
    'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
eligiblePos = atomsPerSecond(bestEligibleAtomInd);
line([eligiblePos, eligiblePos], yLimits, ...
    'LineWidth', 2, 'Color', [0.8, 0.8, 0.3]);

plot(eligiblePos, countMetric(bestEligibleAtomInd, 3), 'o', ...
    'LineWidth', 2.5, 'MarkerSize', 14, 'Color', [0.8, 0.8, 0.3]);
plot(eligiblePos, hitMetric(bestEligibleAtomInd, 3), 'o', ...
    'LineWidth', 2.5, 'MarkerSize', 14, 'Color', [0.8, 0.8, 0.3]);
plot(eligiblePos, timeMetric(bestEligibleAtomInd, 3), 'o', ...
    'LineWidth', 2.5, 'MarkerSize', 14, 'Color', [0.8, 0.8, 0.3]);
plot(eligiblePos, onsetMetric(bestEligibleAtomInd, 3), 'o', ...
    'LineWidth', 2.5, 'MarkerSize', 14, 'Color', [0.8, 0.8, 0.3]);
plot(eligiblePos, intersectMetric(bestEligibleAtomInd, 3), 'o', ...
    'LineWidth', 2.5, 'MarkerSize', 14, 'Color', [0.8, 0.8, 0.3]);
hold off
ylabel('Performance')
xlabel('Atoms/second')
title(theTitle, 'Interpreter', 'None');
legend([legendBoth, 'STD spin/min', 'STD range', ...
    ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))], ...
     'Best point'], 'Location', 'eastoutside');
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