%% This script displays EEG data overlaid with expert events
%
% You must set up the following information (see examples below)
%   dataDir         path of directory containing EEG .set files to analyze
%   eventDir        directory of labeled event files
%   resultsDir      directory that Spindler uses to write its output
%   imageDir        directory that Spindler users to save images
%   summaryFile     full path name of the file containing the summary analysis
%   channelLabels   cell array containing possible channel labels
%                      (Spindler uses the first label that matches one in EEG)
%   paramsInit      structure containing the parameter values
%                   (if an empty structure, Spindler uses defaults)
%
% Spindler uses the input to run a batch analysis. If eventDir is not empty,
% Spindler runs performance comparisons, provided it can match file names for
% files in eventDir with those in dataDir.  Ideally, the event file names
% should have the data file names as prefixes, although Spindler tries more
% complicated matching strategies as well.  Event files contain "ground truth"
% in text files with two columns containing the start and end times in seconds.
%
%

eventColors = [0.8, 0, 0; 0, 0.9, 0; 0, 0, 0.9; 0.5, 0, 0.9; 0, 0, 0];

%% Example 1: Setup for driving data
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% % eventDirs = {'D:\TestData\Alpha\spindleData\bcit\events'; ...
% %              'D:\TestData\Alpha\spindleData\bcit\eventsAaronRerate'};
% eventDirs = {'D:\TestData\Alpha\spindleData\bcit\events2Col'};
% eventTypes = {'expert'};
%stageDir = [];
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerOverlays';
% channelLabels = {'PO7'};
% lowFreq = 6;
% highFreq = 13;
% baseBand = [1, 20];
% srateTarget = 128;
% segmentTime = 30;
% scaleFactor = 15;
% %figureFormats = {'png', 'fig'};
% figureFormats = {'png'};
%% Example 2: Setup for the NCTU labeled driving collection
dataDirs = {'D:\TestData\Alpha\spindleData\nctu\data'; ...
    'D:\TestData\Alpha\spindleData\nctu\dataCleaned'};
dataTypes = {'Original', 'Cleaned'};
stageDir = [];
eventDirs = {'D:\TestData\Alpha\spindleData\nctu\events2Col'};
imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerOverlayOut';
eventTypes = {'expert'};
channelLabels = {'P3'};
lowFreq = 6;
highFreq = 13;
segmentTime = 30;
baseBand = [1, 20];
srateTarget = 128;
figureFormats = {'png'};
scaleFactor = 15;

%% Example 3: Set up for the Dreams sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
%stageDir = [];
% eventDirs = {'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion'; ...
%              'D:\TestData\Alpha\spindleData\dreams\events\expert1'; ...
%              'D:\TestData\Alpha\spindleData\dreams\events\expert2'};
% eventTypes = {'Combined'; 'expert1'; 'expert2'};
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerOverlay';
% channelLabels = {'C3-A1', 'CZ-A1'};
% lowFreq = 10;
% highFreq = 17;
% segmentTime = 30;
% baseBand = [1, 20];
% srateTarget = 100;
% figureFormats = {'png', 'fig'};
% scaleFactor = 20;
%% Example 4: Set up for the MASS sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\massNew\data';
% eventDirs = {'D:\TestData\Alpha\spindleData\massNew\events\combinedUnion'; ...
%     'D:\TestData\Alpha\spindleData\massNew\events\expert1'; ...
%     'D:\TestData\Alpha\spindleData\massNew\events\expert2'};
% eventTypes = {'combined', 'expert1', 'expert2'};
% stageDir = 'D:\TestData\Alpha\spindleData\massNew\events\stage2Events';
% imageDir = 'D:\TestData\Alpha\spindleData\massNew\imagesEventOverlays';
% channelLabels = {'CZ'};
% lowFreq = 10;
% highFreq = 17;
% segmentTime = 30;
% baseBand = [1, 20];
% srateTarget = 128;
% figureFormats = {'png'};
% scaleFactor = 15;
%% Get the data and event file names and check that we have the same number
dataFiles = getFiles('FILES', dataDirs{1}, '.set');

%% Create the output directory if it doesn't exist
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    fprintf('Creating image directory %s \n', imageDir);
    mkdir(imageDir);
end

