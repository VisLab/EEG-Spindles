function events = detectEvents(data, srate, threshold)
%% Apply a voting scheme to the signal decomposition to detect events
%
% Parameters:
%
%   data             A row vector of data to threshold.
%   srate            Signal sampling rate in Hz.
%   threshold        Threshold for considering data in the event
%   events           (output) n x 2 array with event start and end times in seconds
%
%  Written by: John La Rocco and Kay Robbins, 2016-17, UTSA
%  (Adapted from code by Lawhern.)

%% Initialize the parameters
events = [];

%% Scale the input signal based on 95th percentile of the data
yScales = prctile(abs(data(:)), 95);
scaledData = abs(data./yScales);

%% Convert to a threshold mask of 0's and 1's
thresholdMask = scaledData > threshold;

%% Find start and end indices of ones mask
diffMask = diff(thresholdMask);
startIndices = find(diffMask == 1);
endIndices = find(diffMask == -1);

%% Handle spindles starting at beginning or ending at the end
startIndices = startIndices + 1;
endIndices = endIndices + 1;
if thresholdMask(1)
    startIndices = [1, startIndices];
end
if thresholdMask(end) 
    endIndices = [endIndices, length(thresholdMask)];
end
if isempty(startIndices) || isempty(endIndices)
    warning('detectEvents:NoEvents', 'No signal above threshold');
    return;
elseif length(startIndices) ~= length(endIndices) || ...
        sum(endIndices < startIndices) > 0
    error('detectEvents:BadEvents', 'Start and end of events do not match');
end

%% Convert event frames to times in seconds
events = [startIndices', endIndices'];
events = (events - 1)/srate;
