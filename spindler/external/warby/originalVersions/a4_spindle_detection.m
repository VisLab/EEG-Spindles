function detection = martin_spindle_detection(C3_N234,C3,fs)
% MARTIN_SPINDLE_DETECTION Detect sleep spindles using the Martin algorithm.
% N. Martin et al. "Topography of age-related changes in sleep spindles",
% Neurobio Aging 34(2), 2013, pp 468-476
% First input is a structure containing EEG from C3-M2 during all NREM
% (S2+S3+S4) episodes, each cell in the structure is a continuous NREM
% segment [muV].
% Third input is EEG from C3-M2 from the entire night [muV].
% Last input is the sampling frequency [Hz].
% Syntax: detection = martin_spindle_detection(C3_N234,C3,fs)
%
% Implemented by M.Sc. Sabrina Lyngbye Wendt, July 2013

resolution = 25;
threshold = threshold_montreal(C3_N234,fs,resolution);
detection = montreal(C3,fs,threshold,resolution);
%% Adjust spindle detections
[begins, ends] = find_spindles(detection);
[detection,begins,ends] = maximum_duration(detection,begins,ends,3,fs);
[detection,~,~] = minimum_duration(detection,begins,ends,0.3,fs);

%% Functions
    function threshold = threshold_montreal(C3nrem234,fs,resolution)
        % THRESHOLD_MONTREAL Calculates the amplitude criterion for spindle detection
        % using the montreal method.
        % Input is a structure where each entry contains a continuous segment of
        % EEG data recorded at C3-M2 during S2+S3+S4. The sampling frequency is the
        % final input.
        
        percentile = 95;
        window_length = 0.25*fs;
        
        Ltotal = 0;
        for k = 1:length(C3nrem234)
            signal = C3nrem234{k}; t_total = length(signal);
            if t_total < 3*1023+1
                samples2zeropad = 3*1023+1-t_total;
                first = round(samples2zeropad/2);
                second = samples2zeropad-first;
                signal = [zeros(first,1); signal; zeros(second,1)];
            else
                first = 0;
                second = 0;
            end
            signal_band = bandpass_filter_montreal(signal,fs);
            signal_band = signal_band(first+1:end-second);
            
            t = 1+floor(window_length/2):resolution:t_total-floor(window_length/2);
            a1 = signal_band.^2./(window_length);
            L = length(t); RMS_part = zeros(L,1);
            for i = 1:L
                RMS_part(i) = sqrt(sum( a1(t(i)-floor(window_length/2):t(i)+floor(window_length/2)) ));
            end
            
            RMS(Ltotal+1:Ltotal+L) = RMS_part;
            Ltotal = Ltotal+L;
        end
        threshold = prctile(RMS,percentile);
    end

    function out = bandpass_filter_montreal(in,Fs)
        % BANDPASS_FILTER_MONTREAL Bandpass filter used in Martin spindle
        % detection.
        % This function creates a 1023rd order (if the sampling frequency is 100 Hz)
        % Rectangular bandpass filter with passband between 11.5 and 14.5 Hz. The
        % filter is -3 dB at 11.1 and 14.9 Hz.
        % The input signal is filtered with the created filter and the filtered
        % signal is returned as output.
        
        N    = 1023;     % Order
        Fc1  = 11.08;    % First Cutoff Frequency
        Fc2  = 14.92;    % Second Cutoff Frequency
        flag = 'scale';  % Sampling Flag
        % Create the window vector for the design algorithm.
        win = rectwin(N+1);
        % Calculate the coefficients using the FIR1 function.
        b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);
        out = filtfilt(b,1,in);
    end

    function detection = montreal(C3,fs,threshold,resolution)
        % MONTREAL Detect sleep spindles in EEG given the amplitude criteria.
        % Input is the EEG signal we wish to detect spindles in, the sampling
        % frequency and the amplitude criteria.
        % Output is a vector containing the detection of spindles.
        
        %% Bandpass filter EEG between 11 and 15 Hz
        C3_band = bandpass_filter_montreal(C3,fs);
        
        %% Calculate the RMS of the filtered signal with a time window of 0.25 sec
        window_length = 0.25*fs;
        t_total = length(C3);
        t = 1+floor(window_length/2):resolution:t_total-floor(window_length/2);
        RMS = zeros(length(t),1);
        
        a1 = C3_band.^2./(window_length);
        for i = 1:length(t)
            RMS(i) = sqrt(sum( a1(t(i)-floor(window_length/2):t(i)+floor(window_length/2)) ));
        end
        
        %% Thresholding the spindle RMS signal
        det = zeros(size(RMS));
        det(RMS>threshold) = 1;
        
        [begin_ones,end_ones] = find_spindles(det);
        begin_spindle = t(begin_ones)-floor(window_length/2);
        end_spindle = t(end_ones)+floor(window_length/2);
        
        detection = zeros(length(C3),1);
        for j = 1:length(begin_spindle)
            detection(begin_spindle(j):end_spindle(j)) = 1;
        end
        
    end

    function [begins, ends] = find_spindles(bv)
        % FIND_SPINDLES - find start and end index' of spindles.
        % Input is a binary vector bv containing ones where spindles are detected.
        % Output is vectors containing the index' of spindle beginnings and ends
        % (first sample of spindle and last sample of spindle, respectively).
        
        sise = size(bv);
        E = bv(2:end)-bv(1:end-1); % Find start and end of intervals with spindles
        
        begins = find(E==1)+1;
        if bv(1) == 1
            if sise(1) > 1
                begins = [1; begins];
            elseif sise(2) > 1
                begins = [1 begins];
            else
                error('The input signal is not one dimensional')
            end
        elseif numel(begins) == 0 && bv(1) == 0
            begins = NaN;
        end
        
        ends = find(E==-1);
        if bv(end) == 1
            if sise(1) > 1
                ends = [ends; length(bv)];
            elseif sise(2) > 1
                ends = [ends length(bv)];
            else
                error('The input signal is not one dimensional')
            end
        elseif numel(ends) == 0 && bv(end) == 0
            ends = NaN;
        end
    end

    function [bv,begins,ends] = maximum_duration(bv,begins,ends,max_dur,fs)
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
                bv(begins(k):ends(k)) = 0;
                begins(k) = 0;
                ends(k) = 0;
            end
        end
        begins = begins(begins~=0);
        ends = ends(ends~=0);
    end

    function [bv,begins,ends] = minimum_duration(bv,begins,ends,min_dur,fs)
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
                bv(begins(k):ends(k)) = 0;
                begins(k) = 0;
                ends(k) = 0;
            end
        end
        begins = begins(begins~=0);
        ends = ends(ends~=0);
    end

end