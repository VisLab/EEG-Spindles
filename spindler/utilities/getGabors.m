function gabors = getGabors(srate, atomFrequencies, atomScales)
deviationFactor = 3;  
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
%Scale the gabors to have sum(gabors.^2)
scales = 1./sqrt(sum(gabors.^2));
gabors = bsxfun(@times, gabors, scales);