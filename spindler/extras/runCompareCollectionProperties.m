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
summaryDirUnsupervised = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
summaryDirSupervised = 'D:\TestData\Alpha\spindleData\summarySupervised';
propertyFileBase = [summaryDirUnsupervised filesep collection '_properties_'];
propertyNames = {'Fraction spindling', 'Spindle length (s)', 'Spindles/min'};
numProperties = length(propertyNames);
supervisedFileBase = ...
    [summaryDirSupervised filesep collection '_' baseMetricName '_' methodName '_'];
yLimits = [0, 0.4; 0.5, 2.0; 0, 15];
%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);

%% Extract the unsupervised properties
numAlgorithmsUnsupervised = length(algorithmsUnsupervised);
propertiesUnsupervised = nan(numFiles, numProperties, numAlgorithmsUnsupervised);
propertiesUnsupervisedFirst = ...
    nan(numFiles, numProperties, numAlgorithmsUnsupervised);
propertiesUnsupervisedSecond = ...
    nan(numFiles, numProperties, numAlgorithmsUnsupervised);
for k = 1:numAlgorithmsUnsupervised
    fileName = [propertyFileBase algorithmsUnsupervised{k} '.mat'];
    test = load(fileName);
    propertiesUnsupervised(:, :,  k) = test.spindleProperties;
    propertiesUnsupervisedFirst(:, :, k) = test.spindlePropertiesFirst;
    propertiesUnsupervisedSecond(:, :, k) = test.spindlePropertiesSecond;
end

%% Extract the experts properties
numExperts = length(experts);
propertiesExperts = nan(numFiles, numProperties, numExperts);
propertiesExpertsFirst = nan(numFiles, numProperties, numExperts);
propertiesExpertsSecond = nan(numFiles, numProperties, numExperts);
for k = 1:numExperts
    fileName = [propertyFileBase experts{k} '.mat'];
    test = load(fileName);
    propertiesExperts(:, :, k) = test.spindleProperties;
    propertiesExpertsFirst(:, :, k) = test.spindlePropertiesFirst;
    propertiesExpertsSecond(:, :, k) = test.spindlePropertiesSecond;
end

%% Extract the supervised metrics
numAlgorithmsSupervised = length(algorithmsSupervised);
propertiesSupervisedFirst = nan(numFiles, numProperties, ...
    numAlgorithmsSupervised, numExperts);
propertiesSupervisedSecond = nan(numFiles, numProperties, numAlgorithmsSupervised, numExperts);
propertiesSupervisedAll = nan(numFiles, numProperties, numAlgorithmsSupervised, numExperts);
for k = 1:numAlgorithmsSupervised
    for n = 1:numExperts
        fileName = [supervisedFileBase experts{n} '_' algorithmsSupervised{k} '.mat'];
        test = load(fileName);
        metrics = test.crossMetrics;
        for m = 1:length(metrics)
            firstProperties = metrics(m).propertiesFirstFromSecond;
            if isnan(firstProperties)
                continue;
            end
            propertiesSupervisedFirst(m, :, k, n) = firstProperties;
            propertiesSupervisedSecond(m, :, k, n) = ...
                metrics(m).propertiesSecondFromFirst;
            propertiesSupervisedAll(m, :, k, n) = metrics(m).propertiesAll;
        end
    end
end

%% Do the pictures

yLabels = {'Spindles/min'};
expertShapes = {'s', 'd'};
expertShapesHalf = {'<', '>'};
expertColors = [1, 0, 0; 0.8, 0, 0];
unsupervisedColors = [0, 0, 0; 0, 0.6, 0; 0, 0.7, 0.7; 0, 0, 0.75];
supervisedColors = [0, 0, 0; 0.8, 0.8, 0.2; 0.54, 0.37, 0.16];
subjects = (1:numFiles)';

