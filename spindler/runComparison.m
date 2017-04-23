warbyDreamsSummaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\Dreams_Warby_Summary.mat';   
spindlerDreamsSummaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\Dreams_Spindler_Summary.mat';
spindlerBCITSummaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\BCIT_Spindler_Summary.mat';
sdarBCITSummaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\BCIT_Sdar_Summary.mat';
sdarDreamsSummaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\Dreams_Sdar_Summary.mat';
warbyDreams = load(warbyDreamsSummaryFile);
spindlerDreams = load(spindlerDreamsSummaryFile);
spindlerBCIT = load(spindlerBCITSummaryFile);
sdarBCIT = load(sdarBCITSummaryFile);
sdarDreams = load(sdarDreamsSummaryFile);

%%
figure
hold on
title('Dreams')
plot(spindlerDreams.results(:),warbyDreams.results(:), 'sk', 'LineWidth', 2, 'MarkerSize', 10);
plot(spindlerDreams.upperBounds(:), warbyDreams.results(:), 'or', 'LineWidth', 2, 'MarkerSize', 10);
line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
hold off
legend('Normal', 'Upper', 'Location', 'NorthWest')
box on
xlabel('Performance Spindler')
ylabel('Warby')


figure
hold on
title('Dreams')
plot(warbyDreams.results(:), spindlerDreams.results(:), 'sk', 'LineWidth', 2, 'MarkerSize', 10);
plot(warbyDreams.results(:), spindlerDreams.upperBounds(:), 'or', 'LineWidth', 2, 'MarkerSize', 10);
line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
hold off
legend('Normal', 'Upper', 'Location', 'NorthWest')
box on
ylabel('Performance Spindler')
xlabel('Warby')


%%
figure
hold on
title('BCIT')
plot(spindlerBCIT.results(:),sdarBCIT.upperBounds(:), 'sk', 'LineWidth', 2, 'MarkerSize', 10);
plot(spindlerBCIT.upperBounds(:), sdarBCIT.upperBounds(:), 'or', 'LineWidth', 2, 'MarkerSize', 10);
line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
hold off
legend('Normal', 'Upper', 'Location', 'NorthWest')
box on
xlabel('Performance Spindler')
ylabel('SDAR')

%%
figure
hold on
title('Dreams')
%plot(spindlerDreams.results(:), sdarDreams.results(:), 'sk', 'LineWidth', 2, 'MarkerSize', 10);
plot(spindlerDreams.upperBounds(:), sdarDreams.upperBounds(:), 'or', 'LineWidth', 2, 'MarkerSize', 10);
line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
hold off
legend('Upper', 'Location', 'NorthWest')
box on
xlabel('Performance Spindler')
ylabel('SDar')