function eventMask = getEventMask(startTimes, endTimes, numFrames, srate)
%% Return an event mask based on event start and end times
%
%  Parameters
%      startTimes   vector of start times in seconds
%      endTimes     vector of end times in seconds
%      numFrames    number of frames in the mask
%      srate        sampling rate of the underlying signal
%
%  Written by:  Kay Robbins, UTSA, 2017

eventMask = false(1, numFrames);
startFrames = min(round(startTimes*srate) + 1, numFrames);
endFrames = min(round(endTimes*srate) + 1, numFrames);
for n = 1:length(startFrames)
    eventMask(startFrames(n):endFrames(n)) = true;
end