function detection = wendt_spindle_detection(C3,O1,fs)
% WENDT_SS_DETECT Detect sleep spindles using the Wendt algorithm.
% S. Wendt et al. "Validation of a Novel Automatic Sleep Spindle Detector
% with High Performance During Sleep in Middle Age Subjects", Conf Proc 
% IEEE Eng Med Biol Soc. 2012, pp 4250-4253
%
% The first input to the function is the EEG derivation C3-A2 and the
% second input is O1-A2 [muV]. Third input is the sampling frequency [Hz]. 
% The output is a vector with ones where there are spindles and zeroes 
% where there are not spindles. This detector uses decision fusion.
%
% Syntax: detection = wendt_spindle_detection(C3,O1,fs)
% Implemented by M.Sc. Sabrina Lyngbye Wendt, July 2013

% Bandpass filter from 11-16 Hz
C3band = bandpass_11_16(C3,fs);
Oband = bandpass_11_16(O1,fs);
% Rectify filtered signal
C3abs = abs(C3band);

% Detect spindles with two different detectors
res1 = detect_spindles(C3,C3band,Oband,C3abs,2.25,3,fs);
[~, begins, ends] = find_spindles(res1);
[res1,begins,ends] = maximum_duration(res1,begins,ends,3,fs);
[res1_03,~,~] = minimum_duration(res1,begins,ends,0.3,fs);

res2 = detect_spindles(C3,C3band,Oband,C3abs,1,8,fs);
[~, begins, ends] = find_spindles(res2);
[res2,begins,ends] = maximum_duration(res2,begins,ends,3,fs);
[res2_03,~,~] = minimum_duration(res2,begins,ends,0.3,fs);

% Fuse the results of the two detectors to yield the final result
sum_res_03 = res1_03+res2_03;
result_03 = zeros(size(C3));
result_03(sum_res_03 >= 1) = 1;
[~, begins, ends] = find_spindles(result_03);
[detection,~,~] = maximum_duration(result_03,begins,ends,3,fs);

