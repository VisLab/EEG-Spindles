function cellEvents = epochedToCell(events)
%% Translate a three-column array of epoched events to a cell array
%
%  Parameters:
%      events      Three column array (epoch#, startTime, endTime) of events
%      cellEvents  Cell array with one cell for each epoch. Each cell
%                  contains an nx2 array of start and end time

%% Process the events