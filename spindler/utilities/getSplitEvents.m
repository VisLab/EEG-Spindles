function  splitEvents = getSplitEvents(eventFile, splitTimes)
%% Split events into epochs. 
%
%  Parameters:
%      eventFile     file containing events
%      splitTimes    n x 2 array containing start and length of splits
%      splitEvents   cell array containing arrays of events in each range
%
%  When an event spans two splits, it is put in section of the start.
%  Written by: Kay Robbins, UTSA, 2017
%
%% Perform the split

    numSplits = size(splitTimes, 1);
    splitEvents = cell(numSplits, 1);
    if numSplits == 0
        return;
    end
    
    events = readEvents(eventFile);
    if isempty(events)
        return;
    end
   
    for k = 1:numSplits
       eventMask = splitTimes(k, 1) <= events(:, 1) & ...
                   events(:, 1) <= splitTimes(k, 2);
       splitEvents{k} = min(events(eventMask, :), splitTimes(k, 2));
       splitEvents{k} = splitEvents{k} - splitTimes(k, 1);
    end
end