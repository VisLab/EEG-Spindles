function splitTimes = getSplitTimes(totalTime, numSplits)
%% Return start and end times of numSplits
%
%  Parameters:
%     totalTime   total time in seconds to split
%     numSplits   number of pieces to split up
%     splitTimes  (output) (numSplits+1) x 2 with the split start and end
%     times
%
%  Used to calculate times for splitting data for supervised running
%
   splitTimes = zeros(numSplits + 1, 2);
   splitInc = double(totalTime)/(numSplits + 1);
   splitEnd = splitInc;
   for k = 1:numSplits
       splitTimes(k, 2) = splitEnd;
       splitTimes(k + 1, 1) = splitEnd;
       splitEnd = splitEnd + splitInc;
   end
   splitTimes(end, 2) = min(splitEnd, totalTime);