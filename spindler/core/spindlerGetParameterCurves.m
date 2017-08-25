function [spindleCurves, warningMsgs] = spindlerGetParameterCurves(spindles, outDir, params)
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
    earlyMatlabVersion = verLessThan('matlab', '9.0');
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
    diffSTD = diff(spindleRateSTD);
    diffTopThreshold = diff(spindleRate(:, end));
    upperAtomRateInd = find(diffTopThreshold <= 0, 1, 'first');
    if isempty(upperAtomRateInd)
        upperAtomRateInd = numAtoms;
    end
    lowerAtomRateInd = find(spindleRateSTD > 0, 1, 'first');
    if isempty(lowerAtomRateInd) || isempty(upperAtomRateInd) || lowerAtomRateInd >= upperAtomRateInd
        warningMsgs{end + 1} = ...
            ['Spindles/sec has non standard behavior for low ' ...
            'spindle length --- algorithm failed, likely because of large artifacts'];
        warning('getSpinderCurves:BadSpindleRateSTD', warningMsgs{end});
        return;
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
    meanSpindleLenMask = meanSpindleLenMask & ...
        spindleRatio > params.spindlerLowMinMaxPercentileRatio;
    maskCounts = sum(meanSpindleLenMask(stdRange, :), 1);
    eligibleThresholdInds = find(maskCounts > ...
        params.spindlerLowEligibleCount*length(stdRange) & ...
        baseThresholds ~= 0 & baseThresholds ~= 1);
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
    bestThreshold = baseThresholds(bestThresholdInd);

    %% Calculate the eligible atoms/sec for all thresholds

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
    allEligibleAtomsPerSecond = atomsPerSecond(allEligibleAtomInd);

    %% Now look for a stable threshold value
    selfMeanMedianAbsDist = abs(meanSpindleLen - spindle50);
    bestMedianMeanDist = median(selfMeanMedianAbsDist(stdRange, :), 1);
    bestNeighborDist = ones(1, numThresholds);
    bestPctlRatio = zeros(1, numThresholds);
    bestPctlHarmonicMean = zeros(1, numThresholds);
    for k = 2:numThresholds - 1
        bestNeighborDist(k) = min( ...
            abs(allEligibleAtomsPerSecond(k) - allEligibleAtomsPerSecond(k - 1)), ...
            abs(allEligibleAtomsPerSecond(k) - allEligibleAtomsPerSecond(k + 1)));
        bestPctlRatio(k) = spindleRatio(allEligibleAtomInd(k), k);
        bestPctlHarmonicMean(k) = spindleHarmonicMean(allEligibleAtomInd(k), k);
    end

    %% Now test the eligible thresholds
    if isempty(eligibleThresholdInds)
        warning('spindleGetParameterCurves:badThresholds', ...
            [theName ' does not have thresholds with stable properties']);
        bestEligibleThresholdInd = bestThresholdInd;
        bestEligibleThreshold = bestThreshold;
    else
        bestEligiblePctlRatio = bestPctlRatio(eligibleThresholdInds);
        bestEligiblePctlHarmonicMean = bestPctlHarmonicMean(eligibleThresholdInds);
        bestEligibleNeighborDist = bestNeighborDist(eligibleThresholdInds);
        bestEligibleMedianMeanDist = bestMedianMeanDist(eligibleThresholdInds);

        %% Narrow down the values
        maxPctlRatio = max(bestEligiblePctlRatio);
        maxNeighborDist = max(bestEligibleNeighborDist);
        maxPctlHarmonicMean = max(bestEligiblePctlHarmonicMean);

        threshFactor = 0.5;
        testMask = bestEligiblePctlRatio > threshFactor*maxPctlRatio & ...
            bestEligibleNeighborDist < threshFactor*maxNeighborDist & ...
            bestEligiblePctlHarmonicMean > threshFactor*maxPctlHarmonicMean;
        bestPositions = eligibleThresholdInds(testMask);
        if isempty( bestPositions)
            [~,  minInd] = min(bestEligibleMedianMeanDist);
            bestEligibleThresholdInd = eligibleThresholdInds(minInd);
        else
            [~, minInd] = min(bestMedianMeanDist(bestPositions));
            bestEligibleThresholdInd = bestPositions(minInd);
        end
        bestEligibleThreshold = baseThresholds(bestEligibleThresholdInd);
    end

    %% Plot the eligible curves
    if strcmpi(params.figureLevels, 'all')
        baseTitle = [theName ' eligible curves'];
        theTitle = {'Eligible curves'; theName};
        figEligible = figure('Name', baseTitle);
        hold on
        plot(bestPctlRatio, 'k', 'LineWidth', 2)
        plot(bestPctlHarmonicMean, 'r', 'LineWidth', 2)
        plot(bestEligibleNeighborDist, 'b', 'LineWidth', 2)
        plot(bestEligibleMedianMeanDist, 'g', 'LineWidth', 2)
        if ~isempty(eligibleThresholdInds)
            plot(eligibleThresholdInds, bestEligiblePctlRatio, 'ok', ...
                'LineWidth', 2, 'MarkerSize', 10, 'LineStyle', 'None')
            plot(eligibleThresholdInds,bestEligiblePctlHarmonicMean, 'or', ...
                'LineWidth', 2, 'MarkerSize', 10, 'LineStyle', 'None')
            plot(eligibleThresholdInds,bestEligibleNeighborDist, 'sb', ...
                'LineWidth', 2, 'MarkerSize', 10, 'LineStyle', 'None')
            plot(eligibleThresholdInds,bestEligibleMedianMeanDist, 'sg', ...
                'LineWidth', 2, 'MarkerSize', 10, 'LineStyle', 'None')
        end
        set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto')
        yLimits = get(gca, 'YLim');
        ylabel('Best values');
        set(gca, 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
        line([bestEligibleThresholdInd, bestEligibleThresholdInd], ...
            [0, yLimits(2)], 'Color', [0.8, 0.8, 0.8]);

        hold off
        box on
        legend('Pctl ratio', 'Pctl Harm M', 'Neigdist', 'MedianMean')
        xlabel('Atom index')
        title(theTitle, 'Interpreter', 'None')
        for k = 1:length(params.figureFormats)
            thisFormat = params.figureFormats{k};
            saveas(figEligible, [outDir filesep theName '_EligibleCurves.' ...
                thisFormat], thisFormat);
        end
        if params.figureClose
            close(figEligible);
        end
    end
    bestEligibleAtomInd =  allEligibleAtomInd(bestEligibleThresholdInd);
    bestEligibleAtomsPerSecond = atomsPerSecond(bestEligibleAtomInd);


    %% Find the distance between the median and the mean spindle length
    rangeSize = length(stdRange);
    distMeanMedian = sum(abs(meanSpindleLen(stdRange, :) - ...
        spindle50(stdRange, :)), 1)./rangeSize;
    meanSpindleRatio = mean(spindleRatio(stdRange, :), 1);
    meanHarmonicMean = mean(spindleHarmonicMean(stdRange, :), 1);
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
    theTitle = {'Average spindle length vs atoms/second'; theName; ...
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
    hLine = line(ax(1), [eligiblePos, eligiblePos], yLimitsTemp, ... ###
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
    set(hLine, 'YData', [0, yLimits(2)]) %####
    set(ax(1), 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRateRange, upperAtomRateRange], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    hleg1 = legend(ax(1), legendStrings, 'Location', 'SouthEast');
    hleg2 = legend(ax(2), 'STD', 'STD range', 'Location', 'NorthEast');
    if ~earlyMatlabVersion
        title(hleg1, 'Parameters');
        title(hleg2, 'Spindles/min')
    end

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
    baseTitle = ['Spindles/min vs atoms/sec as a function of threshold:' theName];
    theTitle = {'Spindles/min vs atoms/sec as a function of threshold'; theName; ...
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
    hLine = line(ax(1), [eligiblePos, eligiblePos], ... ####
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

    yLimits = get(ax(1), 'YLim');
    set(hLine, 'YData', [0, yLimits(2)])  %####
    set(ax(1), 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRateRange, upperAtomRateRange], [0.05, 0.05]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    hleg1 = legend(ax(1), ['T_b=' num2str(bestEligibleThreshold)], 'T_b centered', ...
        'T_b=0', 'T_b=1', 'N_s best', 'Location', 'NorthWest');
    hleg2 = legend(ax(2), 'STD', 'STD range', 'Location', 'NorthEast');
    if ~earlyMatlabVersion
        title(hleg1, 'Parameters')
        title(hleg2, 'Spindles/min')
    end
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
        thisPos = atomsPerSecond(allEligibleAtomInd(k));
        bestRatios(k) = spindleRatio(allAtomInd(k), k);
        if strcmpi(params.figureLevels, 'basic') && k ~= bestEligibleThresholdInd
            continue;
        end

        baseTitle = [theName ': mean spindle length distribution for T_b = ' ...
            num2str(baseThresholds(k))];
        thisTitle = {['Mean spindle length distribution for T_b = ' ...
            num2str(baseThresholds(k))]; theName; ...
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
            'Color', [0.1, 0.6, 0.2], 'LineWidth', 2);
        set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto');
        yLimits = get(gca, 'YLim');
        yLimits(1) = 0;
        set(gca, 'YLim', yLimits, 'YLimMode', 'manual', 'YTickMode', 'auto');
        line(gca, [eligiblePos, eligiblePos], yLimits, 'Color', ...
            [0.8, 0.8, 0.3], 'LineWidth', 2); %#####
        line(gca, [thisPos, thisPos], yLimits, ...
            'Color', [0.6, 0, 0], 'LineStyle', '--', 'LineWidth', 2);

        hold off
        hleg1 = legend('25 PCTL', '50 PCTL', '75 PCTL', 'Central', ...
            'Mean spindle length', 'STD rate range', 'Min/max ratio', ...
            'Harmonic mean', 'Distance to median', 'N_s best', 'N_s this', ...
            'Location', 'NorthEastOutside');
        if ~earlyMatlabVersion
            title(hleg1, ['Spindle len stats (T_b=' num2str(baseThresholds(k)) ')']);
        end
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
    if strcmpi(params.figureLevels, 'all')
        [~, harmonicInd] = max(meanHarmonicMean(:));
        baseTitle = [theName ': Percentile ratios/dists (max mean harm) '];
        theTitle = {'Percentile ratios/dists (max mean harm)'; theName; ...
            ['HMean threshold ' num2str(baseThresholds(harmonicInd)) ...
            ' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
            ' at ind ' num2str(bestEligibleAtomInd) ...
            ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
            ' at ind ' num2str(bestEligibleThresholdInd)]};
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
        
        lh2 = legend(ax(2), 'medians', 'harmonic', 'Location', 'NorthEast');
        if ~earlyMatlabVersion
            title(lh1, 'Ratio')
            title(lh2, 'Dist')
        end
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
    end
    %% Now plot the spindle ratio image
    if strcmpi(params.figureLevels, 'all')
        baseTitle = [theName ': Mean is below 75%'];
        theTitle = {'Mean is below 75%'; theName; ...
            [' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
            ' at ind ' num2str(bestEligibleAtomInd) ...
            ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
            ' at ind ' num2str(bestEligibleThresholdInd)]};
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
    end
    %% Now plot the spindle ratio image
    zMask = meanSpindleLenMask;
    zMask(atomsNoSTDMask, :) = 0;
    badMask = true(1, numThresholds);
    badMask(eligibleThresholdInds) = false;
    zMask(:, badMask) = 0;
    baseTitle = [theName ': Eligible threshold-atoms/sec combinations'];
    h5Fig = figure('Name', baseTitle);

    imagesc(zMask')
    axis xy
    ylabel('Threshold number');
    xlabel('Atoms/second number')
    theTitle = {'Eligible threshold-atoms/sec combinations'; theName; ...
        eligibleTString};
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
    sRatio = spindleRatio;
    sRatio(sRatio < 0.05) = 0;
    sRatio(atomsNoSTDMask, :) = 0;
    if strcmpi(params.figureLevels, 'all')

        baseTitle = [theName ': Spindle ratio'];
        theTitle = {'Spindle ratio'; theName; ...
            [' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
            ' at ind ' num2str(bestEligibleAtomInd) ...
            ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
            ' at ind ' num2str(bestEligibleThresholdInd)]};
        h5Fig = figure('Name', baseTitle);
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
    end
    %% Now plot the spindle harmonic mean image
    sHarmonic = spindleHarmonicMean;
    sHarmonic(sHarmonic < 0.05) = 0;
    sHarmonic(atomsNoSTDMask, :) = 0;
    if strcmpi(params.figureLevels, 'all')
        baseName = [theName ': Spindle harmonic mean'];
        theTitle = {'Spindle harmonic mean'; theName;  ...
            [' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
            ' at ind ' num2str(bestEligibleAtomInd)...
            ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
            ' at ind ' num2str(bestEligibleThresholdInd)]};
        h6Fig = figure('Name', baseName);

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
    end
    %% Now plot the spindle ratio image
    xProduct = sRatio .* sHarmonic.*meanSpindleLenMask;
    baseTitle = [theName ': Spindle ratio * spindle harmonic mean'];
    theTitle = {'Spindle ratio * spindle harmonic mean'; theName;  ...
        [' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
        ' at ind ' num2str(bestEligibleAtomInd)...
        ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
        ' at ind ' num2str(bestEligibleThresholdInd)]};
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

    %% Now harmonic means versus ratios
    if strcmpi(params.figureLevels, 'all')
        baseTitle = [theName ': harmonic mean vs ratio'];
        theTitle = {'Harmonic mean vs ratio (colors for threshold)'; theName};
        h8Fig = figure('Name', baseTitle);
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
        title(theTitle, 'Interpreter', 'none')
        for f = 1:length(params.figureFormats)
            thisFormat = params.figureFormats{f};
            saveas(h8Fig, [outDir filesep theName '_SpindleRatioVSHarmonicMean.' ...
                thisFormat], thisFormat);
        end
        if params.figureClose
            close(h8Fig);
        end
    end
end

function sT = convertNumber(value, replaceChar)
     sT = sprintf('%08.6f', value);
     sT = strrep(sT, '.', replaceChar);
end     