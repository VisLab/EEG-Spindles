function [spindleCurves, warningMsgs] = spindlerGetParameterCurves2Old(spindles, outDir, params)
%% Show behavior of spindle counts as a function of threshold and atoms/sec 
%
%  Parameters:
%     spindles     Spindler structure with results of MP decomposition
%     totalSeconds Total seconds in the dataset
%     theName      String identifying the name of the dataset
%     outDir       Optional argument (if present and non empty, saves a
%                  plot of the parameter selection results in outDir
%     spindleCurves (output) Structure containing results of parameter
%                  selection
%     warningMsgs (output) Structure containing results of parameter
%                  selection
%
%  Written by:  Kay Robbins and John La Rocco, UTSA 2017

    %% Get the atoms per second and thresholds
    warningMsgs = {};
    spindleCurves = struct('name', NaN, ...
                 'atomsPerSecond', NaN, 'bestAtomsPerSecond', NaN, ....
                 'baseThresholds', NaN, 'bestLinearInd', NaN, ...
                 'bestThreshold', NaN, 'bestThresholdInd', NaN, ...
                  'atomRateRange', NaN, 'atomRateRangeInd', NaN,...
                 'atomHitRange', NaN, 'atomHitRangeInd', NaN,...
                 'eFractionBest', NaN, 'eFractMaxInd', NaN, ...
                 'bestAtomInd', NaN, 'spindleRateSTD', NaN);
    defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());         
    params = processParameters('getSpindlerCurves', nargin, 2, params, defaults);
    atomsPerSecond = unique(cellfun(@double, {spindles.atomsPerSecond}))';
    baseThresholds = unique(cellfun(@double, {spindles.baseThreshold}));
    numAtoms = length(atomsPerSecond);
    numThresholds = length(baseThresholds);
    [~, minThresholdInd] = min(baseThresholds);
    [~, maxThresholdInd] = max(baseThresholds);
    totalSeconds = params.frames./params.srate;
    theName = params.name;
    stdLimits = params.spindlerSTDLimits;
    spindleCurves.name = params.name;

    %% Get the spindle hits and spindle times
    spindleHits = cellfun(@double, {spindles.numberSpindles});
    spindleHits = reshape(spindleHits, numAtoms, numThresholds);
    spindleTime = cellfun(@double, {spindles.spindleTime});
    spindleTime = reshape(spindleTime, numAtoms, numThresholds);
    spindleRate = 60*spindleHits/totalSeconds;
    spindle25 = cellfun(@double, {spindles.eventTime25Per});
    spindle50 = cellfun(@double, {spindles.eventTime50Per});
    spindle75 = cellfun(@double, {spindles.eventTime75Per});
    spindleRatio = zeros(size(spindle50));
    spindleMask = spindle25 == spindle50 | spindle50 == spindle75;
    spindleMin = zeros(size(spindle50));
    spindleMax = zeros(size(spindle50));
    spindleHarmonicMean = zeros(size(spindle50));
    for k = 1:length(spindle50)
        if spindleMask
            continue;
        end
        spindleMin(k) = min(spindle50(k) - spindle25(k), ...
                              spindle75(k) - spindle50(k));
        spindleMax(k) = max(spindle50(k) - spindle25(k), ...
                              spindle75(k) - spindle50(k));
        spindleRatio(k) = spindleMin(k)/spindleMax(k);
        spindleHarmonicMean(k) = ...
            2*spindleMin(k)*spindleMax(k)./(spindleMin(k) + spindleMax(k));
    end 
    spindleRatio(isnan(spindleRatio)) = 0;
    spindleHarmonicMean(isnan(spindleHarmonicMean)) = 0;
    spindleRatio = reshape(spindleRatio, numAtoms, numThresholds);
    spindle25 = reshape(spindle25, numAtoms, numThresholds);
    spindle50 = reshape(spindle50, numAtoms, numThresholds);
    spindle75 = reshape(spindle75, numAtoms, numThresholds);
    spindleHarmonicMean = reshape(spindleHarmonicMean, numAtoms, numThresholds);
    %% Get the standard deviations and slopes
    spindleRateSTD = std(spindleRate, 0, 2);
    stdRateMax = max(spindleRateSTD(:));
    diffSTD = diff(spindleRateSTD);
    upperAtomRateInd = find(spindleRateSTD > stdRateMax*stdLimits(2), 1, 'first');
    if isempty(upperAtomRateInd)
        upperAtomRateInd = numAtoms;
    end
    lowerAtomRateInd = find(spindleRateSTD > stdRateMax*stdLimits(1), 1, 'first');
    if isempty(lowerAtomRateInd) || isempty(upperAtomRateInd) || lowerAtomRateInd >= upperAtomRateInd
        warningMsgs{end + 1} = ...
             ['Spindles/sec has non standard behavior for low ' ...
             'spindle length --- algorithm have have failed, likely because of large artifacts'];
        warning('getSpinderCurves:BadSpindleRateSTD', warningMsgs{end});
    end

    %% If the STD is not an increasing function of atoms/sec, decomposition bad
    if sum(diffSTD(upperAtomRateInd:end) < 0) > 0
        warningMsgs{end + 1} =   ['STD spindles/sec not montonic function of atoms/sec ' ...
             '--- algorithm may have failed, likely because of large artifacts'];
        warning('spindlerGetParameterCurves:SpindleSTDNotMonotonic',  warningMsgs{end});

    end
    lowerAtomRateInd = max(1, lowerAtomRateInd - 1);
    atomRateRangeInd = [lowerAtomRateInd, upperAtomRateInd];
    upperAtomRateRange = atomsPerSecond(upperAtomRateInd);
    lowerAtomRateRange = atomsPerSecond(lowerAtomRateInd);

    %% Get the standard deviations of hits
    totalMin = totalSeconds/60;
    spindleHitSTD = std(spindleHits/totalMin, 0, 2);
    upperAtomHitInd = find(spindleHitSTD > stdRateMax*stdLimits(2), 1, 'first');
    if isempty(upperAtomHitInd)
        upperAtomHitInd = numAtoms;
    end
    lowerAtomHitInd = find(spindleHitSTD > stdRateMax*stdLimits(1), 1, 'first');
    if isempty(lowerAtomHitInd) || isempty(upperAtomHitInd) || lowerAtomHitInd >= upperAtomRateInd
        warningMsgs{end + 1} = ...
             ['Spindles/sec has non standard behavior for low ' ...
             'atoms/sec --- algorithm have have failed, likely because of large artifacts'];
        warning('getSpinderCurves:BadSpindleHitSTD', warningMsgs{end});
    end
    lowerAtomHitInd = max(1, lowerAtomHitInd - 1);
    atomHitRangeInd = [lowerAtomHitInd, upperAtomHitInd];
    upperAtomHitRange = atomsPerSecond(upperAtomHitInd);
    lowerAtomHitRange = atomsPerSecond(lowerAtomHitInd);
    %% Get the ratios and scaled ratios
    xTHRatio = spindleTime./spindleHits;
    xTHRatio(isnan(xTHRatio)) = 0;
    xTHRatioMean = (xTHRatio(:, minThresholdInd) + xTHRatio(:, maxThresholdInd))/2;
    xTHRatioDiv = 1./xTHRatioMean;
    xTHRatioDiv(isnan(xTHRatioDiv)) = 0;
    xTHRatioScaled = bsxfun(@times, xTHRatio, xTHRatioDiv);
    
    %% Find the threshold whose scaled ratio is closed to the central ratio
    stdRange = atomRateRangeInd(1):atomRateRangeInd(2);
    averL1THDist = mean(abs(xTHRatioScaled(stdRange, :) - 1));
    [~, bestThresholdInd] = min(averL1THDist);
    bestThreshold = baseThresholds(bestThresholdInd);
    [~, mInd] = findFirstMin(xTHRatio(stdRange, bestThresholdInd));
    if isempty(mInd)
        [~, mInd] = min(xTHRatio(stdRange, bestThresholdInd));
    end
    bestAtomInd = mInd + lowerAtomRateInd - 1;
    bestAtomsPerSecond = atomsPerSecond(bestAtomInd);
    
    %% Find the threshold whose median is closest to the scaled ratio
    spindle50Scaled = bsxfun(@times, spindle50, xTHRatioDiv);
    averL1TH50Dist = mean(abs(spindle50Scaled(stdRange, :) - 1));
    [~, best50ThresholdInd] = min(averL1TH50Dist);
    best50Threshold = baseThresholds(best50ThresholdInd);
