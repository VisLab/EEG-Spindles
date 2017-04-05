function [gabors, sigmaFreq] = getGabors(srate, params)
%% Create a dictionary of zero-phase Gabor atoms for specified parameters
%
%  Parameters:
%     srate            sampling rate in Hz of the Gabor dictionary
%     params           structure with optional parameters
%        gaborFrequencies
%        gaborScales
%        gaborSupportFactor
%
%  Output:
%     gabors         K x L array containing K gabor atoms of length L
%     sigmaFreq      K x 2 array containing SD and frequency of the
%                      K Gabor atoms in the columns
%  
%  Written by:  Kay Robbins, 2015-2017, UTSA
%

%% Set up the parameters
params = processSpindlerParameters('getGabors', nargin, 1, params);
atomSupportFactor = params.gaborSupportFactor; 
atomScales = params.gaborScales;
atomFrequencies = params.gaborFrequencies;
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

%% Create the time vector, making sure there are an odd number of elements
t = 1/srate:1/srate:atomSupportFactor*maxSD;
t = [fliplr(-t), 0, t];

%% Create Gabors
gabors = zeros(length(t), numberGabors);
for k = 1:numberGabors
    factor = sigmaFreq(k, 1)*sqrt(2*pi);
    gabors(:, k) = exp(-.5*(t.^2)*sigmaFreq(k, 1).^(-2)).*cos(2*pi*t*sigmaFreq(k, 2))./factor;
end

%% Scale the Gabors by sum(gabors.^2)
scales = 1./sqrt(sum(gabors.^2));
gabors = bsxfun(@times, gabors, scales);