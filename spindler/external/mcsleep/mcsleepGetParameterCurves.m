function spindleCurves = mcsleepGetParameterCurves(spindles, outDir, params)
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
    totalSeconds = params.frames./params.srate;
    spindleCurves.name = params.name;

    %% Get the spindle hits and spindle times
    spindleHits = cellfun(@double, {spindles.numberSpindles});
    spindleHits = reshape(spindleHits, numLambda2s, numThresholds);
    spindleTime = cellfun(@double, {spindles.spindleTime});
    spindleTime = reshape(spindleTime, numLambda2s, numThresholds);
    spindleRate = 60*spindleHits/totalSeconds;
    meanSpindleLen = spindleTime./spindleHits;
    spindleCurves.spindleHits = spindleHits;
    spindleCurves.spindleTime = spindleTime;
    spindleCurves.spindleRate = spindleRate;
    spindleCurves.meanSpindleLen = meanSpindleLen;
    spindleCurves.thresholds = thresholds;
    spindleCurves.lambda2s = lambda2s;
    %% Show the spindle length summary values versus lambda2
    legendStrings = cell(1, numThresholds);
    for k = 1:numThresholds
       legendStrings{k} = num2str(thresholds(k));
    end
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
    hleg1 = legend( legendStrings, 'Location', 'EastOutside');
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
        saveas(h1Fig, [outDir filesep params.name '_SpindleLength.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end
    
      %% Show the spindle length summary values
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
    hleg2 = legend(legendStrings, 'Location', 'EastOutside');
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
        saveas(h2Fig, [outDir filesep params.name '_SpindleRateByLambda2.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

    %% Show the spindle length summary values versus thresholds
    legendStringsT = cell(1, numLambda2s);
    for k = 1:numLambda2s
       legendStringsT{k} = num2str(lambda2s(k));
    end
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
    hleg1 = legend(legendStringsT, 'Location', 'EastOutside');
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
        saveas(h1Fig, [outDir filesep params.name '_SpindleLengthByThreshold.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end
    
      %% Show the spindle length summary values
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
    hleg2 = legend(legendStringsT, 'Location', 'EastOutside');
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
        saveas(h2Fig, [outDir filesep params.name '_SpindleRateByThreshold.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

end
