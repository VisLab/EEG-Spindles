%% This script displays EEG data overlaid with events 
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
stageDir = [];
eventDir = [];

%% Example 1: Setup for driving data
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDirs = {'D:\TestData\Alpha\spindleData\bcit\events'};
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindlerNew';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerNewOverlays';
% channelLabels = {'PO7'};
% lowFreq = 6;
% highFreq = 13;
% epochTime = 30;
% showPredicted = true;
% baseBand = [1, 20];

%% Example 2: Setup for the BCIT driving collection
% dataDir = 'E:\CTADATA\BCIT\level_0';
% eventDir = '';
% resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindlerNewAgain';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindlerNewAgain';
% channelLabels = {'PO3', 'H27'};
% paramsInit = struct();

%% Example 3: Setup for the NCTU labeled driving collection
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDirs = {'D:\TestData\Alpha\spindleData\nctu\events'};
% eventTitles = {'expert'};
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindlerNew';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerNewOverlayNoPredictions';
% channelLabels = {'P3'};
% lowFreq = 6;
% highFreq = 13;
% epochTime = 30;
% showPredicted = false;
% baseBand = [1, 20];

%% Example 4: Set up for the Dreams sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindlerNew';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerNew';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Spindler_SummaryNew.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% % % paramsInit.spindlerGaborFrequencies = 10.5:0.5:16.5;
% paramsInit.spindlerGaborFrequencies = 10.5:0.5:16.5;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;
% % paramsInit.srateTarget = 200;
% % % paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Example 4: Set up for the MASS sleep collection
dataDir = 'D:\TestData\Alpha\spindleData\mass\dataRestricted';
eventDirs = {'D:\TestData\Alpha\spindleData\mass\events\spindlesE1'; ...
             'D:\TestData\Alpha\spindleData\mass\events\spindlesE1'};
eventTypes = {'expert1', 'expert2'};      
resultsDir = 'D:\TestData\Alpha\spindleData\mass\resultsRestrictedSpindlerNew1';
imageDir = 'D:\TestData\Alpha\spindleData\mass\imagesRestrictedSpindlerNew1Overlays';
channelLabels = {'CZ'};
lowFreq = 10;
highFreq = 20;
epochTime = 30;
showPredicted = true;
baseBand = [1, 20];

%% Example 5: Set up for the Dreams sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\dataRestricted';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\eventsRestricted\combinedUnion';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsRestrictedSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesRestrictedSpindler';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreamsRestricted_Spindler_Summary.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.spindlerGaborFrequencies = 10.5:0.5:16.5;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;
% paramsInit.srateTarget = 200;
% paramsInit.figureFormats = {'png', 'fig', 'pdf', 'eps'};

%% Example 6: Driving data supervised 256 Hz
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindler256Hz';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindler256Hz';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_Summary256.mat';
% channelLabels = {'PO7'};
% paramsInit = struct();
% paramsInit.srateTarget = 256;

%% Example 6: Driving data unsupervised 256 Hz
% dataDir = 'D:\TestData\Alpha\spindleData\bcit\data';
% eventDir = 'D:\TestData\Alpha\spindleData\bcit\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\bcit\resultsSpindlerMoreRes';
% imageDir = 'D:\TestData\Alpha\spindleData\bcit\imagesSpindlerMoreRes';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\bcit_Spindler_SummaryMoreRes.mat';
% channelLabels = {'PO7'};
% paramsInit = struct();
% paramsInit.srateTarget = 256;
% paramsInit.spindlerGaborFrequencies = 6:0.5:13;

%% Example 7 NCTU data unsupervised 
% dataDir = 'D:\TestData\Alpha\spindleData\nctu\data';
% eventDir = 'D:\TestData\Alpha\spindleData\nctu\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\nctu\resultsSpindlerMoreRes';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\imagesSpindlerMoreRes';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\nctu_Spindler_SummaryMoreRes.mat';
% channelLabels = {'P3'};
% paramsInit = struct();
% paramsInit.srateTarget = 250;
% paramsInit.spindlerGaborFrequencies = 6:0.5:13;

%% Example 5: Set up for the Dreams sleep collection
% dataDir = 'D:\TestData\Alpha\spindleData\dreams\data';
% eventDir = 'D:\TestData\Alpha\spindleData\dreams\events';
% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindlerMoreRes';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindlerMoreRes';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\dreams_Spindler_SummaryMoreRes.mat';
% channelLabels = {'C3-A1', 'CZ-A1'};
% paramsInit = struct();
% paramsInit.srateTarget = 200;
% paramsInit.spindlerGaborFrequencies = 10:0.5:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;

%% Example 6: Mas
% dataDir = 'D:\TestData\Alpha\spindleData\mass\data';
% eventDir = [];
% resultsDir = 'D:\TestData\Alpha\spindleData\mass\resultsSpindlerMoreRes';
% imageDir = 'D:\TestData\Alpha\spindleData\mass\imagesSpindlerMoreRes';
% summaryFile = 'D:\TestData\Alpha\spindleData\ResultSummary\mass_Spindler_SummaryMoreRes.mat';
% channelLabels = {'C3'};
% paramsInit = struct();
% paramsInit.srateTarget = 256;
% paramsInit.spindlerGaborFrequencies = 10:0.5:16;
% paramsInit.spindlerOnsetTolerance = 0.3;
% paramsInit.spindlerTimingTolerance = 0.1;

%% Get the data and event file names and check that we have the same number
dataFiles = getFileListWithExt('FILES', dataDir, '.set');

%% Create the output directory if it doesn't exist
if ~isempty(imageDir) && ~exist(imageDir, 'dir')
    fprintf('Creating image directory %s \n', imageDir);
    mkdir(imageDir);
end

