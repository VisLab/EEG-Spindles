function expertEvents = readEvents(filePath)
%% Reads events in either format and returns expertEvents
%
%  Parameters
%     filePath      path of the .mat file containing the events 
%     expertEvents  (output) two-column event array with start and end
%
%  Written by:  Kay Robbins, UTSA, 2017
%% Perform the operations
    expertEvents = [];
    if isempty(filePath)
        return;
    end
    testEvents = load(filePath);
    if isfield(testEvents, 'expert_events') && iscell(testEvents.expert_events)
        startEvents = cellfun(@double, testEvents.expert_events(:, 2));
        endEvents = cellfun(@double, testEvents.expert_events(:, 3));
        expertEvents = [startEvents(:), endEvents(:)];
    elseif isfield(testEvents, 'expertEvents') && size(testEvents.expertEvents, 2) == 2
        expertEvents = testEvents.expertEvents;
    else
        warning('readEvents:NotRecognized', 'Unrecognized file format for events');
    end