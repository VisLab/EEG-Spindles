function events = epochedToList(eventsIn, epochTime)
%% Translate a three-column array of epoched events to a cell array
%
%  Parameters:
%      events      Three column array (epoch#, startTime, endTime) of events
%      cellEvents  Cell array with one cell for each epoch. Each cell
%                  contains an nx2 array of start and end time

%% Process the events
if isempty(eventsIn) || size(eventsIn, 2) < 3
    events = [];
    warning('Expecting a three-column array of epoched events');
    return;
end

numEvents = size(eventsIn, 1);
events = zeros(numEvents, 2);
for k = 1:numEvents
    events(k, :) = eventsIn(k, 2:3) + (eventsIn(k, 1) - 1)*epochTime;
end
    