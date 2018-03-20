function [tp, tn, fp, fn] = getConfusionHits(trueEvents, labeledEvents, ...
                                     totalTime, defaultSpindleLength)
%% Calculate confusion matrix for trueEvents and labeledEvents using hit method
%
% Parameters:
%    trueEvents     n x 2 array with true start and end event times 
%    labeledEvents  m x 2 array with labeled start and end event times 
%    totalTime      total time of the data 
%    defaultSpindleLength   amount of time spindles occupy by default (for tn)
%    confusion      (output) structure with confusion matrix (tp, tn, fp, fn)
%
% Written by: Kay Robbins 2017, UTSA
%
%% Initialize the variables

    %% Handle the boundary cases first
    numTrue = size(trueEvents, 1);
    numLabeled = size(labeledEvents, 1);
    if numTrue == 0 && numLabeled == 0
        tp = 0;
        fp = 0;
        tn = 0;
        fn = round(totalTime/defaultSpindleLength);
        return;
    elseif numTrue == 0
        labeledTime = sum(labeledEvents(:, 2) - labeledEvents(:, 1));
        tp = 0;
        fp = numLabeled;
        tn = round((totalTime - labeledTime)/defaultSpindleLength);
        fn = 0;
        return;
    elseif numLabeled == 0
        trueTime = sum(trueEvents(:, 2) - trueEvents(:, 1));
        tp = 0;
        fp = 0;
        tn = round((totalTime - trueTime)/defaultSpindleLength);
        fn = numTrue;
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
    fp = sum(labeledMarks == 0);
    tp = sum(trueMarks ~= 0);
    fn = sum(trueMarks == 0);
    tn = sum(nullMarks ~= 0);
end

