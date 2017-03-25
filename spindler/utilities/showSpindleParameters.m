function [] = showSpindleParameters(spindles, totalSeconds, theName,  outDir)
%% Show behavior of spindle counts as a function of threshold and atoms/sec 
%
%  Parameters
%


%% Get the atoms per second and thresholds
atomsPerSecond = unique(cellfun(@double, {spindles.atomsPerSecond}))';
baseThresholds = unique(cellfun(@double, {spindles.baseThreshold}));
numAtoms = length(atomsPerSecond);
numThresholds = length(baseThresholds);
[~, minThreshInd] = min(baseThresholds);
[~, maxThreshInd] = max(baseThresholds);

%% Get the spindle hits and spindle times
spindleHits = cellfun(@double, {spindles.numberSpindles});
spindleHits = reshape(spindleHits, numAtoms, numThresholds);
spindleTime = cellfun(@double, {spindles.spindleTime});
spindleTime = reshape(spindleTime, numAtoms, numThresholds);
spindleHits = spindleHits/totalSeconds;
spindleTime = spindleTime/totalSeconds;

%% Get the standard deviations and slopes
spindleSTD = std(spindleHits, 0, 2);
stdMax = max(spindleSTD(:));
spindleSTD = spindleSTD./stdMax;
spindleSTD(isnan(spindleSTD)) = 0;
diffSTD = diff(spindleSTD)./diff(atomsPerSecond);
diffSTDMax = max(abs(diffSTD(:)));
diffSTD = diffSTD./diffSTDMax;
diffSTD(isnan(diffSTD)) = 0;
diffAtoms = (atomsPerSecond(1:end-1) + atomsPerSecond(2:end))/2;
[~, stdDMinInd] = min(diffSTD);
stdDMinPos = diffAtoms(stdDMinInd);

%% Get the ratios and scaled ratios
xTHRatio = spindleTime./spindleHits;
xTHRatio(isnan(xTHRatio)) = 0;
xTHRatioMean = (xTHRatio(:, minThreshInd) + xTHRatio(:, maxThreshInd))/2;
[xTHRatioMeanMin, xTHRatioMeanInd] = min(xTHRatioMean);
xTHRatioMeanMinPos = atomsPerSecond(xTHRatioMeanInd);
xTHRatioDiv = 1./xTHRatioMean;
xTHRatioDiv(isnan(xTHRatioDiv)) = 0;
xTHRatioScaled = bsxfun(@times, xTHRatio, xTHRatioDiv);
averL1THDist = mean(abs(xTHRatioScaled - 1));
[~, minTHRatioDistInd] = min(averL1THDist);

% xHTRatio = spindleHits./spindleTime;
% xHTRatio(isnan(xHTRatio)) = 0;
% xHTRatioMean = (xHTRatio(:, minThreshInd) + xHTRatio(:, maxThreshInd))/2;
% [xHTRatioMeanMax, xHTRatioMeanInd] = max(xHTRatioMean);
% xHTRatioMeanMaxPos = atomsPerSecond(xHTRatioMeanInd);
% xHTRatioDiv = 1./xHTRatioMean;
% xHTRatioDiv(isnan(xHTRatioDiv)) = 0;
% xHTRatioScaled = bsxfun(@times, xHTRatio, xHTRatioDiv);
% averL1HTDist = mean(abs(xHTRatioScaled - 1));
% [~, minHTRatioDistInd] = min(averL1HTDist);

eFraction = cellfun(@double, {spindles.eFraction});
eFraction = reshape(eFraction, numAtoms, numThresholds);
eFractAverage = (eFraction(:, minThreshInd) + eFraction(:, maxThreshInd))/2;

%% Show the spindle values for each dataset individually
theColors = jet(numThresholds);

%% Spindle time/spindle hits versus atoms/second
legends = cell(size(baseThresholds));
for k = 1:numThresholds
    legends{k} = [num2str(baseThresholds(k)) ':' num2str(averL1THDist(k))];
end
theTitle = {'Spindle time/spindle hits vs atoms/second'; theName; ...    
       ['MeanMin=' num2str(xTHRatioMeanMin) ' at ' ...
       num2str(xTHRatioMeanMinPos) ...
       ', STDMinPos at ' num2str(stdDMinPos) ...
       ', best threshold=' num2str(baseThresholds(minTHRatioDistInd))]};
h1 = figure('Name', [theName ':Spindle time/spindle hits vs atoms/second']);
hold on
for j = 1:numThresholds
   plot(atomsPerSecond, xTHRatio(:, j), 'LineWidth', 2, 'Color', theColors(j, :));
end

plot(atomsPerSecond, xTHRatioMean, 'LineWidth', 3, 'Color', [0, 0, 0]);
plot(atomsPerSecond, spindleSTD, 'LineWidth', 2, 'Color', [0.6, 0.6, 0.6]);
plot(diffAtoms, diffSTD, 'LineWidth', 2, 'Color', [0.8, 0.8, 0.8]);

