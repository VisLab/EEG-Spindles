function detection = moelle_spindle_detection(C3_N2,C3,fs)
% MOLLE Detect sleep spindles using the Moelle algorithm.
% M. Molle et al. "Grouping of Spindle Activity during Slow Oscillations
% in Human Non-Rapid Eye Movement Sleep", J Neurosc 22(24), 2002, pp
% 10941-10947
%
% First input is a structure containing EEG from C3-M2 during all NREM
% (S2) episodes, each cell in the structure is a continuous NREM
% segment [muV].
% Second input is EEG from C3-M2 from the entire night [muV].
% Last input is the sampling frequency [Hz].
% Syntax: detection = moelle_spindle_detection(C3_N2,C3,fs)
%
% Implemented by M.Sc. Sabrina Lyngbye Wendt, July 2013

stdC3band = threshold_lubeck(C3_N2,fs);
detection = lubeck(C3,fs,stdC3band);

%% Adjust spindle detections
[begins, ends] = find_spindles(detection);
[detection,begins,ends] = maximum_duration(detection,begins,ends,3,fs);
[detection,~,~] = minimum_duration(detection,begins,ends,0.3,fs);

%% Functions
    function std_C3band = threshold_lubeck(C3nrem,fs)
        % THRESHOLD_LUBECK Calculates the amplitude criteria for spindle detection
        % using the lubeck method.
        % Input is a structure where each cell contains a continuous segment of
        % EEG data recorded at C3 during S2 [muV].
        % The sampling frequency is the final input [Hz].
        
        L_total = 0;
        for i = 1:length(C3nrem)
            signal = C3nrem{i}; L = length(signal);
            L_total = L_total+L;
        end
        C3_band = zeros(L_total,1);
        L2 = 0;
        for k = 1:length(C3nrem)
            signal = C3nrem{i}; L = length(signal);
            signal_band = bandpass_filter_lubeck(signal,fs);
            C3_band(L2+1:L2+L) = signal_band;
            L2 = L2+L;
        end
        std_C3band = std(C3_band);
    end

    function out = bandpass_filter_lubeck(in,Fs)
        % BANDPASS_FILTER_LUBECK Bandpass filter used in Moelle spindle 
        % detection. 
        % This function creates a 236th order (if the sampling frequency is 100 Hz)
        % Equiripple bandpass filter with passband between 12 and 15 Hz. The
        % filter is -3 dB at 11.3 and 15.7 Hz.
        % The input signal is filtered with the created filter and the filtered
        % signal is returned as output.
        
        Fstop1 = 10;                % First Stopband Frequency
        Fpass1 = 11.3;              % First Passband Frequency
        Fpass2 = 15.7;              % Second Passband Frequency
        Fstop2 = 17;                % Second Stopband Frequency
        Dstop1 = 1.1220184543e-05;  % First Stopband Attenuation
        Dpass  = 0.057501127785;    % Passband Ripple
        Dstop2 = 1.1220184543e-05;  % Second Stopband Attenuation
        dens   = 20;                % Density Factor
        
        % Calculate the order from the parameters using FIRPMORD.
        [N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 0], [Dstop1 Dpass Dstop2]);
        % Calculate the coefficients using the FIRPM function.
        b  = firpm(N, Fo, Ao, W, {dens});
        out = filtfilt(b,1,in);
    end

    function detection = lubeck(C3,fs,std_C3band)
        % LUBECK Detect sleep spindles in EEG given the amplitude criteria.
        % Input is the EEG signal we wish to detect spindles in, the sampling
        % frequency and the amplitude criteria.
        % Output is a vector containing the detection of spindles.
        
        %% Bandpass filter EEG
        C3_band = bandpass_filter_lubeck(C3,fs);
        
        %% Calculating RMS with a time resolution of 50 ms using a time window of 100 ms
        time_res = round(0.05*fs);
        t_total = length(C3);
        t = time_res+1:time_res:t_total-time_res;
        RMS = zeros(length(t),1);
        
        for i = 1:length(t)
            RMS(i) = rms( C3_band(t(i)-time_res:t(i)+time_res-1) );
        end
        
        %% Detect spindles when RMS exceeds the threshold
        threshold = 1.5*std_C3band;
        
        det = zeros(size(RMS));
        det(RMS>threshold) = 1;
        
        [begin_ones,end_ones] = find_spindles(det);
        
        begin_spindle = t(begin_ones);
        end_spindle = t(end_ones);
        
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