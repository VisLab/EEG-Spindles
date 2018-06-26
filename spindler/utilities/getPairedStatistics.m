function stats = getPairedStatistics(results, baseIndex, algorithms, ...
                                     experts, metricName, methodName)
%% Performs paired statistics tests base Index to others.
%
%   Parameters:
%       results        algorithms x experts cell array of results
%       baseIndex      index of algorithm to use as the base
%       algorithms     cell array of algorithm names
%       metricName     name of the metric
%       methodName     name of the method for comparing ground truth
%% Consolidate the data into an array for the paired ttest
[numAlgs, numExperts] = size(results);

numFiles = length(results{1, 1});
consolidated = nan(numFiles*numExperts, numAlgs);
for k = 1:numAlgs
    start = 1;
    for n = 1:numExperts
        consolidated(start:start + numFiles - 1, k) = results{k, n};
        start = start + numFiles;
    end
end
nanMask = isnan(consolidated(:, 1));
for k = 2:numAlgs
    nanMask = nanMask | isnan(consolidated(:, k));
end
consolidated = consolidated(~nanMask, :);

%% Now computed paired t-test
baseData = consolidated(:, baseIndex);
stats(numAlgs - 1) = struct('algorithm', NaN, 'baseAlgorithm', NaN,  ...
   'experts', NaN, 'metric', NaN, 'method', NaN, 'h', NaN, 'p', NaN, 'ci', NaN, ...
   'tstats', NaN, 'status', NaN);

otherData = consolidated;
otherData(:, baseIndex) = [];
baseAlgorithm = algorithms{baseIndex};
otherAlgorithms = algorithms;
otherAlgorithms(baseIndex) = [];
fprintf(['\nSignificance of %s for %d experts for %d datasets ' ...
         'for metric %s and method %s:\n'], ...
        baseAlgorithm, numExperts, numFiles, metricName, methodName);
for k = 1:numAlgs - 1
    stats(k) = stats(end);
    stats(k).algorithm = otherAlgorithms{k};
    stats(k).baseAlgorithm = baseAlgorithm;
    stats(k).experts = experts;
    [stats(k).h, stats(k).p, stats(k).ci, stats(k).tstats] = ...
        ttest(baseData(:), otherData(:, k), 'Tail', 'Both');
    if stats(k).ci(1) > 0
        status = 'significantly greater';
    elseif stats(k).ci(2) < 0
        status = 'significantly smaller';
    else
        status = 'Not significantly different than';
    end
    status = sprintf('%s %s %s: p=%g  ci=[%g, %g] tstat = %g', ...
        baseAlgorithm,  status, stats(k).algorithm, ...
        stats(k).p, stats(k).ci(1), stats(k).ci(2), stats(k).tstats.tstat);
    fprintf('%s\n', status);
end
