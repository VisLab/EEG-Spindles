function mcSleepSpindles = mcsleepCalculateSpindles(y, thresholds, lambda2s, params)
% function [spindles] = parallelSpindleDetection(params)
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

% fprintf('Multichannel spindle detector \n');
% % Load the edf and necessary information
% [data, header] = lab_read_edf([params.filename, '.edf']);
% fprintf([params.filename, '.edf loaded \n']);
% fs = header.samplingrate;
% 
% % Load the desired channels
% N = header.numtimeframes;
% numChannels = length(params.channels);
% y = zeros(numChannels, N);
% for i = 1:numChannels
%     y(i,:) = data(params.channels(i),:);
% end
% 
% % Clear expensive variables that are not required
% clear data;

% % Estimate the raw oscillations
% fprintf('Starting mcsleep transient separation algorithm ...\n')

%% Set up the parameters
    [numChans, numFrames] = size(y);
    fs = params.srate;
    f1 = params.mcsleepSpindleFrequencyRange(1);
    f2 = params.mcsleepSpindleFrequencyRange(2);
    [B, A] = butter(params.mcsleepFilterOrder, [f1 f2]/(fs/2));
    numThresholds = length(thresholds);
    numLambda2s = length(lambda2s);
    epochTime = params.epochLength;
    %% Initialize the structures
    totalParms = length(thresholds)*length(lambda2s);
    mcSleepSpindles(totalParms) = ...
        struct('lambda2', NaN, 'threshold', NaN, 'spindles', NaN);
    %%Convert data for parfor
    numEpochs = floor(numFrames / (fs *epochTime));

    %% Segment input signal into cells of epochTime seconds in length
    Y = cell(numEpochs,1);
    for i = 1:numEpochs
        Y{i} = y(:, (i-1)*epochTime*fs + 1: i*epochTime*fs);
    end
    fprintf('Number of epochs: %d\n', numEpochs);
    % parfor i = 1:numEpochs
    pos = 0;
    for n = 1:numLambda2s
        C = cell(numEpochs,1);
        for i = 1:numEpochs
            [~, C{i}, ~] = mcsleepSeparateSignal(Y{i}, lambda2s(n), params);
        end

        %% Reassemble the signal
        s = zeros(numChans, numFrames);
        for i = 1:numEpochs
            s(:, (i-1)*epochTime*fs + 1:i*epochTime*fs) = C{i};
        end

        %% Apply bandpass filter to oscillatory component
        bandpassFiltered = filtfilt(B, A, s');

        %% Apply Teager Operator and get the envelope
        fprintf('Evaluating envelope of bandpass filtered signal ... \n');
        envelopeSpindle = T(mean(bandpassFiltered, 2));
        for m = 1:numThresholds
            pos = pos + 1;
            mcSleepSpindles(pos) = mcSleepSpindles(end);
            mcSleepSpindles(pos).lambda2 = lambda2s(n);
            mcSleepSpindles(pos).threshold = thresholds(m);    
            binary = envelopeSpindle > thresholds(m);
            binary = discardOutOfRange(binary);
            spindleMask = [0 binary(:)']; 
            mcSleepSpindles(pos).spindles = ...
                               getMaskEvents(spindleMask, params.srate);
        end
    end

    function binaryDiscard = discardOutOfRange(binary)
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
        [binaryDiscard,~,~] = maximum_duration(binary,begins,ends,3,fs);
    end

%% Teager operator
    function [ y ] = T( x )
        %applies the teager operator, and returns the output
        %y = T(x)
        
        y = zeros(size(x));
        y = y(1:end-1);
        for k = 2:length(x)-1
            y(k) = x(k)^2 - x(k-1)*x(k+1);
        end      
    end

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