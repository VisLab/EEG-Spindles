function events = readEvents(theDir, theName, isEpoched, epochTime)
%% Reads events in either format and returns events
%
%  Parameters
%     theDir        directory of the .mat file containing the events 
%     theName       name of the .mat file containing the events
%     isEpoched     optional logical parameter indicating whether epoched
%     events       (output) two-column array with event start and ends
%                      or a cell array whose entries are two-column arrays
%
%  Written by:  Kay Robbins, UTSA, 2017
%
%  The readEvents function recognizes several formats 
%% Perform the operations

    events = [];
    if isempty(theDir) || isempty(theName) || ...
       ~exist([theDir filesep theName], 'file')
        return;
    end
    
    eventsIn = load([theDir filesep theName]);
    if nargin > 2 && isEpoched
        events = epochedToList(eventsIn, epochTime);
        return;
    end

    
    if isnumeric(eventsIn) && size(eventsIn, 2) >= 2
        events = eventsIn(:, 1:2);
    elseif isfield(eventsIn, 'events')
        events = eventsIn.events;
    elseif isfield(eventsIn, 'expert_events')
        events = eventsIn.expert_events;
    elseif isfield(eventsIn, 'expertEvents')
        events = eventsIn.expertEvents;
    else
        warning('readEvents:NotRecognized', 'Unrecognized file format for events');
    end
    if iscell(events)
        startEvents = cellfun(@double, events(:, 2));
        endEvents = cellfun(@double, events(:, 3));
        events = [startEvents(:), endEvents(:)];
    end

        
   