%% Extracts compares data for a particular metric against first
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
%algorithms = {'spindler', 'cwta7', 'cwta8', 'sem'};
algorithms = {'spindler', 'mcsleep', 'spinky'};
experts = {'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summarySupervised';
summaryDirUnsupervised = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
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
        [results{k, n}, metricLabels] = extractCrossMetric(test.crossMetrics, metricName);
    end
end


%% Now compare supervised algorithms averaged first and second half
fprintf('\nSupervised averaged\n');
for m = 1:numExperts
    fprintf('\nExpert %s\n', experts{m});
    fileName = [summaryDirUnsupervised filesep collection '_' metricName ...
        '_' methodName '_' experts{m} '_spindler.mat'];
    if exist(fileName, 'file')
        test = load(fileName);
        spindlerMetrics = test.metrics;
    else
        spindlerMetrics = [];
    end
    for n = 1:numAlgorithms
        if ~isempty(spindlerMetrics)
            properties1a = squeeze(results{n, m}(:, 4));
            properties1b = squeeze(results{n, m}(:, 5));
            propertyMask = ~isnan(properties1a) & ~isnan(properties1b) ...
                & ~isnan(spindlerMetrics);
            properties = 0.5*(properties1a(propertyMask) + ...
                properties1b(propertyMask));
            spindler = spindlerMetrics(propertyMask);
            [~, p, ci, tstats] = ttest(spindler(:), properties(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater';
            elseif ci(2) < 0
                status = 'significantly smaller';
            else
                status = 'Not significantly different';
            end
            fprintf(['%s spindler is %s than averaged %s: p=%g  ci=[%g, %g] ' ...
                'tstat = %g  df = %g sd = %g\n'], metricName, ...
                status, algorithms{n}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
        end
        for k = n + 1:numAlgorithms
            properties1a = squeeze(results{n, m}(:, 4));
            properties1b = squeeze(results{n, m}(:, 5));
            properties2a = squeeze(results{k, m}(:, 4));
            properties2b = squeeze(results{k, m}(:, 5));
            propertyMask = ~isnan(properties1a) & ~isnan(properties2a) ...
                & ~isnan(properties1b) & ~isnan(properties2b);
            properties1a = properties1a(propertyMask);
            properties2a = properties2a(propertyMask);
            properties1b = properties1b(propertyMask);
            properties2b = properties2b(propertyMask);
            properties1 = 0.5*(properties1a + properties1b);
            properties2 = 0.5*(properties2a + properties2b);
            [~, p, ci, tstats] = ttest(properties1(:), properties2(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater';
            elseif ci(2) < 0
                status = 'significantly smaller';
            else
                status = 'Not significantly different';
            end
            fprintf(['%s averaged %s is %s than averaged %s: p=%g  ci=[%g, %g] ' ...
                'tstat = %g  df = %g sd = %g\n'], metricName, ...
                algorithms{n}, status, algorithms{k}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
            [~, p, ci, tstats] = ttest(properties1a(:), properties1b(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater';
            elseif ci(2) < 0
                status = 'significantly smaller';
            else
                status = 'Not significantly different';
            end
            fprintf(['%s first half %s is %s than second half %s: p=%g  ci=[%g, %g] ' ...
                'tstat = %g  df = %g sd = %g\n'], metricName, ...
                algorithms{n}, status, algorithms{n}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
            [~, p, ci, tstats] = ttest(properties2a(:), properties2b(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater';
            elseif ci(2) < 0
                status = 'significantly smaller';
            else
                status = 'Not significantly different';
            end
            fprintf(['%s first half %s is %s than second half %s: p=%g  ci=[%g, %g] ' ...
                'tstat = %g  df = %g sd = %g\n'], metricName, ...
                algorithms{k}, status, algorithms{k}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd)
        end
        
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