summaryLegends = {'Mean', 'SpindleSTD', 'STDSlope'};
allLegends = [legends, summaryLegends];
legend(allLegends);
xLimits = get(gca, 'XLim');
line(xLimits, [0, 0], 'Color', [0, 0, 0]);
yLimits = get(gca, 'YLim');

line([xTHRatioMeanMinPos, xTHRatioMeanMinPos], yLimits, 'Color', [0, 0, 0]);
line([stdDMinPos, stdDMinPos], yLimits, 'Color', [0.8, 0.8, 0.8]);
ylabel('Spindle time/spindle hits');
xlabel('Atoms/second');
box on
hold off
title(theTitle, 'Interpreter', 'None');
saveas(h1, [outDir filesep theName '_Params_SpindleTimeDivHits.png'], 'png');  

%% Scaled TH ratio spindle time/spindle hits versus atoms/second
legends = cell(size(baseThresholds));
for k = 1:numThresholds
    legends{k} = [num2str(baseThresholds(k)) ':' num2str(averL1THDist(k))];
end
theTitle = {'Spindle Scaled time/spindle hits vs atoms/second'; ...
             theName; ...
            ['MeanMin=' num2str(xTHRatioMeanMin) ' at ' num2str(xTHRatioMeanMinPos) ...
             ', STDMinPos at ' num2str(stdDMinPos)]};
h2 = figure('Name', [theName ':Spindle time/spindle hits vs atoms/second']);
hold on
for j = 1:numThresholds
   plot(atomsPerSecond, xTHRatioScaled(:, j), 'LineWidth', 2, 'Color', theColors(j, :));
end

plot(atomsPerSecond, ones(size(atomsPerSecond)), 'LineWidth', 3, 'Color', [0, 0, 0]);
plot(atomsPerSecond, spindleSTD, 'LineWidth', 2, 'Color', [0.6, 0.6, 0.6]);
plot(diffAtoms, diffSTD, 'LineWidth', 2, 'Color', [0.8, 0.8, 0.8]);

summaryLegends = {'Mean', 'SpindleSTD', 'STDSlope'};
allLegends = [legends, summaryLegends];
legend(allLegends);
xLimits = get(gca, 'XLim');
line(xLimits, [0, 0], 'Color', [0, 0, 0]);
yLimits = get(gca, 'YLim');

line([xTHRatioMeanMinPos, xTHRatioMeanMinPos], yLimits, 'Color', [0, 0, 0]);
line([stdDMinPos, stdDMinPos], yLimits, 'Color', [0.8, 0.8, 0.8]);
ylabel('Spindle time/spindle hits');
xlabel('Atoms/second');
box on
hold off
title(theTitle, 'Interpreter', 'None');
saveas(h2, [outDir filesep theName '_Params_SpindleTimeDivHitsScaled.png'], 'png');  


%% Fraction of energy captures
theTitle = [theName ': Fraction of energy in spindles'];
legends = cell(size(baseThresholds));
for k = 1:numThresholds
    legends{k} = num2str(baseThresholds(k));
end
h3 = figure('Name', theTitle);
hold on
for j = 1:numThresholds
    plot(atomsPerSecond, eFraction(:, j), 'LineWidth', 2, ...
        'Color', theColors(j, :));
end
plot(atomsPerSecond, eFractAverage, 'LineWidth', 2, 'Color', [0, 0, 0]);
hold off
ylabel('Fraction of energy')
xlabel('Atoms/second')
title(theTitle, 'Interpreter', 'None');
legend(legends, 'Location', 'NorthEast');
box on;
saveas(h3, [outDir filesep theName '_Params_SpindleFraction.png'], 'png');
    

%% Plot hits/second vs atoms/second

    legends = cell(size(baseThresholds));
    for k = 1:numThresholds
        legends{k} = num2str(baseThresholds(k));
    end
    theTitle = [theName ': Spindle hits/second vs atoms/second'];
    h4 = figure('Name', theTitle);
    hold on
    for j = 1:numThresholds
        plot(atomsPerSecond, spindleHits(:, j), 'LineWidth', 2, ...
            'Color', theColors(j, :));
    end
    hold off
    ylabel('Spindles/second')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    legend(legends, 'Location', 'NorthWest');
    box on;
    saveas(h4, [outDir filesep theName '_Params_SpindleHits.png'], 'png');


%% Spindle hits STD vs atoms/second
    spindleSTD = std(spindleHits, 0, 2);
    diffSTD = diff(spindleSTD);
    diffAtoms = (atomsPerSecond(1:end-1) + atomsPerSecond(2:end))/2;
    theTitle = [theName ': STD spindleHits'];
    h5 = figure('Name', theTitle);
    [ax, fh1, fh2] = plotyy(atomsPerSecond, spindleSTD, diffAtoms, diffSTD);
    set(fh1, 'LineWidth', 2)
    set(fh2, 'LineWidth', 2)
    ylabel(ax(1), 'STD spindle hits/second')
    xlabel(ax(1), 'Atoms/second')
    xlabel(ax(2), '');
    ylabel(ax(2), 'Diff STD spindle hits/second');
    title(theTitle, 'Interpreter', 'None');
    box on;
    saveas(h5, [outDir filesep theName '_Params_SpindleSTD.png'], 'png');