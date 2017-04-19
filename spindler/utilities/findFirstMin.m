function [yMin, minPos] = findFirstMin(y)
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
yMin = [];
minPos = [];

%% Calculate the values
ySlope = diff(y);
maxPos = find(ySlope < 0, 1, 'first');
if isempty(maxPos)
    return;
end
yNewSlope = ySlope(maxPos + 1:end);
if isempty(yNewSlope)
    return;
end
minPos = find(yNewSlope >= 0, 1, 'first');
if isempty(minPos)
    return;
end
minPos = maxPos + minPos;
yMin = y(minPos);