%% Plot the unsupervised graph
legendStrings = [experts, algorithmsUnsupervised];
for p = 1:numProperties
    theTitle = [collection ':' propertyNames{p} ' Unsupervised'];
    figure('Name', theTitle);
    hold on
    for n = 1:numExperts
        properties = squeeze(propertiesExperts(:, p, n));
        propertyMask = ~isnan(properties);
        theSubjects = subjects(propertyMask);
        theProperties = properties(propertyMask);
        
        theSizes = repmat(200, size(theSubjects));
        ah = scatter(theSubjects, theProperties, theSizes,  'filled', ...
            'MarkerEdgeColor', expertColors(n, :), ...
            'MarkerFaceColor',  expertColors(n, :),...
            'Marker', expertShapes{n});
        
    end
    for n = 1:numAlgorithmsUnsupervised
        properties = squeeze(propertiesUnsupervised(:, p, n));
        propertyMask = ~isnan(properties);
        theSubjects = subjects(propertyMask);
        theProperties = properties(propertyMask);
        if n == 1
            sizeFactor = 200;
        else
            sizeFactor = 100;
        end
        theSizes = repmat(sizeFactor, size(theSubjects));
        ah = scatter(theSubjects, theProperties, theSizes,...
            'filled', ...
            'MarkerEdgeColor', unsupervisedColors(n, :), ...
            'MarkerFaceColor', unsupervisedColors(n, :),...
            'MarkerFaceAlpha', 0.4, ...
            'Marker', 'o', 'LineWidth', 2);
        
    end
    
    set(gca, 'XTick', 1:length(subjects), 'XTickMode', 'manual');
    set(gca, 'YLim', yLimits(p, :), 'YLimMode', 'manual');
    xlabel('Subject');
    ylabel(propertyNames{p});
    legend(legendStrings, 'Location', 'EastOutside');
    title(theTitle);
    grid on
    box on
    hold off
    
    %% Plot the unsupervised averaged halves
    theTitle = [collection ':' propertyNames{p} ' Unsupervised halves averaged'];
    figure('Name', theTitle);
    hold on
    for n = 1:numExperts
        properties1 = squeeze(propertiesExpertsFirst(:, p, n));
        properties2 = squeeze(propertiesExpertsSecond(:, p, n));
        propertyMask = ~isnan(properties1) & ~isnan(properties2);
        theSubjects = subjects(propertyMask);
        theProperties = 0.5*(properties1(propertyMask) + ...
            properties2(propertyMask));
        
        theSizes = repmat(200, size(theSubjects));
        ah = scatter(theSubjects, theProperties, theSizes,  'filled', ...
            'MarkerEdgeColor', expertColors(n, :), ...
            'MarkerFaceColor',  expertColors(n, :),...
            'Marker', expertShapes{n});
        
    end
    for n = 1:numAlgorithmsUnsupervised
        properties1 = squeeze(propertiesUnsupervisedFirst(:, p, n));
        properties2 = squeeze(propertiesUnsupervisedSecond(:, p, n));
        propertyMask = ~isnan(properties1) & ~isnan(properties2);
        theSubjects = subjects(propertyMask);
        theProperties = 0.5*(properties1(propertyMask) + ...
            properties2(propertyMask));
        if n == 1
            sizeFactor = 200;
        else
            sizeFactor = 100;
        end
        theSizes = repmat(sizeFactor, size(theSubjects));
        ah = scatter(theSubjects, theProperties, theSizes,...
            'filled', ...
            'MarkerEdgeColor', unsupervisedColors(n, :), ...
            'MarkerFaceColor', unsupervisedColors(n, :),...
            'MarkerFaceAlpha', 0.4, ...
            'Marker', 'o', 'LineWidth', 2);
        
    end
    
    set(gca, 'XTick', 1:length(subjects), 'XTickMode', 'manual');
    set(gca, 'YLim', yLimits(p, :), 'YLimMode', 'manual');
    xlabel('Subject');
    ylabel(propertyNames{p});
    legend(legendStrings, 'Location', 'EastOutside');
    title(theTitle);
    grid on
    box on
    hold off
    
    %% Figure supervised
    legendStringsSup = {'spindler-unsup', 'expert1-all', 'expert2-all',  ...
        'expert1-half', 'expert1-half'};
    legendStringsSup = [legendStringsSup, algorithmsSupervised, ...
        algorithmsSupervised]; %#ok<*AGROW>
    sizeFactor = 200;
    theTitle = [collection ':' propertyNames{p} ' Supervised'];
    figure('Name', theTitle);
    hold on
    propertiesU = squeeze(propertiesUnsupervised(:, p, 1));
    propertyMaskU = ~isnan(propertiesU);
    theSubjectsU = subjects(propertyMaskU);
    thePropertiesU = propertiesU(propertyMaskU);
    scatter(theSubjectsU, thePropertiesU, sizeFactor,...
        'filled', ...
        'MarkerFaceColor', unsupervisedColors(1, :),...
        'MarkerFaceAlpha', 0.2, ...
        'Marker', 'o', 'LineWidth', 2);
    
    for n = 1:numExperts
        properties = squeeze(propertiesExperts(:, p, n));
        propertyMask = ~isnan(properties);
        theSubjects = subjects(propertyMask);
        theProperties = properties(propertyMask);
        
        theSizes = repmat(sizeFactor, size(theSubjects));
        ah = scatter(theSubjects, theProperties, theSizes,  'filled', ...
            'MarkerFaceColor', expertColors(n, :), ...
            'MarkerFaceAlpha', 0.2, ...
            'Marker', expertShapes{n});
    end
    
    for k = 1:numExperts
        expertsFirst = squeeze(propertiesExpertsFirst(:, p, k));
        expertsSecond = squeeze(propertiesExpertsSecond(:, p, k));
        
        propertyMask = ~isnan(expertsFirst);
        subjectsFirst = subjects(propertyMask);
        expertsFirst = expertsFirst(propertyMask);
        propertyMask = ~isnan(expertsSecond);
        subjectsSecond = subjects(propertyMask);
        expertsSecond = expertsSecond(propertyMask);
        theSubjects = [subjectsFirst; subjectsSecond];
        theProperties = [expertsFirst; expertsSecond];
        
        theSizes = repmat(sizeFactor, size(theSubjects));
        scatter(theSubjects, theProperties, theSizes,...
            'MarkerEdgeColor', expertColors(k, :), ...
            'MarkerFaceColor', expertColors(k, :), ...
            'Marker', expertShapesHalf{k}, 'LineWidth', 2);
    end
    
    for k = 1:numExperts
        for n = 1:numAlgorithmsSupervised
            propertiesFirst = squeeze(propertiesSupervisedFirst(:, p, n, k));
            propertyMask = ~isnan(propertiesFirst);
            subjectsFirst = subjects(propertyMask);
            propertiesFirst = propertiesFirst(propertyMask);
            propertiesSecond = squeeze(propertiesSupervisedSecond(:, p, n, k));
            propertyMask = ~isnan(propertiesSecond);
            subjectsSecond = subjects(propertyMask);
            propertiesSecond = propertiesSecond(propertyMask);
            theProperties =[propertiesFirst; propertiesSecond];
            theSubjects = [subjectsFirst; subjectsSecond];
            
            theSizes = repmat(sizeFactor, size(theSubjects));
            
            scatter(theSubjects, theProperties, theSizes,...
                'MarkerEdgeColor', supervisedColors(n, :), ...
                'Marker', expertShapesHalf{k}, 'LineWidth', 2);
            
        end
    end
    set(gca, 'XTick', 1:length(subjects), 'XTickMode', 'manual');
    set(gca, 'YLim', yLimits(p, :), 'YLimMode', 'manual');
    xlabel('Subject');
    ylabel(propertyNames{p});
    legend(legendStringsSup, 'Location', 'EastOutside');
    grid on
    box on
    hold off
    title(theTitle)
    
    
    %% Compare supervised averaged properties with experts
    legendStringsSup = {'expert1-all', 'expert2-all', 'spindler-unsup'};
    
    sizeFactor = 200;
    theTitle = [collection ':' propertyNames{p} ' Supervised averaged halves'];
    figure('Name', theTitle);
    hold on
    
    for n = 1:numExperts
        theProperties = squeeze(propertiesExperts(:, p, n));
        propertyMask = ~isnan(theProperties);
        theSubjects = subjects(propertyMask);
        theProperties = theProperties(propertyMask);
        
        theSizes = repmat(sizeFactor, size(theSubjects));
        ah = scatter(theSubjects, theProperties, theSizes,  'filled', ...
            'MarkerFaceColor', expertColors(n, :), ...
            'Marker', expertShapes{n});
    end
    properties1 = squeeze(propertiesUnsupervisedFirst(:, p, 1));
    properties2 = squeeze(propertiesUnsupervisedSecond(:, p, 1));
    propertyMask = ~isnan(properties1) & ~isnan(properties2);
    theSubjects = subjects(propertyMask);
    theProperties = 0.5*(properties1(propertyMask) + properties2(propertyMask));
    scatter(theSubjects, theProperties, sizeFactor,...
        'filled', ...
        'MarkerFaceColor', unsupervisedColors(1, :),...
        'MarkerFaceAlpha', 0.2, ...
        'Marker', 'o', 'LineWidth', 2);
    
    
    for k = 1:numExperts
        for n = 1:numAlgorithmsSupervised
            propertiesFirst = squeeze(propertiesSupervisedFirst(:, p, n, k));
            propertiesSecond = squeeze(propertiesSupervisedSecond(:, p, n, k));
            propertyMask = ~isnan(propertiesFirst) & ~isnan(propertiesSecond);
            theSubjects = subjects(propertyMask);
            theProperties = 0.5*(propertiesFirst(propertyMask) + ...
                propertiesSecond(propertyMask));
            theSizes = repmat(sizeFactor, size(theSubjects));
            
            scatter(theSubjects, theProperties, theSizes,...
                'MarkerEdgeColor', supervisedColors(n, :), ...
                'Marker', expertShapesHalf{k}, 'LineWidth', 2);
            nextLegend = {[algorithmsSupervised{n} '-' experts{k}]};
            legendStringsSup = [legendStringsSup, nextLegend]; %#ok<*AGROW>
        end
    end
    set(gca, 'XTick', 1:length(subjects), 'XTickMode', 'manual');
    set(gca, 'YLim', yLimits(p, :), 'YLimMode', 'manual');
    xlabel('Subject');
    ylabel(propertyNames{p});
    legend(legendStringsSup, 'Location', 'EastOutside');
    grid on
    box on
    hold off
    title(theTitle)
