function figHan = compareMetricSupervised(results, resultsOptimal, ...
    metricName, algorithmNames, theColors, theColorsOptimal, ...
    methodLegends, methodMarkers, theTitle)

theTitle = [theTitle ': ' metricName];

figHan = figure('Name', theTitle);
hold on
legendStrings = cell(1, length(methodLegends)*(length(algorithmNames) - 1));
baseResults = squeeze(results(:, :, 1));
lCount = 0;

for k = 1:length(algorithmNames)
   theseResultsOptimal = squeeze(resultsOptimal(:, :, k));
   for j = 1:length(methodLegends)
       lCount = lCount + 1;
       legendStrings{lCount} = [methodLegends{j} ': ' algorithmNames{k} ' best'];
       plot(baseResults(:, j), theseResultsOptimal(:, j), 'Marker', methodMarkers{j}, ...
            'LineStyle', 'None', 'LineWidth', 2, 'MarkerSize', 10, ...
            'Color', theColorsOptimal(k, :));
   end 
end

for k = 2:length(algorithmNames)
   theseResults = squeeze(results(:, :, k));
   for j = 1:length(methodLegends)
       lCount = lCount + 1;
       legendStrings{lCount} = [methodLegends{j} ': ' algorithmNames{k}];
       plot(baseResults(:, j), theseResults(:, j), 'Marker', methodMarkers{j}, ...
            'LineStyle', 'None', 'LineWidth', 2, 'MarkerSize', 10, 'Color', theColors(k - 1, :));
   end
end

line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
hold off
legend(legendStrings, 'Location', 'EastOutside', 'Interpreter', 'None');
box on
xlabel([metricName ' ' algorithmNames{1}])
ylabel([metricName ' others'])
title(theTitle)