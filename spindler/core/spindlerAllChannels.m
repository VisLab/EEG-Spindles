function [spindleEvents, params] = spindlerAllChannels(EEG, imageDir, baseName, params)
%% Run spindler on all channels of an EEG structure and return events
%
%  Parameters:
%     EEG       EEGLAB EEG structure containing all only channels to spindle
%     imageDir  directory to dump images
%     baseName  base name for identifying images and other items
%     params    parameter structure with override for defaults
%     spindleEvents   (output) structure containing the spindle events and metadata
%     params    (output) updated parameter structure
%
%  Written by: Kay Robbins, UTSA, 2017
%
    if ~isempty(imageDir) && ~exist(imageDir, 'dir')
        mkdir(imageDir);
    end
    channelLabels = {EEG.chanlocs.labels};
    numChans = length(channelLabels);
    spindleEvents(numChans) = getEventsStruct(); 
    
    for n = 1:numChans
        spindleEvents(n) = getEventsStruct();
        spindleEvents(n).channelNumber = n;
        spindleEvents(n).channelLabel = channelLabels{n};
        
        %% Calculate the spindle representations for a range of parameters
        [spindles, params] = spindlerExtractSpindles(EEG, n, params);
        params.name = ['Ch_' channelLabels{n} '_' baseName];
        [spindlerCurves, warningMsgs, warningCodes] = ...
                  spindlerGetParameterCurves(spindles, imageDir, params);
        if spindlerCurves.bestEligibleLinearInd > 0
            events = spindles(spindlerCurves.bestEligibleLinearInd).events;
        end

        spindleEvents(n).bestEligibleThreshold = spindlerCurves.bestEligibleThreshold;
        spindleEvents(n).bestEligibleAtomsPerSecond = ...
        spindlerCurves.bestEligibleAtomsPerSecond;
        spindleEvents(n).atomRateRange = spindlerCurves.atomRateRange;
        spindleEvents(n).spindleRateSTD = spindlerCurves.spindleRateSTD;
        spindleEvents(n).warningMsgs = warningMsgs;
        spindleEvents(n).warningCodes = warningCodes;
        spindleEvents(n).events = events;
    end
    if isfield(params, 'channelNumber')
       params = rmfield(params, 'channelNumber');
    end
    if isfield(params, 'channelLabel')
       params = rmfield(params, 'channelLabel');
    end
    params.name = baseName;
    params.chanlocs = EEG.chanlocs;
end    
    
function spindleEvents = getEventsStruct()
%% Get the initialization for Spindler's summary spindle events structure
   spindleEvents = struct('channelNumber', NaN,  'channelLabel', NaN, ...
          'events', NaN, 'warningMsgs', NaN, 'warningCodes', NaN, ...
          'bestEligibleThreshold', NaN, 'bestEligibleAtomsPerSecond', NaN, ... 
          'atomRateRange', NaN, 'spindleRateSTD', NaN);
end