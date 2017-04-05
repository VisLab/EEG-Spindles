function confusion = getConfusionHits(trueEvents, labeledEvents, totalTime)
%% Calculate confusion matrix for trueEvents and labeledEvents in [startTime, endTime] using hit method
%
% Parameters:
%    trueEvents     n x 2 array with true start and end event times in columns
%    labeledEvents  m x 2 array with labeled start and end event times in columns
%    startTime      minimum time of data slice
%    endTime        maximum time of the data slice
%    confusion      (output) structure with confusion matrix (tp, tn, fp, fn)
%
% Written by: Kay Robbins 2017, UTSA
%
%% Initialize the variables
confusion = struct('tp', NaN, 'tn', NaN, 'fp', NaN, 'fn', NaN);
numTrue = size(trueEvents, 1);
numLabeled = size(labeledEvents, 1);

%% Handle the boundary cases first
if isempty(trueEvents)
    confusion.tp = 0;
    confusion.fp = numLabeled;
    confusion.tn = 1;
    confusion.fn = 0;
    return;
elseif isempty(labeledEvents)
    confusion.tp = 0;
    confusion.fp = 0;
    confusion.tn = 1;
    confusion.fn = numTrue;
    return;
end

%% Match hits on true events
trueMarks = zeros(numTrue, 1);
labeledPos = 1;
for k = 1:numTrue
    while labeledPos <= numLabeled && ...
            labeledEvents(labeledPos, 2) < trueEvents(k, 1)
        labeledPos = labeledPos + 1;
    end
    if labeledPos <= numLabeled && ...
            labeledEvents(labeledPos, 1) <= trueEvents(k, 2)
        trueMarks(k) = labeledPos;
    end
end

%% Match hits on labeled events
labeledMarks = zeros(numLabeled, 1);
truePos = 1;
for k = 1:numLabeled
    while truePos <= numTrue && ...
            trueEvents(truePos, 2) < labeledEvents(k, 1)
        truePos = truePos + 1;
    end
    if truePos <= numTrue && ...
            trueEvents(truePos, 1) <= labeledEvents(k, 2)
        labeledMarks(k) = truePos;
    end
end

%% Match hits on complementary events
notTrue = getComplementEvents(trueEvents, totalTime);
notLabeled = getComplementEvents(labeledEvents, totalTime);
numNotTrue = size(notTrue, 1);
numNotLabeled = size(notLabeled, 1);
nullMarks = zeros(numNotTrue, 1);
labeledPos = 1;
for k = 1:numNotTrue
    while labeledPos <= numNotLabeled && ...
          notLabeled(labeledPos, 2) < notTrue(k, 1)
        labeledPos = labeledPos + 1;
    end
    if labeledPos <= numNotLabeled && ...
          notLabeled(labeledPos, 1) <= notTrue(k, 2)
       nullMarks(k) = labeledPos;
    end
end

%% Set up the confusion matrix for return
confusion.fp = sum(labeledMarks == 0);
confusion.tp = sum(trueMarks ~= 0);
confusion.fn = sum(trueMarks == 0);
confusion.tn = sum(nullMarks ~= 0);

end

