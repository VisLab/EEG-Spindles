%% Read the data
channels = 25;
dataPath = 'D:\Research\AlphaCharacterization\NewVersion\spindleTest\data';
EEGOrig = pop_loadset([dataPath filesep 'driving-data1.set']);
EEGOrig = pop_eegfiltnew(EEGOrig, 1, 30, 424, 0, [], 1);
EEGClean = pop_loadset([dataPath filesep 'driving-data1-ICA-ArtRemoved.set']);
EEGClean = pop_eegfiltnew(EEGClean, 1, 30, 424, 0, [], 1);
load ([dataPath filesep 'S1010_labels.mat']);
yCoord = 1;
theTitle = 'driving-data1 with expert annotation';
%% 
eventTimes = cellfun(@double, expert_events(:, 2:3))';
numberEvents = size(eventTimes, 1);
yCoords = repmat(yCoord, size(eventTimes));

EEGOrigData = EEGOrig.data(channels, :);
EEGOrigTimes = (0:size(EEGOrigData, 2) - 1)/EEGOrig.srate;
EEGCleanData = EEGClean.data(channels, :);
EEGCleanTimes = (0:size(EEGCleanData, 2) - 1)/EEGClean.srate;
theScale = max(max(abs(EEGCleanData)), max(abs(EEGOrigData)));
eventScale = theScale/max(yCoord);
figure
hold on
plot(EEGOrigTimes, EEGOrigData, 'k');
plot(EEGCleanTimes, EEGCleanData, 'g');
line(eventTimes, yCoords.*eventScale, 'LineWidth', 3, 'Color', [1, 0, 0]);
line(eventTimes, yCoords.*eventScale, 'LineWidth', 3, 'Color', [1, 0, 0]);
hold off
box on
xlabel('Seconds')
ylabel('uV')
title(theTitle)