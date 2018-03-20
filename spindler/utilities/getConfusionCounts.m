function [tp, tn, fp, fn] = getConfusionCounts(trueEvents, labeledEvents, ...
                              totalTime, spindleDuration, epochTime)
%% Evaluate confusion matrix based on total spindle counts
%
%  Parameters:
%     trueEvents      n x 2 array of start and end times of true events 
%     labeledEvents   m x 2 array of start and end times of labeled events
%     totalTime       time in seconds of the dataset
%     spindleDuration fixed assumed spindle length in seconds assumed to
%                     compute true negatives
%
%  Written by:  Kay Robbins, UTSA, 2017
    [~, trueList] = epochEvents(trueEvents, totalTime, epochTime);
    [~, labeledList] = epochEvents(labeledEvents, totalTime, epochTime);
    tp = 0;
    tn = 0;
    fp = 0;
    fn = 0;
    for k = 1:length(trueList)
        numTrue = size(trueList{k}, 1);
        numLabeled = size(labeledList{k}, 1);
        tpThis = min(numLabeled, numTrue);
        fpThis = max(0, numLabeled - tpThis);
        fnThis = max(0, numTrue - tpThis);
        tnThis = round((totalTime - (tpThis + fpThis + fnThis)*...
            spindleDuration)/spindleDuration);
        tp = tp + tpThis;
        tn = tn + tnThis;
        fp = fp + fpThis;
        fn = fn + fnThis;
    end