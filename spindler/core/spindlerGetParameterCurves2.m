function [spindleCurves, warningMsgs] = spindlerGetParameterCurves2(spindles, outDir, params)
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
    spindleCurves = struct('name', NaN,  'atomsPerSecond', NaN, ...
                  'baseThresholds', NaN, ...
                  'bestEligibleAtomsPerSecond', NaN', ...
                  'bestEligibleAtomInd', NaN, ...
                 'bestEligibleLinearInd', NaN, ...
                  'bestEligibleThreshold', NaN, ...
                  'bestEligibleThresholdInd', NaN, ...
                  'atomRateRange', NaN, 'atomRateRangeInd', NaN, ...
                  'spindleRateSTD', NaN);
    
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
    %stdLimits = params.spindlerSTDLimits;
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
    spindleRateSTD(isnan(spindleRateSTD)) = 0;
    stdRateMax = max(spindleRateSTD(:));
    diffSTD = diff(spindleRateSTD);
    diffTopThreshold = diff(spindleRate(:, end));
    upperAtomRateInd = find(diffTopThreshold <= 0, 1, 'first');
    if isempty(upperAtomRateInd)
        upperAtomRateInd = numAtoms;
    end
    %lowerAtomRateInd = find(spindleRateSTD > stdRateMax*stdLimits(1), 1, 'first');
    lowerAtomRateInd = find(spindleRateSTD > 0, 1, 'first');
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

    %% Get the ratios and scaled ratios
    meanSpindleLen = spindleTime./spindleHits;
    meanSpindleLen(isnan(meanSpindleLen)) = 0;
    meanSpindleLenCentral = (meanSpindleLen(:, minThresholdInd) + meanSpindleLen(:, maxThresholdInd))/2;
    meanSpindleLenDiv = 1./meanSpindleLenCentral;
    meanSpindleLenDiv(isnan(meanSpindleLenDiv)) = 0;
    meanSpindleLenScaled = bsxfun(@times, meanSpindleLen, meanSpindleLenDiv);
    
    %% Find the threshold whose scaled ratio is closed to the central ratio
    stdRange = atomRateRangeInd(1):atomRateRangeInd(2);
    atomsNoSTDMask = true(length(atomsPerSecond), 1);
    atomsNoSTDMask(stdRange) = false;
    meanSpindleLenMask = spindle50 < meanSpindleLen & meanSpindleLen < spindle75 & ...
                   spindle25 < spindle50 & spindle50 < spindle75;
    %xTHRatioMask = xTHRatioMask & bsxfun(@le, xTHRatioMean, spindle75);
    meanSpindleLenMask = meanSpindleLenMask & spindleRatio > 0.1;
    maskCounts = sum(meanSpindleLenMask(stdRange, :), 1); 
    eligibleThresholdInds = find(maskCounts > 0.5*length(stdRange));
    if isempty(eligibleThresholdInds)
        warning('Not enough thresholds have good distribution, taking best');
        eligibleThresholdInds = find(maskCounts == max(maskCounts));
    end
    mPercent = 100*length(eligibleThresholdInds)/numThresholds;
    eligibleTString = ['Eligible(' num2str(mPercent) '%):'];
    for k = 1:length(eligibleThresholdInds)
        eligibleTString = [eligibleTString ' ' ...
                          num2str(eligibleThresholdInds(k))];%#ok<AGROW>
    end
    
    %% Find first minimum in the average spindle length for all thresholds
    allAtomInd = zeros(1, numThresholds);
    for k = 1:numThresholds
        [~, mInd] = findFirstMin(meanSpindleLen(stdRange, k));
        if isempty(mInd)
            [~, mInd] = min(meanSpindleLen(stdRange, k));
        end
        allAtomInd(k) = mInd + lowerAtomRateInd - 1;
    end
    
    %% Find the one with average spindle length closest to central
    averL1THDist = mean(abs(meanSpindleLenScaled(stdRange, :) - 1));
    [~, bestThresholdInd] = min(averL1THDist);
    bestAtomInd =allAtomInd(bestThresholdInd);
    bestAtomsPerSecond = atomsPerSecond(bestAtomInd);
    bestThreshold = baseThresholds(bestThresholdInd);
    %% Also find the eligible threshold closest to the mean

    
    %% Calculate the eligible atoms/sec for all thresholds
    selfMeanMedianAbsDist = abs(meanSpindleLen - spindle50);
    medMeanDistAtBest = median(selfMeanMedianAbsDist(stdRange, :));
    allEligibleAtomInd =  zeros(1, numThresholds);
    for k = 1:numThresholds
        ratioCurve = spindleRatio(stdRange, k);
        ratioMask = ratioCurve > 0.1;
        ratioInd = find(ratioMask == 0, 1, 'last');
        if isempty(ratioInd)
            ratioInd = 1;
        end
        ratioCurve = ratioCurve(ratioInd:end);
        [~, mInd] = findFirstMax(ratioCurve);
        if isempty(mInd)
            [~, mInd] = max(ratioCurve);
        end
        allEligibleAtomInd(k) =  mInd + lowerAtomRateInd + ratioInd - 2;
    
    end
    minDist = min(medMeanDistAtBest(eligibleThresholdInds));
    bestPos = find(medMeanDistAtBest(eligibleThresholdInds) == minDist);
    if length(bestPos) > 1
        nowEligible = eligibleThresholdInds(bestPos);  
        averDistBestThresholds = averL1THDist(nowEligible);
        [~, bInd] = min(averDistBestThresholds);
        bestEligibleThresholdInd = nowEligible(bInd);
    else
        bestEligibleThresholdInd = eligibleThresholdInds(bestPos(1));
    end
    bestEligibleThreshold = baseThresholds(bestEligibleThresholdInd);
    if isempty(bestEligibleThresholdInd)
        warning('Having trouble finding an eligible threshold with good properties');
        bestEligibleThresholdInd = bestThresholdInd;
        bestEligibleThreshold = bestThreshold;
    end
    bestEligibleAtomInd =  allEligibleAtomInd(bestEligibleThresholdInd);
    bestEligibleAtomsPerSecond = atomsPerSecond(bestEligibleAtomInd);
    
    %% Find the threshold whose median is closest to the scaled ratio
    spindle50Scaled = bsxfun(@times, spindle50, meanSpindleLenDiv);
    averL1TH50Dist = mean(abs(spindle50Scaled(stdRange, :) - 1));
    [~, best50ThresholdInd] = min(averL1TH50Dist);
    best50Threshold = baseThresholds(best50ThresholdInd);

    %% Find the distance between the median and the mean spindle length
    rangeSize = length(stdRange);
    distMeanMedian = sum(abs(meanSpindleLen(stdRange, :) - ...
                     spindle50(stdRange, :)), 1)./rangeSize;
    meanSpindleRatio = mean(spindleRatio(stdRange, :), 1);
    meanHarmonicMean = mean(spindleHarmonicMean(stdRange, :), 1);

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
%     %% Find the atoms/second with highest energy fraction in candidate range
%     [~, eFractMaxInd] = max(eFractionBest(atomRateRangeInd(1):atomRateRangeInd(2)));
%     eFractMaxInd = eFractMaxInd + lowerAtomRateInd - 1;

    %%
    sRateMean = (spindleRate(:,  minThresholdInd) + spindleRate(:, maxThresholdInd))/2;

    %% Now save the calculated spindle parameters
    spindleCurves.name = theName;
    spindleCurves.atomsPerSecond = atomsPerSecond;
    spindleCurves.baseThresholds = baseThresholds;
    spindleCurves.bestEligibleAtomsPerSecond = bestEligibleAtomsPerSecond;
    spindleCurves.bestEligibleAtomInd = bestEligibleAtomInd;
    spindleCurves.bestEligibleLinearInd = length(atomsPerSecond)*(bestEligibleThresholdInd - 1) + ...
        bestEligibleAtomInd;
    spindleCurves.bestEligibleThreshold = bestEligibleThreshold;
    spindleCurves.bestEligibleThresholdInd = bestEligibleThresholdInd;
    spindleCurves.atomRateRangeInd = atomRateRangeInd;
    spindleCurves.atomRateRange = [lowerAtomRateRange, upperAtomRateRange];
    spindleCurves.spindleRateSTD = spindleRateSTD;

    %% Determine whether to display the results
    if isempty(outDir)
        return;
    elseif ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    %% Show the spindle length summary values
    eligiblePos = atomsPerSecond(bestEligibleAtomInd);
    theColors = jet(numThresholds);
    legendStrings = {['T_b=' num2str(bestEligibleThreshold)], ...
                      'T_b centered', ...
                     ['T_b=' num2str(baseThresholds(1))], ...
                     ['T_b=' num2str(baseThresholds(end))],'N_s best'};
    baseTitle = [theName ':Average spindle length vs atoms/second'];
    theTitle = {baseTitle; ...    
           ['STD range: [' num2str(lowerAtomRateRange) ',' ...
           num2str(upperAtomRateRange) '] ' ...
           ' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
           ' Best threshold: ' ...
           num2str(baseThresholds(bestEligibleThresholdInd))]};
    h1Fig = figure('Name', baseTitle);
    hold on
    [ax, h1, h2] = plotyy(atomsPerSecond, meanSpindleLen(:, bestEligibleThresholdInd), ...
                          atomsPerSecond, spindleRateSTD);
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
    plot(ax(1), atomsPerSecond, meanSpindleLenCentral, ...
             'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, minThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, maxThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
  
    yLimitsTemp = [meanSpindleLen(:, maxThresholdInd), meanSpindleLen(:, minThresholdInd)];
    hLine = line(ax(1), [eligiblePos, eligiblePos], yLimitsTemp, ...
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);
    for k = 1:numThresholds
        plot(ax(1), atomsPerSecond, meanSpindleLen(:, k), 'Color', theColors(k, :));
    end
        plot(ax(1), atomsPerSecond, meanSpindleLenCentral, ...
             'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, minThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, maxThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, bestEligibleThresholdInd),...
        'LineWidth', 3, 'Color', [0, 0, 0]);
    set(h2, 'LineWidth', 3);
    set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto')
    yLimits = get(ax(1), 'YLim');
    set(hLine, 'YData', [0, yLimits(2)])
    set(ax(1), 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRateRange, upperAtomRateRange], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    hleg1 = legend(ax(1), legendStrings, 'Location', 'SouthEast');
    title(hleg1, 'Parameters');
    hleg2 = legend(ax(2), 'STD', 'STD range', 'Location', 'NorthEast');
    title(hleg2, 'Spindles/min')
    ylabel(ax(1), 'Average spindle length (sec)');
    ylabel(ax(2), 'STD spindles/min');
    xlabel(ax(1), 'Atoms/sec');
    xlabel(ax(2), '');
    box(ax(1), 'on')
    box(ax(2), 'on')
    hold off
    title(theTitle, 'Interpreter', 'None');
    for k = 1:length(params.figureFormats)
      thisFormat = params.figureFormats{k};
      saveas(h1Fig, [outDir filesep theName '_AverageSpindleLength.' ...
          thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end

    %% Spindles/min as a function of threshold
    theColors = jet(numThresholds);
    baseTitle = [theName ': Spindles/min vs atoms/sec as a function of threshold'];
    theTitle = {baseTitle; ...    
               ['STD range: [' num2str(lowerAtomRateRange) ',' num2str(upperAtomRateRange) '] ' ]};           
    h2Fig = figure('Name', baseTitle);
    hold on
    [ax, h1, h2] = plotyy(atomsPerSecond, spindleRate(:, bestEligibleThresholdInd), ...
                         atomsPerSecond, spindleRateSTD);
    set(h2, 'LineWidth', 3);
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
    plot(ax(1), atomsPerSecond, sRateMean, ...
             'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, spindleRate(:, minThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, spindleRate(:, maxThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    hLine = line(ax(1), [eligiblePos, eligiblePos], ...
           [0, spindleRate(3, minThresholdInd)], ...
           'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);
    for k = 1:numThresholds
        plot(ax(1), atomsPerSecond, spindleRate(:, k), 'Color', theColors(k, :));
    end
    plot(ax(1), atomsPerSecond, sRateMean, ...
             'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, spindleRate(:, minThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, spindleRate(:, maxThresholdInd), ...
             'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    plot(atomsPerSecond, spindleRate(:, bestEligibleThresholdInd), ...
      'LineWidth', 3, 'Color', [0, 0, 0]);
    ylabel(ax(1), 'Spindles/min');
    ylabel(ax(2), 'STD spindles/min wrt threshold');
    set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto');
    
    %line(ax(1), [ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);
    yLimits = get(ax(1), 'YLim');
    set(hLine, 'YData', [0, yLimits(2)])
    set(ax(1), 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRateRange, upperAtomRateRange], [0.05, 0.05]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    hleg1 = legend(ax(1), ['T_b=' num2str(bestEligibleThreshold)], 'T_b centered', ...
            'T_b=0', 'T_b=1', 'N_s best', 'Location', 'NorthWest');
    title(hleg1, 'Parameters')
    hleg2 = legend(ax(2), 'STD', 'STD range', 'Location', 'NorthEast');
    title(hleg2, 'Spindles/min')
    xlabel(ax(1), 'Atoms/sec');
    xlabel(ax(2), '');
    box(ax(1), 'on')
    box(ax(2), 'on')
    hold off
    title(theTitle, 'Interpreter', 'None');
    for k = 1:length(params.figureFormats)
      thisFormat = params.figureFormats{k};
      saveas(h2Fig, [outDir filesep theName '_AverageSpindlePerMin.' ...
          thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end
    
    %% Plot the threshold
    bestRatios = zeros(size(baseThresholds));
    for k = 1:numThresholds 
        %thisPos = atomsPerSecond(allAtomInd(k));
        thisPos = atomsPerSecond(allEligibleAtomInd(k));
        bestRatios(k) = spindleRatio(allAtomInd(k), k);
        baseTitle = [theName ': mean spindle length distribution for T_b = ' ...
                     num2str(baseThresholds(k))];
        thisTitle = {baseTitle; ...
            ['Best atoms/sec is ' num2str(thisPos) ...
            ' ratio=' num2str(spindleRatio(allEligibleAtomInd(k), k)) ...
            ' harmonic mean='  ...
            num2str(spindleHarmonicMean(allEligibleAtomInd(k), k))]};
        h3Fig = figure('Name', baseTitle);
        hold on
        plot(atomsPerSecond, spindle25(:, k), 'Color', [0.6, 0.6, 0.6], ...
            'LineWidth', 2, 'LineStyle', '-.')
        plot(atomsPerSecond, spindle50(:, k), 'Color', [0.6, 0.6, 0.6], ...
            'LineWidth', 2);
        plot(atomsPerSecond, spindle75(:, k), 'Color', [0.6, 0.6, 0.6], ...
            'LineWidth', 2, 'LineStyle', '--');
        plot(atomsPerSecond, meanSpindleLenCentral, 'Color', [0, 0.4470, 0.7410], ...
            'LineWidth', 3);
        plot(atomsPerSecond, meanSpindleLen(:, k), 'Color', [0.0, 0.0, 0.0], ...
            'LineWidth', 3);
        line([lowerAtomRateRange, upperAtomRateRange], [0.2, 0.2], ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
        plot(atomsPerSecond, spindleRatio(:, k), 'Color', [0, 0.7, 0.7], 'LineWidth', 2)
        
        plot(atomsPerSecond, spindleHarmonicMean(:, k), 'Color', [0.0, 0.7, 0.7], ...
            'LineStyle', '--', 'LineWidth', 2);
        plot(atomsPerSecond, selfMeanMedianAbsDist(:, k), ...
             'Color', [0.3, 0.8, 0.8], 'LineWidth', 2);     
        set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto');
        yLimits = get(gca, 'YLim');
        yLimits(1) = 0;
        set(gca, 'YLim', yLimits, 'YLimMode', 'manual');
        line(gca, [eligiblePos, eligiblePos], yLimits, 'Color', ...
            [0.8, 0.8, 0.3], 'LineWidth', 2);
        line(gca, [thisPos, thisPos], yLimits, ...
            'Color', [0.6, 0, 0], 'LineStyle', ':', 'LineWidth', 2);

        hold off
        hleg1 = legend('25 PCTL', '50 PCTL', '75 PCTL', 'Central', ...
            'Mean spindle length', 'STD rate range', 'Max/min ratio', ...
            'Harmonic mean', 'Distance to median', 'N_s best', 'N_s this', 'Location', 'EastOutside');
        title(hleg1, 'Spindle length stats')
        xlabel('Atoms per second')
        ylabel('Spindle length(s)');
        if sum(eligibleThresholdInds == k) > 0 
            titleColor = [0.7, 0.0, 0.0];
        else
            titleColor = [0, 0, 0];
        end
        title(thisTitle, 'Interpreter', 'None', 'Color', titleColor);
        box on
        for f = 1:length(params.figureFormats)
           thisFormat = params.figureFormats{f};
           saveas(h3Fig, [outDir filesep theName '_LengthDist_Threshold_' ...
                   convertNumber(baseThresholds(k), '_') '.' thisFormat], thisFormat);
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
    
  %% Now plot the spindle ratio image
    baseTitle = [theName ': Making sure mean is below 75%'];
    theTitle = {baseTitle; ...
                [' Best index: ' num2str(atomsPerSecond(bestAtomInd)) ...
                ' Closest threshold: ' num2str(baseThresholds(bestThresholdInd)) ...
                ' Closest median: ' num2str(best50Threshold)]};
    h5Fig = figure('Name', baseTitle);
    imagesc(meanSpindleLenMask')
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

 %% Now plot the spindle ratio image
    baseTitle = [theName ': Eligible threshold-atoms/sec combinations'];
    h5Fig = figure('Name', baseTitle);
    zMask = meanSpindleLenMask;
    zMask(atomsNoSTDMask, :) = 0;
    badMask = true(1, numThresholds);
    badMask(eligibleThresholdInds) = false;
    zMask(:, badMask) = 0;
    imagesc(zMask')
    axis xy
    ylabel('Threshold number');
    xlabel('Atoms/second number')
    theTitle = {baseTitle; eligibleTString};
    title(theTitle, 'Interpreter', 'None')
    for f = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{f};
        saveas(h5Fig, [outDir filesep theName '_SpindleCombinationsImage.' ...
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
                [' Best: ' num2str(atomsPerSecond(bestAtomInd)) ...
                 ' Best eligible: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
                ' Closest mean: ' num2str(baseThresholds(bestThresholdInd)) ...
                ' Closest median: ' num2str(best50Threshold)]};
    h5Fig = figure('Name', baseTitle);
    sRatio = spindleRatio;
    sRatio(sRatio < 0.05) = 0;
    sRatio(atomsNoSTDMask, :) = 0;
    imagesc(sRatio')
    axis xy
    colorbar 
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
    colorbar
    for f = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{f};
        saveas(h6Fig, [outDir filesep theName '_SpindleHarmonic.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h6Fig);
    end

       %% Now plot the spindle ratio image
       xProduct = sRatio .* sHarmonic.*meanSpindleLenMask;
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
    colorbar
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
    line([0, 1], [0, 1])
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

function sT = convertNumber(value, replaceChar)
     sT = sprintf('%08.6f', value);
     sT = strrep(sT, '.', replaceChar);
end     