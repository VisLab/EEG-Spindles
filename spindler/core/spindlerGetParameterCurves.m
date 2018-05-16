function [spindleCurves, warningMsgs, warningCodes] = ...
                   spindlerGetParameterCurves(spindles, outDir, params)
%% Show behavior of spindle counts as a function of threshold and atoms/sec 
%
%  Parameters:
%     spindles     Spindler structure with results of MP decomposition
%     outDir       Optional argument (If present and non empty, saves a
%                  plot of the parameter selection results in outDir)
%     spindleCurves (output) Structure containing results of parameter
%                  selection
%     warningMsgs (output) Cell array of warning messages
%     warningCodes (output) Integer array of corresponding error codes
%
%  Written by:  Kay Robbins and John La Rocco, UTSA 2017-2018

%% Get the atoms per second and thresholds
    earlyMatlabVersion = verLessThan('matlab', '9.0');
    warningMsgs = {};
    warningCodes = [];
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
    params = processParameters('spindlerGetParameterCurves', nargin, 2, params, defaults);
    atomsPerSecond = unique(cellfun(@double, {spindles.atomsPerSecond}))';
    baseThresholds = unique(cellfun(@double, {spindles.baseThreshold}));
    numAtoms = length(atomsPerSecond);
    numThresholds = length(baseThresholds);
    totalSeconds = params.frames./params.srate;
    spindleCurves.name = params.name;

    %% Get the spindle hits and spindle times
    spindleHits = cellfun(@double, {spindles.numberSpindles});
    spindleHits = reshape(spindleHits, numAtoms, numThresholds);
    spindleTime = cellfun(@double, {spindles.spindleTime});
    spindleTime = reshape(spindleTime, numAtoms, numThresholds);
    spindleFraction = reshape(spindleTime/totalSeconds, numAtoms, numThresholds);
    spindleRate = 60*spindleHits/totalSeconds;
    spindle25 = zeros(length(spindles), 1);
    spindle50 = zeros(length(spindles), 1);
    spindle75 = zeros(length(spindles), 1);
    for k = 1:length(spindles)
        events = spindles(k).events;
        if isempty(events)
            continue;
        end
        ptimes = prctile(events(:, 2) - events(:, 1), [25, 50, 75]);
        spindle25(k) = ptimes(1);
        spindle50(k) = ptimes(2);
        spindle75(k) = ptimes(3);
    end
    spindleRatio = zeros(size(spindle50));
    spindleHarmonicMean = zeros(size(spindle50));
    spindleMin = min(spindle50 - spindle25, spindle75 - spindle50);
    spindleMax = max(spindle50 - spindle25, spindle75 - spindle50);
    spindleMask = spindleMax > 0;
    spindleRatio(spindleMask) = spindleMin(spindleMask)./spindleMax(spindleMask);
    spindleHarmonicMean(spindleMask) = 2*spindleMin(spindleMask).*spindleMax(spindleMask) ...
          ./(spindleMin(spindleMask) + spindleMax(spindleMask));
 
    spindleRatio = reshape(spindleRatio, numAtoms, numThresholds);
    spindle25 = reshape(spindle25, numAtoms, numThresholds);
    spindle50 = reshape(spindle50, numAtoms, numThresholds);
    spindle75 = reshape(spindle75, numAtoms, numThresholds);
    spindleHarmonicMean = reshape(spindleHarmonicMean, numAtoms, numThresholds);
    
    %% Get the standard deviations and slopes of spindle rate
    spindleRateSTD = std(spindleRate, 0, 2);
    spindleRateSTD(isnan(spindleRateSTD)) = 0;
    diffSTD = diff(spindleRateSTD);
    diffTopThreshold = diff(spindleRate(:, end));
    upperAtomRateInd = find(diffTopThreshold < 0, 1, 'first');
    if isempty(upperAtomRateInd)
        upperAtomRateInd = numAtoms;
    end
    lowerAtomRateInd = find(spindleRateSTD > 0, 1, 'first');
    if isempty(lowerAtomRateInd) || isempty(upperAtomRateInd) || lowerAtomRateInd >= upperAtomRateInd
        warningCodes(end + 1) = 1;
        warningMsgs{end + 1} = ...
            ['Spindles/sec has non standard behavior for low ' ...
            'spindle length --- algorithm failed, likely because of large artifacts'];
        warning('getSpinderCurves:BadSpindleRateSTD', warningMsgs{end});
        return;
    end

    %% If the STD is not an increasing function of atoms/sec, decomposition bad
    if sum(diffSTD(upperAtomRateInd:end) < 0) > 0
        warningCodes(end + 1) = 2;
        warningMsgs{end + 1} =   ['STD spindles/sec not montonic function of atoms/sec ' ...
            '--- algorithm may have failed, likely because of large artifacts'];
        warning('spindlerGetParameterCurves:SpindleSTDNotMonotonic',  warningMsgs{end});

    end
    %lowerAtomRateInd = max(1, lowerAtomRateInd - 1);
    
    %% Adjust to narrower region
    bendSTD = spindleRateSTD(upperAtomRateInd);
    upperAtomRateInd = find(spindleRateSTD >= 0.5 * bendSTD, 1, 'first');
    lowerAtomRateInd = find(spindleRateSTD >= 0.05 * bendSTD, 1, 'first');
    %%
    atomRateRangeInd = [lowerAtomRateInd, upperAtomRateInd];
    upperAtomRate = atomsPerSecond(upperAtomRateInd);
    lowerAtomRate = atomsPerSecond(lowerAtomRateInd);
    
    %% Get the mean spindle length
    meanSpindleLen = spindleTime./spindleHits;
    meanSpindleLen(isnan(meanSpindleLen)) = 0;
    meanSpindleLenCentral = (meanSpindleLen(:, 1) + meanSpindleLen(:, end))/2;
    spindleFractionCentral = (spindleFraction(:, 1) + spindleFraction(:, end))/2;
    %% Distances to central spindle length
    stdRange = atomRateRangeInd(1):atomRateRangeInd(2);
    distances = bsxfun(@minus, meanSpindleLen(stdRange, :), ...
                          meanSpindleLenCentral(stdRange));
    distances = sum(abs(distances), 1);
    [~, bestEligibleThresholdInd] = min(distances);
    bestEligibleThreshold = baseThresholds(bestEligibleThresholdInd);
    testLens = meanSpindleLenCentral(stdRange);
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
    spindleCurves.baseThresholds = baseThresholds;
    spindleCurves.bestEligibleAtomsPerSecond = bestEligibleAtomsPerSecond;
    spindleCurves.bestEligibleAtomInd = bestEligibleAtomInd;
    spindleCurves.bestEligibleLinearInd = length(atomsPerSecond)*(bestEligibleThresholdInd - 1) + ...
        bestEligibleAtomInd;
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
        'T_b centered', ['T_b=' num2str(baseThresholds(1))], ...
        ['T_b=' num2str(baseThresholds(end))], ...
        ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))]};
    baseTitle = [params.name ':Average spindle length vs atoms/second'];
    theTitle = {'Average spindle length vs atoms/second'; params.name; ...
        ['STD range: [' num2str(lowerAtomRate) ',' ...
        num2str(upperAtomRate) '] Best atoms/sec: ' ...
        num2str(atomsPerSecond(bestEligibleAtomInd)) ...
        ' Best threshold: ' ...
        num2str(baseThresholds(bestEligibleThresholdInd))]};
    h1Fig = figure('Name', baseTitle);
    hold on
    [ax, h1, h2] = plotyy(atomsPerSecond, meanSpindleLen(:, bestEligibleThresholdInd), ...
        atomsPerSecond, spindleRateSTD);
