function [onsets,spindle_duration ] = pos2onset(possp,fs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
            y=possp;
            sa=sign(diff([-inf y]));
            sb=sign(diff([-inf y(end:-1:1)]));
            sb=sb(end:-1:1);
            d=find(sb==-1);
            f=find(sa==-1);
            

            for i=1:length(f)
            gh(2*i-1)=d(i)/fs;
            gh(2*i)=f(i)/fs;
            spindle_duration(i)=gh(2*i)-gh(2*i-1);
            end
            onsets=gh;



end

