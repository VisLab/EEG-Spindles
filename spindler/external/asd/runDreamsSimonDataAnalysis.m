%% Set up the files
dataDir = 'D:\TestData\Alpha\spindleData\dreams\level0';
eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';

%% Get the file names
numSubjects = 1;
outFiles = cell(numSubjects, 1);
eventFiles = cell(numSubjects, 1);
for subnum = 1:numSubjects
    outFiles{subnum}=[dataDir filesep 'excerpt' num2str(subnum) '.set'];
    eventFiles{subnum}=[eventDir filesep 'expert_events' num2str(subnum) '.mat'];
end;

doPerformance = true;
freqBounds = [10, 16];
atomScales = [0.125, 0.25, 0.5];
numberAtoms = 200;
freqInc = 1;
atomFrequencies = freqBounds(1):freqInc:freqBounds(2);



%% Load the data
numDatasets = length(outFiles);
eventList = cell(numDatasets, 1);
spindleList = cell(numDatasets, 1);
srateList = cell(numDatasets, 1);
frameList = cell(numDatasets,  1);
numAtomsList = cell(numDatasets, 1);
maxAtoms = 0;
for k = 1:length(outFiles)
    EEG = pop_loadset(outFiles{k});
    load(eventFiles{k});
    EEG=pop_resample(EEG,128);
    
    if k>6
        
        channelList = 3;
        
    else
        channelList=1;
        
    end
    [events, spindles]=newSimon(EEG, channelList, atomFrequencies, expert_events);

    %[events, spindles] = STAMP(EEG, channelList, numberAtoms, atomFrequencies, atomScales, expert_events);
    eventList{k} = events;
    spindleList{k} = spindles;
    srateList{k} = EEG.srate;
    frameList{k} = EEG.pnts;
    numAtomsList{k} = length(spindleList{k});
    maxAtoms = max(maxAtoms, length(spindleList{k}));
end

%% Show the spindle values for each dataset individually
legendStrings = cell(1, numDatasets);
for k = 1:numDatasets
    numberAtoms = length(spindleList{k});
    numberSpindles = cellfun(@double, {spindleList{k}.numberSpindles});
    spindleTime = cellfun(@double, {spindleList{k}.spindleTime});
    theFrames = (1:numberAtoms)';
    totalSeconds = frameList{k}./srateList{k};
    theFrames = theFrames./totalSeconds;
    numberSpindles = numberSpindles/totalSeconds;
    spindleTime = spindleTime/totalSeconds;
    [thePath, theName, theExt] = fileparts(outFiles{k});
    legendStrings{k} = theName;
    theTitle = [theName ': Spindles versus atoms'];
    figure('Name', theTitle)
    hold on
    ax = plotyy(theFrames, numberSpindles, theFrames, spindleTime);
    ylabel(ax(1), 'Number of spindles/second');
    ylabel(ax(2), 'Spindle time/second')
    xlabel(ax(1), 'Atoms/second')
    title(theTitle);
    hold off
end

%% Overplot the individual spindle times/second
theColors = jet(numDatasets);
theTitle = 'Spindle time/second';
figure('Name', theTitle)
hold on
for n = 1:numDatasets
    numberAtoms = length(spindleList{n});
    spindleTime = cellfun(@double, {spindleList{n}.spindleTime});
    theFrames = (1:numberAtoms)';
    totalSeconds = frameList{n}./srateList{n};
    theFrames = theFrames./totalSeconds;
    numberSpindles = numberSpindles/totalSeconds;
    spindleTime = spindleTime/totalSeconds;
    plot(theFrames, spindleTime, 'Color', theColors(n, :));
end
hold off
ylabel('Spindle time/second')
xlabel('Atoms/second')
title(theTitle);
legend(legendStrings, 'Location', 'SouthEast')

%% Overplot the individual spindles/second
theColors = jet(numDatasets);
theTitle = 'Spindles/second';
figure('Name', theTitle)
hold on
for n = 1:numDatasets
    numberAtoms = length(spindleList{n});
    numberSpindles = cellfun(@double, {spindleList{n}.numberSpindles});
    theFrames = (1:numberAtoms)';
    totalSeconds = frameList{n}./srateList{n};
    theFrames = theFrames./totalSeconds;
    numberSpindles = numberSpindles/totalSeconds;
    plot(theFrames, numberSpindles, 'Color', theColors(n, :));
