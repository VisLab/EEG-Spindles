function thresholdRange = spinkyGetThresholdRange(data, fs, frequencyRange)
%% Compute threshold grid from data --- from original Spinky implementation
% data=data_epoching(sig,fs,epoch_length); % divide EEG data into "epoch_length" segments (the function output is a cell array)
   sc = 1./((frequencyRange(1):0.15:frequencyRange(2))/fs); %selon AASM sleep spindles dans la bande [11 16]
   wname = 'fbsp 20-0.5-1';
   [numEpochs, ~] = size(data);
   maximumSP = zeros(numEpochs, 1);
   meanSP = zeros(numEpochs, 1);
   for i = 1:numEpochs
        W = cwt(data(i, :), sc, wname);
        CTF = abs(W);
        maximumSP(i) = max(CTF(:));
        meanSP(i) = mean(CTF(:));
    end

    maxSp = round(mean(maximumSP));
    minSp = round(mean(meanSP));
    thresholdRange = minSp:10:maxSp;
end