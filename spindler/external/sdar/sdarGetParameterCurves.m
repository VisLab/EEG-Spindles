function spindleCurves = sdarGetParameterCurves(spindles, outDir, params)

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
    defaults = concatenateStructs(getGeneralDefaults(), sdarGetDefaults());
    params = processParameters('sdarGetParameterCurves', nargin, 3, params, defaults);
    baseThresholds = cellfun(@double, {spindles.baseThresholds});
    totalSeconds = params.frames./params.srate;
    theName = params.name;

    %% Get the spindle hits and spindle times
    spindleHits = cellfun(@double, {spindles.numberSpindles});
    spindleTime = cellfun(@double, {spindles.spindleTime});
    spindleRate = 60*spindleHits/totalSeconds;
    meanSpindleLength = spindleTime./spindleHits;
    meanSpindleLength(isnan(meanSpindleLength)) = 0;
    thresholdFraction = baseThresholds/max(baseThresholds);
    spindleCurves.thresholds = baseThresholds;
    spindleCurves.spindleHits = spindleHits;
    spindleCurves.spindleTime = spindleTime;
    spindleCurves.spindleRate = spindleRate;
    spindleCurves.meanSpindleLength = meanSpindleLength;
    spindleCurves.thresholds = baseThresholds;

    %% Determine whether to display the results
    if isempty(outDir)
        return;
    elseif ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    %% Plot the average spindle length
    baseTitle = [theName ':Average spindle length vs threshold'];
    h1Fig = figure('Name', baseTitle);
    meanSpindleLength(meanSpindleLength > 3) = 3.0;
    hold on
    plot(thresholdFraction, meanSpindleLength, 'LineWidth', 2);
    set(gca, 'XLim', [0, 1], 'XLimMode', 'manual');
    
    ylabel('Average spindle length (sec)');
    xlabel('Threshold fraction');
    box on
    hold off
    title(baseTitle, 'Interpreter', 'None');

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h1Fig, [outDir filesep params.name '_SpindleLength.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h1Fig);
    end

    %% Plot the spindle rate
    %% Plot the average spindle length
    baseTitle = [theName ':Spindles/min'];
    h2Fig = figure('Name', baseTitle);
    hold on
    plot(thresholdFraction, spindleRate, 'LineWidth', 2);
    set(gca, 'XLim', [0, 1], 'XLimMode', 'manual');

    ylabel('Spindles/min');
    xlabel('Threshold fraction');
    box on
    hold off
    title(baseTitle, 'Interpreter', 'None');

    for k = 1:length(params.figureFormats)
        thisFormat = params.figureFormats{k};
        saveas(h2Fig, [outDir filesep params.name '_SpindleRate.' ...
            thisFormat], thisFormat);
    end
    if params.figureClose
        close(h2Fig);
    end
