%% Extracts compares data for a particular metric against first
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
%algorithms = {'spindler', 'cwta7', 'cwta8', 'sem'};
algorithms = {'spindler'};
experts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summarySupervised';
summaryImageDir = 'D:\TestData\Alpha\spindleData\summaryImageSupervised';
summaryStatisticsDir = 'D:\TestData\Alpha\spindleData\summaryStatisticsSupervised';
metricName = 'f1';
methodName = 'time';
figureFormats = {'png', 'fig'};
figureClose = false;

%% Make sure the output directories exist
if ~exist(summaryImageDir, 'dir')
    mkdir(summaryImageDir);
end

if ~exist(summaryStatisticsDir, 'dir')
    mkdir(summaryStatisticsDir)
end

%% Read in the performance data
numAlgorithms = length(algorithms);
numExperts = length(experts);
results = cell(numAlgorithms, numExperts);
for k = 1:numAlgorithms
   for n = 1:numExperts
       fileName = [summaryDir filesep collection '_' metricName ...
                   '_' methodName '_' experts{n} '_' algorithms{k} '.mat'];
       if ~exist(fileName, 'file')
            results{k, n} = nan;
            continue;
       end
       test = load(fileName);
       results{k, n} = extractCrossMetric(test.crossMetrics, metricName);
   end
end

% numAlgorithms = length(algorithms);
% numExperts = length(experts);
% results = cell(numAlgorithms, numExperts);
% for k = 1:numAlgorithms
%    for n = 1:numExperts
%        fileName = [summaryDir filesep collection '_' metricName ...
%                    '_' methodName '_' experts{n} '_' algorithms{k} '.mat'];
%        if ~exist(fileName, 'file')
%             results{k, n} = nan;
%             continue;
%        end
%        test = load(fileName);
%        results{k, n} = test.metrics;
%    end
% end
%  
% %% Set up algorithms
% algColors = [0.8, 0.8, 0.2; 0, 0, 0.75; 0, 0.7, 0.7; 0.8, 0.8, 0.3];
% theTitle = [collection ': ' methodName];
% eventMarkers = {'*', '^', 'v'};
% figHan = figure('Name', theTitle);
% hold on
% legendStrings = cell(1, numExperts*(numAlgorithms - 1));
% lCount = 0;
% for n = 1:numExperts
%     baseResult = results{1, n};
%     for k = 2:numAlgorithms
%        theseResults = results{k, n};
%        nanMask = isnan(baseResult) | isnan(theseResults);
%        plot(baseResult(~nanMask), theseResults(~nanMask), ...
%                'Marker', eventMarkers{n}, 'Color', algColors(k, :), ...
%                 'LineStyle', 'None', 'LineWidth', 2, 'MarkerSize', 10) 
%       
%        lCount = lCount + 1;
%        legendStrings{lCount} = [algorithms{k} ': ' experts{n}];
%        
%    end 
% end
% 
% line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
% hold off
% legend(legendStrings, 'Location', 'EastOutside', 'Interpreter', 'None');
% box on
% xlabel([metricName ' ' algorithms{1}])
% ylabel([metricName ' other algorithms'])
% title(theTitle)
% 
% %% Save the directories
% if ~isempty(summaryImageDir)
%     for k = 1:length(figureFormats)
%        thisFormat = figureFormats{k};
%        saveas(figHan, [summaryImageDir filesep collection '_' ...
%               metricName '_unsupervised.' thisFormat], thisFormat);
%     end
% end
% 
% if figureClose
%    close(figHan);
% end
% 
% %% Now calculate paired statistics
% stats = getPairedStatistics(results, 1, algorithms, ...
%                            experts, metricName, methodName);
% statsName = [collection '_' metricName '_unsupervised.mat'];
% save([summaryStatisticsDir filesep statsName], 'stats', '-v7.3');