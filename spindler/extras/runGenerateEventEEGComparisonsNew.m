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
dataDir = 'D:\TestData\Alpha\spindleData\bcit\dataMara';
eventDirs = {'D:\TestData\Alpha\spindleData\bcit\events'; ...
             'D:\TestData\Alpha\spindleData\bcit\eventsScottRerate'; ...
             'D:\TestData\Alpha\spindleData\bcit\eventsAaronRerate'};
%eventDirs = {'D:\TestData\Alpha\spindleData\bcit\events2Col'};
eventTypes = {'original', 'scott', 'aaron'};
stageDir = [];
imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerOverlaysMaraNew';
%imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerOverlays';
channelLabels = {'PO7'};
lowFreq = 6;
highFreq = 13;
baseBand = [1, 20];
srateTarget = 128;
segmentTime = 30;
scaleFactor = 15;
figureFormats = {'png', 'fig'};
%dataType = 'Mara cleaned ';
dataType = '';
%% Example 2: Setup for the NCTU labeled driving collection
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\dataMara';
% %eventDirs = {'D:\TestData\Alpha\spindleData\nctu\events2Col'};
% eventDirs = {};
% %imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerOverlayMaraCleaned';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerOverlayMaraCleanedNoEvents';
% %eventTypes = {'expert'};
% eventTypes = {};
% %dataType = 'Mara cleaned';
% dataType = 'Mara cleaned no events';
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\dataMara';
% stageDir = [];
% %eventDirs = {'D:\TestData\Alpha\spindleData\nctu\events2Col'};
% eventDirs = {};
% %imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerOverlayMaraCleaned';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerOverlayMaraCleanedNoEvents';
% %eventTypes = {'expert'};
% eventTypes = {};
% %dataType = 'Mara cleaned';
% dataType = 'Mara cleaned no events';

% dataDir = 'D:\TestData\Alpha\spindleData\nctu\dataMara';
% eventDirs = {'D:\TestData\Alpha\spindleData\nctu\events2Col'; ...
%              'D:\TestData\Alpha\spindleData\nctu\eventsJohnReratedMAT'};
% eventTypes = {'John original', 'John rerate'};
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerOverlayMaraCleanedJohnRerated';
% dataType = 'Mara cleaned';

% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDirs = {'D:\TestData\Alpha\spindleData\nctu\events2Col'; ...
%              'D:\TestData\Alpha\spindleData\nctu\eventsJohnReratedMAT'};
% eventTypes = {'John original', 'John rerate'};
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerOverlayJohnRerated';
% dataType = 'Mara cleaned';
% 
% stageDir = [];
% channelLabels = {'P3'};
% lowFreq = 6;
% highFreq = 13;
% segmentTime = 30;
% baseBand = [1, 20];
% srateTarget = 128;
% figureFormats = {'png', 'fig'};
% scaleFactor = 15;

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
dataFiles = getFiles('FILES', dataDir, '.set');

%% Create the output directory if it doesn't exist
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    fprintf('Creating image directory %s \n', imageDir);
    mkdir(imageDir);
end

