function [events1, events2, frameSplitFirst, frameSplitLast] = splitEvents(events, srate, params)
%% Split the events in two pieces
     
params = processParameters('splitEvents', nargin, 2, params, getGeneralDefaults());
numEvents = size(events, 1);
[frameSplitFirst, frameSplitLast, eFirst, eLast] = getSplit();
events1 = events(1:eFirst, :);
events2 = events(eLast:end, :);

    function [frameSplitFirst, frameSplitLast, eFirst, eLast] = getSplit()
        eFirst = floor(numEvents/2);
        eLast = eFirst + 1;
        lastEnd = events(eFirst, 2);
        nextStart = events(eFirst + 1, 1);
        gapTime = (nextStart - lastEnd)/2;
        frameSplitFirst = floor((nextStart - gapTime)*srate) + 1;
        frameSplitLast = frameSplitFirst + 1;
    end
end

 