%% Functions
    function out = bandpass_11_16(in,Fs)
        % BANDPASS_11_16 - Bandpass filter used in Wendt spindle
        % detection.
        % This function creates a 253rd order (if the sampling frequency is 100 Hz)
        % Equiripple bandpass filter with passband between 11 and 16 Hz. The
        % filter is -3 dB at 10.8 and 16.2 Hz.
        % The input signal is filtered with the created filter and the filtered
        % signal is returned as output.
        
        Fstop1 = 10;              % First Stopband Frequency
        Fpass1 = 11;              % First Passband Frequency
        Fpass2 = 16;              % Second Passband Frequency
        Fstop2 = 17;              % Second Stopband Frequency
        Dstop1 = 0.0001;          % First Stopband Attenuation
        Dpass  = 0.057501127785;  % Passband Ripple
        Dstop2 = 0.0001;          % Second Stopband Attenuation
        dens   = 20;              % Density Factor
        
        % Calculate the order from the parameters using FIRPMORD.
        [N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 0],...
            [Dstop1 Dpass Dstop2]);
        % Calculate the coefficients using the FIRPM function.
        b  = firpm(N, Fo, Ao, W, {dens});
        out = filtfilt(b,1,in);   % b coeffs, a coeffs, inputsignal
    end

    function result = detect_spindles(C3raw,C3band,Oband,C3abs,lowpassF,offset,fs)
        % DETECT_SPINDLES Detect sleep spindles.
        % Inputs to the function are the raw C3-M2 recording, the 11-16 Hz
        % bandpass filtered C3-M2 and O1-M2, the rectified bandpass filtered
        % central signal, and parameters for the envelope thus the time varying
        % threshold (lowpass cut off frequency and threshold).
        % Output is the result from detecting spindles with this particular time
        % varying threshold.
        
        % Calculate the envelope
        C3low = lowpass(C3abs,lowpassF,fs);
        % Calculate zerocrossings of the first and second derivative of the
        % envelope
        Z = zero_crossings(C3low);
        % Find where the rectified signal exceeds the added envelope
        D = zeros(size(C3abs)); D(C3abs>C3low+offset)= 1;
        % Find intervals between 2. derivative in which the rectified signal
        % exceeds the added envelope
        [DD, beginns, ennds] = find_spindles(D,Z,C3band,Oband,fs);
        % Check amplitude of original signal and check length of spindle
        % interval
        [result,~,~] = check_amplitude(C3raw,DD,beginns,ennds);
    end

    function out = lowpass(in,Fpass,Fs)
        % LOWPASS - equripple lowpass filter a signal with passband Fpass and stopband
        % Fpass+1 Hz.
        % Input is an EEG signal. Output is the filtered EEG signal.
        
        Fstop = Fpass+1;         % Stopband Frequency
        Dpass = 0.057501127785;  % Passband Ripple
        Dstop = 0.0001;          % Stopband Attenuation
        dens  = 20;              % Density Factor
        
        % Calculate the order from the parameters using FIRPMORD.
        [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
        % Calculate the coefficients using the FIRPM function.
        b  = firpm(N, Fo, Ao, W, {dens});
        out = filtfilt(b,1,in);   % b coeffs, a coeffs, inputsignal
    end

    function [Z,zdf,zddf] = zero_crossings(C3low)
        % ZERO_CROSSINGS - finds zero crossings of 1. and 2. derivative and ignores
        % points of inflection
        % The derivatives are approximated using the central difference.
        % Input is a signal to locate zero crossings of the first and second
        % derivative in.
        % Outputs are a vector with index' at which zero crossings occur, vectors
        % with ones at zero crossings of the first and second derivative,
        % respectively.
        
        sise = size(C3low);
        % Calculate 1. and 2. derivative and zero crossings of these
        df = zeros(sise); df(2:end-1) = (C3low(3:end)-C3low(1:end-2))/(2);
        zdf = zerox(df);
        ddf = zeros(sise); ddf(2:end-1) = (df(3:end)-df(1:end-2))/(2);
        zddf = zerox(ddf);
        
        Z = zdf+2*zddf;
        % Remove points of inflection
        Z = adjust_derivative(Z);
    end

    function [E] = zerox(df)
        % ZEROX - function to find zero crossings from negative to positive
        % Input is the signal to find the zero crossings off.
        % Output is a binary vector with value 1 where a zero crossing is.
        
        E = zeros(size(df));
        for i = 2:length(df)
            if df(i-1) < 0 && df(i) > 0
                E(i) = 1;
            elseif df(i-1) > 0 && df(i) < 0
                E(i) = 1;
            end
        end
    end

    function Zout = adjust_derivative(Zin)
        % ADJUST_DERIVATIVE - removes zero crossings at almost stationary points of inflection.
        % Input is a vector with ones at zero crossings of the first derivative and
        % twos at zero crossings of the second derivative.
        % Output is a vector with indexes of zero crossings without points of
        % inflection.
        
        P = find(Zin==1); P = [1; P; length(Zin)]; % zero crossing of 1. derivative
        Q = find(Zin==2);                          % zero crossing of 2. derivative
        z = 0;
        for i = 1:length(P)-1
            if sum(Zin(P(i)+1:P(i+1)-1)) == 6
                Zin(Q(z+2)) = 0;
                z = z + 3;
            else
                z = z + 1;
            end
        end
        Zout = find(Zin~=0);
    end

    function [DD, begins, ends] = find_spindles(D,Z,C3,O,fs)
        % FIND_SPINDLES - find start and end index' of spindles.
        % Input is a vector D containing ones where the rectified bandpasfiltered
        % signal exceeds the envelope, Z is index' of zero crossings, C3 is the
        % bandpass filtered central signal and O is the bandpass filtered
        % occipital signal. If only D is the input the function finds the index'
        % of the start and end of spindles.
        % Output is a vector containing ones in the interval where the spindle is
        % and indexs describing the start and end of the spindle (first sample of
        % spindle and last samle of spindle, respectively).
        
        sise = size(D);
        if nargin == 5
            DD = zeros(sise);
            for j = 1:length(Z)-1
                if sum(D(Z(j):Z(j+1))) ~= 0
                    C3_int = C3(Z(j):Z(j+1));
                    O_int = O(Z(j):Z(j+1));
                    a = remove_alpha(C3_int,O_int,fs);
                    if a == 0
                        DD(Z(j):Z(j+1)) = 1;
                    else
                        DD(Z(j):Z(j+1)) = 0;
                    end
                end
            end
        else
            DD = D;
        end
        % Find start and end of intervals with spindles
        E = DD(2:end)-DD(1:end-1);
        
        begins = find(E==1)+1;
        if DD(1) == 1
            if sise(1) > 1
                begins = [1; begins];
            elseif sise(2) > 1
                begins = [1 begins];
            else
                error('The input signal is not one dimensional')
            end
        elseif numel(begins) == 0 && DD(1) == 0
            begins = NaN;
        end
        
        ends = find(E==-1);
        if DD(end) == 1
            if sise(1) > 1
                ends = [ends; length(DD)];
            elseif sise(2) > 1
                ends = [ends length(DD)];
            else
                error('The input signal is not one dimensional')
            end
        elseif numel(ends) == 0 && DD(end) == 0
            ends = NaN;
        end
    end

    function a = remove_alpha(C3,O,fs)
        % REMOVE_ALPHA - investigates whether a spindle candidate interval is a
        % spindle or an alpha intrusion.
        % Input is the bandpass filtered central and occipital signal in the
        % interval.
        % Output is equal to 0 if the interval is a spindle, and equal to 1 if the
        % interval is an alpha intrusion.
        
        % Fourier transform of the bandpass filtered central signal. Find the
        % frequency between 8-16 Hz where the amplitude is greatest.
        fftC = abs(fftshift(fft(C3,2*fs)));
        fftC = fftC(round(length(fftC)/2):end);
        freq = [0:length(fftC)-1]*round(fs/2)/(length(fftC)-1);
        freq_cut = freq(freq>=8 & freq<=16);
        fftC_cut = fftC(freq>=8 & freq<=16);
        [~,imC] = max(fftC_cut);
        fmC = freq_cut(imC);
        
        % If the frequency is equal to or below 13 Hz, compare the energy of the
        % central and occipital signals.
        if  fmC <= 13
            PC = sum(C3.^2);
            PO = sum(O.^2);
            if PO > PC
                a = 1;
            else
                a = 0;
            end
        else
            a = 0;
        end
    end

    function [DD,start,slut] = check_amplitude(signal,DD,start,slut)
        % CHECK_AMPLITUDE - checks the amplitude of the original signal in the
        % interval where a spindle is found.
        % Input is the original EEG, a vector containing ones in the interval
        % where the spindle is and indexs describing the start and end of the
        % spindle.
        % Output is a vector containing ones in the interval where the spindle is
        % and the amplitude of the original signal is lower than 85 muV and
        % indexs describing the start and end of the spindle.
        
        C3rawabs = abs(signal);
        for k = 1:length(start)
            if sum(C3rawabs(start(k):slut(k))>85) ~= 0
                DD(start(k):slut(k)) = 0;
                start(k) = 0;
                slut(k) = 0;
            end
        end
        start = start(start~=0);
        slut = slut(slut~=0);
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

end