%% Extracts data for a particular collection of unsupervised algorithms
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithmsUnsupervised = {'spindler', 'cwta7', 'cwta8', 'sem'};
algorithmsSupervised = {'spindler', 'mcsleep', 'spinky'};
experts = {'expert1', 'expert2'};
baseMetricName = 'f1';
methodName = 'time';
metricNames = {'f1', 'fdr'};
summaryDirUnsupervised = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
summaryDirSupervised = 'D:\TestData\Alpha\spindleData\summarySupervised';
supervisedFileBase = ...
    [summaryDirSupervised filesep collection '_' baseMetricName '_' methodName '_'];


%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
numMetrics = length(metricNames);
numExperts = length(experts);
%% Extract the unsupervised metrics
numAlgorithmsUnsupervised = length(algorithmsUnsupervised);
metricsUnsupervised = nan(numFiles, numMetrics, ...
    numAlgorithmsUnsupervised, numExperts);
for m = 1:numMetrics
    fileBase = [summaryDirUnsupervised filesep collection '_' ...
        metricNames{m} '_' methodName '_'];
    for k = 1:numAlgorithmsUnsupervised
        for n = 1:numExperts
            fileName = [fileBase experts{n} '_' algorithmsUnsupervised{k} '.mat'];
            test = load(fileName);
            metricsUnsupervised(:, m,  k, n) = test.metrics;
        end
    end
end

%% Metrics experts
params = processParameters('runCompareCollectionMetrics', 0, 0, struct(), getGeneralDefaults());
metricsExperts = nan(numFiles, numMetrics, numExperts, numExperts);
baseFile = [summaryDirUnsupervised filesep collection '_properties_'];
for n = 1:numExperts
    test1 = load([baseFile experts{n} '.mat']);
    events = test1.eventSummary;
    if isempty(events)
        continue;
    end
    for k = 1:numExperts
        test2 = load([baseFile experts{k} '.mat']);
        eventsLabeled = test2.eventSummary;
        if isempty(eventsLabeled)
            continue;
        end
        for i = 1:numFiles 
            params.srate = test2.samplingRates(i);
            if isnan(params.srate)
                continue;
            end
            metrics = getPerformanceMetrics(events{i}, eventsLabeled{i}, ...
                       test2.totalTimes(i), params);
            for m = 1:numMetrics
                metricsExperts(i, m, k, n) = metrics.(methodName).(metricNames{m});
            end
        end
    end
end

%% Extract the supervised metrics
numAlgorithmsSupervised = length(algorithmsSupervised);
metricsSupervisedFirst = nan(numFiles, numMetrics, ...
                             numAlgorithmsSupervised, numExperts);
metricsSupervisedSecond = nan(numFiles, numMetrics, ...
    numAlgorithmsSupervised, numExperts);

for k = 1:numAlgorithmsSupervised
    for n = 1:numExperts
        fileName = [supervisedFileBase experts{n} '_' algorithmsSupervised{k} '.mat'];
        test = load(fileName);
        results = test.crossMetrics;
        for i = 1:length(results)
            for m = 1:numMetrics
                pos = strcmpi(results(i).metricNames, metricNames{m});
                if isempty(pos) || isnan(results(i).valueAll)
                    continue;
                end
                
                metricsSupervisedFirst(i, m, k, n) = ...
                    results(i).metricsFirstFromSecond(pos);
                metricsSupervisedSecond(i, m, k, n) = ...
                    results(i).metricsSecondFromFirst(pos);
            end
        end
    end
end

%% Now compare expert ratings against each other
fprintf('\n\nCompare experts against each other\n');
for m = 1:numMetrics
    for n = 1:numExperts
        for k = 1:numExperts
            metrics1 = squeeze(metricsExperts(:, m, n, k));
            metricsMask = ~isnan(metrics1);
            metrics1 = metrics1(metricsMask);
           
            fprintf('[%s] %s (ground truth %s): %g(%g)\n', metricNames{m}, ...
                experts{n}, experts{k}, mean(metrics1), std(metrics1));
        end
    end
end

