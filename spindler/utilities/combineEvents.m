function [newEvents] = combineEvents(events, minLength, minTime)
% combineEvents         Combines and removes events based on event lengths
%
%  Input:
%     events            Events structure obtained from applyThreshold
%     minLength         Minimum length (in seconds) of the events. Events
%                       less than this value wil be removed from the data. 
%     minTime           Minimum time (in seconds) between events. If events
%                       are separated by less than this value, they will be
%                       combined into one event. 
%  Output
%    newEvents          New event structure
% Adapted from the DETECT toolbox
%
% calculates the inter-event interval (IEI) to find differences in events
if isempty(events)
    newEvents = [];
    return;
end
index = cell2mat(events(:,2));
t2 = cell2mat(events(:,3));
IEI = index(2:end)-t2(1:end-1);

% combines events separated by less than minTime. 
temp_events{1, 1} = 'alphaspindle';
temp_events{1, 2} = events{1, 2};
k = 1;
for i = 1 : length(IEI)
   if IEI(i) > minTime
       temp_events{k, 3} = events{i, 3};
       k = k + 1;
       temp_events{k, 1} = 'alphaspindle';
       temp_events{k, 2} = events{i+1, 2};
   end   
end
temp_events{end,3} = events{end, 3};

% after the merging of events, extract event lengths greater than the
% minimum and ignore the rest. 
event_lengths = cell2mat(temp_events(:,3)) - cell2mat(temp_events(:,2));
index = event_lengths > minLength;
newEvents = temp_events(index,:);
end
