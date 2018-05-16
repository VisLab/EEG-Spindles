function events = epochedToList(epochedEvents, epochTime)
%% Translate a cell array of epoched events to a single array of events
%
%  Parameters:
%      epochedEvents  Cell array containing events for each epoch
%      events         n x 2 array with consolidated event list
%

%% Process the events
if isempty(epochedEvents) || ~iscell(epochedEvents)
    events = [];
    return;
elseif ~iscell(epochedEvents)
    events = epochedEvents;
    return;
end

numEpochs = length(epochedEvents);
eventTime  = 0;
events = epochedEvents{1};
for k = 2:numEpochs
    eventTime = eventTime + epochTime;
    nextEvents = epochedEvents{k} + epochTime;
    events = [events; nextEvents]; %#ok<AGROW>
end
