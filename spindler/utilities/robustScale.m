function [data, winMean, winSTD] = robustScale(data, winValue)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
yScales = prctile(data, [winValue, 100-winValue], 2);

[numChans, numPts] = size(data);
% Winsorize the data
winMean = zeros(numChans, 1);
winSTD = zeros(numChans, 1);
for k = 1:numChans
    thisData = data(k, :);
    thisData(thisData < yScales(k, 1)) = yScales(k, 1);
    thisData(thisData >  yScales(k, 2)) = yScales(k, 2);
    winMean(k) = mean(thisData);
    data(k, :) = thisData - winMean(k);
    winSTD(k, :) = sqrt(sum(data(k, :).*data(k, :))/(numPts - 1));
    if winSTD(k, :) > 0
       data(k, :) = data(k, :)./winSTD(k, :);
    end
end



