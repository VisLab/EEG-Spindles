function [sp_thresh] =sp_thresholds_ranges(data,fs)
% data=data_epoching(sig,fs,epoch_length); % divide EEG data into "epoch_length" segments (the function output is a cell array)
for i=1:length(data)
%%%%% spindles range
sc=1./((10.5:0.15:16.5)/fs); %selon AASM sleep spindles dans la bande [11 16] 
wname='fbsp 20-0.5-1';  
W=cwt(data{i},sc,wname);
CTF=abs(W);
Msp(i)=max(max(CTF));
msp(i)=mean(mean(CTF));
end

maxSp=round(mean(Msp));
minSp=round(mean(msp));
sp_thresh=minSp:10:maxSp;
end

