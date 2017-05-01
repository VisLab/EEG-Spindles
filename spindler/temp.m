resultsDir = 'D:\TestData\Alpha\spindleData\ResultSummary';
dreamsAlgs = {'Spindler', 'Asd', 'Tsanas_a7', 'Tsanas_a8', 'Wendt'};
drivingAlgs = {'Spindler', 'Asd', 'Tsanas_a7', 'Tsanas_a8'};
algColors = [0.8, 0.8, 0.2; 0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0];
metricNames = {'F1', 'F2', 'G'};

%% Read in all of the summary data
dreamsResults = cell(length(dreamsAlgs), 1);
for k = 1:length(dreamsResults)
    dreamsResults{k} = load([resultsDir filesep 'dreams_' dreamsAlgs{k} '_Summary.mat']);
    dreamsResults{k}.algorithm = dreamsAlgs{k};
end
drivingResults = cell(2*length(drivingAlgs), 1);
for k = 1:length(drivingAlgs)
    drivingResults{k} = load([resultsDir filesep 'bcit_' drivingAlgs{k} '_Summary.mat']);
    drivingResults{k}.algorithm = [drivingAlgs{k} '_bcit'];
    
    drivingResults{length(drivingAlgs) + k} = load([resultsDir filesep 'nctu_' drivingAlgs{k} '_Summary.mat']);
    drivingResults{length(drivingAlgs) + k}.algorithm = [drivingAlgs{k} '_nctu'];
end

%% Construct dreams summary matrix for plotting
numberMethods = length(dreamsResults{1}.methodNames);
numberFiles = length(dreamsResults{1}.dataNames);
numberAlgs = length(dreamsAlgs);
numberMetrics = 3;
dreams = zeros(numberFiles - 2, numberMethods, numberAlgs, numberMetrics);
for k = 1:numberAlgs
    theseResults = dreamsResults{k}.results;
    for n = 1:numberMetrics
        for j = 1:numberFiles - 2
            for m = 1:numberMethods
                dreams(j, m, k, n) = theseResults(m, n, j);
            end
        end
    end
end

%%
hitIndices = 2:4;
baseIndex = 1;
dataSummary = dreams(:, hitIndices, :, :);
dreamsStats = getPairedStatistics(dataSummary, baseIndex, dreamsAlgs); 
% [numDatasets, numMethods, numAlgs, numMetrics] = size(dreams);
% stats(numAlgs - 1) = struct('baseAlg', NaN, 'alg', NaN, ...
%                             'h', NaN, 'p', NaN, 'ci', NaN, 'tstats', NaN);
% fprintf('Base algorithm %s is ...\n', algorithms{baseIndex});
% for k = 1:numAlgs
%     stats(k) = stats(end);
%     thisData = squeeze(otherData(:, hitIndices, k, :));
%     stats(k).baseAlg = algorithms{baseIndex};
%     stats(k).alg = algorithms{k};
%     [h, p, ci, tstats] = ttest(baseData, thisData(:), 'Tail', 'Both');
%     if ci(1) > 0
%         status = 'significantly better than';
%     elseif ci(2) < 0
%         status = 'significantly worse than';
%     else
%         status = 'Not significantly different than';
%     end
%     stats(k).h = h;
%     stats(k).p = p;
%     stats(k).ci = ci;
%     stats(k).tstats = tstats;
%     fprintf('%s %s: p=%g  ci=[%g, %g]\n', status, algorithms{k}, p, ci(1), ci(2));
% end
    

%% Plot the dreams summary
% theTitle = 'Dreams performance';
% for n = 1:numberMetrics
%     metricName = metricNames{n};
%     theseResults = squeeze(dreams(:, :, :, n));
%     figHan = compareMetric(theseResults, metricName, dreamsAlgs, ...
%                            algColors, theTitle);
% end
% 
% %% Construct driving results
% numberMethods = length(drivingResults{1}.methodNames);
% numberFiles = length(drivingResults{1}.dataNames);
% numberAlgs = length(drivingAlgs);
% numberMetrics = length(metricNames);
% driving1 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
% for k = 1:numberAlgs
%     theseResults = drivingResults{k}.results;
%     for n = 1:numberMetrics
%         for j = 1:numberFiles
%             for m = 1:numberMethods
%                 driving1(j, m, k, n) = theseResults(m, n, j);
%             end
%         end
%     end
% end
% drivingResults2 = drivingResults(numberAlgs + 1:end);
% numberMethods = length(drivingResults2{1}.methodNames);
% numberFiles = length(drivingResults2{1}.dataNames);
% numberAlgs = length(drivingAlgs);
% numberMetrics = 3;
% driving2 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
% for k = 1:numberAlgs
%     theseResults = drivingResults2{k}.results;
%     for n = 1:numberMetrics
%         for j = 1:numberFiles
%             for m = 1:numberMethods
%                 driving2(j, m, k, n) = theseResults(m, n, j);
%             end
%         end
%     end
% end
% driving = [driving1; driving2];
% 
% %% Plot the summary performance
% theTitle = 'Driving performance';
% for n = 1:numberMetrics
%     metricName = metricNames{n};
%     theseResults = squeeze(driving(:, :, :, n));
%     figHan = compareMetric(theseResults, metricName, drivingAlgs, ...
%                            algColors, theTitle);
% end
