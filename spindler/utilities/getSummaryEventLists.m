function [eventLists] = getSummaryEventLists(baseDirs, algNames)
%% Consolidate summary statistics from results files named by convention

baseStruct = struct('name', NaN, 'events', NaN, 'frames', NaN, 'srate', NaN);
numAlgs = length(algNames);
numTypes = length(baseDirs);
eventLists = cell(numAlgs, numTypes);
for k = 1:numAlgs
    for m = 1:numTypes
        resultsDir = [baseDirs{m} algNames{k}];
        resultFiles = getFiles('FILES', resultsDir, '.mat');
        numResults = length(resultFiles);
        clear ev;
        ev(numResults) = baseStruct;
        for n = 1:length(resultFiles)
            test = load(resultFiles{n});
            events = test.events;
            if isempty(events)
                continue;
            end
            ev(n) = baseStruct;
            ev(n).name = resultFiles{n};
            ev(n).events = events;
            ev(n).frames = test.params.frames;
            ev(n).srate = test.params.srate;
        end
        eventLists{k, m} = ev;
    end
end