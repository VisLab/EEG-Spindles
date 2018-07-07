function spindleCurves = ...
    mcsleepGetParameterCurves(spindles, totalTime, outDir, params)
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
    lambda2s = params.mcsleepLambda2s;
    thresholds = params.mcsleepThresholds;
    numLambda2s = length(lambda2s);
    numThresholds = length(thresholds);
    
    spindleCurves.name = params.name;

    %% Get the spindle hits and spindle times
    spindleHits = cellfun(@double, {spindles.numberSpindles});
    spindleHits = reshape(spindleHits, numLambda2s, numThresholds);
    spindleTime = cellfun(@double, {spindles.spindleTime});
    spindleTime = reshape(spindleTime, numLambda2s, numThresholds);
    spindleFraction = spindleTime./totalTime;
    spindleRate = 60*spindleHits/totalTime;
    meanSpindleLen = spindleTime./spindleHits;
    spindleCurves.spindleHits = spindleHits;
    spindleCurves.spindleTime = spindleTime;
    spindleCurves.spindleRate = spindleRate;
    spindleCurves.spindleFraction = spindleFraction;
    spindleCurves.meanSpindleLen = meanSpindleLen;
    spindleCurves.thresholds = thresholds;
    spindleCurves.lambda2s = lambda2s;
    
    %% Compute the legend strings
    thresholdLegendStrings = cell(1, numThresholds);
    for k = 1:numThresholds
       thresholdLegendStrings{k} = num2str(thresholds(k));
    end
    
    lambda2LegendStrings = cell(1, numLambda2s);
    for k = 1:numLambda2s
       lambda2LegendStrings{k} = num2str(lambda2s(k));
    end
    %% Also compute the display lambda2s and thresholds for better picture
    lambda2Display = params.mcsleepLambda2Display;
    lambda2DisplayPos = zeros(size(lambda2Display));
    lambda2DisplayLegendStrings = cell(1, length(lambda2Display));
    for n = 1:length(lambda2Display)
        [~, lambda2DisplayPos(n)] = min(abs(lambda2s - lambda2Display(n)));
        lambda2DisplayLegendStrings{n} = num2str(lambda2s(lambda2DisplayPos(n)));
    end
    numDisplayLambda2s = length(lambda2DisplayLegendStrings);
    
    thresholdDisplay = params.mcsleepThresholdDisplay;
    thresholdDisplayPos = zeros(size(thresholdDisplay));
    thresholdDisplayLegendStrings = cell(1, length(thresholdDisplay));
    for n = 1:length(thresholdDisplay)
        [~, thresholdDisplayPos(n)] = min(abs(thresholds - thresholdDisplay(n)));
        thresholdDisplayLegendStrings{n} = num2str(thresholds(thresholdDisplayPos(n)));
    end
    numDisplayThresholds = length(thresholdDisplayLegendStrings);
    displayColorOffset = 1;
    %% Show the spindle length summary values versus lambda2
    theColors = parula(numThresholds);
    baseTitle = [params.name ':Average spindle length vs Lambda2'];
    h1Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numThresholds
        plot(lambda2s(:), meanSpindleLen(:, m), ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('\lambda_2');
    ylabel('Average spindle length(s)')
    title(baseTitle, 'Interpreter', 'None');
    hleg1 = legend(thresholdLegendStrings, 'Location', 'EastOutside');
    box on
    if ~earlyMatlabVersion
        title(hleg1, 'Thresholds');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_SpindleLengthVsLambda2.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end
    
    %% Show the spindle length summary values versus lambda2 with display thresholds 
    theColors = parula(numDisplayThresholds + displayColorOffset);
    baseTitle = [params.name ':Spindle length vs Lambda2 selected thresholds'];
    h1Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numDisplayThresholds
        plot(lambda2s(:), meanSpindleLen(:, thresholdDisplayPos(m)), ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('\lambda_2');
    ylabel('Average spindle length(s)')
    title(baseTitle, 'Interpreter', 'None');
    hleg1 = legend(thresholdDisplayLegendStrings, 'Location', 'EastOutside');
    box on
    if ~earlyMatlabVersion
        title(hleg1, 'Thresholds');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_SpindleLengthVsLambda2SelectedThresholds.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end
    
    %% Show the spindle rate summary values
    theColors = parula(numThresholds);
    baseTitle = [params.name ':Spindle rate vs Lambda2'];
    h2Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numThresholds
        plot(lambda2s(:), spindleRate(:, m), ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('\lambda_2');
    ylabel('Spindles/min')
    title(baseTitle, 'Interpreter', 'None');
    hleg2 = legend(thresholdLegendStrings, 'Location', 'EastOutside');
    if ~earlyMatlabVersion
        title(hleg2, 'Thresholds');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off
    box on
    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h2Fig, [outDir filesep params.name '_SpindleRateVsLambda2.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

    %% Show the spindle rate summary values for selected thresholds
    theColors = parula(numDisplayThresholds + displayColorOffset);
    baseTitle = [params.name ':Spindle rate vs Lambda2 selected thresholds'];
    h2Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numDisplayThresholds
        plot(lambda2s(:), spindleRate(:, thresholdDisplayPos(m)), ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('\lambda_2');
    ylabel('Spindles/min')
    title(baseTitle, 'Interpreter', 'None');
    hleg2 = legend(thresholdDisplayLegendStrings, 'Location', 'EastOutside');
    if ~earlyMatlabVersion
        title(hleg2, 'Thresholds');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off
    box on
    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h2Fig, [outDir filesep params.name '_SpindleRateVsLambda2SelectedThresholds.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

  %% Show the fraction of time spindling versus lambda2
    theColors = parula(numThresholds);
    baseTitle = [params.name ':Fraction of time spindling vs Lambda2'];
    h1Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numThresholds
        plot(lambda2s(:), spindleFraction(:, m), ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('\lambda_2');
    ylabel('Fraction of time spindling')
    title(baseTitle, 'Interpreter', 'None');
    hleg1 = legend(thresholdLegendStrings, 'Location', 'EastOutside');
    box on
    if ~earlyMatlabVersion
        title(hleg1, 'Thresholds');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_SpindleFractionVsLambda2.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end

  %% Show the fraction of time spindling versus lambda2 selected Thresholds
    theColors = parula(numDisplayThresholds + displayColorOffset);
    baseTitle = [params.name ':Fraction of time spindling vs Lambda2 selected thresholds'];
    h1Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numDisplayThresholds
        plot(lambda2s(:), spindleFraction(:, thresholdDisplayPos(m)), ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('\lambda_2');
    ylabel('Fraction of time spindling')
    title(baseTitle, 'Interpreter', 'None');
    hleg1 = legend(thresholdDisplayLegendStrings, 'Location', 'EastOutside');
    box on
    if ~earlyMatlabVersion
        title(hleg1, 'Thresholds');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name ...
            '_SpindleFractionVsLambda2SelectedThresholds.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end
    
    %% Show the spindle length summary values versus thresholds
    theColors = parula(numLambda2s);
    baseTitle = [params.name ':Average spindle length vs Threshold'];
    h1Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numLambda2s
        plot(thresholds(:), meanSpindleLen(m, :)', ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('Threshold');
    ylabel('Average spindle length(s)')
    title(baseTitle, 'Interpreter', 'None');
    hleg1 = legend(lambda2LegendStrings, 'Location', 'EastOutside');
    box on
    if ~earlyMatlabVersion
        title(hleg1, '\lambda_2');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_SpindleLengthVsThreshold.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end

    %% Show the spindle length summary values versus thresholds for selected lambda2s
    theColors = parula(numDisplayLambda2s + displayColorOffset);
    baseTitle = [params.name ':Spindle length vs Threshold selected lambda2s'];
    h1Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numDisplayLambda2s
        plot(thresholds(:), meanSpindleLen(lambda2DisplayPos(m), :)', ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('Threshold');
    ylabel('Average spindle length(s)')
    title(baseTitle, 'Interpreter', 'None');
    hleg1 = legend(lambda2DisplayLegendStrings, 'Location', 'EastOutside');
    box on
    if ~earlyMatlabVersion
        title(hleg1, '\lambda_2');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_SpindleLengthVsThresholdSelectedLambda2s.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end
    
    %% Show the spindle rate summary values
    theColors = parula(numLambda2s);
    baseTitle = [params.name ':Spindle rate vs Thresholds'];
    h2Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numLambda2s
        plot(thresholds(:), spindleRate(m, :)', ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
  
    xlabel('Threshold');
    ylabel('Spindles/min')
    title(baseTitle, 'Interpreter', 'None');
    hleg2 = legend(lambda2LegendStrings, 'Location', 'EastOutside');
    if ~earlyMatlabVersion
        title(hleg2, '\lambda_2');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off
    box on
    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h2Fig, [outDir filesep params.name '_SpindleRateVsThreshold.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

    %% Show the spindle rate summary values
    theColors = parula(numDisplayLambda2s + displayColorOffset);
    baseTitle = [params.name ':Spindle rate vs Thresholds Selected lambda2s'];
    h2Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numDisplayLambda2s
        plot(thresholds(:), spindleRate(lambda2DisplayPos(m), :)', ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
  
    xlabel('Threshold');
    ylabel('Spindles/min')
    title(baseTitle, 'Interpreter', 'None');
    hleg2 = legend(lambda2DisplayLegendStrings, 'Location', 'EastOutside');
    if ~earlyMatlabVersion
        title(hleg2, '\lambda_2');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off
    box on
    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h2Fig, [outDir filesep params.name '_SpindleRateVsThresholdSelectedLambda2s.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

   %% Show the fraction of time spindling versus thresholds
    theColors = parula(numLambda2s);
    baseTitle = [params.name ':Fraction of time spindling vs Threshold'];
    h1Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numLambda2s
        plot(thresholds(:), spindleFraction(m, :)', ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('Threshold');
    ylabel('Fraction of time spindling')
    title(baseTitle, 'Interpreter', 'None');
    hleg1 = legend(lambda2LegendStrings, 'Location', 'EastOutside');
    box on
    if ~earlyMatlabVersion
        title(hleg1, '\lambda_2');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_SpindleFractionVsThreshold.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end

    %% Show the fraction of time spindling versus thresholds for selected lambda2s
    theColors = parula(numDisplayLambda2s + displayColorOffset);
    baseTitle = [params.name ':Fraction of time spindling vs Threshold for selected lambda2s'];
    h1Fig = figure('Name', baseTitle);
    hold on
    for m = 1:numDisplayLambda2s
        plot(thresholds(:), spindleFraction(lambda2DisplayPos(m), :)', ...
            'LineWidth', 2, 'Color', theColors(m, :))
    end
    xlabel('Threshold');
    ylabel('Fraction of time spindling')
    title(baseTitle, 'Interpreter', 'None');
    hleg1 = legend(lambda2DisplayLegendStrings, 'Location', 'EastOutside');
    box on
    if ~earlyMatlabVersion
        title(hleg1, '\lambda_2');
    end
    yLimits = get(gca, 'YLim');
    yLimits(1) = 0;
    set(gca, 'YLim', yLimits);
    hold off

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_SpindleFractionVsThresholdSelectedLambda2s.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end
    
end