end

%% Compare properties of expert 1 and expert 2
fprintf('\n\nStatistical comparison of expert properties:\n');
for m = 1:numProperties
    properties1 = squeeze(propertiesExperts(:, m, 1));
    properties2 = squeeze(propertiesExperts(:, m, 2));
    expertMask = ~isnan(properties1) & ~isnan(properties2);
    properties1 = properties1(expertMask);
    properties2 = properties2(expertMask);
    fprintf('Expert 1:\t%g (%g)\tExpert 2\t%g (%g)\n', ...
        mean(properties1(:)), std(properties1(:)), ...
        mean(properties2(:)), std(properties2(:)));
    [h, p, ci, tstats] = ttest(properties1(:), properties2(:), 'Tail', 'Both');
    if ci(1) > 0
        status = 'significantly greater than';
    elseif ci(2) < 0
        status = 'significantly smaller than';
    else
        status = 'not significantly different from';
    end
    fprintf(['%s expert1 is %s expert2:\tp=%g\tci=[%g, %g]\t' ...
        'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, status,...
        p, ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
end

%% Compare expert properties with unsupervised algorithms
theExpert = 2;
fprintf('\n\nCompare unsupervised with expert %d\n', theExpert);
for m = 1:numProperties
    propertiesE = squeeze(propertiesExperts(:, m, theExpert));
    for n = 1:numAlgorithmsUnsupervised
        properties = squeeze(propertiesUnsupervised(:, m, n));
        propertyMask = ~isnan(properties) & ~isnan(propertiesE);
        expert = propertiesE(propertyMask);
        properties = properties(propertyMask);
        fprintf('Expert %d:\t%g (%g)\t%s\t%g (%g)\n', theExpert, ...
            mean(propertiesE(:)), std(propertiesE(:)), algorithmsUnsupervised{n}, ...
            mean(properties(:)), std(properties(:)));
        [h, p, ci, tstats] = ttest(expert(:), properties(:), 'Tail', 'Both');
        if ci(1) > 0
            status = 'significantly greater than';
        elseif ci(2) < 0
            status = 'significantly smaller than';
        else
            status = 'not significantly different from';
        end
        fprintf(['%s expert2 is %s %s:\tp=%g\tci=[%g, %g]\t' ...
            'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, status,...
            algorithmsUnsupervised{n}, p, ci(1), ci(2), tstats.tstat, ...
            tstats.df, tstats.sd);
    end
end

%% Now compare unsupervised algorithms
fprintf('\n\nCompare unsupervised algorithms');
for m = 1:numProperties
    for n = 1:numAlgorithmsUnsupervised
        for k = n+1:numAlgorithmsUnsupervised
            properties1 = squeeze(propertiesUnsupervised(:, m, n));
            properties2 = squeeze(propertiesUnsupervised(:, m, k));
            propertyMask = ~isnan(properties1) & ~isnan(properties2);
            properties1 = properties1(propertyMask);
            properties2 = properties2(propertyMask);
            fprintf('%s:\t%g (%g)\t%s\t%g (%g)\n', algorithmsUnsupervised{n}, ...
                mean(properties1(:)), std(properties1(:)), algorithmsUnsupervised{k}, ...
                mean(properties2(:)), std(properties2(:)));
            [h, p, ci, tstats] = ttest(properties1(:), properties2(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater than';
            elseif ci(2) < 0
                status = 'significantly smaller than';
            else
                status = 'not significantly different from';
            end
            fprintf(['%s %s is %s %s:\tp=%g\tci=[%g, %g]\t' ...
                'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, ...
                algorithmsUnsupervised{n}, status, algorithmsUnsupervised{k}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
        end
    end
end

%% Compare properties of halves of expert 1 and expert 2
fprintf('\n\nComparing first and second halfs within experts\n');
for m = 1:numProperties
    properties1a = squeeze(propertiesExpertsFirst(:, m, 1));
    properties1b = squeeze(propertiesExpertsSecond(:, m, 1));
    properties2a = squeeze(propertiesExpertsFirst(:, m, 2));
    properties2b = squeeze(propertiesExpertsSecond(:, m, 2));
    expertMask = ~isnan(properties1a) & ~isnan(properties2a) ...
        & ~isnan(properties1b) & ~isnan(properties2b);
    properties1a = properties1a(expertMask);
    properties2a = properties2a(expertMask);
    properties1b = properties1b(expertMask);
    properties2b = properties2b(expertMask);
    fprintf('Expert1a:\t%g (%g)\tExpert1b\t%g (%g)\n', ...
        mean(properties1a(:)), std(properties1a(:)),  ...
        mean(properties1b(:)), std(properties1b(:)));
    [~, p, ci, tstats] = ttest(properties1a(:), properties1b(:), 'Tail', 'Both');
    if ci(1) > 0
        status = 'significantly greater than';
    elseif ci(2) < 0
        status = 'significantly smaller than';
    else
        status = 'not significantly different from';
    end
    fprintf(['%s expert1a is %s expert1b:\tp=%g\tci=[%g, %g]\t' ...
        'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, status,...
        p, ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
    
    fprintf('Expert2a:\t%g (%g)\tExpert2b\t%g (%g)\n', ...
        mean(properties2a(:)), std(properties2a(:)),  ...
        mean(properties2b(:)), std(properties2b(:)));
    [~, p, ci, tstats] = ttest(properties2a(:), properties2b(:), 'Tail', 'Both');
    if ci(1) > 0
        status = 'significantly greater than';
    elseif ci(2) < 0
        status = 'significantly smaller than';
    else
        status = 'not significantly different from';
    end
    
    fprintf(['%s expert2a is %s expert2b:\tp=%g\tci=[%g, %g]\t' ...
        'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, status,...
        p, ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
    
    [~, p, ci, tstats] = ttest(properties1a(:), properties2a(:), 'Tail', 'Both');
    if ci(1) > 0
        status = 'significantly greater than';
    elseif ci(2) < 0
        status = 'significantly smaller than';
    else
        status = 'not significantly different from';
    end
    fprintf(['%s expert1a is %s than expert2a:\tp=%g\tci=[%g, %g]\t' ...
        'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, status,...
        p, ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
    [~, p, ci, tstats] = ttest(properties1b(:), properties2b(:), 'Tail', 'Both');
    if ci(1) > 0
        status = 'significantly greater than';
    elseif ci(2) < 0
        status = 'significantly smaller than';
    else
        status = 'not significantly different from';
    end
    fprintf(['%s expert1b is %s expert2b:\tp=%g\tci=[%g, %g]\t' ...
        'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, status,...
        p, ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
end

%% Compare expert properties with supervised algorithms
fprintf('\n\nComparing supervised with expert %d\n', theExpert);
for m = 1:numProperties
    propertiesEa = squeeze(propertiesExpertsFirst(:, m, theExpert));
    propertiesEb = squeeze(propertiesExpertsSecond(:, m, theExpert));
    for n = 1:numAlgorithmsSupervised
        propertiesFirst = squeeze(propertiesSupervisedFirst(:, m, n, theExpert));
        propertiesSecond = squeeze(propertiesSupervisedSecond(:, m, n, theExpert));
        propertyMask = ~isnan(propertiesEa) & ~isnan(propertiesEb) & ...
            ~isnan(propertiesFirst) & ~isnan(propertiesSecond);
        experta = propertiesEa(propertyMask);
        expertb = propertiesEb(propertyMask);
        propertiesFirst = propertiesFirst(propertyMask);
        propertiesSecond = propertiesSecond(propertyMask);
        expertAveraged = 0.5*(experta + expertb);
        propertiesAveraged = 0.5*(propertiesFirst + propertiesSecond);
        
        fprintf('%s\tExpert %d first half:\t%g (%g)\t%s first half\t%g (%g)\n', ...
            propertyNames{m}, theExpert, ...
            mean(experta(:)), std(experta(:)), algorithmsSupervised{n}, ...
            mean(propertiesFirst(:)), std(propertiesFirst(:)));
        [~, p, ci, tstats] = ttest(experta(:), propertiesFirst(:), 'Tail', 'Both');
        if ci(1) > 0
            status = 'significantly greater than';
        elseif ci(2) < 0
            status = 'significantly smaller than';
        else
            status = 'not significantly different from';
        end
        fprintf(['%s\tExpert %d first half is %s first half %s:\tp=%g\tci=[%g, %g]\t' ...
            'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, theExpert, ...
            status, algorithmsSupervised{n}, p, ci(1), ci(2), ...
            tstats.tstat, tstats.df, tstats.sd);
        
        fprintf('%s\tExpert %d second half:\t%g (%g)\t%s second half\t%g (%g)\n', ...
            propertyNames{m}, theExpert, ...
            mean(expertb(:)), std(expertb(:)), algorithmsSupervised{n}, ...
            mean(propertiesSecond(:)), std(propertiesSecond(:)));
        [h, p, ci, tstats] = ttest(expertb(:), propertiesSecond(:), 'Tail', 'Both');
        if ci(1) > 0
            status = 'significantly greater than';
        elseif ci(2) < 0
            status = 'significantly smaller than';
        else
            status = 'not significantly different from';
        end
        fprintf(['%s\tExpert %d second half is %s second half %s:\tp=%g\tci=[%g, %g]\t' ...
            'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, theExpert, ...
            status, algorithmsSupervised{n}, p, ci(1), ci(2), ...
            tstats.tstat, tstats.df, tstats.sd);
        
        fprintf('%s\tExpert %d averaged:\t%g (%g)\t%s averaged\t%g (%g)\n', ...
            propertyNames{m}, theExpert, ...
            mean(expertAveraged(:)), std(expertAveraged(:)), algorithmsSupervised{n}, ...
            mean(propertiesAveraged(:)), std(propertiesAveraged(:)));
        [~, p, ci, tstats] = ttest(expertAveraged(:), propertiesAveraged(:), 'Tail', 'Both');
        if ci(1) > 0
            status = 'significantly greater than';
        elseif ci(2) < 0
            status = 'significantly smaller than';
        else
            status = 'not significantly different from';
        end
        fprintf(['%s\tExpert %d averaged is %s than  averaged %s:\tp=%g\tci=[%g, %g]\t' ...
            'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, theExpert, ...
            status, algorithmsSupervised{n}, p, ci(1), ci(2), ...
            tstats.tstat, tstats.df, tstats.sd);
    end
end

%% Now compare supervised algorithms self
fprintf('\n\nCompare supervised self halves\n');
for k = 1:numExperts
    for m = 1:numProperties
        for n = 1:numAlgorithmsSupervised
            
            properties1 = squeeze(propertiesSupervisedFirst(:, m, n, k));
            properties2 = squeeze(propertiesSupervisedSecond(:, m, n, k));
            propertyMask = ~isnan(properties1) & ~isnan(properties2);
            properties1 = properties1(propertyMask);
            properties2 = properties2(propertyMask);
            fprintf('%s\t%s first half:\t%g (%g)\t%s second half\t%g (%g)\n', ...
                propertyNames{m}, algorithmsSupervised{n}, ...
                mean(properties1(:)), std(properties1(:)), algorithmsSupervised{n}, ...
                mean(properties2(:)), std(properties2(:)));
            [~, p, ci, tstats] = ttest(properties1(:), properties2(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater than';
            elseif ci(2) < 0
                status = 'significantly smaller than';
            else
                status = 'not significantly different from';
            end
            
            fprintf(['%s\tfirst half %s is %s second half %s for %s:\tp=%g\tci=[%g, %g]\t' ...
                'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, ...
                algorithmsSupervised{n}, status, ...
                algorithmsSupervised{n}, experts{k}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
        end
    end
end

%% Now compare supervised algorithms first halves and second halves
fprintf('\n\n Compare supervised first halves and second halves\n');
for i = 1:numExperts
    for m = 1:numProperties
        for n = 1:numAlgorithmsSupervised
            for k = n + 1:numAlgorithmsSupervised
                properties1First = squeeze(propertiesSupervisedFirst(:, m, n, i));
                properties2First = squeeze(propertiesSupervisedFirst(:, m, k, i));
                propertyMaskFirst = ~isnan(properties1First) & ~isnan(properties2First);
                properties1First = properties1First(propertyMaskFirst);
                properties2First = properties2First(propertyMaskFirst);
                
                fprintf('%s\t%s first half:\t%g (%g)\t%s first half\t%g (%g)\n', ...
                    propertyNames{m}, algorithmsSupervised{n}, ...
                    mean(properties1First(:)), std(properties1First(:)), algorithmsSupervised{k}, ...
                    mean(properties2First(:)), std(properties2First(:)));
                [~, p, ci, tstats] = ttest(properties1First(:), properties2First(:), 'Tail', 'Both');
                if ci(1) > 0
                    status = 'significantly greater than';
                elseif ci(2) < 0
                    status = 'significantly smaller than';
                else
                    status = 'not significantly different from';
                end
                fprintf(['%s\tfirst half %s is %s first half %s for %s:\tp=%g\tci=[%g, %g]\t' ...
                    'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, ...
                    algorithmsSupervised{n}, status, ...
                    algorithmsSupervised{k}, experts{i}, p, ...
                    ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
                
                properties1Second = squeeze(propertiesSupervisedSecond(:, m, n, i));
                properties2Second = squeeze(propertiesSupervisedSecond(:, m, k, i));
                propertyMaskSecond = ~isnan(properties1Second) & ~isnan(properties2Second);
                properties1Second = properties1Second(propertyMaskSecond);
                properties2Second = properties2Second(propertyMaskSecond);
                fprintf('%s\t%s second half:\t%g (%g)\t%s second half\t%g (%g)\n', ...
                    propertyNames{m}, algorithmsSupervised{n}, ...
                    mean(properties1Second(:)), std(properties1Second(:)), algorithmsSupervised{k}, ...
                    mean(properties2Second(:)), std(properties2Second(:)));
                [~, p, ci, tstats] = ttest(properties1Second(:), properties2Second(:), 'Tail', 'Both');
                if ci(1) > 0
                    status = 'significantly greater than';
                elseif ci(2) < 0
                    status = 'significantly smaller than';
                else
                    status = 'not significantly different from';
                end
                fprintf(['%s\tsecond half %s is %s second half %s for %s:\tp=%g\tci=[%g, %g]\t' ...
                    'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, ...
                    algorithmsSupervised{n}, status, ...
                    algorithmsSupervised{k}, experts{i}, p, ...
                    ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
            end
        end
    end
end

%% Now compare supervised algorithms averaged to spindler
fprintf('\n\nSpindler unsupervised to supervised averaged\n');
for k = 1:numExperts
    for m = 1:numProperties
        for n = 1:numAlgorithmsSupervised
            spindlerProperties = squeeze(propertiesUnsupervised(:, m, 1));
            properties1 = squeeze(propertiesSupervisedFirst(:, m, n, k));
            properties2 = squeeze(propertiesSupervisedSecond(:, m, n, k));
            propertyMask = ~isnan(properties1) & ~isnan(properties2) & ...
                ~isnan(spindlerProperties);
            properties1 = properties1(propertyMask);
            properties2 = properties2(propertyMask);
            properties = 0.5*(properties1 + properties2);
            spindlerProperties = spindlerProperties(propertyMask);
            fprintf('%s\tSpindler:\t%g (%g)\t%s averaged\t%g (%g)\n',  ...
                propertyNames{m}, mean(spindlerProperties(:)), ...
                std(spindlerProperties(:)), algorithmsSupervised{n}, ...
                mean(properties(:)), std(properties(:)));
            [~, p, ci, tstats] = ttest(spindlerProperties(:), properties(:), 'Tail', 'Both');
            if ci(1) > 0
                status = 'significantly greater than';
            elseif ci(2) < 0
                status = 'significantly smaller than';
            else
                status = 'not significantly different from';
            end
            fprintf(['%s\tspindler is %s averaged %s from %s:\tp=%g\tci=[%g, %g]\t' ...
                'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, ...
                status, algorithmsSupervised{n}, experts{k}, p, ...
                ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
        end
    end
end
%% Now compare supervised algorithms averaged first and second half
fprintf('\nCompare supervised averaged\n');
for i = 1:numExperts
    for m = 1:numProperties
        for n = 1:numAlgorithmsSupervised
            for k = n + 1:numAlgorithmsSupervised
                properties1First = squeeze(propertiesSupervisedFirst(:, m, n, i));
                properties2First = squeeze(propertiesSupervisedFirst(:, m, k, i));
                properties1Second = squeeze(propertiesSupervisedSecond(:, m, n, i));
                properties2Second = squeeze(propertiesSupervisedSecond(:, m, k, i));
                propertyMask = ~isnan(properties1Second) & ~isnan(properties2Second) ...
                    & ~isnan(properties1First) & ~isnan(properties2First);
                properties1First = properties1First(propertyMask);
                properties2First = properties2First(propertyMask);
                properties1Second = properties1Second(propertyMask);
                properties2Second = properties2Second(propertyMask);
                properties1 = 0.5*(properties1First + properties1Second);
                properties2 = 0.5*(properties2First + properties2Second);
                fprintf('%s\t%s:\t%g (%g)\t%s\t%g (%g)\n', ...
                    propertyNames{m}, algorithmsSupervised{n}, ...
                    mean(properties1(:)), std(properties1(:)), algorithmsSupervised{k}, ...
                    mean(properties2(:)), std(properties2(:)));
                
                [~, p, ci, tstats] = ttest(properties1(:), properties2(:), 'Tail', 'Both');
                if ci(1) > 0
                    status = 'significantly greater than';
                elseif ci(2) < 0
                    status = 'significantly smaller than';
                else
                    status = 'not significantly different from';
                end
                fprintf(['%s\taveraged %s is %s averaged %s from %s:\tp=%g\tci=[%g, %g]\t' ...
                    'tstat = %g\tdf = %g\tsd = %g\n'], propertyNames{m}, ...
                    algorithmsSupervised{n}, status, ...
                    algorithmsSupervised{k}, experts{i}, p, ...
                    ci(1), ci(2), tstats.tstat, tstats.df, tstats.sd);
            end
        end
    end
end