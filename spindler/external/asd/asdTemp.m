function [events, params, additionalInfo] = ...
                              asdExtractEvents(EEG, channelNumber, params)
% Last updated: November 2016, J. LaRocco, K. Robbins

% Details: Simon 2015-based detection of events.

% Usage:
% [events, spindles] =newSimon(EEG, channelNumbers, atomFrequencies, expertEvents)

% [events, spindles] =newSimon(EEG, channelNumbers, atomFrequencies)
%
%  data            Input EEG structure (EEGLAB format)
%  channelList:    Vector of channel numbers to analyze
%  freqBounds:     Frequency boundry to restrict reconstruction to. (1x2 vector with positive integers, e.g.,[6 14])
%  expertEvents:   Struct with expert-rated times and durations for spindles (scalar or vector of positive integers).
%
% Output:
%  events:         Matrix of detected events, with first column as start
%                  time and second as end time (both in seconds).
%  spindles:       Struct containing MP info, and if relevant, performance.


%% Initialize the return values and check parameters
events = [];
additionalInfo = struct('eventFrequencies', NaN, 'eventAmplitudes', NaN, ...
           'eventOscillationIndices', NaN);
params = processAsdParameters('asd', nargin, 2, params);
params.srate = EEG.srate;
params.frames = size(EEG.data, 2);
params.channelNumber = channelNumber;
params.channelLabels = EEG.chanlocs(channelNumber);
if isempty(channelNumber)
    error('extractSpindles:NoChannels', 'Must have non-empty');
end
data = EEG.data(channelNumber, :);
data = data(:);
srate = EEG.srate;

%% Set up the image directory if visualize is on
imagePath = [];
imageBase = '';
if params.AsdVisualize
    [imagePath, imageBase, ~] = fileparts(params.AsdImagePathPrefix);
    if isempty(imagePath)
        imagePath = pwd;
    elseif ~exist(imagePath, 'dir')
        mkdir(imagePath);
    end
end
%% Initialize the other parameters

baseRange = params.AsdBaseRange;
peakRange = params.AsdPeakRange;
lowBase = max(1, baseRange(1));
highBase = min(baseRange(2), srate/2);

slideWidth = floor(params.AsdWindowSlide*srate);
windowLength = floor(params.AsdWindowSize*srate);
numSlides = floor((length(data) - windowLength)/slideWidth) + 1;

% Pre-allocate the array of structures
peakFrequency = zeros(numSlides, 1);
peakPosition = zeros(numSlides, 1);
peakAmplitude = zeros(numSlides, 1);
oscillationIndex = zeros(numSlides, 1);
lowerEdge = 1;
upperEdge = windowLength;
hammingWin = hamming(windowLength);
noiseBW = enbw(hammingWin, srate);
ampX = zeros(1, numSlides);
f = [];
for k = 1:numSlides
    dataWin = data(lowerEdge:upperEdge);
    dataWin = double(dataWin(:));
    dataWin = dataWin - mean(dataWin);   
    [pxx, f] = periodogram(dataWin, hammingWin, [], srate);
    if k == 1
        ampX = zeros(length(pxx), numSlides);
    end
    ampX(:, k) = sqrt(pxx(:));
    
    %% Compute the peak
    [~, maxIndex] = max(ampX(lowBase:highBase, k)); % finds maximum between 4 and 40hz
    peakPosition(k) = maxIndex + lowBase - 1;
    peakFrequency(k) = f(peakPosition(k)); % finds the associated frequency
    peakAmplitude(k) = ampX(peakPosition(k), k);
    %% Update the slide
    upperEdge = upperEdge + slideWidth;
    lowerEdge = lowerEdge + slideWidth;
    %windowRange(k, :) = [t(k) - ceil(slideWidth/2) t(k) + floor(slideWidth/2) - 1] / srate;
end  

%% Now compute the mean spectrum and fit the noise level
meanAmpX = mean(ampX, 2);
fh = @(x,p) exp(-x./p(1));
errfh = @(p,x,y) sum((y(:)-fh(x(:),p)).^2);
p0 = (max(f) - min(f))/2;
P = fminsearch(errfh, p0, [], f, meanAmpX);
noiseFit = fh(f, P);
if params.AsdVisualize
    theTitle = [imageBase ' [Average spectrum and noise fit]'];
    sumFig = figure('Name', theTitle);
    hold on
    plot(f, meanAmpX, f, noiseFit,'r-', 'linewidth', 2)
    set(gca, 'fontweight', 'bold', 'fontsize', 12)
    xlabel('Frequency (Hz)');
    ylabel('\surd(V^2/Hz)');
    title(theTitle, 'Interpreter', 'None')
    legend('ASD mean', 'ASD noise fit')
    box on
    saveas(sumFig, [imagePath filesep imageBase '_MeanFit.png'], 'png');
    close(sumFig);
