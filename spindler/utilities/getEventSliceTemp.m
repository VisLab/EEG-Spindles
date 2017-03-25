function [events1New, events2New, startTimeNew, endTimeNew] = ...
      getEventSlice(events1, events2, startTime, endTime, slack)
  
%% Get adjusted event times  
eventMask1 = events1(:, 1) >= startTime + slack && ...
                              events1(:, 2) <= endTime - slack;
eventMask2 = events2(:, 1) >= startTime + slack && ...
                              events2(:, 2) <= endTime - slack;

%% Now adjust to make sure no other events
first1 = find(eventMask1, 1, first);
startTimeNew = startTime;
if ~isempty(first1) && first1 ~= 1
    startTimeNew = max(startTimeNew, events1(first1 - 1, 2));
end
first2 = find(eventMask2, 1, first);
if ~isempty(first2) && first2 ~= 1
    startTimeNew = max(startTimeNew, events1(first2 - 1, 2));
end

last1 = find(eventMask1, 1, last);
endTimeNew = endTime;
if ~isempty(last1) && last1 ~= size(events1, 1)
    endTimeNew = min(endTimeNew, events1(last1 + 1, 1));
end
last2 = find(eventMask2, 1, last);
if ~isempty(last2) && last2 ~= size(events2, 1)
    endTimeNew = min(endTimeNew, events2(last2 + 1, 1));
end

eventMask1 = events1(:, 1) >= startTimeNew && events1(:, 2) <= endTimeNew;
eventMask2 = events2(:, 1) >= startTimeNew && events2(:, 2) <= endTimeNew;

events2New = events2(eventMask2, :);
events1New = events1(eventMask1, :);

