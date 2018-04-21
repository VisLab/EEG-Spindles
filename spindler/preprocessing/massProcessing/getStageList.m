function stageList = getStageList(stageEvents, stageTypes, stageMatch)
%% Returns a list of start and stop times for a given stage.
%
    stageMask = strcmpi(stageTypes, stageMatch);
   
    %% Find the starts of consecutive groups
    stageMask = [0; stageMask(:); 0];
    groupDiffs = diff(stageMask);  
    groupStarts = find(groupDiffs == 1);
    groupEnds = find(groupDiffs == -1);
    groupEnds = groupEnds - 1;
    numGroups = length(groupStarts);
    stageList = zeros(numGroups, 2);
    for k = 1:numGroups
        stageList(k, 1) = stageEvents(groupStarts(k), 1);
        stageList(k, 2) = stageEvents(groupEnds(k), 2);
    end