function [spindleCurves, warningMsgs, warningCodes] = ...
                   spindlerGetParameterCurves(spindles, outDir, params)
%% Show behavior of spindle counts as a function of threshold and atoms/sec 
%
%  Parameters:
%     spindles     Spindler structure with results of MP decomposition
%     outDir       Optional argument (If present and non empty, saves a
%                  plot of the parameter selection results in outDir)
%     spindleCurves (output) Structure with results of parameter selection
%     warningMsgs  (output) Cell array of warning messages
%     warningCodes (output) Integer array of corresponding error codes
%
%  Written by:  Kay Robbins and John La Rocco, UTSA 2017-2018

%% Get the atoms per second and thresholds
    earlyMatlabVersion = verLessThan('matlab', '9.0');
    warningMsgs = {};
    warningCodes = [];
    spindleCurves = struct('name', NaN,  'atomsPerSecond', NaN, ...
        'thresholds', NaN, ...
        'bestEligibleAtomsPerSecond', NaN', ...
        'bestEligibleAtomInd', NaN, ...
        'bestEligibleThreshold', NaN, ...
        'bestEligibleThresholdInd', NaN, ...
        'atomRateRange', NaN, 'atomRateRangeInd', NaN, ...
        'spindleRateSTD', NaN);

    defaults = concatenateStructs(getGeneralDefaults(), spindlerGetDefaults());
    params = processParameters('spindlerGetParameterCurves', nargin, 3, params, defaults);
    atomsPerSecond = params.spindlerAtomsPerSecond;
    thresholds = params.spindlerThresholds;
    numAtoms = length(atomsPerSecond);
    numThresholds = length(thresholds);
    totalSeconds = params.frames./params.srate;
    spindleCurves.name = params.name;

    %% Get the spindle hits and spindle times
    spindleHits = zeros(size(spindles));
    spindleTime = zeros(size(spindles));
    spindle25 = zeros(size(spindles));
    spindle50 = zeros(size(spindles));
    spindle75 = zeros(size(spindles));
    for k = 1:numAtoms
        for j = 1:numThresholds
            spindleHits(k, j) = spindles(k, j).numberSpindles;
            spindleTime(k, j) = spindles(k, j).spindleTime;
            events = spindles(k, j).events;
            ptimes = prctile(events(:, 2) - events(:, 1), [25, 50, 75]);
            spindle25(k, j) = ptimes(1);
            spindle50(k, j) = ptimes(2);
            spindle75(k, j) = ptimes(3);
        end
    end
    spindleFraction = spindleTime./totalSeconds;
    spindleRate = 60*spindleHits./totalSeconds;

    spindleRatio = zeros(size(spindle50));
    spindleHarmonicMean = zeros(size(spindle50));
    spindleMin = min(spindle50 - spindle25, spindle75 - spindle50);
    spindleMax = max(spindle50 - spindle25, spindle75 - spindle50);
    spindleMask = spindleMax > 0;
    spindleRatio(spindleMask) = spindleMin(spindleMask)./spindleMax(spindleMask);
    spindleHarmonicMean(spindleMask) = 2*spindleMin(spindleMask).*spindleMax(spindleMask) ...
          ./(spindleMin(spindleMask) + spindleMax(spindleMask));
 
    %% Get the mean spindle length
    spindleLen = spindleTime./spindleHits;
    spindleLen(isnan(spindleLen)) = 0;
    spindleLenCentral = (spindleLen(:, 1) + spindleLen(:, end))/2;
    spindleFractionCentral = (spindleFraction(:, 1) + spindleFraction(:, end))/2;
    
    %% Get the standard deviations and slopes of spindle rate
    spindleRateSTD = std(spindleRate, 0, 2);
    spindleRateSTD(isnan(spindleRateSTD)) = 0;
    diffSTD = diff(spindleRateSTD);

    %% Determine the lower index for range
    lowerAtomRateInd = find(spindleRateSTD > 0, 1, 'first');
    if isempty(lowerAtomRateInd) 
        warningCodes(end + 1) = 1;
        warningMsgs{end + 1} = ...
            ['Spindles/sec has non standard behavior for low ' ...
            'spindle length -- spindler completely failed, ' ...
            'likely because of large artifacts'];
        warning('getSpinderCurves:BadSpindleRateSTD', warningMsgs{end});
        return;
    end
    lowerAtomRateInd2 = ...
        find(spindleLen(:, end) > spindleLen(1, end), 1, 'last');
    if ~isempty(lowerAtomRateInd2)
        lowerAtomRateInd = max(lowerAtomRateInd, lowerAtomRateInd2);
    end
    
    %% Determine upper index for range relative to lower range
    spindleRateRel = spindleRate(lowerAtomRateInd:end, :);
    upperAtomRateInd = ...
        find(spindleRateRel(:, 1) - spindleRateRel(:, end) > 0.1, 1, 'first');
    if isempty(upperAtomRateInd)
        upperAtomRateInd = numAtoms;
    else
        upperAtomRateInd = upperAtomRateInd + lowerAtomRateInd - 1;
    end
    diffTopThreshold = diff(spindleRateRel(:, end));
    upperAtomRateInd2 = find(diffTopThreshold < 0, 1, 'first');
    if ~isempty(upperAtomRateInd2)
        upperAtomRateInd = min(upperAtomRateInd, ...
            upperAtomRateInd2 + lowerAtomRateInd - 1);
    end
  
    %% If the STD is not an increasing function of atoms/sec, decomposition bad
    if sum(diffSTD(upperAtomRateInd:end) < 0) > 0
        warningCodes(end + 1) = 2;
        warningMsgs{end + 1} =   ['STD spindles/sec not montonic function of atoms/sec ' ...
            '--- algorithm may have failed, likely because of large artifacts'];
        warning('spindlerGetParameterCurves:SpindleSTDNotMonotonic',  warningMsgs{end});

    end
    
    %% Eligible region is at least spindlerMinAtomsPerSecondInterval
    minEligibleRegion = params.spindlerMinAtomsPerSecondInterval;
    upperAtomRate = atomsPerSecond(upperAtomRateInd);
    lowerAtomRate = atomsPerSecond(lowerAtomRateInd);
    if upperAtomRate - lowerAtomRate < minEligibleRegion
        warningCodes(end + 1) = 3;
        warningMsgs{end + 1} =   ['Eligible atoms/sec interval too small--' ...
            'expanding to ' num2str(minEligibleRegion)];
        warning('spindlerGetParameterCurves:ToosmallEligibleRegion',  warningMsgs{end});
        upperAtomRate = lowerAtomRate + minEligibleRegion;
        [~, upperAtomRateInd] = min(abs(atomsPerSecond - upperAtomRate));
        upperAtomRate = atomsPerSecond(upperAtomRateInd);
    end
    atomRateRangeInd = [lowerAtomRateInd, upperAtomRateInd];

    %% Distances to central spindle fraction
    stdRange = atomRateRangeInd(1):atomRateRangeInd(2);
    distances = bsxfun(@minus, spindleFraction(stdRange, :), ...
                          spindleFractionCentral(stdRange));
    distances = sum(abs(distances), 1);
    [~, bestEligibleThresholdInd] = min(distances);
    bestEligibleThreshold = thresholds(bestEligibleThresholdInd);
    testLens = spindleLen(stdRange, bestEligibleThresholdInd);
    diffTestLens = diff(testLens);
    diffInd = find(diffTestLens >= 0, 1, 'first');
    if isempty(diffInd)
        bestEligibleAtomInd = stdRange(end);
    else
        bestEligibleAtomInd = diffInd + stdRange(1) - 1;
    end
    bestEligibleAtomsPerSecond = atomsPerSecond(bestEligibleAtomInd);
    
    %% Find the distance between the median and the mean spindle length
    sRateMean = (spindleRate(:,  1) + spindleRate(:, end))/2;

    %% Now save the calculated spindle parameters
    spindleCurves.name = params.name;
    spindleCurves.atomsPerSecond = atomsPerSecond;
    spindleCurves.thresholds = thresholds;
    spindleCurves.bestEligibleAtomsPerSecond = bestEligibleAtomsPerSecond;
    spindleCurves.bestEligibleAtomInd = bestEligibleAtomInd;
    spindleCurves.bestEligibleThreshold = bestEligibleThreshold;
    spindleCurves.bestEligibleThresholdInd = bestEligibleThresholdInd;
    spindleCurves.atomRateRangeInd = atomRateRangeInd;
    spindleCurves.atomRateRange = [atomsPerSecond(lowerAtomRateInd), ...
                                   atomsPerSecond(upperAtomRateInd)];
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
        'T_b centered', ['T_b=' num2str(thresholds(1))], ...
        ['T_b=' num2str(thresholds(end))], ...
        ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))]};
    baseTitle = [params.name ':Average spindle length vs atoms/second'];
    theTitle = {'Average spindle length vs atoms/second'; params.name; ...
        ['STD range: [' num2str(lowerAtomRate) ',' ...
        num2str(upperAtomRate) '] Best atoms/sec: ' ...
        num2str(atomsPerSecond(bestEligibleAtomInd)) ...
        ' Best threshold: ' ...
        num2str(thresholds(bestEligibleThresholdInd))]};
    h1Fig = figure('Name', baseTitle);
    hold on
    [ax, h1, h2] = plotyy(atomsPerSecond, spindleLen(:, bestEligibleThresholdInd), ...
        atomsPerSecond, spindleRateSTD);
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
    plot(ax(1), atomsPerSecond, spindleLenCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, spindleLen(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, spindleLen(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    yMax = params.spindleLengthMax;
    hLine = line(ax(1), [eligiblePos, eligiblePos], [0, yMax], ... ###
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);

    for k = 1:numThresholds
        plot(ax(1), atomsPerSecond, spindleLen(:, k), 'Color', theColors(k, :));
    end
    plot(ax(1), atomsPerSecond, spindleLenCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, spindleLen(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, spindleLen(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    plot(ax(1), atomsPerSecond, spindleLen(:, bestEligibleThresholdInd),...
        'LineWidth', 3, 'Color', [0, 0, 0]);
    set(h2, 'LineWidth', 3);
    set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto')
    yLimits = get(ax(1), 'YLim');
    yLimits(2) = max(yLimits(2), params.spindleLengthMax);
    set(hLine, 'YData', [0, yLimits(2)]) %####
    set(ax(1), 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRate, upperAtomRate], [0.1, 0.1]*yLimits(2), ...
       'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    hleg1 = legend(ax(1), legendStrings, 'Location', 'SouthEast');
    hleg2 = legend(ax(2), 'STD', 'STD range', 'Location', 'NorthEast');
    if ~earlyMatlabVersion
        title(hleg1, 'Parameters');
        title(hleg2, 'Spindles/min')
    end
   
    if ~earlyMatlabVersion
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
        saveas(h1Fig, [outDir filesep params.name '_spindleLengthWithSD.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end

    %% Show the spindle length summary values without spin/min STD
    eligiblePos = atomsPerSecond(bestEligibleAtomInd);
    theColors = jet(numThresholds);
    legendStrings = {['T_b=' num2str(bestEligibleThreshold)], ...
        'T_b centered', ...
        ['T_b=' num2str(thresholds(1))], ...
        ['T_b=' num2str(thresholds(end))],'STD range', ...
        ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))]};
    baseTitle = [params.name ':Average spindle length vs atoms/second no STD'];
    theTitle = {'Average spindle length vs atoms/second no STD'; params.name; ...
        ['STD range: [' num2str(lowerAtomRate) ',' ...
        num2str(upperAtomRate) '] ' ...
        ' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
        ' Best threshold: ' ...
        num2str(thresholds(bestEligibleThresholdInd))]};
    h1Figa = figure('Name', baseTitle);
    hold on
    h1 = plot(atomsPerSecond, spindleLen(:, bestEligibleThresholdInd));
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
    plot(atomsPerSecond, spindleLenCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(atomsPerSecond, spindleLen(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(atomsPerSecond, spindleLen(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    yMax = params.spindleLengthMax;
    set(gca, 'YLim', [0, yMax], 'YLimMode', 'manual');
    yLimits = get(gca, 'YLim');
    hLine1 = line([lowerAtomRate, upperAtomRate], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    
    line([eligiblePos, eligiblePos],[0, yMax], ... ###
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);
 
    eligibleThresholdInds = 1:length(thresholds);
    numEligibleThresholds = length(eligibleThresholdInds);
    for k = 1:numEligibleThresholds
        thisInd = eligibleThresholdInds(k);
        plot(atomsPerSecond, spindleLen(:, thisInd), ...
            'Color', theColors(thisInd, :));
    end
    plot(atomsPerSecond, spindleLenCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(atomsPerSecond, spindleLen(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(atomsPerSecond, spindleLen(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    plot(atomsPerSecond, spindleLen(:, bestEligibleThresholdInd),...
        'LineWidth', 3, 'Color', [0, 0, 0]);
    
%     set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto')
%     yLimits = get(gca, 'YLim');
%     yLimits(2) = max(yLimits(2), params.spindleLengthMax);
% %     line(ax(1), [eligiblePos, eligiblePos], [0, yLimits(2)], ... ###
% %          'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);
%     set(hLine, 'YData', [0, yLimits(2)]) %####
    set(hLine1, 'YData', [0.1, 0.1]*yLimits(2));
    set(gca, 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
    hleg1 = legend(gca, legendStrings, 'Location', 'SouthEast');
    %hleg2 = legend(ax(2), 'STD', 'STD range', 'Location', 'NorthEast');
    if ~earlyMatlabVersion
        title(hleg1, 'Parameters');
        %title(hleg2, 'Spindles/min')
    end
    if ~earlyMatlabVersion
        title(hleg1, 'Parameters');
    end

    ylabel('Average spindle length (sec)');
    xlabel('Atoms/sec');
    box('on')
    hold off
    title(theTitle, 'Interpreter', 'None');
    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Figa, [outDir filesep params.name '_spindleLength.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Figa);
    end


   %% Show the fraction of time spindling
    eligiblePos = atomsPerSecond(bestEligibleAtomInd);
    theColors = jet(numThresholds);
    legendStrings = {['T_b=' num2str(bestEligibleThreshold)], ...
        'T_b centered', ...
        ['T_b=' num2str(thresholds(1))], ...
        ['T_b=' num2str(thresholds(end))],'STD range', 'N_s best'};
    baseTitle = [params.name ':Fraction of time spindling'];
    theTitle = {'Fraction of time spindling vs atoms/second'; params.name; ...
        ['STD range: [' num2str(lowerAtomRate) ',' ...
        num2str(upperAtomRate) '] ' ...
        ' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
        ' Best threshold: ' ...
        num2str(thresholds(bestEligibleThresholdInd))]};
    h1Figa = figure('Name', baseTitle);
    hold on
    h1 = plot(atomsPerSecond, spindleFraction(:, bestEligibleThresholdInd));
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
    plot(atomsPerSecond, spindleFractionCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(atomsPerSecond, spindleFraction(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(atomsPerSecond, spindleFraction(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    set(gca, 'YLim', [0, 0.25], 'YLimMode', 'manual', 'YTickMode', 'auto');
    yLimits = get(gca, 'YLim');
    line([lowerAtomRate, upperAtomRate], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
   
   line([eligiblePos, eligiblePos], yLimits, ... 
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);

    eligibleThresholdInds = 1:length(thresholds);
    numEligibleThresholds = length(eligibleThresholdInds);
    for k = 1:numEligibleThresholds
        thisInd = eligibleThresholdInds(k);
        plot(atomsPerSecond, spindleFraction(:, thisInd), ...
            'Color', theColors(thisInd, :));
    end
    plot(atomsPerSecond, spindleFractionCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(atomsPerSecond, spindleFraction(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(atomsPerSecond, spindleFraction(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    plot(atomsPerSecond, spindleFraction(:, bestEligibleThresholdInd),...
        'LineWidth', 3, 'Color', [0, 0, 0]);
    
    hleg1 = legend(legendStrings, 'Location', 'SouthEast');
    if ~earlyMatlabVersion
        title(hleg1, 'Parameters');
    end
    if ~earlyMatlabVersion
        title(hleg1, 'Parameters');
    end

    ylabel('Fraction time spindling');
    xlabel('Atoms/sec');
    box('on')
    hold off
    title(theTitle, 'Interpreter', 'None');
    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Figa, [outDir filesep params.name '_spindleFraction.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Figa);
    end
    
    %% Spindles/min as a function of threshold
    theColors = jet(numThresholds);
    baseTitle = ['Spindles/min vs atoms/sec as a function of threshold:' params.name];
    theTitle = {'Spindles/min vs atoms/sec as a function of threshold'; params.name; ...
        ['Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
         ' STD range: [' num2str(lowerAtomRate) ',' num2str(upperAtomRate) '] ' ]};
    h2Fig = figure('Name', baseTitle);
    hold on
    [ax, h1, h2] = plotyy(atomsPerSecond, spindleRate(:, bestEligibleThresholdInd), ...
        atomsPerSecond, spindleRateSTD);
    set(ax(1), 'YColor', [0, 0, 0]);
    set(ax(2), 'YColor', [0, 0, 0]);
    set(h2, 'LineWidth', 3);
    set(h2, 'Color', [0.65, 0.65, 0.65])
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
    plot(ax(1), atomsPerSecond, sRateMean, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, spindleRate(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, spindleRate(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    set(ax(1), 'YLim', [0, 10], 'YLimMode', 'manual', 'YTickMode', 'auto');
    yLimits = get(ax(1), 'YLim');
    line(ax(1), [eligiblePos, eligiblePos], ... ####
        [0, yLimits(2)], ...
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);
    set(ax(2), 'YLim', [0, 2], 'YLimMode', 'manual', 'YTickMode', 'auto');
    for k = 1:numThresholds
        plot(ax(1), atomsPerSecond, spindleRate(:, k), 'Color', theColors(k, :));
    end
    plot(ax(1), atomsPerSecond, sRateMean, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, spindleRate(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, spindleRate(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    plot(atomsPerSecond, spindleRate(:, bestEligibleThresholdInd), ...
        'LineWidth', 3, 'Color', [0, 0, 0]);
    ylabel(ax(1), 'Spindles/min');
    ylabel(ax(2), 'STD spindles/min wrt threshold');
   
    yLimits = get(ax(2), 'YLim');
    line(ax(2), [lowerAtomRate, upperAtomRate], [0.05, 0.05]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    hleg1 = legend(ax(1), ['T_b=' num2str(bestEligibleThreshold)], 'T_b centered', ...
        'T_b=0', 'T_b=1', ...
        ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))], 'Location', 'NorthWest');
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
        saveas(h2Fig, [outDir filesep params.name '_spindleRate.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

    %% Plot the spindle length distribution for each threshold
    for k = bestEligibleThresholdInd %1:numThresholds
        thisPos = bestEligibleAtomInd;
        
        baseTitle = [params.name ': mean spindle length distribution for T_b = ' ...
            num2str(thresholds(k))];
            thisTitle = {['Mean spindle length distribution for T_b = ' ...
            num2str(thresholds(k))]; params.name; ...
            ['Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd))  ...
            ' ratio=' num2str(spindleRatio(thisPos, k)) ...
            ' harmonic mean='  ...
            num2str(spindleHarmonicMean(thisPos, k))]};
        h3Fig = figure('Name', baseTitle);
        hold on
        plot(atomsPerSecond, spindle25(:, k), 'Color', [0.6, 0.6, 0.6], ...
            'LineWidth', 2, 'LineStyle', '-.')
        plot(atomsPerSecond, spindle50(:, k), 'Color', [0.6, 0.6, 0.6], ...
            'LineWidth', 2);
        plot(atomsPerSecond, spindle75(:, k), 'Color', [0.6, 0.6, 0.6], ...
            'LineWidth', 2, 'LineStyle', '--');
        plot(atomsPerSecond, spindleLen(:, 1), 'Color', [0, 0.4470, 0.7410], ...
            'LineWidth', 3, 'LineStyle', '--');
        plot(atomsPerSecond, spindleLen(:, end), 'Color', [0, 0.4470, 0.7410], ...
            'LineWidth', 3, 'LineStyle', ':');
        plot(atomsPerSecond, spindleLenCentral, 'Color', [0, 0.4470, 0.7410], ...
            'LineWidth', 3);
        plot(atomsPerSecond, spindleLen(:, k), 'Color', [0.0, 0.0, 0.0], ...
            'LineWidth', 3);
        line([lowerAtomRate, upperAtomRate], [0.2, 0.2], ...
            'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
        plot(atomsPerSecond, spindleRatio(:, k), 'Color', [0, 0.7, 0.7], 'LineWidth', 2)

        set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto');
        yLimits = get(gca, 'YLim');
        yLimits(1) = 0;
        set(gca, 'YLim', yLimits, 'YLimMode', 'manual', 'YTickMode', 'auto');
        line(gca, [eligiblePos, eligiblePos], yLimits, 'Color', ...
            [0.8, 0.8, 0.3], 'LineWidth', 2); %#####

        hold off
        hleg1 = legend('25 PCTL', '50 PCTL', '75 PCTL', 'Tb = 0', 'Central', ...
            'Tb = 1', 'Mean spindle length', 'STD rate range', 'Min/max ratio', ...
            ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))], 'Location', 'NorthEastOutside');
        if ~earlyMatlabVersion
            title(hleg1, ['Spindle len stats (T_b=' num2str(thresholds(k)) ')']);
        end
        xlabel('Atoms per second')
        ylabel('Spindle length(s)');

        titleColor = [0, 0, 0];
        title(thisTitle, 'Interpreter', 'None', 'Color', titleColor);
        box on
        for f = 1:length(params.figureFormats)
            thisFormat = params.figureFormats{f};
            saveas(h3Fig, [outDir filesep params.name '_spindleLengthDist_Threshold_' ...
                convertNumber(thresholds(k), '_') '.' thisFormat], thisFormat);
        end
        if params.figureClose
            close(h3Fig);
        end
    end

end

function sT = convertNumber(value, replaceChar)
     sT = sprintf('%08.6f', value);
     sT = strrep(sT, '.', replaceChar);
end     