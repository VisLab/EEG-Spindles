function [events] = applyThreshold(data, srate, threshold, vote_percentage)
% applyThreshold       Applies a threshold to the data
%
% Input:
%
%      data         Either a row vector or a matrix of data to threshold.
%                   If it is a row the vote_percentage is set to be 0. 
%      srate        sampling rate of the data, in Hz.
%  threshold        value to threshold the data. If the data points are
%                   greater than this value then the threshold is 1. Else 
%                   it is 0.
% vote_percentage   A number from [0,1]. This input only applies when the
%                   input data is contains more than one row. At least 
%                   (vote_percentage x rows) thresholds should be greater 
%                   than the threshold given above for the time region to
%                   be analyzed.
%
% Output:
%
%    events         a cell array of size num_events x 3. The first column
%                   is a string identifying the event, and the last two 
%                   columns denote the start and end time, in seconds.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If data is row, set voting percentage to 0.
if size(data, 1) > 1
    index1 = (mean(data>threshold) >= vote_percentage);
else
    index1 = data > threshold;
end

% find tine regions where signal crossed threshold using SplitVec
indices = SplitVec(index1, 'equal', 'loc');
thresholdValue = SplitVec(index1, 'equal', 'firstval');

% extract time indices where thresholdValue == 1 and get first and last
% frame
temp3 = find(thresholdValue==1);
index = zeros(length(temp3), 2);

% pre-allocation
events = cell(size(index, 1), 3);
for i = 1 : length(temp3)
    events{i, 1} = 'alphaspindle';
    events{i, 2} = indices{temp3(i)}(1)/srate;
    events{i, 3} = indices{temp3(i)}(end)/srate;
end


end
