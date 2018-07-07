function [reconstructed, sigmaFreq, atomParams, gabors] = mpReconstruct( ...
            EEG, channelNumbers, numberAtoms, atomFrequencies, atomScales)

%--------------------------------------------------------------------------
% mpReconstruct

% Last updated: October 2016, J. LaRocco

% Details: MP reconstruction of EEG with restricted dictionary.

% Usage:
% [smoothed,ws,sigmaFreq,atomParams,gabors] = mpReconstruct(EEG,channel_index,values,bounds,scales)

% Input:
%  EEG: Input EEG struct. (EEGLAB format)
%  channel_index: A matrix of channels to limit analysis to.
%  values: total number of atoms to use in reconstruction. (Scalar, positive integer)
%  bounds: frequency boundry to restrict reconstruction to. (1x2 vector with positive integers, e.g.,[6 14])
%  scales: scales of gabor atoms in a positive vector [0.5 1 2]
%  gabors: Gabor dictionary

% Output:
%  smoothed: MP reconstruction (matrix of channels by samples)
%  ws: MP atom coefficients (matrix of dimensions of channel by gabors)
%  sigmaFreq: 2 column matrix with scale values in first column and freq in second column
%  atomParams: Information on each atom: 1st column: atomIndex, 2nd: timeFrame, 3rd: amplitude

%--------------------------------------------------------------------------

deviationFactor = 3;  %Number of standard deviations for the support
srate = EEG.srate;
numberScales = length(atomScales);
numberFreq = length(atomFrequencies);
numberGabors = numberFreq*numberScales;
sigmaFreq = zeros(numberGabors, 2);
k = 1;
for n = 1:numberScales
    for m = 1:numberFreq
        sigmaFreq(k, 1) = 0.5*atomScales(n);
        sigmaFreq(k, 2) = atomFrequencies(m);
        k = k + 1;
    end
end
maxSD = max(atomScales)/2;
t = -deviationFactor*maxSD:1/srate:deviationFactor*maxSD;  % time in seconds

%% Create Gabors
gabors = zeros(length(t), numberGabors);
for k = 1:numberGabors
    factor = sigmaFreq(k, 1)*sqrt(2*pi);
    gabors(:, k) = exp(-.5*(t.^2)*sigmaFreq(k, 1).^(-2)).*cos(2*pi*t*sigmaFreq(k, 2))./factor;
end
%Scale the gabors to have sum(B.^2)
scales = 1./sqrt(sum(gabors.^2));
gabors = bsxfun(@times, gabors, scales);
    
reconstructed = zeros(length(channelNumbers),size(EEG.data,2));
ws = zeros(length(channelNumbers), size(EEG.data,2), size(gabors, 2));
atomParams = zeros(length(channelNumbers), numberAtoms, 3);
for k = 1:length(channelNumbers)
    [ws(k,:,:),reconstructed(k,:),atomParams(k,:,:)] = ...
        temporalMP(EEG.data(channelNumbers(k),:)', gabors, false, numberAtoms); 
end