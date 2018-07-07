function figHan = spindlerShowMetric(spindlerCurves, allMetrics, ...
                                     metricName, imageDir, params)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindlerCurves       structure from spindlerGetParameterCurves
%     allMetrics           structure containing all metrecis 
%     metricName           name of the metric to plot
%     imageDir             directory to save images
%     params               structure containing figure defaults and name
%
% Written by: Kay Robbins, UTSA  2017-2018
%
%% Set up image directory if saving
defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());     
params = processParameters('spindlerShowMetric', nargin, 5, params, defaults);
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
theName = params.name;

%% Figure out the thresholds to plot and calculate the mean
datasetName = spindlerCurves.name;
atomsPerSecond = spindlerCurves.atomsPerSecond;
thresholds = spindlerCurves.thresholds;
[~, minInd] = min(thresholds);
[~, maxInd] = max(thresholds);
spindleRateSTD = spindlerCurves.spindleRateSTD;
bestEligibleAtomInd = spindlerCurves.bestEligibleAtomInd;
bestEligibleThresholdInd = spindlerCurves.bestEligibleThresholdInd;

%% Extract the values to plot
metrics = getMetric(allMetrics, 'count', metricName);
countMetric = [metrics(:, minInd), metrics(:, maxInd),  ...
               metrics(:, bestEligibleThresholdInd)]; 
metrics = getMetric(allMetrics, 'hit', metricName);
hitMetric = [metrics(:, minInd), metrics(:, maxInd),  ...
             metrics(:, bestEligibleThresholdInd)];
metrics = getMetric(allMetrics, 'intersect', metricName);         
intersectMetric = [metrics(:, minInd), metrics(:, maxInd) ...
                   metrics(:, bestEligibleThresholdInd)];
metrics = getMetric(allMetrics, 'onset', metricName);
onsetMetric = [metrics(:, minInd), metrics(:, maxInd), ...
               metrics(:, bestEligibleThresholdInd)];
metrics = getMetric(allMetrics, 'time', metricName);           
timeMetric = [metrics(:, minInd), metrics(:, maxInd), ...
              metrics(:, bestEligibleThresholdInd)];

%% Set up the legends
legendStrings = {'T_b=0', 'T_b=1', ...
                 ['T_b=' num2str(spindlerCurves.bestEligibleThreshold)]};

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

yLimits = [0, 1];
line(spindlerCurves.atomRateRange, [0.1, 0.1], ...
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