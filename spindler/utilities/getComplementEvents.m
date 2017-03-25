function complementEvents = getComplementEvents(events, finalTime)
%% Return an event array with the complement of the events in events
%
%  Parameters
%     events            n x 2 array with the start and end event times in columns
%     finalTime         time in seconds of the last frame
%     complementEvents  (output) m x 2 array with complementary events
%  
%  Written by:  Kay Robbins, 2017, UTSA
%
eventStarts = events(:, 1);
eventEnds = events(:, 2);
complementStarts = [0; eventEnds];
complementEnds = [eventStarts; finalTime];
mask = complementStarts == complementEnds;
complementStarts(mask) = [];
complementEnds(mask) = [];
complementEvents = [complementStarts, complementEnds];