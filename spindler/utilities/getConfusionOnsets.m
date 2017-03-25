function [confusion, params] = getConfusionOnsets(trueEvents, labeledEvents, totalTime, params)
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
params = processSpindleParameters('getOnsetConfusion', nargin, 3, params);
onsetTolerance = params.spindleOnsetTolerance;
spindleSeconds = params.spindleSeconds;
confusion = struct('tp', NaN, 'tn', NaN, 'fp', NaN, 'fn', NaN);

%% 
trueStarts = trueEvents(:, 1);
labeledStarts = labeledEvents(:, 1);

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
confusion.fp = fp;
confusion.tp = tp;
confusion.fn = fn;
confusion.tn = round((totalTime - spindleSeconds * (tp + fp + fn))/spindleSeconds);
