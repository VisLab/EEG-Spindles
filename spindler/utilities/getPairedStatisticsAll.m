function stats = getPairedStatistics(dataSummary, baseIndex, ...
                                      algorithms, metricNames, methodNames)
%% Performs paired statistics tests base Index to others.
%
%   Parameters:
%       dataSummary    files x methods x algorithms x metrics results
%       baseIndex      index of algorithm to use as the base
%       algorithms     cell array of algorithm names.

[numDatasets, numMethods, numAlgs, numMetrics] = size(dataSummary);
baseData = dataSummary(:, :, baseIndex, :);
baseData = baseData(:);
stats(numAlgs - 1) = struct('baseAlg', NaN, 'alg', NaN, ...
    'h', NaN, 'p', NaN, 'ci', NaN, 'tstats', NaN, 'status', NaN);
fprintf('\nSignificance of %s for %d datasets, %d methods, and %d metrics ...\n', ...
    algorithms{baseIndex}, numDatasets, numMethods, numMetrics);
otherIndices = setdiff(1:numAlgs, baseIndex);
baseAlgorithm = algorithms{baseIndex};
fprintf('For metrics: ');
for k = 1:numMetrics
    fprintf('%s ', metricNames{k});
end
fprintf('\n');
fprintf('For methods: ');
for k = 1:numMethods
    fprintf('%s ', methodNames{k});
end
fprintf('\n');

for k = 1:length(otherIndices)
    thisIndex = otherIndices(k);
    thisAlgorithm = algorithms{thisIndex};
    thisData = squeeze(dataSummary(:, :, thisIndex, :));
    
    stats(k) = getTTest(baseData(:), thisData(:), baseAlgorithm, thisAlgorithm);
end

%% Now do this for the individual metrics


    function theseStats = getTTest(baseData, thisData, baseAlgorithm, thisAlgorithm)
        
        theseStats = struct('baseAlg', NaN, 'alg', NaN, ...
            'h', NaN, 'p', NaN, 'ci', NaN, 'tstats', NaN, 'status', NaN);
        theseStats.baseAlg = baseAlgorithm;
        theseStats.alg = thisAlgorithm;
        [h, p, ci, tstats] = ttest(baseData(:), thisData(:), 'Tail', 'Both');
        if ci(1) > 0
            status = 'significantly better than';
        elseif ci(2) < 0
            status = 'significantly worse than';
        else
            status = 'Not significantly different than';
        end
        status = sprintf('%s %s %s: p=%g  ci=[%g, %g] tstat = %g', ...
            baseAlgorithm,  status, thisAlgorithm, p, ci(1), ci(2), tstats.tstat);
        theseStats.h = h;
        theseStats.p = p;
        theseStats.ci = ci;
        theseStats.tstats = tstats;
        theseStats.status = status;
        fprintf('%s\n', status);
    end
end