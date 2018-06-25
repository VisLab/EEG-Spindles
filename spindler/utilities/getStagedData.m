function [data, boundaryFrames, stageEvents, expertEvents] = ...
                 getStagedData(data, expertEvents, srate, minLength)
%% Turns data into staged data.
    if isempty(stageName)
    stageEvents = [];
    if ~isempty(stageDir)
        stageStuff = load([stageDir filesep theName '.mat']);
        stageEvents = stageStuff.stage2Events;
        stageLengths = stageEvents(:, 2) - stageEvents(:, 1);
        [maxLength, maxInd] = max(stageLengths);
        if ~isempty(expertEvents)
            eventMask = stageEvents(maxInd, 1) <= expertEvents(:, 1) & ...
                expertEvents(:, 1) <= stageEvents(maxInd, 2);
            expertEvents = expertEvents(eventMask, :) - stageEvents(maxInd, 1);
        end
        startFrame = max(1, round(stageEvents(maxInd, 1)*params.srate));
        endFrame = min(length(data), round(stageEvents(maxInd, 2)*params.srate));
        data = data(:, startFrame:endFrame);    
    end