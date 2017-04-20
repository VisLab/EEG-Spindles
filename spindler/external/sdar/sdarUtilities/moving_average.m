function [vectorout]=moving_average(vectorin,eFave)

%% MOVING_AVERAGE
% function [vectorout]=moving_average(vectorin,eFave)
% Author: Adrián Lara-Quintanilla
% Date:   12/03/2013
% This function calculates a moving average
% vectorout=output
% vectorin=input
% eFave=elementsFORaverage=elements used to calculate the average. Average
% is calculated and set as the value of the element in the middle. Example:
% vectorin=[1 3 6 4 1 3 7], eFave=5, vectorout=[3 3.4 4.2] (some values
% are lost at each end of the vector, exactly, floor(eFave/2) values.
% Repairing first and last part of vector out
% It will be an average of the values until (beginning) or remaining from
% (end) the current value.

%% script

l_vectorin=length(vectorin);
l_half_interval=floor(eFave/2);     % nOe after and before the current value used for the mean

ifor1=1;
for ifor1=1:l_vectorin
    if ifor1<=l_half_interval
        vectorout(ifor1)=mean(vectorin(1:ifor1));   % Then I calculate the average with values until the current value                                    % values until this one
    elseif ifor1>l_half_interval&&ifor1<(l_vectorin-l_half_interval)
        vectorout(ifor1)=mean(vectorin(ifor1-l_half_interval:ifor1+l_half_interval));
    elseif ifor1>=(l_vectorin-l_half_interval)
        vectorout(ifor1)=mean(vectorin(ifor1:l_vectorin));   % Then I calculate the average with values until the current value                                    % values until this one
    end
end