%% Process the data
for k = 1%:length(dataFiles)
    %% Get the results file with spindle information
    [~, theName, ~] = fileparts(dataFiles{k});
    
    %% Make sure the image subdirectory exists
    thisImageDir = [imageDir filesep theName];
    mkdir(thisImageDir);
    
    %% Read in the EEG and find the correct channel number
    [data, srateOriginal, channelNumber, channelLabel] = ...
        getChannelData(dataFiles{k}, channelLabels, srateTarget);
    if isempty(data)
        warning('No data found for %s\n', dataFiles{k});
        continue;
    end
    
    %% Also get a filtered signal to overlay
    dataBand = getFilteredData(data, srateTarget, lowFreq, highFreq);
    if ~isempty(baseBand)
        data = getFilteredData(data, srateTarget, baseBand(1), baseBand(2));
    end
    
    %% Make sure that the image directory exists
    thisImageDir = [imageDir filesep theName];
    if ~exist(thisImageDir, 'dir')
        fprintf('Creating image directory %s \n', thisImageDir);
        mkdir(thisImageDir);
    end
    
    %% Now determine the start and end of the data
    startFrame = 1;
    endFrame = length(data);
    stageFile = [stageDir filesep theName '.mat'];
    if ~isempty(stageDir) && exist(stageFile, 'file')
        test = load(stageFile);
        stageEvents = test.stage2Events;
        [~, maxInd] = max(stageEvents(:, 2) - stageEvents(:, 1));
        startFrame = 1 + floor(stageEvents(maxInd, 1)*srateTarget);
        endFrame = 1 + floor(stageEvents(maxInd, 2)*srateTarget);
    end
    
    %% Set up the plots
    baseTime = (startFrame - 1)./srateTarget;
    data = data(startFrame:endFrame);
    dataBand = dataBand(startFrame:endFrame);
    
    %% Scale data
    maxValue = min(scaleFactor*mad(abs(data), 1), max(abs(data)));
    data(data > maxValue) = maxValue;
    data(data < -maxValue) = -maxValue;
    dataBand(dataBand > maxValue) = maxValue;
    dataBand(dataBand < -maxValue) = -maxValue;
    totalTime = (length(data) - 1)/srateTarget;
    startTime = (startFrame - 1)/srateTarget;
    
    %% Now get the events
    eventList = getSegmentedEvents(eventDirs, theName, eventTypes, ...
        startTime, segmentTime, totalTime);
    eventPositions = ((1:length(eventList))*0.05 + 1.1)*maxValue;
    maxLimit = ((length(eventList) + 2)* 0.05 + 1.1)*maxValue;
    
    framesSegment = round(segmentTime*srateTarget);
    numSegments = floor(totalTime/segmentTime);
    startSegment = 1;
    for n = 1:numSegments
        endSegment = startSegment + framesSegment - 1;
        t = (startSegment:endSegment)';
        t = (t-1)/srateTarget + baseTime;
        theData = data(startSegment:endSegment)';
        theBand = dataBand(startSegment:endSegment)';
        theTitle = [dataType theName ' channel ' channelLabel  ...
            ' Segment ' num2str(n) ...
            ' [' num2str(round(min(t))) ':' num2str(round(max(t))) '] sec' ...
            ' Frames [' num2str(startSegment) ':' num2str(endSegment) ']'];
        hFig1 = figure('Name', theTitle);
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
           for m = 1:length(xTicks)
               if mod(m-1, 5) == 0
                   xTickLabels{m} = sprintf('%6.2f', xTicks(m));
               else
                   xTickLabels{m} = '';
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
        for m = 1:length(eventList)
            if isempty(eventList(m).eventSegments)
                continue;
            end
            thisList = eventList(m).eventSegments{n};
            if isempty(thisList)
                continue;
            end
            line(thisList(1, :) + min(t), ...
                [eventPositions(m), eventPositions(m)], ...
                'Color', eventColors(m, :), 'LineWidth', 2);
            legendStrings{end + 1} = eventList(m).eventType; %#ok<*SAGROW>
        end
        for m = 1:length(eventList)
            if isempty(eventList(m).eventSegments)
                continue;
            end
            thisList = eventList(m).eventSegments{n};
            if isempty(thisList)
                continue;
            end
            for s = 2:size(thisList, 1)
                line(thisList(s, :) + min(t), ...
                    [eventPositions(m), eventPositions(m)], ...
                    'Color', eventColors(m, :), 'LineWidth', 2);
            end
        end
        
        hleg = legend(legendStrings, 'Location', 'SouthEast');
        title(theTitle, 'Interpreter', 'None');
        hold off
        box on
        startSegment = endSegment + 1;
        imageName = [thisImageDir filesep theName '_' num2str(n) ...
            '_' num2str(min(t)) 's_' num2str(max(t)) 's.'];
        for f = 1:length(figureFormats)
            saveas(hFig1, [imageName figureFormats{f}], figureFormats{f});
        end
        
        close(hFig1);
   
    end
end
