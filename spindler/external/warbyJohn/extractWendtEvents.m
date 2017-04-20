function [spindles, params] = ...
                               extractWendtEvents(EEG, params)
%% Calculate spindle events from different Gabor reconstructions 
%  
%  Parameters:
%    EEG              Input EEG structure (EEGLAB format)
%    params           (Input/Output) Structure with parameters for algorithm 
%                            (See getSpindleDefaults)
%    spindles         (Output) Structure with performance information

%
%  Written by:     J. LaRocco, K. Robbins, UTSA 2016-2017
%

%% Process the input parameters and set up the calculation
%defaults = concatenateStructs(getGeneralDefaults(), getSpindlerDefaults());
%params = processParameters('extractEvents', nargin, 2, params, defaults);
params.srate = EEG.srate;
params.frames = size(EEG.data, 2);
%params.channelNumber = channelNumber;
channelNumber=params.channelNumber;
params.centralNumber=channelNumber(1);
params.occipitalNumber=channelNumber(2);

params.channelLabels = EEG.chanlocs(channelNumber).labels;
if isempty(channelNumber)
    error('extractSpindles:NoChannels', 'Must have non-empty');
end  


minLength = params.minSpindleLength;
minSeparation = params.minSpindleSeparation;


%% Extract the channels and filter the EEG signal before MP
[numChans, numFrames] = size(EEG.data);
if channelNumber > numChans
    error('extractSpindles:BadChannel', 'The EEG does not have channel needed');
end
srate = EEG.srate;
EEG.data = EEG.data(channelNumber, :);
EEG.nbchan = 1;
totalTime = (numFrames - 1)/EEG.srate;

wendtFrequencies=params.wendtFrequencies;

%% Bandpass filter the EEG
lowFreq = max(1, min(wendtFrequencies));
highFreq = min(ceil(EEG.srate/2.1), max(wendtFrequencies));
EEGFilt = pop_eegfiltnew(EEG, lowFreq, highFreq);

%% Combine adjacent spindles and eliminate items that are too short.

spindles(1) = ...
            struct('atomsPerSecond', 0, 'numberAtoms', 0, ...
                   'baseThreshold', 0', 'numberSpindles', 0, ...
                   'spindleTime', 0, 'spindleTimeRatio', 0, ...
                   'events', NaN, 'meanEventTime', 0, ...
                   'r2', 0, 'eFraction', 0);

        p=1;
        spindles(p) = spindles(end);
        
        detection = wendt_spindle_detection_modded(EEGFilt.data(1,:), EEGFilt.data(2,:), srate);
        
        %% event conversion
        [start_i, end_i] = eventDetector(detection);
        
        spind(:,1)=start_i;
        spind(:,2)=end_i;
        numLabelledEvents = size(spind, 1);
        spind=spind/EEG.srate;
        EEG.params.numLabelledEvents=numLabelledEvents;
        
        if size(spind,1)==0;
            spind(1,:)=1;
        end
        
        
        events = combineEvents(spind, minLength, minSeparation);

        

        spindles(p).events = events;
        [spindles(p).numberSpindles, spindles(p).spindleTime, ...
            spindles(p).meanEventTime] = getSpindleCounts(events);
        spindles(p).spindleTimeRatio = spindles(p).spindleTime/totalTime;
    end


