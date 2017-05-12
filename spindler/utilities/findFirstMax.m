function [yMax, maxPos] = findFirstMax(y)
%% Find the first local minimum after the first local maximum
%
%  Parameters:
%    x      Vector of x values
%    y      Vector of y values
%    xMax   (Output) x value of the local minimum
%    yMax   (Output) y value of the local minimum
%    maxPos (Output) index of the local minimum
%
% Written by:  Kay Robbins, UTSA, 2017

%% Initialize the values
yMax = [];
maxPos = [];

%% Calculate the values
ySlope = diff(y);
minPos = find(ySlope > 0, 1, 'first');
if isempty(minPos)
    return;
end
yNewSlope = ySlope(minPos:end);
if isempty(yNewSlope)
    return;
end
maxPos = find(yNewSlope < 0, 1, 'first');
if isempty(maxPos)
    return;
end
maxPos = minPos + maxPos - 1;
yMax = y(maxPos);