end
hold off
ylabel('Spindles/second')
xlabel('Atoms/second')
title(theTitle);
legend(legendStrings, 'Location', 'SouthEast')
box on
%%
if doPerformance
    precision = zeros(numDatasets, maxAtoms, 2);
    recall = zeros(numDatasets, maxAtoms, 2);
    f1 = zeros(numDatasets, maxAtoms, 2);
    f1Mod = zeros(numDatasets, maxAtoms, 2);
    G = zeros(numDatasets, maxAtoms, 2);
    for n = 1:numDatasets
        theseSpindles = spindleList{n};
        for k = 1:numAtomsList{n}
            precision(n, k, 1) = theseSpindles(k).metricsTime.precision;
            precision(n, k, 2) = theseSpindles(k).metricsHits.precision;
            recall(n, k, 1) = theseSpindles(k).metricsTime.recall;
            recall(n, k, 2) = theseSpindles(k).metricsHits.recall;
            f1(n, k, 1) = theseSpindles(k).metricsTime.f1;
            f1(n, k, 2) = theseSpindles(k).metricsHits.f1;
            f1Mod(n, k, 1) = theseSpindles(k).metricsTime.f1Mod;
            f1Mod(n, k, 2) = theseSpindles(k).metricsHits.f1Mod;
            G(n, k, 1) = theseSpindles(k).metricsTime.G;
            G(n, k, 2) = theseSpindles(k).metricsHits.G;
        end
    end
    
    %% Plot performance of each dataset
    for n = 1:numDatasets
        numberAtoms = length(spindleList{n});
        theFrames = (1:numberAtoms)';
        totalSeconds = frameList{n}./srateList{n};
        theFrames = theFrames./totalSeconds;
        theTitle = [legendStrings{n}, ':performance'];
        figure('Name', theTitle)
        hold on
        plot(theFrames, precision(n, 1:numberAtoms, 1), 'k-', 'LineWidth', 2)
        plot(theFrames, precision(n, 1:numberAtoms, 2), 'k-.', 'LineWidth', 2)
        plot(theFrames, recall(n, 1:numberAtoms, 1), 'b-', 'LineWidth', 2)
        plot(theFrames, recall(n, 1:numberAtoms, 2), 'b-.', 'LineWidth', 2)
        plot(theFrames, f1(n, 1:numberAtoms, 1), 'r-', 'LineWidth', 2)
        plot(theFrames, f1(n, 1:numberAtoms, 2), 'r-.')
        plot(theFrames, f1Mod(n, 1:numberAtoms, 1), 'm-', 'LineWidth', 2)
        plot(theFrames, f1Mod(n, 1:numberAtoms, 2), 'm-.', 'LineWidth', 2)
        plot(theFrames, G(n, 1:numberAtoms, 1), 'g-', 'LineWidth', 2)
        plot(theFrames, G(n, 1:numberAtoms, 2), 'g-.', 'LineWidth', 2)
        xlabel('Atoms');
        ylabel('Performance')
        legend('Precision T', 'Precision H', 'Recall T', 'Recall H', ...
            'F1 T', 'F1 H', 'F1Mod T', 'F1Mod H', 'G T', 'G H', ...
            'Location', 'SouthEast');
        title(theTitle)
        hold off
        box on
    end
    
    %% Plot performance of each metric
    for n = 1:numDatasets
        numberAtoms = length(spindleList{n});
        numberSpindles = cellfun(@double, {spindleList{n}.numberSpindles});
        theFrames = (1:numberAtoms);
        totalSeconds = frameList{n}./srateList{n};
        theFrames = theFrames./totalSeconds;
        theTitle = [legendStrings{n}, ':performance'];
        figure('Name', theTitle)
        hold on
        plot(theFrames, precision(n, 1:numberAtoms, 1), 'k-')
        plot(theFrames, precision(n, 1:numberAtoms, 2), 'k-.')
        plot(theFrames, recall(n, 1:numberAtoms, 1), 'b-')
        plot(theFrames, recall(n, 1:numberAtoms, 2), 'b-.')
        plot(theFrames, f1(n, 1:numberAtoms, 1), 'r-')
        plot(theFrames, f1(n, 1:numberAtoms, 2), 'r-.')
        plot(theFrames, f1Mod(n, 1:numberAtoms, 1), 'm-')
        plot(theFrames, f1Mod(n, 1:numberAtoms, 2), 'm-.')
        plot(theFrames, G(n, 1:numberAtoms, 1), 'g-')
        plot(theFrames, G(n, 1:numberAtoms, 2), 'g-.')
        xlabel('Atoms/second');
        ylabel('Performance')
        legend('Precision T', 'Precision H', 'Recall T', 'Recall H', ...
            'F1 T', 'F1 H', 'F1Mod T', 'F1Mod H', 'G T', 'G H', ...
            'Location', 'SouthEast');
        title(theTitle)
        hold off
        box on
    end
    
    %% Plot performance of each metric
    legendStringsExp = cell(1, 2*numDatasets);
    theTitle = 'Precision - recall spindle time/second';
    figure('Name', theTitle)
    hold on
    for n = 1:numDatasets
        numberAtoms = length(spindleList{n});
        theFrames = (1:numberAtoms)';
        totalSeconds = frameList{n}./srateList{n};
        theFrames = theFrames./totalSeconds;
        legendStringsExp{2*n - 1} = [legendStrings{n} ':p'];
        legendStringsExp{2*n} = [legendStrings{n} ':r'];
        plot(theFrames, precision(n, 1:numberAtoms, 1), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-')
        plot(theFrames, recall(n, 1:numberAtoms, 1), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-.')
    end
    xlabel('Atoms/second');
    ylabel('Performance')
    legend(legendStringsExp, 'Location', 'East')
    title(theTitle)
    hold off
    box on
    
    %% Precision-recall hits/second
    legendStringsExp = cell(1, 2*numDatasets);
    theTitle = 'Precision - recall spindle hits/second';
    figure('Name', theTitle)
    hold on
    for n = 1:numDatasets
        numberAtoms = length(spindleList{n});
        theFrames = (1:numberAtoms)';
        totalSeconds = frameList{n}./srateList{n};
        theFrames = theFrames./totalSeconds;
        legendStringsExp{2*n - 1} = [legendStrings{n} ':p'];
        legendStringsExp{2*n} = [legendStrings{n} ':r'];
        plot(theFrames, precision(n, 1:numberAtoms, 2), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-')
        plot(theFrames, recall(n, 1:numberAtoms, 2), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-.')
    end
    xlabel('Atoms/second');
    ylabel('Performance')
    legend(legendStringsExp, 'Location', 'East')
    title(theTitle)
    hold off
    box on
    
    %% F1
    legendStringsExp = cell(1, 2*numDatasets);
    theTitle = 'F1 time versus hits';
    figure('Name', theTitle)
    hold on
    for n = 1:numDatasets
        numberAtoms = length(spindleList{n});
        theFrames = (1:numberAtoms)';
        totalSeconds = frameList{n}./srateList{n};
        theFrames = theFrames./totalSeconds;
        legendStringsExp{2*n - 1} = [legendStrings{n} ':T'];
        legendStringsExp{2*n} = [legendStrings{n} ':H'];
        plot(theFrames, f1(n, 1:numberAtoms, 1), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-')
        plot(theFrames, f1(n, 1:numberAtoms, 2), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-.')
    end
    xlabel('Atoms/second');
    ylabel('Performance')
    legend(legendStringsExp, 'Location', 'NorthEast')
    title(theTitle)
    hold off
    box on
    
    %% F1 - Mod
    legendStringsExp = cell(1, 2*numDatasets);
    theTitle = 'F1 (beta = 2) time versus hits';
    figure('Name', theTitle)
    hold on
    for n = 1:numDatasets
        numberAtoms = length(spindleList{n});
        theFrames = (1:numberAtoms)';
        totalSeconds = frameList{n}./srateList{n};
        theFrames = theFrames./totalSeconds;
        legendStringsExp{2*n - 1} = [legendStrings{n} ':T'];
        legendStringsExp{2*n} = [legendStrings{n} ':H'];
        plot(theFrames, f1Mod(n, 1:numberAtoms, 1), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-')
        plot(theFrames, f1Mod(n, 1:numberAtoms, 2), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-.')
    end
    xlabel('Atoms/second');
    ylabel('Performance')
    legend(legendStringsExp, 'Location', 'NorthEast')
    title(theTitle)
    hold off
    box on
    
    %% G
    legendStringsExp = cell(1, 2*numDatasets);
    theTitle = 'G time versus hits';
    figure('Name', theTitle)
    hold on
    for n = 1:numDatasets
        numberAtoms = length(spindleList{n});
        theFrames = (1:numberAtoms)';
        totalSeconds = frameList{n}./srateList{n};
        theFrames = theFrames./totalSeconds;
        legendStringsExp{2*n - 1} = [legendStrings{n} ':T'];
        legendStringsExp{2*n} = [legendStrings{n} ':H'];
        plot(theFrames, G(n, 1:numberAtoms, 1), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-')
        plot(theFrames, G(n, 1:numberAtoms, 2), ...
            'Color', theColors(n, :), 'LineWidth', 2, 'LineStyle', '-.')
    end
    xlabel('Atoms/second');
    ylabel('Performance')
    legend(legendStringsExp, 'Location', 'NorthEast')
    title(theTitle)
    hold off
    box on
    
    
end

%save('dreamsSimon.mat','spindleList');