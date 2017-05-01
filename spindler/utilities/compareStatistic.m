function figHan = compareStatistic(stats, baseIndex, otherIndices, ...
                       statName, algorithms, algColors, theTitle)
%% Graph the specified statistics
baseStats = squeeze(stats(baseIndex, :));
baseAlgorithm = algorithms{baseIndex};
theTitle = [theTitle ': ' statName];
figHan = figure('Name', theTitle);
hold on
%legendStrings = cell(1, length(methodNames)*(length(algorithmNames) - 1));
legendStrings = cell(1, length(otherIndices));
for k = 1:length(otherIndices)
   j = otherIndices(k);
   otherStats = squeeze(stats(j, :)); 
   legendStrings{k} = algorithms{j};
    plot(baseStats, otherStats, 'Marker', 'o', ...
            'LineStyle', 'None', 'LineWidth', 2, 'MarkerSize', 10, ...
            'Color', algColors(k, :));
end
xLims = get(gca, 'XLim');
yLims = get(gca, 'YLim');
lLimit = max(max(xLims, yLims));
line([0, lLimit], [0, lLimit], 'Color', [0.7, 0.7, 0.7]);
hold off
legend(legendStrings, 'Location', 'EastOutside', 'Interpreter', 'None');
box on
xlabel([baseAlgorithm ' ' statName])
ylabel([statName ' other algorithms'])
title(theTitle)