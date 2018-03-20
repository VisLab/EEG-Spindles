function epochedEvents = combineEvents(theseEvents, minLength, minSeparation)
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
        %% Combine events separated by less than minSeparation seconds
    if isempty(theseEvents)
        epochedEvents = [];
        return;
    end
    interEventIntervals = theseEvents(2:end, 1) - theseEvents(1:end - 1, 2);
    epochedEvents = theseEvents;
    k = 1;
    for i = 1:length(interEventIntervals)
        if interEventIntervals(i) > minSeparation
            k = k + 1;
        else
            epochedEvents(k, 2) = epochedEvents(k + 1, 2);
            epochedEvents(k + 1, :) = [];
        end
    end

    %% Eliminate events that are shorter than minLength seconds
    eventMask = epochedEvents(:, 2) - epochedEvents(:, 1) < minLength;
    epochedEvents(eventMask, :) = [];
end