function stats = getPairedStatistics(dataSummary, baseIndex, algorithms) 
%% Performs paired statistics

[numDatasets, numMethods, numAlgs, numMetrics] = size(dataSummary);
baseData = dataSummary(:, :, baseIndex, :);
baseData = baseData(:);
stats(numAlgs - 1) = struct('baseAlg', NaN, 'alg', NaN, ...
               'h', NaN, 'p', NaN, 'ci', NaN, 'tstats', NaN, 'status', NaN);
fprintf('Significance of %s for %d datasets, %d methods, and %d metrics ...\n', ...
         algorithms{baseIndex}, numDatasets, numMethods, numMetrics);
for k = 1:numAlgs
    stats(k) = stats(end);
    thisData = squeeze(dataSummary(:, :, k, :));
    stats(k).baseAlg = algorithms{baseIndex};
    stats(k).alg = algorithms{k};
    [h, p, ci, tstats] = ttest(baseData, thisData(:), 'Tail', 'Both');
    if ci(1) > 0
        status = 'significantly better than';
    elseif ci(2) < 0
        status = 'significantly worse than';
    else
        status = 'Not significantly different than';
    end
    status = sprintf('%s %s %s: p=%g  ci=[%g, %g] tstat = %g', ...
         algorithms{baseIndex},  status, algorithms{k}, p, ci(1), ci(2), tstats.tstat);
    stats(k).h = h;
    stats(k).p = p;
    stats(k).ci = ci;
    stats(k).tstats = tstats;
    stats(k).status = status;
    fprintf('%s\n', status);
end