%% Process the data
events = {};
eventLabels = {};
startMarks = [];
for k = 1:length(dataFiles)
    %% Get the results file with spindle information
    [~, theName, ~] = fileparts(dataFiles{k});
    test = load([resultsDir filesep theName, '_spindlerResults.mat']);
   

    params = test.params;
    additionalInfo = test.additionalInfo;
    
    %% Read in the EEG and find the correct channel number   
    [data, params] = getChannelData(dataFiles{k}, channelLabels, params);
    if isempty(data)
        warning('No data found for %s\n', dataFiles{k});
        continue;
    end
    
    %% Also get a filtered signal to overlay 
    dataBand = getFilteredData(data, params.srate, lowFreq, highFreq);
    if ~isempty(baseBand)
        data = getFilteredData(data, params.srate, baseBand(1), baseBand(2));
    end
    
    %% Make sure that the image directory exists
    thisImageDir = [imageDir filesep theName];
    if ~exist(thisImageDir, 'dir')
       fprintf('Creating image directory %s \n', thisImageDir);
       mkdir(thisImageDir);
    end
    
    %% Set up the plots
    baseTime = (additionalInfo.startFrame - 1)./params.srate;
    data = data(additionalInfo.startFrame:additionalInfo.endFrame);
    dataBand = dataBand(additionalInfo.startFrame:additionalInfo.endFrame);
    
    %% Scale data  
    maxValue = min(12*mad(abs(data), 1), max(abs(data)));
    data(data > maxValue) = maxValue;
    data(data < -maxValue) = -maxValue;
    dataBand(dataBand > maxValue) = maxValue;
    dataBand(dataBand < -maxValue) = -maxValue;    
    totalTime = (length(data) - 1)/params.srate;
    startTime = (additionalInfo.startFrame - 1)/params.srate;
    eventStarts = [];
    events = {};
    eventLabels = {};
    if showPredicted && isfield(test, 'events') && ~isempty(test.events)
       events{end + 1} = test.events;
       eventLabels{end + 1} = 'Predicted';
       eventStarts(end + 1) = 0;
    end
   
    if isfield(test, 'expertEvents') && ~isempty(test.expertEvents)
       events{end + 1} = test.expertEvents;
       eventLabels{end + 1} = 'Expert';
       eventStarts(end + 1) = 0;
    end
    for n = 1:length(eventDirs)
        theseEvents = readEvents([eventDirs{n} filesep theName '.mat']);
        if isempty(theseEvents)
            continue;
        end
        events{end + 1} = theseEvents;
        eventLabels{end + 1} = eventTypes{n};
        eventStarts(end + 1) = startTime;
    end
  
    eventColors = jet(length(events) + 1);
    eventCounts = {};
    eventLists = {};
    for n = 1:length(events)
       [counts, lists] = epochEvents(expertEvents, 0, totalTime, epochTime);
    [eventCounts, eventList] = epochEvents(events, 0, totalTime, epochTime);
    framesSegment = round(epochTime*params.srate);
    numSegments = length(expertList);
    startSegment = 1;
    for n = 1:numSegments
        endSegment = startSegment + framesSegment - 1;
        theData = data(startSegment:endSegment)';
        theBand = dataBand(startSegment:endSegment)';
        theTitle = [theName ' channel ' params.channelLabel, ...
                   ' Segment:' num2str(n) ' Frames:[' num2str(startSegment) ':' num2str(endSegment) ']'];
        hFig1 = figure('Name', theTitle);
        t = (startSegment:endSegment)';
        t = (t-1)/params.srate + baseTime;
        hold on
        plot(t, theBand, 'g-', 'LineWidth', 2);
        p1 = plot(t, theData, 'k-');
        xlabel('time (s)')
        ylabel('Voltage');
        set(hFig1, 'Position', [300 500 1500 400]);
        %yLim = get(gca, 'yLim');
        %yMax = max(abs(yLim));         
%         expertPos = 1.05*yMax;
%         eventPos = 1.1*yMax;
        expertPos = 1.05*maxValue;
        eventPos = 1.1*maxValue;   
        set(gca, 'YLimMode', 'manual', 'YLim', [-1.3, 1.3]*maxValue); 
        set(gca, 'XLimMode', 'manual', 'XLim', [min(t), max(t)]);
        expertEv = expertList{n};
        theseEvents = eventList{n};    
        legendStrings = ...
            {['EEG [' num2str(lowFreq) ',' num2str(highFreq), '] Hz'], ...
             ['EEG [' num2str(baseBand(1)) ',' num2str(baseBand(2)), '] Hz']};
        if ~isempty(expertEv)
            line(expertEv(1, :) + min(t), [expertPos, expertPos], ...
                'Color', [0,0,0], 'LineWidth', 2);
            legendStrings{end + 1} = 'Expert'; %#ok<*SAGROW>
        end
        
        if ~isempty(theseEvents)
            line(theseEvents(1, :) + min(t), [eventPos, eventPos], ...
                'Color', [1,0,0], 'LineWidth', 2);
            legendStrings{end + 1} = 'Predicted';
        end
        for j = 2:size(expertEv, 1)
            line(expertEv(j, :) + min(t), [expertPos, expertPos], 'Color', [0,0,0], 'LineWidth', 2);
        end
       
        for j = 2:size(theseEvents, 1)
            line(theseEvents(j, :) + min(t), [eventPos, eventPos], 'Color', [1,0,0], 'LineWidth', 2);
        end
        hleg = legend(legendStrings, 'Location', 'SouthEast');
        title(theTitle, 'Interpreter', 'None');
        hold off
        box on
        startSegment = endSegment + 1;
        imageName = [thisImageDir filesep theName '_' num2str(n) '.png'];
        saveas(hFig1, imageName, 'png');
        close(hFig1);
    end
end
