function [confusion, params] = getConfusionTimes(trueEvents, labeledEvents, ...
                      totalFrames, srate, params)
%% Evaluate timing errors in comparing labelSet1(truth) against labeledSet2
%
%  Parameters
%     eventSet
%% Process the defaults and initialize parameters
    confusion = struct('tp', NaN, 'tn', NaN, 'fp', NaN, 'fn', NaN);
    params = processSpindleParameters('getTimingConfusion', nargin, 4, params);
    timingTolerance = params.spindleTimingTolerance;
   
    %% Initialize the variables and express frames in terms of events
    timingSamples = floor(timingTolerance * srate);
    frameMask1 = getFrameMask(trueEvents);
    frameMask2 = getFrameMask(labeledEvents);
    overlaps = frameMask1 + frameMask2;
    matchMask = overlaps == 2;
    diffMask = diff(matchMask);
    startMatches = find(diffMask == 1) + 1;
    endMatches = find(diffMask == -1) + 1;
    extendMask1 = false(size(matchMask)); 
    extendMask2 = false(size(matchMask));
    for k = 1:length(startMatches)
        if startMatches(k) == 1
            continue;
        elseif frameMask1(startMatches(k) - 1) == 1
            extendMask1 = extendMask1 | ...
                extendBefore(frameMask1, startMatches(k) - 1, timingSamples);
        elseif frameMask2(startMatches(k) - 1) == 1
            extendMask2 = extendMask2 | extendBefore(frameMask2, ...
                 startMatches(k) - 1, timingSamples);
        end
    end
    
    for k = 1:length(endMatches)
        if endMatches(k) == length(matchMask);
            continue;
        elseif frameMask1(endMatches(k) + 1) == 1
            extendMask1 = extendMask1 | ...
                extendAfter(frameMask1, endMatches(k) + 1, timingSamples);
        elseif frameMask2(endMatches(k) + 1) == 1
            extendMask2 = extendMask2 | extendAfter(frameMask2, ...
                endMatches(k) + 1, timingSamples);
        end
    end 
    
    overlaps = frameMask1 + frameMask2 + extendMask1 + extendMask2;
    overlaps(overlaps > 2) = 2;
    overlapMask = overlaps == 2;
    confusion.tp = sum(overlapMask)/srate;
    confusion.fn = sum(frameMask1 & overlapMask == 0)/srate;
    confusion.fp = sum(frameMask2 & overlapMask == 0)/srate;
    confusion.tn = (totalFrames - 1)/srate - confusion.tp - confusion.fn - confusion.fp;

    function [frameMask, eventFrames] = getFrameMask(eventSet)
        %% Calculate frameMask which has true for frames inside events
        frameMask = false(1, totalFrames);
        eventFrames = floor(eventSet*srate) + 1;
        for m = 1:size(eventSet, 1)
            frameMask(eventFrames(m, 1):eventFrames(m, 2)) = true;
        end
    end
    
    function newMask = extendBefore(testMask, position, maxFrames)
         newMask = false(size(testMask));
         p = position;
         bPosition = max(position - maxFrames + 1, 1);
         while (bPosition <= p)
             if ~testMask(p)
                 return;
             end
             newMask(p) = true;
             p = p - 1;
         end
    end
    
    function newMask = extendAfter(testMask, position, maxFrames)
         newMask = false(size(testMask));
         p = position;
         bPosition = min(position + maxFrames - 1, length(newMask));
         while (p <= bPosition)
             if ~testMask(p)
                 return;
             end
             newMask(p) = true;
             p = p + 1;
         end
    end
end