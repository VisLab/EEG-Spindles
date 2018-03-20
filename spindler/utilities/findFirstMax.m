function [yMax, maxPos] = findFirstMax(y, minTarget)
%% Find the first local maximum that is at least as large as minTarget
%
%  Parameters:
%    y      Vector of y values
%    xMax   (Output) x value of the local minimum
%    yMax   (Output) y value of the local minimum
%    maxPos (Output) index of the local minimum
%
% Written by:  Kay Robbins, UTSA, 2017

%% Initialize the values
yMax = [];
maxPos = [];

%% If minTarget is not passed, it is assumed to be zero
if nargin == 1
    minTarget = 0;
end

%% Extend the y at either end
yTest = [0; y(:); 0];

%% Calculate the values
ySlope = diff(yTest);
for k = 1:length(y)
    if ySlope(k) >= 0 && ySlope(k + 1) < 0 && y(k) >= minTarget
        yMax = y(k);
        maxPos = k;
        return;
    end
end