%     [~, mInd] = findFirstMin(spindle50(stdRange, bestThresholdInd));
%     if isempty(mInd)
%         [~, mInd] = min(xTHRatio(stdRange, bestThresholdInd));
%     end
%     bestAtomInd = mInd + lowerAtomInd - 1;
%     bestAtomsPerSecond = atomsPerSecond(bestAtomInd);

    %% Find the distance between the median and the mean spindle length
    rangeSize = length(stdRange);
    distMeanMedian = sum(abs(xTHRatio(stdRange, :) - ...
                     spindle50(stdRange, :)), 1)./rangeSize;
    meanSpindleRatio = mean(spindleRatio(stdRange, :), 1);
    meanHarmonicMean = mean(spindleHarmonicMean(stdRange, :), 1);
    
    %% Find all atom indices
    allAtomInd = zeros(1, numThresholds);
    for k = 1:numThresholds
        [~, mInd] = findFirstMin(xTHRatio(stdRange, k));
        if isempty(mInd)
            [~, mInd] = min(xTHRatio(stdRange, k));
        end
        allAtomInd(k) = mInd + lowerAtomRateInd - 1;
    end

    %% Get the Fraction of energy
    eFraction = cellfun(@double, {spindles.eFraction});
    eFraction = reshape(eFraction, numAtoms, numThresholds);
    eFractionBest = eFraction(:, bestThresholdInd);
    eFractionMax = max(eFractionBest(:));
    eFractionBest = eFractionBest./eFractionMax;
    if params.spindlerLowEnergyWarning > eFractionBest(end)
        warningMsgs{end + 1} =  ...
            'Energy curve indicates large artifacts may be present';
        warning('spindlerGetParameterCurves:SpindleSTDNotMonotonic',BadEnergy', warningMsgs{end});
    end
    %% Find the atoms/second with highest energy fraction in candidate range
    [~, eFractMaxInd] = max(eFractionBest(atomRateRangeInd(1):atomRateRangeInd(2)));
    eFractMaxInd = eFractMaxInd + lowerAtomRateInd - 1;

    %%
    sRateMean = (spindleRate(:,  minThresholdInd) + spindleRate(:, maxThresholdInd))/2;

    %% Now save the calculated spindle parameters
    spindleCurves.name = theName;
    spindleCurves.atomsPerSecond = atomsPerSecond;
    spindleCurves.bestAtomsPerSecond = bestAtomsPerSecond;
    spindleCurves.baseThresholds = baseThresholds;
    spindleCurves.bestThreshold = bestThreshold;
    spindleCurves.bestThresholdInd = bestThresholdInd;
    spindleCurves.atomRateRangeInd = atomRateRangeInd;
    spindleCurves.atomRateRange = [lowerAtomRateRange, upperAtomRateRange];
    spindleCurves.atomHitRangeInd = atomHitRangeInd;
    spindleCurves.atomHitRange = [lowerAtomHitRange, upperAtomHitRange];
    spindleCurves.eFractionBest = eFractionBest;
    spindleCurves.eFractMaxInd = eFractMaxInd;
    spindleCurves.bestAtomInd = bestAtomInd;
    spindleCurves.spindleRateSTD = spindleRateSTD;
    spindleCurves.spindleRateSTDScale = stdRateMax;
    spindleCurves.bestLinearInd = length(atomsPerSecond)*(bestThresholdInd - 1) + ...
                                         bestAtomInd;
    %% Determine whether to display the results
    if isempty(outDir)
        return;
    elseif ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    %% Show the spindle values for each dataset individually
    legendStrings = {['SL at T_b=' num2str(bestThreshold)], ...
                      'SL Centered', ...
                     ['SL at T_b=' num2str(baseThresholds(1))], ...
                     ['SL at T_b=' num2str(baseThresholds(end))]};
    baseTitle = [theName ':Average spindle length vs atoms/second'];
    theTitle = {baseTitle; ...    
           ['STD range: [' num2str(lowerAtomRateRange) ',' ...
           num2str(upperAtomRateRange) '] ' ...
           'Energy max: ' num2str(atomsPerSecond(eFractMaxInd)) ...
           ' Best index: ' num2str(atomsPerSecond(bestAtomInd)) ...
           ' Closest threshold: ' num2str(baseThresholds(bestThresholdInd)) ...
           ' Closest median: ' num2str(best50Threshold)]};
    h1Fig = figure('Name', baseTitle);
    hold on
    rates = [spindleRateSTD, spindleHitSTD];
    [ax, h1, h2] = plotyy(atomsPerSecond, xTHRatio(:, bestThresholdInd), atomsPerSecond, rates);
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0]);
    plot(ax(1), atomsPerSecond, xTHRatioMean, ...
             'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, xTHRatio(:, minThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, xTHRatio(:, maxThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
   
    set(h1, 'LineWidth', 3);
    set(h2(1), 'LineWidth', 3);
    set(h2(2), 'LineWidth', 3);
    plot(ax(1), atomsPerSecond, eFractionBest, 'LineWidth', 3, 'Color', [0.1, 0.6, 0.1]);
    allLegends = [legendStrings, 'Energy Fract'];
    legend(ax(1), allLegends, 'Location', 'NorthWest');
    xLimits = get(ax(1), 'XLim');
    line(ax(1), xLimits, [0, 0], 'Color', [0, 0, 0]);
    set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto')
    yLimits = get(ax(1), 'YLim');
     
    ePos = atomsPerSecond(bestAtomInd);
    line(ax(1), [ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);

    line(ax(1), [lowerAtomRateRange, upperAtomRateRange], [-0.1, -0.1], ...
        'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
    set(ax(1), 'YLim', [0, yLimits(2)]);
    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRateRange, upperAtomRateRange], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
    line(ax(2), [lowerAtomHitRange, upperAtomHitRange], [0.05, 0.05]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.6, 0.6, 0.6]);
    hleg2 = legend(ax(2), 'Spin len', 'Spin/Min', 'Location', 'NorthEast');
    title(hleg2, 'STD')
    ylabel(ax(1), 'Average spindle length (sec)');
    ylabel(ax(2), 'STD');
    xlabel(ax(1), 'Atoms/sec');
    xlabel(ax(2), '');
    box(ax(1), 'on')
    box(ax(2), 'on')
    hold off
    title(theTitle, 'Interpreter', 'None');
    for k = 1:length(params.figureFormats)
      thisFormat = params.figureFormats{k};
      saveas(h1Fig, [outDir filesep theName '_Params_AverageSpindleLength.' ...
          thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end

    %% Spindles/min as a function of threshold
    baseTitle = [theName ': Spindles/min vs atoms/sec as a function of threshold'];
    theTitle = {baseTitle; ...    
               ['STD range: [' num2str(lowerAtomRateRange) ',' num2str(upperAtomRateRange) '] ' ]};           
    h2Fig = figure('Name', baseTitle);
    hold on
    rates = [spindleRateSTD, spindleHitSTD];
    [ax, h1, h2] = plotyy(atomsPerSecond, spindleRate(:, bestThresholdInd), ...
                         atomsPerSecond, rates);
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0]);
    plot(ax(1), atomsPerSecond, sRateMean, ...
             'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, spindleRate(:, minThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, spindleRate(:, maxThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    hleg = legend(ax(1), ['T_b=' num2str(bestThreshold)], 'T_b centered', ...
                         'T_b=0', 'T_b=1', 'Location', 'NorthWest');
    title(hleg, 'Threshold')
    set(h1, 'LineWidth', 3);
    set(h2(1), 'LineWidth', 3);
    set(h2(2), 'LineWidth', 3);
    ylabel(ax(1), 'Spindles/min');
    ylabel(ax(2), 'STD spindles/min wrt threshold');
    set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto');
    yLimits = get(ax(1), 'YLim');
    line(ax(1), [ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);

    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRateRange, upperAtomRateRange], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
    line(ax(2), [lowerAtomHitRange, upperAtomHitRange], [0.05, 0.05]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.6, 0.6, 0.6]);
    hleg2 = legend(ax(2), 'Spin len', 'Spin/Min', 'Location', 'NorthEast');
    title(hleg2, 'STD')
    xlabel(ax(1), 'Atoms/sec');
    xlabel(ax(2), '');
    box(ax(1), 'on')
    box(ax(2), 'on')
    hold off
    title(theTitle, 'Interpreter', 'None');
    for k = 1:length(params.figureFormats)
      thisFormat = params.figureFormats{k};
      saveas(h2Fig, [outDir filesep theName '_Params_CenteredSpindleHits.' ...
          thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end
    
   %% Spindles/min as a function of threshold for all thresholds
    baseTitle = [theName ': Spindles/min vs atoms/sec all thresholds'];
    theColors = jet(numThresholds);
    theTitle = {baseTitle; ...    
               ['STD range: [' num2str(lowerAtomRateRange) ',' num2str(upperAtomRateRange) '] ' ]};           
    h2Fig = figure('Name', baseTitle);
    hold on
    [ax, h1, h2] = plotyy(atomsPerSecond, spindleRate(:, bestThresholdInd), ...
                         atomsPerSecond, spindleHitSTD);
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0]);
    for k = 1:numThresholds
        plot(ax(1), atomsPerSecond, spindleRate(:, k), 'Color', theColors(k, :));
    end
    plot(ax(1), atomsPerSecond, sRateMean, ...
             'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, spindleRate(:, minThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, spindleRate(:, maxThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    hleg = legend(ax(1), ['T_b=' num2str(bestThreshold)], 'T_b centered', ...
                         'T_b=0', 'T_b=1', 'Location', 'NorthWest');
    title(hleg, 'Threshold')
    set(h1, 'LineWidth', 3);
    set(h2, 'LineWidth', 3);
   % set(h2(2), 'LineWidth', 3);
    ylabel(ax(1), 'Spindles/min');
    ylabel(ax(2), 'STD spindles/min wrt threshold');
    set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto');
    yLimits = get(ax(1), 'YLim');
    line(ax(1), [ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);

    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRateRange, upperAtomRateRange], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
    line(ax(2), [lowerAtomHitRange, upperAtomHitRange], [0.05, 0.05]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.6, 0.6, 0.6]);
    hleg2 = legend(ax(2), 'Spin len', 'Spin/Min', 'Location', 'NorthEast');
    title(hleg2, 'STD')
    xlabel(ax(1), 'Atoms/sec');
    xlabel(ax(2), '');
    box(ax(1), 'on')
    box(ax(2), 'on')
    hold off
    title(theTitle, 'Interpreter', 'None');
    for k = 1:length(params.figureFormats)
      thisFormat = params.figureFormats{k};
      saveas(h2Fig, [outDir filesep theName '_Params_CenteredSpindleHits.' ...
          thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

    %% Plot the threshold
    bestRatios = zeros(size(baseThresholds));
    for k = 1:numThresholds 
        tPos = atomsPerSecond(allAtomInd(k));
        bestRatios(k) = spindleRatio(allAtomInd(k), k);
        thisTitle = [theName ' threshold ' num2str(k) ' of ' num2str(baseThresholds(k)) ...
            ': ratio ' num2str(spindleRatio(allAtomInd(k), k)) ' at ' num2str(tPos) ' atoms/sec'];
        h3Fig = figure('Name', thisTitle);
        hold on
        plot(atomsPerSecond, spindle25(:, k), 'Color', [0.7, 0.7, 0.7], ...
            'LineWidth', 2, 'LineStyle', '-.')
        plot(atomsPerSecond, spindle50(:, k), 'Color', [0.7, 0.7, 0.7], ...
            'LineWidth', 2);
        plot(atomsPerSecond, spindle75(:, k), 'Color', [0.7, 0.7, 0.7], ...
            'LineWidth', 2, 'LineStyle', '--');
        plot(atomsPerSecond, xTHRatioMean, 'Color', [0, 0.1, 0.8], ...
            'LineWidth', 2);
        plot(atomsPerSecond, xTHRatio(:, k), 'Color', [0.0, 0.0, 0.0], ...
            'LineWidth', 3);
        plot(atomsPerSecond, xTHRatio(:, bestThresholdInd), 'Color', ...
                      [0.0, 0.7, 0.1], 'LineWidth', 2, 'LineStyle', '--');
        plot(atomsPerSecond, spindleRatio(:, k), 'Color', 'r', 'LineWidth', 2)
        set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto');
        plot(atomsPerSecond, spindleHarmonicMean(:, k), 'Color', 'r', ...
            'LineStyle', '--', 'LineWidth', 2);
        plot(atomsPerSecond, abs(xTHRatioMean - spindle50(:, k)), ...
             'Color', [0, 0.8, 0.8], 'LineWidth', 2);
        yLimits = get(gca, 'YLim');
        yLimits(1) = 0;
        set(gca, 'YLim', yLimits);
        line(gca, [ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);
        line(gca, [lowerAtomRateRange, lowerAtomRateRange], yLimits, ...
            'LineWidth', 1, 'Color', [0.8, 0.8, 0.8], 'LineStyle', '--');
        line(gca, [upperAtomRateRange, upperAtomRateRange], yLimits, ...
            'LineWidth', 1, 'Color', [0.8, 0.8, 0.8], 'LineStyle', '--');

        line(gca, [tPos, tPos], yLimits, 'Color', [0.8, 0, 0]);
        hold off
        legend('25%', '50%', '75%', 'Mean', 'This', 'Best', 'Ratio', ...
            'HMean', 'MedianDist', 'Location', 'EastOutside')
        xlabel('Atoms per second')
        ylabel('Spindle length(s)');
        title(thisTitle);
        box on
        for f = 1:length(params.figureFormats)
           thisFormat = params.figureFormats{f};
           saveas(h3Fig, [outDir filesep theName '_SpindleLengthDist_Threshold_' ...
                   convertNumberPt(baseThresholds(k), 'p') '.' thisFormat], thisFormat);
        end
        if params.figureClose
            close(h3Fig);
        end
    end

    %% Now plot the spindle curve
    [~, harmonicInd] = max(meanHarmonicMean(:)); 
    baseTitle = [theName ': Percentile ratios/dists (max mean harm '];
    theTitle = {baseTitle; ...
                [num2str(baseThresholds(harmonicInd)) ')' ...
                ' Best index: ' num2str(atomsPerSecond(bestAtomInd)) ...
                ' Closest threshold: ' num2str(baseThresholds(bestThresholdInd)) ...
               ' Closest median: ' num2str(best50Threshold)]};
    h4Fig = figure('Name', baseTitle);
    dists = [distMeanMedian(:), meanHarmonicMean(:)];
    [ax, h1, h2] = plotyy(baseThresholds(:), bestRatios(:), ...
                          baseThresholds(:), dists);
    hold on
    h4 = plot(ax(1), baseThresholds, meanSpindleRatio);
    set(h4, 'LineWidth', 2', 'Color', [0, 0.6, 0]);

    set(h1, 'LineWidth', 2);
    set(h2(1), 'LineWidth', 2);
    set(h2(2), 'LineWidth', 2', 'LineStyle', '--');
    xlabel(ax(1), 'Threshold')
    ylabel(ax(1), 'Ratio of lengths at best')
    ylabel(ax(2), 'Dist between mean and median')
    lh1 = legend(ax(1), 'best', 'mean', 'Location', 'NorthWest');
    title(lh1, 'Ratio')
    lh2 = legend(ax(2), 'medians', 'harmonic', 'Location', 'NorthEast');
    title(lh2, 'Dist')
    hold off
    box on
    title(theTitle, 'Interpreter', 'None')
    for f = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{f};
        saveas(h4Fig, [outDir filesep theName '_SpindleLengthDistRatio.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h4Fig);
    end
    
%%
  %% Now plot the spindle ratio image
    atomsNoSTDMask = true(length(atomsPerSecond), 1);
    atomsNoSTDMask(stdRange) = false;
    baseTitle = [theName ': Making sure mean is below 75%'];
    theTitle = {baseTitle; ...
                [' Best index: ' num2str(atomsPerSecond(bestAtomInd)) ...
                ' Closest threshold: ' num2str(baseThresholds(bestThresholdInd)) ...
                ' Closest median: ' num2str(best50Threshold)]};
    h5Fig = figure('Name', baseTitle);
    xMask = spindle50 < xTHRatio & xTHRatio < spindle75;
    xMask(atomsNoSTDMask, :) = 0;
   
    imagesc(xMask)
    axis xy
    xlabel('Threshold number');
    ylabel('Atoms/second number')
    title(theTitle, 'Interpreter', 'None')
    for f = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{f};
        saveas(h5Fig, [outDir filesep theName '_SpindleRatioImage.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h5Fig);
    end
 
   %% Now plot the spindle ratio image
    atomsNoSTDMask = true(length(atomsPerSecond), 1);
    atomsNoSTDMask(stdRange) = false;
    baseTitle = [theName ': Spindle ratio'];
    theTitle = {baseTitle; ...
                [' Best index: ' num2str(atomsPerSecond(bestAtomInd)) ...
                ' Closest threshold: ' num2str(baseThresholds(bestThresholdInd)) ...
                ' Closest median: ' num2str(best50Threshold)]};
    h5Fig = figure('Name', baseTitle);
    sRatio = spindleRatio;
    sRatio(sRatio < 0.05) = 0;
    sRatio(atomsNoSTDMask, :) = 0;
    imagesc(sRatio')
    axis xy
    ylabel('Threshold number');
    xlabel('Atoms/second number')
    title(theTitle, 'Interpreter', 'None')
    for f = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{f};
        saveas(h5Fig, [outDir filesep theName '_SpindleRatioImage.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h5Fig);
    end
 
   %% Now plot the spindle harmonic mean image
    theTitle = [theName ': Spindle harmonic mean'];
    h6Fig = figure('Name', theTitle);
    sHarmonic = spindleHarmonicMean;
    sHarmonic(sHarmonic < 0.05) = 0;
    sHarmonic(atomsNoSTDMask, :) = 0;
    imagesc(sHarmonic')
    ylabel('Threshold number');
    xlabel('Atoms/second number')
    title(theTitle, 'Interpreter', 'None')
    axis xy
    for f = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{f};
        saveas(h6Fig, [outDir filesep theName '_SpindleHarmonic.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h6Fig);
    end

       %% Now plot the spindle ratio image
       xProduct = sRatio .* sHarmonic.*xMask;
    [~, maxProdInd] = max(xProduct(:));
    atomInd = rem(maxProdInd, numAtoms);
    threshInd = (maxProdInd - atomInd)/numAtoms + 1;
    baseTitle = [theName ': Spindle ratio * spindle harmonic mean'];
    theTitle = {baseTitle; ...
                [' Best index: ' num2str(atomsPerSecond(bestAtomInd)) ...
                ' Closest threshold: ' num2str(baseThresholds(bestThresholdInd)) ...
                ' Closest median: ' num2str(best50Threshold)];
                ['Max atoms: ' num2str(atomsPerSecond(atomInd)) ...
                 ' Max thresh: ' num2str(baseThresholds(threshInd))]};
    h7Fig = figure('Name', baseTitle);
    
    imagesc(xProduct');
    axis xy
    ylabel('Threshold number');
    xlabel('Atoms/second number')
    title(theTitle, 'Interpreter', 'None')
    for f = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{f};
        saveas(h7Fig, [outDir filesep theName '_SpindleRatioHarmonicMeanImage.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h7Fig);
    end
    
    %% Now plot the spindle curve
    theTitle = [theName ': harmonic mean vs ratio'];
    h8Fig = figure('Name', theTitle);
    hColors = jet(numThresholds);
    hold on
    for k = 1:numThresholds
       plot(spindleRatio(:, k), spindleHarmonicMean(:, k), 'LineWidth', 2, ...
          'LineStyle', 'None', 'Color', hColors(k, :), 'Marker', 's', ...
          'MarkerSize', 8);
      [~, maxIndH] = max(spindleHarmonicMean(stdRange, k));
      plot(spindleRatio(maxIndH, k), spindleHarmonicMean(maxIndH, k), 'LineWidth', 2, ...
          'LineStyle', 'None', 'Color', [0, 0, 0], 'Marker', 'o', ...
          'MarkerSize', 12);
      [~, maxIndR] = max(spindleRatio(stdRange, k));
      plot(spindleRatio(maxIndR, k), spindleHarmonicMean(maxIndR, k), 'LineWidth', 2, ...
          'LineStyle', 'None', 'Color', [0, 0, 0], 'Marker', 'd', ...
          'MarkerSize', 12);
    end
    hold off
    xlabel('Spindle ratio')
    ylabel('Spindle max/min harmonic mean')
    box on
    title(theTitle)
    for f = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{f};
        saveas(h8Fig, [outDir filesep theName '_SpindleRatioVSHarmonicMean.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h8Fig);
    end
end

function sT = convertNumberPt(value, replaceChar)
     sT = num2str(value);
     sT = strrep(sT, '.', replaceChar);
end     