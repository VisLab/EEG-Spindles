function  splitEEG = getSplitEEG(EEG, splitTimes)
%% Extract a new EEG structure between startTime and endTime
%
%  Parameters:
%      EEG         (input/output) EEGLAB set structure
%      splitTimes  n x 2 array with split starts and ends in seconds
%
%  Written by: Kay Robbins, UTSA, 2017
%
%% Perform the split

    numSplits = size(splitTimes, 1);
    splitEEG = cell(numSplits, 1);
    if numSplits == 0
        return;
    end

    for k = 1:numSplits
        splitEEG{k} = split(EEG, splitTimes(k, 1), splitTimes(k, 2));
    end
end


function EEG = split(EEG, startTime, endTime)
    srate = EEG.srate;
    numFrames = size(EEG.data, 2);
    startFrame = min(round(startTime*srate) + 1, numFrames);
    endFrame = min(round(endTime*srate) + 1, numFrames);
    EEG.data = EEG.data(:, startFrame:endFrame);
    EEG.pnts = size(EEG.data, 2);
    EEG.times = EEG.times(startFrame:endFrame);
    EEG.xmax = (EEG.pnts - 1)./srate;
    EEG.setname = [EEG.setname '_' num2str(startFrame) '_' num2str(endFrame)];
    %% Fix the events
    if ~isempty(EEG.event)
        frames = round(cellfun(@double, {EEG.event.latency}));
        eventMask = startFrame <= frames & frames <= endFrame;
        EEG.event = EEG.event(eventMask);
    end
end