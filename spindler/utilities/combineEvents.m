function newEvents = combineEvents(events, minLength, minSeparation)
% Combine events within minSeparation of each other and remove short events
%
%  Input:
%     events            n x 2 array of event start and end times from detectEvents
%     minLength         Minimum length (in seconds) of the events. 
%     minSeparation     Minimum time (in seconds) between events. (Events
%                       separated by less than this value will be
%                       combined into one event.)
%  Output
%    newEvents          New array with event start and end times in columns
%
% Adapted from the DETECT toolbox, Lawhern, et al. 2013
% Modified by: John LaRocca and Kay Robbins, UTSA 2016-2017
% 

%% Check to make sure that there are events
newEvents = events;
if isempty(events)
    return;
end

%% Combine events separated by less than minSeparation seconds
interEventIntervals = events(2:end, 1) - events(1:end - 1, 2);
newEvents = events;
k = 1;
for i = 1:length(interEventIntervals)
   if interEventIntervals(i) > minSeparation
       k = k + 1;
   else
       newEvents(k, 2) = newEvents(k + 1, 2);
       newEvents(k + 1, :) = [];
   end
end

%% Eliminate events that are shorter than minLength seconds
eventMask = newEvents(:, 2) - newEvents(:, 1) < minLength;
newEvents(eventMask, :) = [];