%% Process the data
for k = 1%:length(dataFiles)
    %% Get the results file with spindle information
    [~, theName, ~] = fileparts(dataFiles{k});
    
    %% Get the events
    startFrame = 1;
    endFrame = 0;
    stageFile = [stageDir filesep theName '.mat'];
    if ~isempty(stageDir) && exist(stageFile, 'file')
        test = load(stageFile);
        stageEvents = test.stage2Events;
        [~, maxInd] = max(stageEvents(:, 2) - stageEvents(:, 1));
        startFrame = 1 + floor(stageEvents(maxInd, 1)*srateTarget);
        endFrame = 1 + floor(stageEvents(maxInd, 2)*srateTarget);
    end
    baseTime = (startFrame - 1)./srateTarget;
    
    %% Make sure the image subdirectory exists
    thisImageDir = [imageDir filesep theName];
    mkdir(thisImageDir);
    
    %% Read in the EEG and find the correct channel number
    data = cell(length(dataDirs), 1);
    dataBand = cell(length(dataDirs), 1);
    maxValues = cell(length(dataDirs), 1);
    missingData = false;
    for m = 1:length(dataDirs)
        thisFile = [dataDirs{m} filesep theName '.set'];
        [thisdata, ~, ~, channelLabel] = ...
            getChannelData(thisFile, channelLabels, srateTarget);
        if isempty(thisdata)
            warning('No data found for %s\n', thisFile);
            missingData = true;
            break;
        end
        
        %% Also get a filtered signal to overlay
        thisDataBand = getFilteredData(thisdata, srateTarget, lowFreq, highFreq);
        if ~isempty(baseBand)
            thisData = getFilteredData(thisdata, srateTarget, baseBand(1), baseBand(2));
        end
        maxValues{m} = min(scaleFactor*mad(abs(thisData), 1), max(abs(thisData)));
        thisData(thisData > maxValues{m}) = maxValues{m};
        thisData(thisData < -maxValues{m}) = -maxValues{m};
        thisDataBand(thisDataBand > maxValues{m}) = maxValues{m};
        thisDataBand(thisDataBand < -maxValues{m}) = -maxValues{m};
        if endFrame == 0
            endFrame = length(thisData);
        end
        thisData = thisData(startFrame:endFrame);
        thisDataBand = thisDataBand(startFrame:endFrame);
        
        data{m} = thisdata;
        dataBand{m} = thisDataBand;
    end
    if missingData
        continue;
    end
    
    %% Make sure that the image directory exists
    thisImageDir = [imageDir filesep theName];
    if ~exist(thisImageDir, 'dir')
        fprintf('Creating image directory %s \n', thisImageDir);
        mkdir(thisImageDir);
    end
    
    %% Scale data
    totalTime = (length(data{1}) - 1)/srateTarget;
    startTime = (startFrame - 1)/srateTarget;
    
    %% Now get the events
    eventList = getSegmentedEvents(eventDirs, theName, eventTypes, ...
        startTime, segmentTime, totalTime);
    
    
    framesSegment = round(segmentTime*srateTarget);
    numSegments = floor(totalTime/segmentTime);
    startSegment = 1;
    for n = 1:numSegments
        endSegment = startSegment + framesSegment - 1;
        t = (startSegment:endSegment)';
        t = (t-1)/srateTarget + baseTime;
      
        theTitle = [theName ' channel ' channelLabel  ...
            ' Segment ' num2str(n) ...
            ' [' num2str(round(min(t))) ':' num2str(round(max(t))) '] sec' ...
            ' Frames [' num2str(startSegment) ':' num2str(endSegment) ']'];
        hFig1 = figure('Name', theTitle);
        for m = 1:length(dataDirs)
            theData = data{m}(startSegment:endSegment)';
            theBand = dataBand{m}(startSegment:endSegment)';
            subplot(length(dataDirs), 1, m);
            hold on
            plot(t, theData, 'Color', [0.8, 0.8, 0.8], 'LineWidth', 1);
            p1 = plot(t, theBand, 'k-');
            xlabel('time (s)')
            ylabel('Voltage');
            set(hFig1, 'Position', [300 500 1500 400]);
            xTicks = ceil(min(t)):floor(max(t));
            
            set(gca, 'YLimMode', 'manual', 'YLim', [-maxLimit, maxLimit]);
            set(gca, 'XLimMode', 'manual', 'XLim', [min(t), max(t)], ...
                'XTickMode', 'manual', 'XTick', xTicks);
            xTickLabels = cell(length(xTicks), 0);
            if xTicks(1) >= 10000.0
                for j = 1:length(xTicks)
                    if mod(j-1, 5) == 0
                        xTickLabels{j} = sprintf('%6.2f', xTicks(j));
                    else
                        xTickLabels{j} = '';
                    end
                end
                set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', xTickLabels);
            end
            grid on
            grid minor
            legendStrings = ...
                {['EEG [' num2str(baseBand(1)) ',' num2str(baseBand(2)), '] Hz'], ...
                ['EEG [' num2str(lowFreq) ',' num2str(highFreq), '] Hz']};
            
            %% Plot the first event in each group to outsmart the legend
            eventPositions = ((1:length(eventList))*0.05 + 1.1)*maxValues{m};
            maxLimit = ((length(eventList) + 2)* 0.05 + 1.1)*maxValues{m};
            for j = 1:length(eventList)
                if isempty(eventList(j).eventSegments)
                    continue;
                end
                thisList = eventList(j).eventSegments{n};
                if isempty(thisList)
                    continue;
                end
                line(thisList(1, :) + min(t), ...
                    [eventPositions(j), eventPositions(j)], ...
                    'Color', eventColors(j, :), 'LineWidth', 2);
                legendStrings{end + 1} = eventList(j).eventType; %#ok<*SAGROW>
            end
            for j = 1:length(eventList)
                if isempty(eventList(j).eventSegments)
                    continue;
                end
                thisList = eventList(j).eventSegments{n};
                if isempty(thisList)
                    continue;
                end
                for s = 2:size(thisList, 1)
                    line(thisList(s, :) + min(t), ...
                        [eventPositions(j), eventPositions(j)], ...
                        'Color', eventColors(j, :), 'LineWidth', 2);
                end
            end
            
            hleg = legend(legendStrings, 'Location', 'SouthEast');
            title(theTitle, 'Interpreter', 'None');
            hold off
            box on
        end
        startSegment = endSegment + 1;
        imageName = [thisImageDir filesep theName '_' num2str(n) ...
            '_' num2str(min(t)) 's_' num2str(max(t)) 's.'];
        for f = 1:length(figureFormats)
            saveas(hFig1, [imageName figureFormats{f}], figureFormats{f});
        end
        
        %close(hFig1);
        
    end
end