%% Now compare unsupervised algorithms for each expert
for n = 1:numExperts
    fprintf('\n\nCompare unsupervised algorithms for %s\n', experts{n});
    for m = 1:numMetrics     
        for k = 1:numAlgorithmsUnsupervised
            for i = k+1:numAlgorithmsUnsupervised
                metrics1 = squeeze(metricsUnsupervised(:, m, k, n));
                metrics2 = squeeze(metricsUnsupervised(:, m, i, n));
                metricsMask = ~isnan(metrics1) & ~isnan(metrics2);
                metrics1 = metrics1(metricsMask);
                metrics2 = metrics2(metricsMask);
                fprintf('%s: %g(%g)   %s: %g(%g)\n', ...
                    algorithmsUnsupervised{k}, mean(metrics1), std(metrics1), ...
                    algorithmsUnsupervised{i}, mean(metrics2), std(metrics2));
                [~, p, ci, tstats] = ttest(metrics1(:), metrics2(:), 'Tail', 'Both');
                if ci(1) > 0
                    status = 'significantly greater';
                elseif ci(2) < 0
                    status = 'significantly smaller';
                else
                    status = 'Not significantly different';
                end
                fprintf(['%s %s is %s than %s: p=%g  ci=[%g, %g] ' ...
                    'tstat = %g  df = %g sd = %g\n'], metricNames{m}, ...
                    algorithmsUnsupervised{k}, status, algorithmsUnsupervised{i}, p, ...
                    ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
            end
        end
    end
end

%% Now compare unsupervised algorithms self performance across experts
fprintf('\n\nCompare unsupervised algorithms self performance across ratings\n');
for m = 1:numMetrics
    for k = 1:numAlgorithmsUnsupervised
        metrics1 = squeeze(metricsUnsupervised(:, m, k, 1));
        metrics2 = squeeze(metricsUnsupervised(:, m, k, 2));
        metricsMask = ~isnan(metrics1) & ~isnan(metrics2);
        metrics1 = metrics1(metricsMask);
        metrics2 = metrics2(metricsMask);
        fprintf('%s: expert 1 %g(%g) expert 2 %g(%g)\n', ...
            algorithmsUnsupervised{k}, mean(metrics1), std(metrics1), ...
            mean(metrics2), std(metrics2));
        [~, p, ci, tstats] = ttest(metrics1(:), metrics2(:), 'Tail', 'Both');
        if ci(1) > 0
            status = 'significantly greater';
        elseif ci(2) < 0
            status = 'significantly smaller';
        else
            status = 'Not significantly different';
        end
        fprintf(['%s %s expert 1 is %s than expert 2: p=%g  ci=[%g, %g] ' ...
            'tstat = %g  df = %g sd = %g\n'], metricNames{m}, ...
            algorithmsUnsupervised{k}, status, p, ...
            ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
    end
end


%% Now compare supervised algorithms self
for n = 1:numExperts
    fprintf('\n\nCompare supervised self halves for %s\n', experts{n});
    for m = 1:numMetrics
        for k = 1:numAlgorithmsSupervised 
            metrics1 = squeeze(metricsSupervisedFirst(:, m, k, n));
            metrics2 = squeeze(metricsSupervisedSecond(:, m, k, n));
            metricMask = ~isnan(metrics1) & ~isnan(metrics2);
            metrics1 = metrics1(metricMask);
            metrics2 = metrics2(metricMask);
            [~, p, ci, tstats] = ttest(metrics1(:), metrics2(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater';
            elseif ci(2) < 0
                status = 'significantly smaller';
            else
                status = 'Not significantly different';
            end
            fprintf(['%s first half %s is %s than second half %s for %s: p=%g  ci=[%g, %g] ' ...
                'tstat = %g  df = %g sd = %g\n'], metricNames{m}, ...
                algorithmsSupervised{k}, status, ...
                algorithmsSupervised{k}, experts{n}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
        end
    end
end

%% Now compare supervised algorithms averaged halves
fprintf('\n\n Compare supervised averaged halves across experts\n');
for m = 1:numMetrics
    for k = 1:numAlgorithmsSupervised
        
        metrics1First = squeeze(metricsSupervisedFirst(:, m, k, 1));
        metrics2First = squeeze(metricsSupervisedFirst(:, m, k, 2));
        metrics1Second = squeeze(metricsSupervisedSecond(:, m, k, 1));
        metrics2Second = squeeze(metricsSupervisedSecond(:, m, k, 2));
        metricMask = ~isnan(metrics1First) & ~isnan(metrics2First) ...
            & ~isnan(metrics1Second) & ~isnan(metrics2Second);
        metrics1 = 0.5*(metrics1First(metricMask) + ...
            metrics1Second(metricMask));
        metrics2 = 0.5*(metrics2First(metricMask) + ...
            metrics2Second(metricMask));
        fprintf('%s: expert 1 %g(%g)  expert 2 %g(%g)\n', ...
            algorithmsSupervised{k}, mean(metrics1), std(metrics1), ...
            mean(metrics2), std(metrics2));
        [~, p, ci, tstats] = ttest(metrics1(:), metrics2(:), 'Tail', 'Both');
        if ci(1) > 0
            status = 'significantly greater';
        elseif ci(2) < 0
            status = 'significantly smaller';
        else
            status = 'Not significantly different';
        end
        fprintf(['%s expert 1 average %s is %s than expert 2 average: p=%g  ci=[%g, %g] ' ...
            'tstat = %g  df = %g sd = %g\n'], metricNames{m}, ...
            algorithmsSupervised{k}, status, p, ...
            ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
        
    end
end


%% Now compare supervised algorithms averaged to spindler 
for n = 1:numExperts
    fprintf('\n\nSpindler unsupervised to supervised averaged for %s\n', ...
        experts{n});
    for m = 1:numMetrics
        for k = 1:numAlgorithmsSupervised
            spindlerMetrics = squeeze(metricsUnsupervised(:, m, 1, n));
            metrics1 = squeeze(metricsSupervisedFirst(:, m, k, n));
            metrics2 = squeeze(metricsSupervisedSecond(:, m, k, n));
            metricMask = ~isnan(metrics1) & ~isnan(metrics2) & ...
                ~isnan(spindlerMetrics);
            metrics = 0.5*(metrics1(metricMask) + metrics2(metricMask));
            spindlerMetrics = spindlerMetrics(metricMask);
            [~, p, ci, tstats] = ttest(spindlerMetrics(:), metrics(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater';
            elseif ci(2) < 0
                status = 'significantly smaller';
            else
                status = 'Not significantly different';
            end
            fprintf('Spindler: %g(%g)   %s: %g(%g)\n', mean(spindlerMetrics), ...
                std(spindlerMetrics), algorithmsSupervised{k}, ...
                mean(metrics), std(metrics));
            fprintf(['%s spindler is %s than averaged %s from %s: p=%g  ci=[%g, %g] ' ...
                'tstat = %g  df = %g sd = %g\n'], metricNames{m}, ...
                status, algorithmsSupervised{k}, experts{n}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
        end
    end
end
%% Now compare supervised algorithms averaged first and second half
fprintf('\nCompare supervised averaged\n');
for i = 1:numExperts
    for m = 1:numMetrics
        for n = 1:numAlgorithmsSupervised
            for k = n + 1:numAlgorithmsSupervised
                metrics1First = squeeze(metricsSupervisedFirst(:, m, n, i));
                metrics2First = squeeze(metricsSupervisedFirst(:, m, k, i));
                metrics1Second = squeeze(metricsSupervisedSecond(:, m, n, i));
                metrics2Second = squeeze(metricsSupervisedSecond(:, m, k, i));
                metricMask = ~isnan(metrics1Second) & ~isnan(metrics2Second) ...
                    & ~isnan(metrics1First) & ~isnan(metrics2First);
                metrics1First = metrics1First(metricMask);
                metrics2First = metrics2First(metricMask);
                metrics1Second = metrics1Second(metricMask);
                metrics2Second = metrics2Second(metricMask);
                metrics1 = 0.5*(metrics1First + metrics1Second);
                metrics2 = 0.5*(metrics2First + metrics2Second);
                [~, p, ci, tstats] = ttest(metrics1(:), metrics2(:), 'Tail', 'Both');
                if ci(1) > 0
                    status = 'significantly greater';
                elseif ci(2) < 0
                    status = 'significantly smaller';
                else
                    status = 'Not significantly different';
                end
                fprintf(['%s averaged %s is %s than averaged %s from %s: p=%g  ci=[%g, %g] ' ...
                    'tstat = %g  df = %g sd = %g\n'], metricNames{m}, ...
                    algorithmsSupervised{n}, status, ...
                    algorithmsSupervised{k}, experts{i}, p, ...
                    ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
            end
        end
    end
end