function [tp, tn, fp, fn] = getConfusionOnsets(trueEvents, labeledEvents, ...
                                totalTime, onsetTolerance, spindleDuration)
%% Evaluate confusion matrix based on if start of events match within tolerance
%
%  Parameters:
%     trueEvents      n x 2 array of start and end times of true events 
%     labeledEvents   m x 2 array of start and end times of labeled events
%     totalTime       time in seconds of the dataset
%     onsetTolerance  minimum distance in onsets for two spindles to match
%     spindleDuration fixed assumed spindle length (s) assumed to
%                     compute true negatives
%
%  Written by:  Kay Robbins, UTSA, 2017

%% Set up the parameters and initialize the variables
if isempty(trueEvents)
    trueStarts = [];
else
    trueStarts = trueEvents(:, 1);
end
if isempty(labeledEvents)
    labeledStarts = [];
else
    labeledStarts = labeledEvents(:, 1);
end


tp = 0;
fp = 0;
fn = 0;
for k = 1:length(labeledStarts)
   distTrue = abs(trueStarts - labeledStarts(k)) < onsetTolerance;
   if sum(distTrue) > 0
       tp = tp + 1;
   else
       fp = fp + 1;
   end
end

for k = 1:length(trueStarts)
   distTrue = abs(labeledStarts - trueStarts(k)) < onsetTolerance;
   if sum(distTrue) == 0
       fn = fn + 1;
   end
end

%% Set up confusion matrix for return
fp = fp;
tp = tp;
fn = fn;
tn = round((totalTime - spindleDuration * (tp + fp + fn))/spindleDuration);
