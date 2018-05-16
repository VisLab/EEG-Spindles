function figHan = mcsleepShowMetric(allmetrics, metricName, ...
                                    imageDir, params)
%% Plot the specified metric for the different evaluation methods
%
%  Parameters:
%     spindleParameters     structure from getSpindlerParameters
%     methods               structure from getSpindlerPerformance
%     metricName            name of the metric to plot

%% Set up image directory if saving
defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());     
params = processParameters('mcsleepShowMetric', nargin, 4, params, defaults);
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
theName = params.name;

%% Make sure the metrics structure has all methods and specified metric
if ~isfield(allmetrics, 'time') || ~isfield(allmetrics, 'hit') || ...
   ~isfield(allmetrics, 'intersect') || ~isfield(allmetrics, 'count') || ...
   ~isfield(allmetrics, 'onset') 
    warning('mcsleepShowMetric:MissingMethod', 'Performance method not available');
    return;
end

%% Get the metrics data
sCounts = {allmetrics.count};
sHits = {allmetrics.hit};
sIntersects = {allmetrics.intersect};
sOnsets = {allmetrics.onset};
sTimes = {allmetrics.time};

if ~isfield(sCounts{1}, metricName) || ...
   ~isfield(sHits{1}, metricName) || ...
   ~isfield(sIntersects{1}, metricName) || ...
   ~isfield(sOnsets{1}, metricName) || ...
   ~isfield(sTimes{1}, metricName) 
    warning('spindlerShowMetric:MissingMetric', 'Performance metric not availale');
    return;
end

%% Figure out the thresholds to plot and calculate the mean
datasetName = params.name;
lambda2s = params.mcsleepLambda2s;
thresholds = params.mcsleepThresholds;
numLambda2s = length(lambda2s);
numThresholds = length(thresholds);

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
countMetric = reshape(countMetric, numLambda2s, numThresholds);         
hitMetric = reshape(hitMetric, numLambda2s, numThresholds);
intersectMetric = reshape(intersectMetric, numLambda2s, numThresholds);
onsetMetric = reshape(onsetMetric, numLambda2s, numThresholds);
timeMetric = reshape(timeMetric, numLambda2s, numThresholds);

%% Set up the legends
legendStrings = {'\lambda_2=24', '\lambda_2=36', '\lambda_2=48'};
lambdaPos = [3, 9, 15];
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
newColors = [0.4, 0.5, 0.8; 0.8, 0.5, 0.4; 0.2, 0.8, 0.8; 0.0, 0.6, 0.0; 0.3, 0.3, 0.3];
lineWidths = [2, 2, 2, 3];
lineStyles = {':', '--', '-'};
for j = 1:3
    pos = lambdaPos(j);
    plot(thresholds, countMetric(pos, :), 'LineWidth', lineWidths(j), ...
         'Color', newColors(1, :), 'LineStyle', lineStyles{j});
    plot(thresholds, hitMetric(pos, :), 'LineWidth', lineWidths(j), ...
         'Color', newColors(2, :), 'LineStyle', lineStyles{j});
    plot(thresholds, intersectMetric(pos, :), 'LineWidth', lineWidths(j), ...
        'LineStyle', lineStyles{j}, 'Color', newColors(3, :));
    plot(thresholds, onsetMetric(pos, :), 'LineWidth', lineWidths(j), ...
        'LineStyle', lineStyles{j}, 'Color', newColors(4, :));
    plot(thresholds, timeMetric(pos, :), 'LineWidth', lineWidths(j), ...
         'LineStyle', '-.', 'Color', newColors(5, :));
end
hold off
ylabel('Performance')
xlabel('Threshold')
title(theTitle, 'Interpreter', 'None');
legend(legendBoth, 'Location', 'eastoutside');
set(gca, 'YLim', [0, 1]);
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
    
% %%
% tit1 = [theTitle ' count'];
% figure('Name', tit1)
%     plot(lambda2s, countMetric);
%     title(tit1);
%     xlabel('\lambda_2');
%     ylabel('Performance')
%     box on
% 
%     tit2 = [theTitle ' hit'];
% figure('Name', tit2)
%     plot(lambda2s, hitMetric);
%     title(tit2);
%     xlabel('\lambda_2');
%     ylabel('Performance')
%     box on
%     
%     tit3 = [theTitle ' intersect'];
%     figure('Name', tit3)
%     plot(lambda2s, intersectMetric);
%     title(tit3);
%     xlabel('\lambda_2');
%     ylabel('Performance')
%     box on
%     
%     tit4 = [theTitle ' onset'];
%     figure('Name', tit4)
%     plot(lambda2s, onsetMetric);
%     title(tit4);
%     xlabel('\lambda_2');
%     ylabel('Performance')
%     box on
%     
%     tit5 = [theTitle ' time'];
%     figure('Name', tit5)
%     plot(lambda2s, timeMetric);
%     title(tit5);
%     xlabel('\lambda_2');
%     ylabel('Performance')
%     box on
% % if ~isempty(imageDir)
% %     for k = 1:length(params.figureFormats)
% %        thisFormat = params.figureFormats{k};
% %        saveas(figHan, [imageDir filesep theName '_Metric_' metricName '.' ...
% %             thisFormat], thisFormat);
% %     end
% % end
% % if params.figureClose
% %    close(figHan);
% end