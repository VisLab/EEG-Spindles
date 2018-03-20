function [kp_thresh] =kp_thresholds_ranges(data)
%data=data_epoching(sig,fs,epoch_length); % divide EEG data into "epoch_length" segments (the function output is a cell array)
for i=1:length(data)
Mkp(i)=min(data{i});
end

minKp=round(mean(Mkp));
kp_thresh=minKp:2:-20;
end

