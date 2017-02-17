function interInfo = evaluateIntersectHits(trueEvents, labeledEvents, tolerance)
% [# Locate event spindles and detection spindles. 
%     E is the set of event spindles in temporal order and 
%     E(i) is the ith event spindle of the total I event spindles. 
%     D is the set of detection spindles in temporal order and 
%     D(j) is the jth detection spindle of the total J detection spindles.]  


interInfo = struct('tp', NaN, 'tn', NaN, 'fp', NaN, 'fn', NaN);
%% Set up the base
numberTrue = size(trueEvents, 1);
numberLabeled = size(labeledEvents, 1);
matches = getEventIntersect(trueEvents, labeledEvents);
TPMat = zeros(numberTrue, numberLabeled);
FNMat = zeros(numberTrue, 1);
FPMat = zeros(1, numberLabeled);
FNNoIntersect = zeros(numberTrue, 1);
FPNoIntersect = zeros(numberTrue, 1);
eventMatch = zeros(numberTrue, numberLabeled);
detectMatch = zeros(numberTrue, numberLabeled);


%% Find true and labeled events with intersections that overlap by at least tolerance
TPCandidates = matches > tolerance;
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

%% See where true and labeled best matches agree
bestMatch = eventMatch + detectMatch;

%% Find which detected events have intersections
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
    TPCandidates2 = matches2 > tolerance;
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

FNMat(sum(TPMat, 2) == 0) = 1;
FPMat(sum(TPMat, 1) == 0) = 1;

interInfo.tp = sum(TPMat(:));
interInfo.fp = sum(FPMat(:));
interInfo.fn = sum(FNMat(:));

    function matches = getEventIntersect(trueEvents, labeledEvents)
        trueStarts = cellfun(@double, trueEvents(:, 2));
        trueEnds = cellfun(@double, trueEvents(:, 3));
        labeledStarts = cellfun(@double, labeledEvents(:, 2));
        labeledEnds = cellfun(@double, labeledEvents(:, 3));
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