%     set(ax(1), 'YColor', [0, 0, 0]);
%     set(ax(2), 'YColor', [0, 0, 0]);
%     set(h2, 'LineWidth', 3);
%     set(h2, 'Color', [0.65, 0.65, 0.65])
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
    plot(ax(1), atomsPerSecond, meanSpindleLenCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');

    yLimitsTemp = [meanSpindleLen(:, end), meanSpindleLen(:, 1)];
    hLine = line(ax(1), [eligiblePos, eligiblePos], yLimitsTemp, ... ###
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);

    for k = 1:numThresholds
        plot(ax(1), atomsPerSecond, meanSpindleLen(:, k), 'Color', theColors(k, :));
    end
    plot(ax(1), atomsPerSecond, meanSpindleLenCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    plot(ax(1), atomsPerSecond, meanSpindleLen(:, bestEligibleThresholdInd),...
        'LineWidth', 3, 'Color', [0, 0, 0]);
    set(h2, 'LineWidth', 3);
    set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto')
    yLimits = get(ax(1), 'YLim');
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
   
%     hleg2 = legend(ax(2), {'STD', 'STD range'}, 'Location', 'NorthEastOutside');
%     if ~earlyMatlabVersion
%         title(hleg2, 'Spindles/min')
%     end

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
        saveas(h1Fig, [outDir filesep params.name '_AverageSpindleLengthWithSD.' ...
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
        ['T_b=' num2str(baseThresholds(1))], ...
        ['T_b=' num2str(baseThresholds(end))],'STD range', ...
        ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))]};
    baseTitle = [params.name ':Average spindle length vs atoms/second no STD'];
    theTitle = {'Average spindle length vs atoms/second no STD'; params.name; ...
        ['STD range: [' num2str(lowerAtomRate) ',' ...
        num2str(upperAtomRate) '] ' ...
        ' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
        ' Best threshold: ' ...
        num2str(baseThresholds(bestEligibleThresholdInd))]};
    h1Figa = figure('Name', baseTitle);
    hold on
    h1 = plot(atomsPerSecond, meanSpindleLen(:, bestEligibleThresholdInd));
    theColor = get(h1, 'Color');
    set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
    plot(atomsPerSecond, meanSpindleLenCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(atomsPerSecond, meanSpindleLen(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(atomsPerSecond, meanSpindleLen(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    yLimits = get(gca, 'YLim');
    hLine1 = line([lowerAtomRate, upperAtomRate], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    yLimitsTemp = [meanSpindleLen(:, end), meanSpindleLen(:, 1)];
    hLine = line([eligiblePos, eligiblePos], yLimitsTemp, ... ###
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);
 
   %hleg1 = legend(gca, legendStrings, 'Location', 'SouthEast');
%     for k = 1:numThresholds
%         plot(atomsPerSecond, meanSpindleLen(:, k), 'Color', theColors(k, :));
%     end
    eligibleThresholdInds = 1:length(baseThresholds);
    numEligibleThresholds = length(eligibleThresholdInds);
    for k = 1:numEligibleThresholds
        thisInd = eligibleThresholdInds(k);
        plot(atomsPerSecond, meanSpindleLen(:, thisInd), ...
            'Color', theColors(thisInd, :));
    end
    plot(atomsPerSecond, meanSpindleLenCentral, ...
        'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
    plot(atomsPerSecond, meanSpindleLen(:, 1), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
    plot(atomsPerSecond, meanSpindleLen(:, end), ...
        'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
    plot(atomsPerSecond, meanSpindleLen(:, bestEligibleThresholdInd),...
        'LineWidth', 3, 'Color', [0, 0, 0]);
    
    set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto')
    yLimits = get(gca, 'YLim');
    set(hLine, 'YData', [0, yLimits(2)]) %####
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
        saveas(h1Figa, [outDir filesep params.name '_AverageSpindleLength.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Figa);
    end

    %% Show the spindle length summary values without spin/min STD --- temp
%     eligiblePos = atomsPerSecond(bestEligibleAtomInd);
%     theColors = jet(numThresholds);
%     legendStrings = {['T_b=' num2str(bestEligibleThreshold)], ...
%         'T_b centered', ...
%         ['T_b=' num2str(baseThresholds(1))], ...
%         ['T_b=' num2str(baseThresholds(end))],'STD range', ...
%         ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))]};
%     baseTitle = [params.name ':Average spindle length vs atoms/second no STD'];
%     theTitle = {'Average spindle length vs atoms/second no STD'; params.name; ...
%         ['STD range: [' num2str(lowerAtomRate) ',' ...
%         num2str(upperAtomRate) '] ' ...
%         ' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
%         ' Best threshold: ' ...
%         num2str(baseThresholds(bestEligibleThresholdInd))]};
%     h1Figa = figure('Name', baseTitle);
%     hold on
%         eligibleThresholdInds = 1:length(baseThresholds);
%     numEligibleThresholds = length(eligibleThresholdInds);
%     tempLegends = cell(1, numEligibleThresholds);
%     for k = 1:numEligibleThresholds
%         thisInd = eligibleThresholdInds(k);
%         tempLegends{k} = sprintf('%f12.5', baseThresholds(k));
%         plot(atomsPerSecond, meanSpindleLen(:, thisInd), ...
%             'Color', theColors(thisInd, :));
%     end
%     h1 = plot(atomsPerSecond, meanSpindleLen(:, bestEligibleThresholdInd));
%     theColor = get(h1, 'Color');
%     set(h1, 'Color', [0, 0, 0], 'LineWidth', 3);
%     plot(atomsPerSecond, meanSpindleLenCentral, ...
%         'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
%     plot(atomsPerSecond, meanSpindleLen(:, 1), ...
%         'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
%     plot(atomsPerSecond, meanSpindleLen(:, end), ...
%         'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
%     yLimits = get(gca, 'YLim');
%     hLine1 = line([lowerAtomRate, upperAtomRate], [0.1, 0.1]*yLimits(2), ...
%         'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
%     yLimitsTemp = [meanSpindleLen(:, end), meanSpindleLen(:, 1)];
%     hLine = line([eligiblePos, eligiblePos], yLimitsTemp, ... ###
%         'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);
%  
%    %hleg1 = legend(gca, legendStrings, 'Location', 'SouthEast');
% %     for k = 1:numThresholds
% %         plot(atomsPerSecond, meanSpindleLen(:, k), 'Color', theColors(k, :));
% %     end
%     eligibleThresholdInds = 1:length(baseThresholds);
%     numEligibleThresholds = length(eligibleThresholdInds);
%     for k = 1:numEligibleThresholds
%         thisInd = eligibleThresholdInds(k);
%         plot(atomsPerSecond, meanSpindleLen(:, thisInd), ...
%             'Color', theColors(thisInd, :));
%     end
%     plot(atomsPerSecond, meanSpindleLenCentral, ...
%         'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
%     plot(atomsPerSecond, meanSpindleLen(:, 1), ...
%         'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
%     plot(atomsPerSecond, meanSpindleLen(:, end), ...
%         'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');
%     plot(atomsPerSecond, meanSpindleLen(:, bestEligibleThresholdInd),...
%         'LineWidth', 3, 'Color', [0, 0, 0]);
%     
%     set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto')
%     yLimits = get(gca, 'YLim');
%     set(hLine, 'YData', [0, yLimits(2)]) %####
%     set(hLine1, 'YData', [0.1, 0.1]*yLimits(2));
%     set(gca, 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
%     %hleg1 = legend(gca, legendStrings, 'Location', 'SouthEast');
%     %hleg2 = legend(ax(2), 'STD', 'STD range', 'Location', 'NorthEast');
%     hleg1 = legend(gca, tempLegends, 'Location', 'EastOutside');
%     if ~earlyMatlabVersion
%         title(hleg1, 'Parameters');
%         %title(hleg2, 'Spindles/min')
%     end
%     if ~earlyMatlabVersion
%         title(hleg1, 'Parameters');
%     end
% 
%     ylabel('Average spindle length (sec)');
%     xlabel('Atoms/sec');
%     box('on')
%     hold off
%     title(theTitle, 'Interpreter', 'None');
%     for k = 1:length(params.figureFormats)
%         thisFormat = params.figureFormats{k};
%         saveas(h1Figa, [outDir filesep params.name '_AverageSpindleLengthTemp.' ...
%             thisFormat], thisFormat);
%     end
%     if params.figureClose
%         close(h1Figa);
%     end
%     
   %% Show the fraction of time spindling
    eligiblePos = atomsPerSecond(bestEligibleAtomInd);
    theColors = jet(numThresholds);
    legendStrings = {['T_b=' num2str(bestEligibleThreshold)], ...
        'T_b centered', ...
        ['T_b=' num2str(baseThresholds(1))], ...
        ['T_b=' num2str(baseThresholds(end))],'STD range', 'N_s best'};
    baseTitle = [params.name ':Fraction of time spindling'];
    theTitle = {'Fraction of time spindling vs atoms/second'; params.name; ...
        ['STD range: [' num2str(lowerAtomRate) ',' ...
        num2str(upperAtomRate) '] ' ...
        ' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
        ' Best threshold: ' ...
        num2str(baseThresholds(bestEligibleThresholdInd))]};
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
    yLimits = get(gca, 'YLim');
    hLine1 = line([lowerAtomRate, upperAtomRate], [0.1, 0.1]*yLimits(2), ...
        'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
    yLimitsTemp = [spindleFraction(:, end), spindleFraction(:, 1)];
    hLine = line([eligiblePos, eligiblePos], yLimitsTemp, ... ###
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);
 
%    hleg1 = legend(gca, legendStrings, 'Location', 'SouthEast');
%     for k = 1:numThresholds
%         plot(atomsPerSecond, meanSpindleLen(:, k), 'Color', theColors(k, :));
%     end
    eligibleThresholdInds = 1:length(baseThresholds);
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
    
    set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto')
    yLimits = get(gca, 'YLim');
    set(hLine, 'YData', [0, yLimits(2)]) %####
    set(hLine1, 'YData', [0.1, 0.1]*yLimits(2));
    set(gca, 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
    hleg1 = legend(legendStrings, 'Location', 'SouthEast');
    %hleg2 = legend(ax(2), 'STD', 'STD range', 'Location', 'NorthEast');
    if ~earlyMatlabVersion
        title(hleg1, 'Parameters');
        %title(hleg2, 'Spindles/min')
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
        saveas(h1Figa, [outDir filesep params.name '_FractionSpindlingTime.' ...
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
         'STD range: [' num2str(lowerAtomRate) ',' num2str(upperAtomRate) '] ' ]};
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
    hLine = line(ax(1), [eligiblePos, eligiblePos], ... ####
        [0, spindleRate(3, 1)], ...
        'Color', [0.8, 0.8, 0.2], 'LineWidth', 2);

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
    set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto');

    yLimits = get(ax(1), 'YLim');
    set(hLine, 'YData', [0, yLimits(2)])  %####
    set(ax(1), 'YLim', [0, yLimits(2)], 'YLimMode', 'manual', 'YTickMode', 'auto');
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
        saveas(h2Fig, [outDir filesep params.name '_AverageSpindlePerMin.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

    %% Plot the spindle length distribution for each threshold
    for k = bestEligibleThresholdInd %1:numThresholds
%         thisPos = atomsPerSecond(allEligibleAtomInd(k));
%         if strcmpi(params.figureLevels, 'basic') && k ~= bestEligibleThresholdInd
%             continue;
%         end
        thisPos = bestEligibleAtomInd;
        
        baseTitle = [params.name ': mean spindle length distribution for T_b = ' ...
            num2str(baseThresholds(k))];
%         thisTitle = {['Mean spindle length distribution for T_b = ' ...
%             num2str(baseThresholds(k))]; params.name; ...
%             ['Best atoms/sec is ' num2str(thisPos) ...
%             ' ratio=' num2str(spindleRatio(allEligibleAtomInd(k), k)) ...
%             ' harmonic mean='  ...
%             num2str(spindleHarmonicMean(allEligibleAtomInd(k), k))]};
            thisTitle = {['Mean spindle length distribution for T_b = ' ...
            num2str(baseThresholds(k))]; params.name; ...
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
        plot(atomsPerSecond, meanSpindleLen(:, 1), 'Color', [0, 0.4470, 0.7410], ...
            'LineWidth', 3, 'LineStyle', '--');
        plot(atomsPerSecond, meanSpindleLen(:, end), 'Color', [0, 0.4470, 0.7410], ...
            'LineWidth', 3, 'LineStyle', ':');
        plot(atomsPerSecond, meanSpindleLenCentral, 'Color', [0, 0.4470, 0.7410], ...
            'LineWidth', 3);
        plot(atomsPerSecond, meanSpindleLen(:, k), 'Color', [0.0, 0.0, 0.0], ...
            'LineWidth', 3);
        line([lowerAtomRate, upperAtomRate], [0.2, 0.2], ...
            'LineWidth', 4, 'Color', [0.85, 0.85, 0.85]);
        plot(atomsPerSecond, spindleRatio(:, k), 'Color', [0, 0.7, 0.7], 'LineWidth', 2)

%         plot(atomsPerSecond, spindleHarmonicMean(:, k), 'Color', [0.0, 0.7, 0.7], ...
%             'LineStyle', '--', 'LineWidth', 2);
%         plot(atomsPerSecond, selfMeanMedianAbsDist(:, k), ...
%             'Color', [0.1, 0.6, 0.2], 'LineWidth', 2);
        set(gca, 'YLimMode', 'auto', 'YTickMode', 'auto');
        yLimits = get(gca, 'YLim');
        yLimits(1) = 0;
        set(gca, 'YLim', yLimits, 'YLimMode', 'manual', 'YTickMode', 'auto');
        line(gca, [eligiblePos, eligiblePos], yLimits, 'Color', ...
            [0.8, 0.8, 0.3], 'LineWidth', 2); %#####
%         line(gca, [thisPos, thisPos], yLimits, ...
%             'Color', [0.6, 0, 0], 'LineStyle', '--', 'LineWidth', 2);

        hold off
        hleg1 = legend('25 PCTL', '50 PCTL', '75 PCTL', 'Tb = 0', 'Central', ...
            'Tb = 1', 'Mean spindle length', 'STD rate range', 'Min/max ratio', ...
            ['N_s=' num2str(atomsPerSecond(bestEligibleAtomInd))], 'Location', 'NorthEastOutside');
        if ~earlyMatlabVersion
            title(hleg1, ['Spindle len stats (T_b=' num2str(baseThresholds(k)) ')']);
        end
        xlabel('Atoms per second')
        ylabel('Spindle length(s)');
%         if sum(eligibleThresholdInds == k) > 0
%             titleColor = [0.7, 0.0, 0.0];
%         else
%             titleColor = [0, 0, 0];
%         end
titleColor = [0, 0, 0];
        title(thisTitle, 'Interpreter', 'None', 'Color', titleColor);
        box on
        for f = 1:length(params.figureFormats)
            thisFormat = params.figureFormats{f};
            saveas(h3Fig, [outDir filesep params.name '_LengthDist_Threshold_' ...
                convertNumber(baseThresholds(k), '_') '.' thisFormat], thisFormat);
        end
        if params.figureClose
            close(h3Fig);
        end
    end

%     %% Now plot the spindle curve
%     if strcmpi(params.figureLevels, 'all')
%         [~, harmonicInd] = max(meanHarmonicMean(:));
%         baseTitle = [params.name ': Percentile ratios/dists (max mean harm) '];
%         theTitle = {'Percentile ratios/dists (max mean harm)'; params.name; ...
%             ['HMean threshold ' num2str(baseThresholds(harmonicInd)) ...
%             ' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
%             ' at ind ' num2str(bestEligibleAtomInd) ...
%             ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
%             ' at ind ' num2str(bestEligibleThresholdInd)]};
%         h4Fig = figure('Name', baseTitle);
%         dists = [distMeanMedian(:), meanHarmonicMean(:)];
%         [ax, h1, h2] = plotyy(baseThresholds(:), bestPctlRatio(:), ...
%             baseThresholds(:), dists);
%         hold on
%         h4 = plot(ax(1), baseThresholds, meanSpindleRatio);
%         set(h4, 'LineWidth', 2', 'Color', [0, 0.6, 0]);
%         
%         set(h1, 'LineWidth', 2);
%         set(h2(1), 'LineWidth', 2);
%         set(h2(2), 'LineWidth', 2', 'LineStyle', '--');
%         xlabel(ax(1), 'Threshold')
%         ylabel(ax(1), 'Ratio of lengths at best')
%         ylabel(ax(2), 'Dist between mean and median')
%         lh1 = legend(ax(1), 'best', 'mean', 'Location', 'NorthWest');
%         
%         lh2 = legend(ax(2), 'medians', 'harmonic', 'Location', 'NorthEast');
%         if ~earlyMatlabVersion
%             title(lh1, 'Ratio')
%             title(lh2, 'Dist')
%         end
%         hold off
%         box on
%         title(theTitle, 'Interpreter', 'None')
%         for f = 1:length(params.figureFormats)
%             thisFormat = params.figureFormats{f};
%             saveas(h4Fig, [outDir filesep params.name '_SpindleLengthDistRatio.' ...
%                 thisFormat], thisFormat);
%         end
%         if params.figureClose
%             close(h4Fig);
%         end
%     end
%     %% Now plot the spindle ratio image
%     if strcmpi(params.figureLevels, 'all')
%         baseTitle = [params.name ': Mean is below 75%'];
%         theTitle = {'Mean is below 75%'; params.name; ...
%             [' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
%             ' at ind ' num2str(bestEligibleAtomInd) ...
%             ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
%             ' at ind ' num2str(bestEligibleThresholdInd)]};
%         h5Fig = figure('Name', baseTitle);
%         imagesc(meanSpindleLenMask')
%         axis xy
%         ylabel('Threshold number');
%         xlabel('Atoms/second number')
%         title(theTitle, 'Interpreter', 'None')
%         for f = 1:length(params.figureFormats)
%             thisFormat = params.figureFormats{f};
%             saveas(h5Fig, [outDir filesep params.name '_SpindleRatioImage.' ...
%                 thisFormat], thisFormat);
%         end
%         if params.figureClose
%             close(h5Fig);
%         end
%     end
    %% Now plot the region of the threshold atoms/sec space with decent distributions
%     zMask = meanSpindleLenMask;
%     badMask = true(1, numThresholds);
%     badMask(eligibleThresholdInds) = false;
%     zMask(:, badMask) = 0;
%     baseTitle = [params.name ': Eligible threshold-atoms/sec combinations'];
%     h5Fig = figure('Name', baseTitle);
% 
%     imagesc(zMask')
%     axis xy
%     ylabel('Threshold number');
%     xlabel('Atoms/second number')
%     theTitle = {'Eligible threshold-atoms/sec combinations'; params.name; ...
%         eligibleTString};
%     title(theTitle, 'Interpreter', 'None')
%     for f = 1:length(params.figureFormats)
%         thisFormat = params.figureFormats{f};
%         saveas(h5Fig, [outDir filesep params.name '_SpindleCombinationsImage.' ...
%             thisFormat], thisFormat);
%     end
%     if params.figureClose
%         close(h5Fig);
%     end
% 
%     %% Now plot the spindle ratio image
%     atomsNoSTDMask = true(length(atomsPerSecond), 1);
%     atomsNoSTDMask(stdRange) = false;
%     sRatio = spindleRatio;
%     sRatio(sRatio < 0.05) = 0;
%     sRatio(atomsNoSTDMask, :) = 0;
%     if strcmpi(params.figureLevels, 'all')
% 
%         baseTitle = [params.name ': Spindle ratio'];
%         theTitle = {'Spindle ratio'; params.name; ...
%             [' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
%             ' at ind ' num2str(bestEligibleAtomInd) ...
%             ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
%             ' at ind ' num2str(bestEligibleThresholdInd)]};
%         h5Fig = figure('Name', baseTitle);
%         imagesc(sRatio')
%         axis xy
%         colorbar
%         ylabel('Threshold number');
%         xlabel('Atoms/second number')
%         title(theTitle, 'Interpreter', 'None')
%         for f = 1:length(params.figureFormats)
%             thisFormat = params.figureFormats{f};
%             saveas(h5Fig, [outDir filesep params.name '_SpindleRatioImage.' ...
%                 thisFormat], thisFormat);
%         end
%         if params.figureClose
%             close(h5Fig);
%         end
%     end
%     %% Now plot the spindle harmonic mean image
%     sHarmonic = spindleHarmonicMean;
%     sHarmonic(sHarmonic < 0.05) = 0;
%     sHarmonic(atomsNoSTDMask, :) = 0;
%     if strcmpi(params.figureLevels, 'all')
%         baseName = [params.name ': Spindle harmonic mean'];
%         theTitle = {'Spindle harmonic mean'; params.name;  ...
%             [' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
%             ' at ind ' num2str(bestEligibleAtomInd)...
%             ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
%             ' at ind ' num2str(bestEligibleThresholdInd)]};
%         h6Fig = figure('Name', baseName);
% 
%         imagesc(sHarmonic')
%         ylabel('Threshold number');
%         xlabel('Atoms/second number')
%         title(theTitle, 'Interpreter', 'None')
%         axis xy
%         colorbar
%         for f = 1:length(params.figureFormats)
%             thisFormat = params.figureFormats{f};
%             saveas(h6Fig, [outDir filesep params.name '_SpindleHarmonic.' ...
%                 thisFormat], thisFormat);
%         end
%         if params.figureClose
%             close(h6Fig);
%         end
%     end
%     %% Now plot the spindle ratio image
%     xProduct = sRatio .* sHarmonic.*meanSpindleLenMask;
%     baseTitle = [params.name ': Spindle ratio * spindle harmonic mean'];
%     theTitle = {'Spindle ratio * spindle harmonic mean'; params.name;  ...
%         [' Best atoms/sec: ' num2str(atomsPerSecond(bestEligibleAtomInd)) ...
%         ' at ind ' num2str(bestEligibleAtomInd)...
%         ' Best threshold: ' num2str(baseThresholds(bestEligibleThresholdInd)) ...
%         ' at ind ' num2str(bestEligibleThresholdInd)]};
%     h7Fig = figure('Name', baseTitle);
% 
%     imagesc(xProduct');
%     axis xy
%     colorbar
%     ylabel('Threshold number');
%     xlabel('Atoms/second number')
%     title(theTitle, 'Interpreter', 'None')
%     for f = 1:length(params.figureFormats)
%         thisFormat = params.figureFormats{f};
%         saveas(h7Fig, [outDir filesep params.name '_SpindleRatioHarmonicMeanImage.' ...
%             thisFormat], thisFormat);
%     end
%     if params.figureClose
%         close(h7Fig);
%     end
% 
%     %% Now harmonic means versus ratios
% %     if strcmpi(params.figureLevels, 'all')
% %         baseTitle = [params.name ': harmonic mean vs ratio'];
% %         theTitle = {'Harmonic mean vs ratio (colors for threshold)'; params.name};
% %         h8Fig = figure('Name', baseTitle);
% %         hColors = jet(numThresholds);
% %         hold on
% %         for k = 1:numThresholds
% %             plot(spindleRatio(:, k), spindleHarmonicMean(:, k), 'LineWidth', 2, ...
% %                 'LineStyle', 'None', 'Color', hColors(k, :), 'Marker', 's', ...
% %                 'MarkerSize', 8);
% %             [~, maxIndH] = max(spindleHarmonicMean(stdRange, k));
% %             plot(spindleRatio(maxIndH, k), spindleHarmonicMean(maxIndH, k), 'LineWidth', 2, ...
% %                 'LineStyle', 'None', 'Color', [0, 0, 0], 'Marker', 'o', ...
% %                 'MarkerSize', 12);
% %             [~, maxIndR] = max(spindleRatio(stdRange, k));
% %             plot(spindleRatio(maxIndR, k), spindleHarmonicMean(maxIndR, k), 'LineWidth', 2, ...
% %                 'LineStyle', 'None', 'Color', [0, 0, 0], 'Marker', 'd', ...
% %                 'MarkerSize', 12);
% %         end
% % 
% %         line([0, 1], [0, 1])
% %         hold off
% %         xlabel('Spindle ratio')
% %         ylabel('Spindle max/min harmonic mean')
% %         box on
% %         title(theTitle, 'Interpreter', 'none')
% %         for f = 1:length(params.figureFormats)
% %             thisFormat = params.figureFormats{f};
% %             saveas(h8Fig, [outDir filesep params.name '_SpindleRatioVSHarmonicMean.' ...
% %                 thisFormat], thisFormat);
% %         end
% %         if params.figureClose
% %             close(h8Fig);
% %         end
% %     end
end

function sT = convertNumber(value, replaceChar)
     sT = sprintf('%08.6f', value);
     sT = strrep(sT, '.', replaceChar);
end     