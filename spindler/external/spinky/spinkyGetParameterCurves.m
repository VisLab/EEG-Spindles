function spindleCurves = spinkyGetParameterCurves(spindles, outDir, params)
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
%  Written by:  Kay Robbins 

%% Set up the defaults
    defaults = concatenateStructs(getGeneralDefaults(), spinkyGetDefaults());
    params = processParameters('spinkyGetParameterCurves', nargin, 2, params, defaults);

    thresholds = unique(cellfun(@double, {spindles.threshold}));
    totalSeconds = params.frames./params.srate;

    %% Get the spindle hits and spindle times
    spindleHits = cellfun(@double, {spindles.numberSpindles});
    spindleTime = cellfun(@double, {spindles.spindleTime});
    spindleRate = 60*spindleHits/totalSeconds;

    %% Get the mean spindle length
    meanSpindleLen = spindleTime./spindleHits;
    meanSpindleLen(isnan(meanSpindleLen)) = 0;
    spindleCurves.spindleHits = spindleHits;
    spindleCurves.spindleTime = spindleTime;
    spindleCurves.spindleRate = spindleRate;
    spindleCurves.meanSpindleLen = meanSpindleLen;
    spindleCurves.thresholds = thresholds;
    %% Determine whether to display the results
    if isempty(outDir)
        return;
    elseif ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    %% Show the spindle length summary values
    theTitle = [params.name ' Average spindle length'];
    h1Fig = figure('Name', theTitle);
    plot(thresholds, meanSpindleLen);
    ylim = get(gca, 'YLim')
    ylim(1) = 0;
    set(gca, 'YLimMode', 'manual', 'YLim', ylim);
    xlabel('Threshold')
    ylabel('Average spindle length (s)');
    title(theTitle);
    box on
    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_AverageSpindleLength.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end

    %% Show the spindle length summary values
    theTitle = [params.name ' Spindle rate'];
    h2Fig = figure('Name', theTitle);
    plot(thresholds, spindleRate);
    xlabel('Threshold')
    ylabel('Spindles/min');
    title(theTitle);
    box on
    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h2Fig, [outDir filesep params.name '_SpindleRate.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end

end