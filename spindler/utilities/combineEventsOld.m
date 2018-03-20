function epochEvents = combineEvents(events, minLength, minSeparation)
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
if isempty(events)
    epochEvents = {};
    return;
end
if ~iscell(events)
    epochEvents = cell(1, 1);
    epochEvents{1} = combinedEpochEvents(events);
else
    epochEvents = cell(length(events), 1);
    for m = 1:length(events)
        epochEvents{m} = combinedEpochEvents(events{m});
    end
end

    function epochEvents = combinedEpochEvents(theseEvents)      
        %% Combine events separated by less than minSeparation seconds
        interEventIntervals = theseEvents(2:end, 1) - theseEvents(1:end - 1, 2);
        epochEvents = theseEvents;
        k = 1;
        for i = 1:length(interEventIntervals)
            if interEventIntervals(i) > minSeparation
                k = k + 1;
            else
                epochEvents(k, 2) = epochEvents(k + 1, 2);
                epochEvents(k + 1, :) = [];
            end
        end
        
        %% Eliminate events that are shorter than minLength seconds
        eventMask = epochEvents(:, 2) - epochEvents(:, 1) < minLength;
        epochEvents(eventMask, :) = [];
    end
end