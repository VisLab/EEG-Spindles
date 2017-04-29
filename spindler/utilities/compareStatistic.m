function figHan = compareStatistic(statsBase, statsOthers, statisticName, ...
         baseAlgorithm, otherAlgorithms, theColors, theTitle)

theTitle = [theTitle ': ' statisticName];
figHan = figure('Name', theTitle);
hold on
%legendStrings = cell(1, length(methodNames)*(length(algorithmNames) - 1));
legendStrings = cell(1, length(otherAlgorithms));
for k = 1:length(otherAlgorithms)
   theseStats = squeeze(statsOthers(k, :)); 
   legendStrings{k} = otherAlgorithms{k};
    plot(statsBase, theseStats, 'Marker', 'o', ...
            'LineStyle', 'None', 'LineWidth', 2, 'MarkerSize', 10, ...
            'Color', theColors(k, :));
end
xLims = get(gca, 'XLim');
yLims = get(gca, 'YLim');
lLimit = max(max(xLims, yLims));
line([0, lLimit], [0, lLimit], 'Color', [0.7, 0.7, 0.7]);
hold off
legend(legendStrings, 'Location', 'EastOutside', 'Interpreter', 'None');
box on
xlabel([baseAlgorithm ' ' statisticName])
ylabel([statisticName ' other algorithms'])
title(theTitle)