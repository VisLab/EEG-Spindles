function [spindles, params] = mcsleepExtractSpindles(y, params)
% Extracts spindle events for range of lambda2 and threshold values
%
% Please cite as: 
% Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint 2017, doi: https://doi.org/10.1101/104414
%
% Adapted from code by Ankit Parekh (ankit.parekh@nyu.edu)
% Copyright (c) 2017. Ankit Parekh 

%% Set up the parameters
    defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
    params = processParameters('mcsleepExtractSpindles', nargin, 2, ...
                                params, defaults);
    [params.channels, params.frames] = size(y);
    thresholds = params.mcsleepThresholds;
    lambda2s = params.mcsleepLambda2s;
    fs = params.srate;
    f1 = params.mcsleepSpindleFrequencyRange(1);
    f2 = params.mcsleepSpindleFrequencyRange(2);
    [B, A] = butter(params.mcsleepFilterOrder, [f1 f2]/(fs/2));
    numThresholds = length(thresholds);
    numLambda2s = length(lambda2s);
    epochTime = params.epochLength;
    
    %% Initialize the structures
    spindles(numLambda2s, numThresholds) = ...
        struct('lambda2', NaN, 'threshold', NaN, 'numberSpindles', 0, ...
                   'spindleTime', 0, 'events', NaN);
    %%Convert data for parfor
    numEpochs = floor(params.frames/(fs *epochTime));

    %% Segment input signal into cells of epochTime seconds in length
    Y = cell(numEpochs,1);
    epochFrames = round(epochTime*fs);
    for i = 1:numEpochs
        Y{i} = y(:, (i-1)*epochFrames + 1: i*epochFrames);
    end
    fprintf('Number of epochs: %d\n', numEpochs);
    for n = 1:numLambda2s
        C = cell(numEpochs,1);
        thisLambda2 = lambda2s(n);
        parfor i = 1:numEpochs
            [~, C{i}, ~] = mcsleepSeparateSignal(Y{i}, thisLambda2, params);
        end

        %% Reassemble the signal
        s = zeros(params.channels, params.frames);
        for i = 1:numEpochs
            s(:, (i-1)*epochFrames + 1:i*epochFrames) = C{i};
        end

        %% Apply bandpass filter to oscillatory component
        bandpassFiltered = filtfilt(B, A, s');

        %% Apply Teager Operator and get the envelope
        fprintf('Evaluating envelope of bandpass filtered signal ... \n');
        envelopeSpindle = T(mean(bandpassFiltered, 2));
        for m = 1:numThresholds
            spindles(n, m) = spindles(numLambda2s, numThresholds);
            spindles(n, m).lambda2 = lambda2s(n);
            spindles(n, m).threshold = thresholds(m);    
            binary = envelopeSpindle > thresholds(m);
            binary = discardOutOfRange(binary);
            spindleMask = [0 binary(:)']; 
            spindles(n, m).events = getMaskEvents(spindleMask, params.srate);
            [spindles(n, m).numberSpindles, spindles(n, m).spindleTime] = ...
                getSpindleCounts(spindles(n, m).events);
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
        
        [binary,~,~] = minimum_duration(binary, begins, ends, ...
                       params.spindleLengthMin, fs);
        [binaryDiscard,~,~] = maximum_duration(binary, begins, ends, ...
                       params.spindleLengthMax, fs);
    end

    function y = T( x )
    %% Apply the teager operator
        y = zeros(size(x));
        y = y(1:end - 1);
        for k = 2:length(x) - 1
            y(k) = x(k)^2 - x(k - 1)*x(k + 1);
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