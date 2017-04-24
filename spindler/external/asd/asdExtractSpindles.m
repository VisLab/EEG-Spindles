function [events, params, additionalInfo] = ...
                              asdExtractSpindles(EEG, channelNumber, params)
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
defaults = concatenateStructs(getGeneralDefaults(), asdGetDefaults());
params = processParameters('asd', nargin, 2, params, defaults);

%% Extract the channels and filter the EEG signal before MP
if channelNumber > size(EEG.data, 1)
    error('asdExtractSpindles:BadChannel', 'The EEG does not have channel needed');
end
params.srateOriginal = EEG.srate;
EEG.data = EEG.data(channelNumber, :);
EEG.chanlocs = EEG.chanlocs(channelNumber);
EEG.nbchan = 1;
EEG = resampleToTarget(EEG, params.srateTarget);
srate = EEG.srate;
numFrames = size(EEG.data, 2);
%totalTime = (numFrames - 1)/srate;
params.srate = srate;
params.frames = numFrames;
params.channelNumber = channelNumber;
params.channelLabel = num2str(EEG.chanlocs.labels);
%% Initialize the other parameters
baseFrequencyRange = params.AsdBaseFrequencyRange;
peakFrequencyRange = params.AsdPeakFrequencyRange;
lowBase = max(1, baseFrequencyRange(1));
highBase = min(baseFrequencyRange(2), floor(srate/2) - 1);
EEG = pop_eegfiltnew(EEG, lowBase, highBase);

data = EEG.data;
data = data(:);

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

%% Compute the spectra for the individual sliding windows
slideWidth = floor(params.AsdWindowSlide*srate);
windowLength = floor(params.AsdWindowSize*srate);
numSlides = floor((length(data) - windowLength)/slideWidth) + 1;
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
peakFrequency = zeros(numSlides, 1);
peakPosition = zeros(numSlides, 1);
peakAmplitude = zeros(numSlides, 1);
oscillationIndex = zeros(numSlides, 1);
peakWidthMask = false(numSlides, 1);
for k = 1:numSlides
    noiseLevel = noiseFit*allAreas(k)/meanArea;
    signalLevel = ampX(:, k) - noiseLevel;
    [~, maxIndex] = max(signalLevel(lowBase:highBase)); % finds maximum between 4 and 40hz
    peakPosition(k) = maxIndex + lowBase - 1;
    peakFrequency(k) = f(peakPosition(k)); % finds the associated frequency
    peakAmplitude(k) = signalLevel(peakPosition(k));
    if peakFrequency(k) < peakFrequencyRange(1) || peakFrequencyRange(2) < peakFrequency(k)
        continue;
    end
    halfPeak = peakAmplitude(k)/2; % take half of the max
    riseMask = peakFrequency(k) - params.AsdPeakWidthMax*noiseBW <= f & ...
        f < peakFrequency(k);
    riseIndices = indices(riseMask);
    halfStart = find(signalLevel(riseMask) <= halfPeak, 1, 'last');
    if isempty(halfStart)
        continue;
    end
    startInd = riseIndices(halfStart);
    fStart = getInterpolatedFrequency(f(startInd), f(startInd + 1), ...
                 signalLevel(startInd), signalLevel(startInd + 1), halfPeak);
  
    fallMask = peakFrequency(k) < f & ...
        f <= peakFrequency(k) + params.AsdPeakWidthMax*noiseBW;
    fallIndices = indices(fallMask);
    halfEnd = find(signalLevel(fallMask) <= halfPeak, 1, 'first');
    if isempty(halfEnd)
        continue;
    end
    endInd = fallIndices(halfEnd);
    fEnd = getInterpolatedFrequency(f(endInd - 1), f(endInd), ...
                 signalLevel(endInd - 1), signalLevel(endInd), halfPeak);
    peakWidthMask(k) = (fEnd - fStart) < params.AsdPeakWidthMax*noiseBW;
    FWHM = f(startInd:endInd);
    FWHM(1) = fStart;
    FWHM(end) = fEnd;
    interSignal = signalLevel(startInd:endInd);
    interSignal(1) = halfPeak;
    interSignal(end) = halfPeak;
    interNoise = noiseLevel(startInd:endInd);
    interNoise(1) = getInterpolatedSignal(f(startInd), f(startInd + 1), ...
                 noiseLevel(startInd), noiseLevel(startInd + 1), fStart);
    interNoise(end) = getInterpolatedSignal(f(endInd - 1), f(endInd), ...
             noiseLevel(endInd - 1), noiseLevel(endInd), fEnd);
    ampIntEnd = getInterpolatedSignal(f(endInd - 1), f(endInd), ...
             ampX(endInd - 1, k), ampX(endInd, k), fEnd);
    ampIntStart = getInterpolatedSignal(f(startInd), f(startInd + 1), ...
                 ampX(startInd, k), ampX(startInd + 1, k), fStart);
    oscillationIndex(k) = trapz(FWHM, interSignal)/ ...
                          trapz(FWHM, interNoise);
    if params.AsdVisualize && peakWidthMask(k) && oscillationIndex(k) >= params.AsdFWHMCutoff
        theTitle = [imageBase ' [Window ' num2str(k) ': OI=' ...
            num2str(oscillationIndex(k)) ' at f=' num2str(peakFrequency(k)) ']'];
        wFig = figure('Name', theTitle);
        hold on
        plot(f, ampX(:, k), 'linewidth', 2)
        plot(f, noiseLevel, 'Color', [0.7, 0, 0], 'linewidth', 2)
        plot(f, signalLevel, 'Color', [0, 0.7, 0], 'linewidth', 2)
        set(gca, 'fontweight', 'bold', 'fontsize', 12)
        xlabel('Frequency (Hz)');
        ylabel('\surd(V^2/Hz)');
        title(theTitle, 'Interpreter', 'None')
        line([FWHM(1), FWHM(end)], [ampIntStart, ampIntEnd], ...
            'LineWidth', 3, 'Color', [0, 0, 0]);
        line([FWHM(1), FWHM(end)], [interSignal(1), interSignal(end)], ...
            'LineWidth', 3, 'Color', [0.5, 0.8, 0.5]);
        legend('ASD', 'Noise', 'Signal', 'FWHM', 'S-FWHM')
        box on
        saveas(wFig, [imagePath filesep imageBase '_Win_' num2str(k) '.png'], 'png');
        close(wFig);
    end
end

%% Now merge events
spindleMask = oscillationIndex >= params.AsdFWHMCutoff & peakWidthMask;
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
    events(k, 1) = (theseIndices(1) - 1)*slideWidth;
    events(k, 2) = events(k, 1) + length(theseIndices)*windowLength - 1;
end
events = events/srate;
additionalInfo.eventFrequencies = eventFrequencies;
additionalInfo.eventAmplitudes = eventAmplitudes;
additionalInfo.eventOscillationIndices = eventOscillationIndices;
end

function fInt = getInterpolatedFrequency(f1, f2, s1, s2, sInt)
    if f1 == f2
        fInt = f1;
        return;
    end
    m = (s2 - s1)/(f2 - f1);
    fInt = (sInt - s1)/m + f1;
end

function sInt = getInterpolatedSignal(f1, f2, s1, s2, fInt)
    if f1 == fInt
        sInt = s1;
    elseif f2 == fInt
        sInt = s2;
    else
        sInt = (fInt - f1)*(s2 - s1)/(f2 - f1) + s1;
    end
end