end
meanArea = trapz(f, meanAmpX);
allAreas = trapz(f, ampX);
%% Now compute the spindles
indices = (1:length(f))';
peakMask = peakRange(1) <= peakFrequency & peakFrequency <= peakRange(2); 
for k = 1:numSlides
    if ~peakMask(k)
        continue;
    end
   halfPeak = peakAmplitude(k)/2; % take half of the max
   riseMask = peakFrequency(k) - 2*noiseBW <= f & f <= peakFrequency(k);
   fallMask = peakFrequency(k) <= f & f <= peakFrequency(k) + 2*noiseBW;
   risePXX = ampX(riseMask, k);
   fallPXX = ampX(fallMask, k);
   halfStart = find(risePXX <= halfPeak, 1, 'last');
   halfEnd = find(fallPXX <= halfPeak, 1, 'first');
   if isempty(halfStart) || isempty(halfEnd)
       continue;
   end
   riseIndices = indices(riseMask);
   fallIndices = indices(fallMask);
   FWHMIndices = riseIndices(halfStart):fallIndices(halfEnd);
   fHalfRise = f(FWHMIndices(1));
   fHalfFall = f(FWHMIndices(end));
   
   maxValue = ampX(peakPosition(k), k);
   noiseLevel = noiseFit*allAreas(k)/meanArea;
   oscillationIndex(k) = trapz(ampX(FWHMIndices))/trapz(noiseLevel(FWHMIndices));
   if params.AsdVisualize && oscillationIndex(k) >= params.AsdFWHMCutoff
       theTitle = [imageBase ' [Window ' num2str(k) ': OI=' ...
           num2str(oscillationIndex(k)) ' at f=' num2str(peakFrequency(k)) ']'];
       wFig = figure('Name', theTitle);
       hold on
       plot(f, ampX(:, k), f, noiseLevel,'r-', 'linewidth', 2)
      
       set(gca, 'fontweight', 'bold', 'fontsize', 12)
       xlabel('Frequency (Hz)');
       ylabel('\surd(V^2/Hz)');
       title(theTitle, 'Interpreter', 'None')
       line([fHalfRise, fHalfFall], [maxValue/2 maxValue/2], ...
           'LineWidth', 3, 'Color', [0, 0, 0]);
       legend('ASD', 'Noise fit', 'FWHM')
       box on
       saveas(wFig, [imagePath filesep imageBase '_Win_' num2str(k) '.png'], 'png');
       close(wFig);
   end
end

%% Now merge events
spindleMask = oscillationIndex >= params.AsdFWHMCutoff;
spindleIndices = (1:size(ampX, 2))';
spindleIndices = spindleIndices(spindleMask);
spindleFrequency = peakFrequency(spindleMask);
spindleAmplitude = peakAmplitude(spindleMask);

spindleCounts = zeros(size(spindleIndices));
if isempty(spindleCounts)
    return;
end
spindleCounts(1) = 1;
for k = 2:length(spindleCounts)
    if spindleIndices(k - 1) + 1 == spindleIndices(k) && ...
       abs(spindleFrequency(k - 1) - spindleFrequency(k)) <= 1
       spindleCounts(k) = spindleCounts(k - 1);
    else
        spindleCounts(k) = spindleCounts(k - 1) + 1;
    end
end
numEvents = spindleCounts(end);
events = zeros(numEvents, 2);
eventFrequencies = zeros(numEvents, 1);
eventAmplitudes = zeros(numEvents, 1);
eventOscillationIndices = zeros(numEvents, 1);
for k = 1:numEvents
    spindleMask = spindleCounts == k;
    theseIndices = spindleIndices(spindleMask);
    eventFrequencies(k) = mean(spindleFrequency(spindleMask));
    eventAmplitudes(k) = mean(spindleAmplitude(spindleMask));
    eventOscillationIndices(k) = mean(oscillationIndex(spindleMask));
    events(k, 1) = theseIndices(1);
    events(k, 2) = theseIndices(1) + length(theseIndices)*windowLength - 1;
end
events = (events - 1)/srate;
additionalInfo.eventFrequencies = eventFrequencies;
additionalInfo.eventAmplitudes = eventAmplitudes;
additionalInfo.eventOscillationIndices = eventOscillationIndices; 
