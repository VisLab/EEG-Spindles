function events = getMaskEvents(eventMask, srate)
%% Return two column array of event start and end times from event mask
%
%  Parameters
%     eventMask = logical vector where 1's mark a frame with an event
%     srate       sampling rate of the signal in Hz
%     events      (output) two-element vector of start and end event times (s)
%
% Written by: Kay Robbins, UTSA, 2017
%% Compute the event times
diffMask = diff([0; eventMask(:); 0]);
startFrames = find(diffMask == 1);
endFrames = find(diffMask == -1);

if isempty(startFrames)
    events = [];
    return;
elseif length(startFrames) ~= length(endFrames)
    error('getMaskEvents:BadMask', 'Missing start or end times');
end
startTimes = (startFrames - 1)/srate;
endTimes = (endFrames - 1)/srate;
events = [startTimes(:), endTimes(:)];