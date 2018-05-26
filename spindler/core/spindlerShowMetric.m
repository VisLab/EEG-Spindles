function figHan = spindlerShowMetric(spindleParameters, allMetrics, ...
                                     metricName, imageDir, params)
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

%% Figure out the thresholds to plot and calculate the mean
datasetName = spindleParameters.name;
atomsPerSecond = spindleParameters.atomsPerSecond;
thresholds = spindleParameters.thresholds;
[~, minInd] = min(thresholds);
[~, maxInd] = max(thresholds);
spindleRateSTD = spindleParameters.spindleRateSTD;
bestEligibleAtomInd = spindleParameters.bestEligibleAtomInd;
bestEligibleThresholdInd = spindleParameters.bestEligibleThresholdInd;

%% Extract the values to plot
[numAtoms, numThresholds] = size(allMetrics);
countMetric = zeros(numAtoms, numThresholds);
hitMetric = zeros(numAtoms, numThresholds);
intersectMetric = zeros(numAtoms, numThresholds);
onsetMetric = zeros(numAtoms, numThresholds);
timeMetric = zeros(numAtoms, numThresholds);

for k = 1:numAtoms
    for j = 1:numThresholds
        countMetric(k, j) = allMetrics(k, j).count.(metricName);
        hitMetric(k, j) = allMetrics(k, j).hit.(metricName);
        intersectMetric(k, j) = allMetrics(k, j).intersect.(metricName);
        onsetMetric(k, j) = allMetrics(k, j).onset.(metricName);
        timeMetric(k, j) = allMetrics(k, j).time.(metricName);
    end
end

countMetric = [countMetric(:, minInd), countMetric(:, maxInd),  ...
               countMetric(:, bestEligibleThresholdInd)];       
hitMetric = [hitMetric(:, minInd), hitMetric(:, maxInd),  ...
             hitMetric(:, bestEligibleThresholdInd)];
intersectMetric = [intersectMetric(:, minInd), intersectMetric(:, maxInd) ...
                   intersectMetric(:, bestEligibleThresholdInd)];
onsetMetric = [onsetMetric(:, minInd), onsetMetric(:, maxInd), ...
              onsetMetric(:, bestEligibleThresholdInd)];
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
newColors = [0.4, 0.5, 0.8; 0.8, 0.5, 0.4; 0.2, 0.8, 0.8; 0.0, 0.5, 0.0; 0.3, 0.3, 0.3];
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