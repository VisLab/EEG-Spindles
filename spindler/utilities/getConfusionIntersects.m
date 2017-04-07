function confusion = getConfusionIntersects(trueEvents, ...
            labeledEvents, totalTime, intersectTolerance, spindleDuration)
%% Evaluate confusion matrix using the intersect method
%
%  Parameters:
%      trueEvents     n x 2 array of start and end times of true events 
%      labeledEvents  m x 2 array of start and end times of labeled events
%      tolerance      minimum amount of overlap required for match
%      intersectInfo  (output) structure containing confusion matrix
%
%  Overlap is computed as the ratio of the intersection/union of true and
%  labeled.
%
%  Written by:  Kay Robbins, UTSA, 2017
%% Evaluate confusion matrix based on if start of events match within tolerance
%
%  Parameters:
%     trueEvents     n x 2 array of start and end times of true events 
%     labeledEvents  m x 2 array of start and end times of labeled events
%     totalTime      time in seconds of the dataset
%     params         structure with other parameters
%         spindleOnsetTolerance  seconds onsets must agree for events to
%                                match
%         spindleSeconds         average spindle length in seconds for
%                                computing TN
%
%
%  Written by:  Kay Robbins, UTSA, 2017

%% Set up the parameters and initialize the variables
confusion = struct('tp', NaN, 'tn', NaN, 'fp', NaN, 'fn', NaN);

%% Set up the structure and initialize the variables
    numberTrue = size(trueEvents, 1);
    numberLabeled = size(labeledEvents, 1);
    TPMat = zeros(numberTrue, numberLabeled);
    FNMat = zeros(numberTrue, 1);
    FPMat = zeros(1, numberLabeled);
    FNNoIntersect = zeros(numberTrue, 1);
    FPNoIntersect = zeros(numberTrue, 1);
    eventMatch = zeros(numberTrue, numberLabeled);
    detectMatch = zeros(numberTrue, numberLabeled);

%% Find true and labeled events with intersections that overlap by at least tolerance
    matches = getEventIntersect();
    TPCandidates = matches > intersectTolerance;
    TPSum = sum(TPCandidates, 2);
    matchSum = sum(matches, 2);
    [~, indCand] = max(matches, [], 2);
    for i = 1:numberTrue
        if TPSum(i) > 0  % Find the largest overlap match for true event i
            eventMatch(i, indCand(i)) = 1;
        elseif matchSum(i) == 0
            FNNoIntersect(i) = 1;  % No intersections at all with true event i
        end
    end

%% Find out whether labeled events have good matches with true events
    TPSum = sum(TPCandidates, 1);
    [~, indCand] = max(matches, [], 1);
    matchSum = sum(matches, 1);
    for j = 1:numberLabeled
        if TPSum(j) > 0
            detectMatch(indCand(j), j) = 1; % Find largest overlap with labeled j
        elseif matchSum(j) == 0
            FPNoIntersect(j) = 1;  % No intersections at all with true event j
        end
    end

%% Find which detected events have intersections
    bestMatch = eventMatch + detectMatch;
    for i = 1:numberTrue
        for j = 1:numberLabeled
            if bestMatch(i, j) == 2  % Remove labeled and true events from contention
                TPMat(i, j) = 1;
                bestMatch(i, :) = 0;
                bestMatch(:, j) = 0;
            end
        end
    end

%% If still events remaining, do second round of matching
    if sum(bestMatch(:)) > 0  % Still some that aren't matched, try again
        matches2 = matches;
        matches2(bestMatch ~= 1) = 0;
        TPCandidates2 = matches2 > intersectTolerance;
        TPSum2 = sum(TPCandidates2, 2);
        eventMatch2 = zeros(numberTrue, numberLabeled);
        [~, indCand2] = max(matches2, [], 2);
        for i = 1:numberTrue
            if TPSum2(i) > 0
                eventMatch2(i, indCand2(i)) = 1;
            end
        end

        %% Find out whether labeled events have good matches with true events
        TPSum2 = sum(TPCandidates2, 1);
        detectMatch2 = zeros(numberTrue, numberLabeled);
        [~, indCand2] = max(matches2, [], 1);
        for j = 1:numberLabeled
            if TPSum2(j) > 0
                detectMatch2(indCand2(j), j) = 1;
            end
        end
        bestMatch2 = eventMatch2 + detectMatch2;
        %% Find which detected events have intersections
        for i = 1:numberTrue
            for j = 1:numberLabeled
                if bestMatch2(i, j) == 2
                    TPMat(i, j) = 1;
                end
            end
        end
    end

%% Finalize the confusion matrix
    FNMat(sum(TPMat, 2) == 0) = 1;
    FPMat(sum(TPMat, 1) == 0) = 1;

    tp = sum(TPMat(:));
    fp = sum(FPMat(:));
    fn = sum(FNMat(:));
    confusion.tp = tp;
    confusion.fp = fp;
    confusion.fn = fn;
    confusion.tn = round((totalTime - spindleDuration * (tp + fp + fn))/spindleDuration);


    function matches = getEventIntersect()
        %% Compute matrix of intersect ratios between true and labeled events
        trueStarts = trueEvents(:, 1);
        trueEnds = trueEvents(:, 2);
        labeledStarts = labeledEvents(:, 1);
        labeledEnds = labeledEvents(:, 2);
        matches = zeros(numberTrue, numberLabeled);
        for k = 1:numberTrue
            for n = 1:numberLabeled
                leftEnd = max(trueStarts(k), labeledStarts(n));
                rightEnd = min(trueEnds(k), labeledEnds(n));
                interSize = rightEnd - leftEnd;
                if interSize <= 0
                    continue;
                end
                leftEnd = min(trueStarts(k), labeledStarts(n));
                rightEnd = max(trueEnds(k), labeledEnds(n));
                unionSize = rightEnd - leftEnd;
                matches(k, n) = interSize/unionSize;
            end
        end
    end
end