%% This script calculates basic spindle stats for results files in a directory
% You must specify the results directory and the full path of stats file
%
%% Set up the directories for saving the stats
% resultsDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\VEP_PREP_ICA_VEP2_MARA\results\alpha';
% statsFile = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\stats\VEP_PREP_ICA_VEP2_MARA_alpha.mat';

% statsFile = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\stats\VEP_PREP_ICA_VEP2_MARA_theta.mat';
% imageDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\statImages';
% baseSuffix = 'MARA_theta';

statsFile = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\stats\VEP_PREP_ICA_VEP2_MARA_alpha.mat';
imageDir = 'D:\TestData\Alpha\spindleData\vep\resultsSpindler\statImages';
baseSuffix = 'alpha_MARA';
expName = 'vep';
%%
if ~exist(imageDir, 'dir')
    mkdir(imageDir);
end

%% Load the stats file
load(statsFile);

%% Get the spindle data files and initialize the structure
numFiles = length(spindleStats);


%% Plot distribution of spindle lengths on channels
allLabels = {};
allLengths = [];
allRates = [];
allFractions = [];
for k = 1:numFiles
   labels = {spindleStats(k).chanlocs.labels};
   allLabels = [allLabels; labels(:)]; %#ok<AGROW>
   theseLengths = spindleStats(k).spindleLength;
   allLengths = [allLengths; theseLengths(:)]; %#ok<AGROW>
   theseRates = spindleStats(k).spindleRate;
   allRates = [allRates; theseRates(:)]; %#ok<AGROW>
   theseFractions = spindleStats(k).spindleFraction;
   allFractions = [allFractions; theseFractions(:)]; %#ok<AGROW>
end

%% Plot the lengths using boxplots
sortedLabels = unique(allLabels);
theTitle = [expName '_' baseSuffix ': Spindle length'];
hFig = figure('Name', theTitle, 'Position', [100, 100, 1024, 420]);
boxplot(allLengths, allLabels, 'PlotStyle', 'compact', 'GroupOrder', sortedLabels)
title(theTitle, 'Interpreter', 'None');
ylabel('Spindle length (s)')
xlabel('Channel')
saveas(hFig, [imageDir filesep expName '_' baseSuffix '_Spindle_Length.png'], 'png');

%% Plot the spindle rates using boxplots
sortedLabels = unique(allLabels);
theTitle = [expName '_' baseSuffix ': Spindle rate'];
hFig = figure('Name', theTitle, 'Position', [100, 100, 1024, 420]);
boxplot(allRates, allLabels, 'PlotStyle', 'compact', 'GroupOrder', sortedLabels)
title(theTitle, 'Interpreter', 'None');
ylabel('Spindles/min')
xlabel('Channel')
saveas(hFig, [imageDir filesep expName '_' baseSuffix '_Spindle_Rate.png'], 'png');

%% Plot the spindle rates using boxplots
sortedLabels = unique(allLabels);
theTitle = [expName '_' baseSuffix ': Spindle fraction'];
hFig = figure('Name', theTitle, 'Position', [100, 100, 1024, 420]);
boxplot(allFractions, allLabels, 'PlotStyle', 'compact', 'GroupOrder', sortedLabels)
title(theTitle, 'Interpreter', 'None');
ylabel('Fraction time spindling')
xlabel('Channel')
saveas(hFig, [imageDir filesep expName '_' baseSuffix '_Spindle_Fraction.png'], 'png');

%
%% Plot the spindle length
for k = 1:numFiles
    [~, theName, ~] = fileparts(spindleStats(k).fileName);
    hfig = figure('Name', theName);
    topoplot(spindleStats(k).spindleLength, spindleStats(k).chanlocs, ...
        'maplimits', [0, 3], 'style', 'map', 'electrodes', 'on');
    c = colorbar;
    c.Label.String = 'Average spindle length (s)';
    title(theName, 'Interpreter', 'None');
    saveas(hfig, [imageDir filesep theName '_Length_' baseSuffix, '.png'], 'png')
end
close all
%% Plot the spindle fraction
for k = 1:numFiles
    [~, theName, ~] = fileparts(spindleStats(k).fileName);
    hfig = figure('Name', theName);
    topoplot(spindleStats(k).spindleFraction, spindleStats(k).chanlocs, ...
        'maplimits', [0, 0.5], 'style', 'map', 'electrodes', 'on');
    c = colorbar;
    c.Label.String = 'Fraction of time spindling';
    title(theName, 'Interpreter', 'None');
    saveas(hfig, [imageDir filesep theName '_Fraction_' baseSuffix, '.png'], 'png')
end
close all

%% Plot spindles per minute
for k = 1:numFiles
    [~, theName, ~] = fileparts(spindleStats(k).fileName);
    hfig = figure('Name', theName);
    topoplot(spindleStats(k).spindleRate, spindleStats(k).chanlocs, ...
        'maplimits', [0, 15], 'style', 'map', 'electrodes', 'on');
    c = colorbar;
    c.Label.String = 'Rate (spindles/min)';
    title(theName, 'Interpreter', 'None');
    saveas(hfig, [imageDir filesep theName '_Rate_' baseSuffix, '.png'], 'png')
end
close all