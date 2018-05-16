sleepAlgs = {'Spindler', 'Cwt_a7', 'Cwt_a8', 'Sem'};
drivingAlgs = {'Spindler', 'Asd', 'Cwt_a7', 'Cwt_a8'};
drivingAlgsSupervised = {'Spindler', 'Sdar'};
drivingDirBase = {'D:\TestData\Alpha\spindleData\bcit\results'; ...
                  'D:\TestData\Alpha\spindleData\nctu\results'};
sleepDirBase = {'D:\TestData\Alpha\spindleData\dreams\results';
                'D:\TestData\Alpha\spindleData\massNew\results'};
%algColors = [0.8, 0.8, 0.2; 0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0];
algColors = [0.8, 0.8, 0.2; 0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0];
methodNames = {'count', 'hit', 'intersect', 'onset', 'time'};
metricNames = {'f1', 'f2', 'g', 'fdr'};
dreamsSets = 1:6;
% [drivingStatsSupervised, drivingNamesSupervised] = ...
%         getSummaryStatisticsSupervised(drivingDirBase, drivingAlgs, ...
%                                      methodNames, metricNames);
[drivingStats, drivingStatNames] = getSummaryStatistics(drivingDirBase, drivingAlgs);
[sleepStats, sleepStatNames] = getSummaryStatistics(sleepDirBase, sleepAlgs);
sleepStats = sleepStats(:, dreamsSets, :);

%% Plot the Driving statistics
baseIndex = 1;
otherIndices = 2;
for k = 1:length(drivingStatNames)
    theTitle = 'Alpha spindles';
    figHan = compareStatistic(drivingStats(:, :, k), baseIndex, otherIndices, ...
                drivingStatNames{k}, drivingAlgs, algColors, theTitle);
end

%% Plot sleep statistics
baseIndex = 1;
otherIndices = 2:5;
for k = 1:length(drivingStatNames)
    theTitle = 'Sleep spindles';
    figHan = compareStatistic(sleepStats(:, :, k), baseIndex, otherIndices, ...
                sleepStatNames{k}, sleepAlgs, algColors, theTitle);
end

%% Calculate the driving stats mean and std
drivingMean = squeeze(mean(drivingStats, 2));
drivingStd = squeeze(std(drivingStats, 0, 2));
sleepMean = squeeze(mean(sleepStats, 2));
sleepStd = squeeze(std(sleepStats, 0, 2));

%% Calculate the statistics with errorbars
dreamsInd = [1, 3, 4, 5]; 
drivingInd = 1:2;
theMeans = [drivingMean(drivingInd, :); sleepMean(dreamsInd, :)];
theStds = [drivingStd(drivingInd, :); sleepStd(dreamsInd, :)];
algColors = [0, 0, 0; 0.8, 0.8, 0.2; 0, 0, 0; ...
             0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0];
markers = {'o', 'o', 's', 's', 's', 's', 's'};
statNames = drivingStatNames;
legendStrings = {'Spindler(A)', 'ASD(A)', 'Spindler(S)', 'CWT-a7(S)', 'CWT-a8(S)', 'SEM-a6(S)'};
figure
for k = 1:3
    figure('Name', statNames{k})
    tMean = squeeze(theMeans(:, k));
    tStd = squeeze(theStds(:, k));
    hold on 
    for j = 1:length(tMean)
        errorbar(j, tMean(j), tStd(j), 's', 'MarkerSize', 12, ...
            'Marker', markers{j},  'Color', algColors(j, :), 'LineWidth', 3);
    end
    hold off
    xlabel('Algorithm(data type) combination')
    ylabel(['Mean ' statNames{k} ' (STD error bars)']);
    title(statNames{k});
    box on
    legend(legendStrings, 'Location', 'EastOutside');
end

%%
dreamsInd = [1, 3, 4, 5]; 
drivingInd = 1:2;
slabels = {'Spin-A', 'ASD-A', 'Spin-S', 'CWTa7-S', 'CWTa8-S', 'SEM-S'};
driveNums = repmat([1;2], 1, size(drivingStats, 2));
dreamsNums = repmat([3; 4; 5; 6], 1, size(sleepStats, 2));

drive = drivingStats(drivingInd, :, :);
dreams = sleepStats(dreamsInd, :, :);
statNames = drivingStatNames;
%legendStrings = {'Spindler(A)', 'ASD(A)', 'Spindler(S)', 'CWT-a7(S)', 'CWT-a8(S)', 'SEM-a6(S)'};
theColors = [0, 0, 0; 0, 0, 0; 0, 0.7, 0.9; 0, 0.7, 0.9; 0, 0.7, 0.9; 0, 0.7, 0.9];
figure
allnums = [driveNums(:); dreamsNums(:)];
for k = 1:3
    figure('Name', statNames{k})
    driveData = squeeze(drive(:, :, k));
    dreamsData = squeeze(dreams(:, :, k));
    data = [driveData(:); dreamsData(:)];
    h = boxplot(data, allnums, 'labels', slabels, 'Colors', theColors);
    for m = 1:7
        for j = 1:length(slabels)
           set(h(m, j), 'LineWidth', 1.2)
        end
    end
    for j = 1:length(slabels)
        set(h(5,j), 'MarkerFaceColor', [0.8, 0.8, 0.8]);
    end
    for j = 1:length(slabels)
        set(h(6, j), 'Color', 'r');
    end
    ylabel(statNames{k})
    xlabel('Algorithm-Data')
    box on
end