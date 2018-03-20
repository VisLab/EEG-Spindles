function events = getMassEvents(fileName, startTime, endTime) 
%% Return MASS events that are between startTime and endTime
    if ~exist(fileName, 'file')
        warning('%s does not exist', filename);
        events = [];
        return;
    end
    file1 = load(fileName);
    events = file1.expert_events;
    startEvents = double(cell2mat(events(:, 2)));
    endEvents = double(cell2mat(events(:, 3)));
    eventMask = startTime <= startEvents & startEvents <= endTime;
    startEvents = startEvents(eventMask);
    endEvents = min(endEvents(eventMask), endTime);
    events = [startEvents(:), endEvents(:)];