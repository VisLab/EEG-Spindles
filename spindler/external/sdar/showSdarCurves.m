function [] = showSdarCurves(spindles, outDir, params)
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
defaults = concatenateStructs(getGeneralDefaults(), getSpindlerDefaults());         
params = processParameters('getSdarCurves', nargin, 2, params, defaults);
baseThresholds = params.sdarBaseThresholds;
totalSeconds = params.frames./params.srate;
theName = params.name;

%% Get the spindle hits and spindle times
spindleHits = cellfun(@double, {spindles.numberSpindles});
spindleTime = cellfun(@double, {spindles.spindleTime});
spindleHits = spindleHits/totalSeconds;
spindleTime = spindleTime/totalSeconds;

xTHRatio = spindleTime./spindleHits;
xTHRatio(isnan(xTHRatio)) = 0;
%xTHRatio = min(xTHRatio, 3);

thresholdFraction = baseThresholds/max(baseThresholds);
baseTitle = [theName ':Average spindle length vs threshold'];
h1Fig = figure('Name', baseTitle);
hold on
[ax, h1, h2] = plotyy(thresholdFraction, xTHRatio, thresholdFraction, spindleHits);                     
set(h1, 'LineWidth', 2);
set(h2, 'LineWidth', 2);
set(ax(1), 'XLim', [0, 1], 'XLimMode', 'manual');
set(ax(2), 'XLim', [0, 1], 'XLimMode', 'manual');

ylabel(ax(1), 'Average spindle length (sec)');
ylabel(ax(2), 'Spindles/sec');
xlabel(ax(1), 'Threshold fractions');
xlabel(ax(2), '');
box(ax(1), 'on')
box(ax(2), 'on')
hold off
title(baseTitle, 'Interpreter', 'None');
for k = 1:length(params.figureFormats)
  thisFormat = params.figureFormats{k};
  saveas(h1Fig, [outDir filesep theName '_Params_AverageSpindleLength.' ...
      thisFormat], thisFormat);
end
if params.figureClose
    close(h1Fig);
end

