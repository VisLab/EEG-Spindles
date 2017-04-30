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
warningMsgs = {};
spindleCurves = struct('name', NaN, ...
             'atomsPerSecond', NaN, 'bestAtomsPerSecond', NaN, ....
             'baseThresholds', NaN, 'bestLinearInd', NaN, ...
             'bestThreshold', NaN, 'bestThresholdInd', NaN, ...
              'atomRange', NaN, 'atomRangeInd', NaN,...
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

%% Get the standard deviations and slopes
spindleRateSTD = std(spindleRate, 0, 2);
stdRateMax = max(spindleRateSTD(:));
diffSTD = diff(spindleRateSTD);
upperAtomInd = find(spindleRateSTD > stdRateMax*stdLimits(2), 1, 'first');
if isempty(upperAtomInd)
    upperAtomInd = numAtoms;
end
lowerAtomInd = find(spindleRateSTD > stdRateMax*stdLimits(1), 1, 'first');
if isempty(lowerAtomInd) || isempty(upperAtomInd) || lowerAtomInd >= upperAtomInd
    warningMsgs{end + 1} = ...
         ['Spindles/sec has non standard behavior for low ' ...
         'atoms/sec --- algorithm have have failed, likely because of large artifacts'];
    warning('getSpinderCurves:BadSpindleSTD', warningMsgs{end});
end

%% If the STD is not an increasing function of atoms/sec, decomposition bad
if sum(diffSTD(upperAtomInd:end) < 0) > 0
    warningMsgs{end + 1} =   ['STD spindles/sec not montonic function of atoms/sec ' ...
         '--- algorithm may have failed, likely because of large artifacts'];
    warning('spindlerGetParameterCurves:SpindleSTDNotMonotonic',  warningMsgs{end});
  
end
lowerAtomInd = max(1, lowerAtomInd - 1);
atomRangeInd = [lowerAtomInd, upperAtomInd];
upperAtomRange = atomsPerSecond(upperAtomInd);
lowerAtomRange = atomsPerSecond(lowerAtomInd);

%% Get the ratios and scaled ratios
xTHRatio = spindleTime./spindleHits;
xTHRatio(isnan(xTHRatio)) = 0;
xTHRatioMean = (xTHRatio(:, minThresholdInd) + xTHRatio(:, maxThresholdInd))/2;
xTHRatioDiv = 1./xTHRatioMean;
xTHRatioDiv(isnan(xTHRatioDiv)) = 0;
xTHRatioScaled = bsxfun(@times, xTHRatio, xTHRatioDiv);

%% Find the threshold whose scaled ratio is closed to the central ratio
averL1THDist = mean(abs(xTHRatioScaled(atomRangeInd(1):atomRangeInd(2), :) - 1));
[~, bestThresholdInd] = min(averL1THDist);
bestThreshold = baseThresholds(bestThresholdInd);
[~, mInd] = findFirstMin(xTHRatio(atomRangeInd(1):atomRangeInd(2), bestThresholdInd));
if isempty(mInd)
    [~, mInd] = min(xTHRatio(atomRangeInd(1):atomRangeInd(2), bestThresholdInd));
end
bestAtomInd = mInd + lowerAtomInd - 1;
bestAtomsPerSecond = atomsPerSecond(bestAtomInd);

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
[~, eFractMaxInd] = max(eFractionBest(atomRangeInd(1):atomRangeInd(2)));
eFractMaxInd = eFractMaxInd + lowerAtomInd - 1;

%%
sRateMean = (spindleRate(:,  minThresholdInd) + spindleRate(:, maxThresholdInd))/2;

%% Now save the calculated spindle parameters
spindleCurves.name = theName;
spindleCurves.atomsPerSecond = atomsPerSecond;
spindleCurves.bestAtomsPerSecond = bestAtomsPerSecond;
spindleCurves.baseThresholds = baseThresholds;
spindleCurves.bestThreshold = bestThreshold;
spindleCurves.bestThresholdInd = bestThresholdInd;
spindleCurves.atomRangeInd = atomRangeInd;
spindleCurves.atomRange = [lowerAtomRange, upperAtomRange];
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
       ['STD range: [' num2str(lowerAtomRange) ',' ...
       num2str(upperAtomRange) '] ' ...
       'Energy max at: ' num2str(atomsPerSecond(eFractMaxInd)) ...
       ' Best index at: ' num2str(atomsPerSecond(bestAtomInd)) ...
       ' Closest threshold: ' num2str(baseThresholds(bestThresholdInd))]};
h1Fig = figure('Name', baseTitle);
hold on
[ax, h1, h2] = plotyy(atomsPerSecond, xTHRatio(:, bestThresholdInd), atomsPerSecond, spindleRateSTD);
theColor = get(h1, 'Color');
set(h1, 'Color', [0, 0, 0]);
plot(ax(1), atomsPerSecond, xTHRatioMean, ...
         'LineWidth', 3, 'Color', theColor, 'LineStyle', '-');
plot(ax(1), atomsPerSecond, xTHRatio(:, minThresholdInd), ...
         'LineWidth', 2, 'Color', theColor, 'LineStyle', '--');
plot(ax(1), atomsPerSecond, xTHRatio(:, maxThresholdInd), ...
         'LineWidth', 2, 'Color', theColor, 'LineStyle', ':');

set(h1, 'LineWidth', 3);
set(h2, 'LineWidth', 3);
plot(ax(1), atomsPerSecond, eFractionBest, 'LineWidth', 3, 'Color', [0.1, 0.6, 0.1]);
allLegends = [legendStrings, 'Energy Fract'];
legend(ax(1), allLegends, 'Location', 'NorthWest');
xLimits = get(ax(1), 'XLim');
line(ax(1), xLimits, [0, 0], 'Color', [0, 0, 0]);
set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto')
yLimits = get(ax(1), 'YLim');

ePos = atomsPerSecond(bestAtomInd);
line(ax(1), [ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);

line(ax(1), [lowerAtomRange, upperAtomRange], [-0.1, -0.1], ...
    'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
set(ax(1), 'YLim', [0, yLimits(2)]);
yLimits = get(ax(2), 'YLim');
line(ax(2), [lowerAtomRange, upperAtomRange], [0.1, 0.1]*yLimits(2), ...
    'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
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
  saveas(h1Fig, [outDir filesep theName '_Params_AverageSpindleLength.' ...
      thisFormat], thisFormat);
end
if params.figureClose
    close(h1Fig);
end

%% Spindles/min as a function of threshold
baseTitle = [theName ': Spindles/min vs atoms/sec as a function of threshold'];
theTitle = {baseTitle; ...    
           ['STD range: [' num2str(lowerAtomRange) ',' num2str(upperAtomRange) '] ' ]};           
h2Fig = figure('Name', baseTitle);
hold on
[ax, h1, h2] = plotyy(atomsPerSecond, spindleRate(:, bestThresholdInd), ...
                     atomsPerSecond, spindleRateSTD);
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
set(h2, 'LineWidth', 3);
ylabel(ax(1), 'Spindles/min');
ylabel(ax(2), 'STD spindles/min wrt threshold');
set(ax(1), 'YLimMode', 'auto', 'YTickMode', 'auto');
yLimits = get(ax(1), 'YLim');
line(ax(1), [ePos, ePos], yLimits, 'Color', [0.8, 0.8, 0.8]);

yLimits = get(ax(2), 'YLim');
line(ax(2), [lowerAtomRange, upperAtomRange], [0.1, 0.1]*yLimits(2), ...
    'LineWidth', 4, 'Color', [0.8, 0.8, 0.8]);
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
