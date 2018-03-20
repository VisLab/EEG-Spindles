function [spindles] = analyzeSpindles(params)
% function [spindles] = analyzeSpindles(params)
%
% This function runs the mcsleep spindle detection in parallel
% Ensure that the EDF file given by params.filename is in the current
% directory (or added to path)
% 
% Please cite as: 
% Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint 2017, doi: https://doi.org/10.1101/104414
%
% Last EDIT: 4/22/2017
% Ankit Parekh
% Perm. Contact: ankit.parekh@nyu.edu
%
% Copyright (c) 2017. Ankit Parekh 
% 
fprintf('Multichannel spindle detector \n');
numChannels = size(params.y,1);
fs = params.fs;
N = size(params.y,2);

% Estimate the raw oscillations using fusedLasso LLR
fprintf('Starting Fused Lasso LLR algorithm ...\n')

% Create H and HT transforms. See paper for details.
H = @(x,s,k) Op_A(x,s,k);
HT = @(x,s,k) Op_AT(x,s,k);

fprintf('Requested Fused Lasso LLR algorithm to be run on full EEG ...\n')
fprintf('Over-riding the calculate cost option for parallel execution ... \n')

%Convert data for parfor
numEpochs = floor(N / (fs *30));
X = cell(numEpochs,1);
C = cell(numEpochs,1);
Y = cell(numEpochs,1);

% Segment input signal into cells
for i = 1:numEpochs
    Y{i} = params.y(:, (i-1)*30*fs + 1: i*30*fs);
end

% No need to store the input signal twice
tic
parfor i = 1:numEpochs
    [X{i}, C{i}, ~] = mcsleep(Y{i}, H, HT, params);
end
toc
fprintf('Parallel execution done ... \n')
% Convert cells to full length signal
s = zeros(numChannels, N);
for i = 1:numEpochs
    s(:, (i-1)*30*fs + 1:i*30*fs) = C{i};
end

% Clear expensive variables that are not needed
clear X C Y x;

% Apply bandpass filter to oscillatory component
fprintf('Applying bandpass filter to oscillatory component ... \n');
[B,A] = butter(params.filtOrder, [params.f1 params.f2]/(fs/2));
bandpassFiltered = filtfilt(B,A,s');

% Apply Teager Operator and get the envelope
fprintf('Evaluating envelope of bandpass filtered signal ... \n');
if params.meanEnvelope
    envelopeSpindle = T(mean(bandpassFiltered,2));
else
    envelopeSpindle = T(bandpassFiltered(:,params.desiredChannel));
end
binary = envelopeSpindle > params.Threshold;

% Discard all spindles less than 0.5 seconds and larger than 3 seconds
fprintf('Discarding all spindles less than 0.5 seconds and larger than 3 seconds ... \n')
E = binary(2:end)-binary(1:end-1);
sise = size(binary);

begins = find(E==1)+1;

if binary(1) == 1
    if sise(1) > 1
        begins = [1; begins];
    elseif sise(2) > 1
        begins = [1 begins];
    else
        error('The input signal is not one dimensional')
    end
elseif numel(begins) == 0 && binary(1) == 0
    begins = NaN;
end

ends = find(E==-1);
if binary(end) == 1
    if sise(1) > 1
        ends = [ends; length(binary)];
    elseif sise(2) > 1
        ends = [ends length(binary)];
    else
        error('The input signal is not one dimensional')
    end
elseif numel(ends) == 0 && binary(end) == 0
    ends = NaN;
end

[binary,~,~] = minimum_duration(binary,begins,ends,0.5,fs);
[binary,~,~] = maximum_duration(binary,begins,ends,3,fs);

spindles = [0 binary];
fprintf('Spindle calculation done ... \n');

%% Functions from Warby et al. 2014 for discarding spindles

    function [DD,begins,ends] = minimum_duration(DD,begins,ends,min_dur,fs)
        % MINIMUM_DURATION - checks the sample duration of the spindles.
        % Input is a vector containing ones in the interval where the spindle is
        % and indexs describing the start and end of the spindle. The last two
        % inputs are the minimum duration given in seconds and the sampling
        % frequency given in Hz.
        % Output is a vector containing ones in the interval where the spindle with
        % duration longer than or equal to the minimum duration is and indexs
        % describing the start and end of the spindle.
        
        duration_samples = ends-begins+1;
        for k = 1:length(begins)
            if duration_samples(k) < min_dur*fs
                DD(begins(k):ends(k)) = 0;
                begins(k) = 0;
                ends(k) = 0;
            end
        end
        begins = begins(begins~=0);
        ends = ends(ends~=0);
    end

    function [DD,begins,ends] = maximum_duration(DD,begins,ends,max_dur,fs)
        % MAXIMUM_DURATION - checks the sample duration of the spindles.
        % Input is a vector containing ones in the interval where the spindle is
        % and indexs describing the start and end of the spindle. The last two
        % inputs are the maximum duration given in seconds and the sampling
        % frequency given in Hz.
        % Output is a vector containing ones in the interval where the spindle with
        % duration shorter than or equal to the maximum duration is and indexs
        % describing the start and end of the spindle.
        
        duration_samples = ends-begins+1;
        for k = 1:length(begins)
            if duration_samples(k) > max_dur*fs
                DD(begins(k):ends(k)) = 0;
                begins(k) = 0;
                ends(k) = 0;
            end
        end
        begins = begins(begins~=0);
        ends = ends(ends~=0);
    end

end






















