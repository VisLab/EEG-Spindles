function [data, startFrame, endFrame, expertEvents] = ...
                 getMaxStagedData(data, stageEvents, expertEvents, srate)
%% Find the data from the longest interval of staged data.
%
%  Parameters:
%      data         channels x frames array of data to extract from
%      stageEvents  n x 2 array of start and end times of stage events
%      expertEvents m x 2 array of start and end times of expert events
%      srate        sampling frequency of the data in Hz
%      startFrame   starting frame of interval in original data
%      endFrame     ending frame of interval in original data
%
%% See if there are stage events and return if not
    if isempty(stageEvents)
        startFrame = 1;
        endFrame = size(data, 2);
        return;
    end

%% Find the start and end frames of the maximum length stage event    
    [~, maxInd] = max(stageEvents(:, 2) - stageEvents(:, 1));
    startFrame = max(1, round(stageEvents(maxInd, 1)*srate));
    endFrame = min(size(data, 2), round(stageEvents(maxInd, 2)*srate));

%% Extract the data and the expertEvents for that interval
    data = data(:, startFrame:endFrame);    
    if ~isempty(expertEvents)
        eventMask = stageEvents(maxInd, 1) <= expertEvents(:, 1) & ...
            expertEvents(:, 1) <= stageEvents(maxInd, 2);
        expertEvents = expertEvents(eventMask, :) - stageEvents(maxInd, 1);
    end
        
end