function detection = bodizs_spindle_detection(C3nrem,O1nrem,C3,fs)
% BODIZS Detect sleep spindles using the Bodizs algorithm.
% R. Bodizs et al. "The individual adjustment method of sleep spindle
% analysis: Methodological improvements and roots in the fingerprint
% paradigm", J Neuro Method 178, 2009, pp 205-213
%
% First input is a structure containing EEG from C3-M2 during all NREM
% (S2+S3+S4) episodes, each cell in the structure is a continuous NREM
% segment [muV].
% Second input is a similar structure with data from O1-M2 [muV].
% Third input is EEG from C3-M2 from the entire night [muV].
% Last input is the sampling frequency [Hz].
% Syntax: detection = bodizs_spindle_detection(C3nrem,O1nrem,C3,fs)
%
% Implemented by M.Sc. Sabrina Lyngbye Wendt, July 2013

SpindleInfo = get_spindle_criteria_bodizs(C3nrem,O1nrem,fs);

det = bodizs(C3,fs,SpindleInfo);

%% Adjust spindle detections and collapse slow and fast to one detection
[begins, ends] = find_spindles(det.slow);
[det.slow,begins,ends] = maximum_duration(det.slow,begins,ends,3,fs);
[det.slow_03,~,~] = minimum_duration(det.slow,begins,ends,0.3,fs);

[begins, ends] = find_spindles(det.fast);
[det.fast,begins,ends] = maximum_duration(det.fast,begins,ends,3,fs);
[det.fast_03,~,~] = minimum_duration(det.fast,begins,ends,0.3,fs);

detection = det.slow_03+det.fast_03; detection(detection>=1) = 1;
[begins, ends] = find_spindles(detection);
[detection,~,~] = maximum_duration(detection,begins,ends,3,fs);

%% Functions
    function SpindleInfo = get_spindle_criteria_bodizs(C3nrem,O1nrem,fs)
        % GET_SPINDLE_CRITERIA_BODIZS This function finds the frequency boundaries
        % of slow and fast spindles together with amplitude criteria for both
        % spindle types. The function should be applied before doing the bodizs
        % spindle detection since the output of this function is an input to the
        % detection algorithm.
        
        %% Calculating the average amplitude spectra of NREM sleep records
        fft_points = round(fs/0.0608); % resolution: 249 Hz/4096 points = 0.0608 Hz
        hann_window = hann(4*fs);
        
        sum_spectra = zeros(round(fft_points/2),1);
        no_spectra = 0;
        for i = 1:length(C3nrem) % Going thru each segment of NREM stored in the structure C3nrem
            signal = C3nrem{i};
            vector = 0:4:length(signal)/fs;
            for j = 1:floor(length(signal)/fs/4) % Going thru the segment in 4 s windows with no overlap
                window = signal(1+vector(j)*fs:(vector(j)+4)*fs);
                hanning_corrected = hann_window.*window; % Hanning-correcting the window
                fourier = abs(fftshift(2*fft(hanning_corrected,fft_points)/(fft_points))); % Calculating the FFT with 0.06 Hz spectral resolution and normalizing to get the amplitude spectrum
                fourier = fourier(round(fft_points/2):end);
                sum_spectra = sum_spectra + fourier; % Adding the amplitude spectra
                no_spectra = no_spectra + 1; % Counting how many amplitude spectra have been added
            end
        end
        average_spectraC = sum_spectra/no_spectra; % Calculating the average amplitude spectra
        
        sum_spectra = zeros(round(fft_points/2),1);
        no_spectra = 0;
        for i = 1:length(O1nrem) % Going thru each segment of NREM stored in the structure O1nrem
            signal = O1nrem{i};
            vector = 0:4:length(signal)/fs;
            for j = 1:floor(length(signal)/fs/4) % Going thru the segment in 4 s windows with no overlap
                window = signal(1+vector(j)*fs:(vector(j)+4)*fs);
                hanning_corrected = hann_window.*window; % Hanning-correcting the window
                fourier = abs(fftshift(2*fft(hanning_corrected,fft_points)/(fft_points))); % Calculating the FFT with 0.06 Hz spectral resolution and normalizing to get the amplitude spectrum
                fourier = fourier(round(fft_points/2):end);
                sum_spectra = sum_spectra + fourier; % Adding the amplitude spectra
                no_spectra = no_spectra + 1; % Counting how many amplitude spectra have been added
            end
        end
        average_spectraO = sum_spectra/no_spectra; % Calculating the average amplitude spectra
        
        %% Obtaining the boundary frequencies for spindles
        frequency = [0:length(fourier)-1]/(length(fourier)-1)*round(fs/2);
        freq_9_16 = frequency(frequency>=9 & frequency<=16);
        spectra_9_16C = average_spectraC(frequency>=9 & frequency<=16);
        spectra_9_16O = average_spectraO(frequency>=9 & frequency<=16);
        % Downsampling the spectra by a factor of 4, use every fourth sample
        freq_9_16_lowres = freq_9_16(1:4:end)';
        spectra_lowresC = spectra_9_16C(1:4:end);
        spectra_lowresO = spectra_9_16O(1:4:end);
        
        % Calculating the second order derivative using quadratic curve fitting
        dd_spectraC = zeros(size(spectra_lowresC));
        dd_spectraO = zeros(size(spectra_lowresO));
        for n = 2:length(spectra_lowresC)-1
            p = polyfit(freq_9_16_lowres(n-1:n+1),spectra_lowresC(n-1:n+1),2);
            dd_spectraC(n) = p(1)*2;
            p = polyfit(freq_9_16_lowres(n-1:n+1),spectra_lowresO(n-1:n+1),2);
            dd_spectraO(n) = p(1)*2;
        end
        dd_spectra = mean([dd_spectraC dd_spectraO],2);
        
        hpeaks = dsp.PeakFinder('PeakType','Minima','PeakIndicesOutputPort',true,'PeakValuesOutputPort',true,'MaximumPeakCount',100);
        % Zero crossings of first negative peak
        [cnt, idx, val] = step(hpeaks, dd_spectra);
        idx = idx(1:cnt)+1; val = val(1:cnt); val(val>0) = 0;
        [~,maxidx1] = max(abs(val));
        peakidx1 = idx(maxidx1);
        
        k = peakidx1;
        while sign(dd_spectra(k)) == -1
            k = k-1;
        end
        beforepeak1a = k;
        beforepeak1b = beforepeak1a+1;
        x1a = zero_cross_discrete([freq_9_16_lowres(beforepeak1a) freq_9_16_lowres(beforepeak1b)],[dd_spectra(beforepeak1a) dd_spectra(beforepeak1b)]);
        
        k = peakidx1;
        while sign(dd_spectra(k)) == -1
            k = k+1;
        end
        afterpeak1b = k;
        afterpeak1a = k-1;
        x1b = zero_cross_discrete([freq_9_16_lowres(afterpeak1a) freq_9_16_lowres(afterpeak1b)],[dd_spectra(afterpeak1a) dd_spectra(afterpeak1b)]);
        
        % Zero crossings of second negative peak
        dd_spectra2 = dd_spectra; dd_spectra2(beforepeak1a+1:afterpeak1b-1) = 0;
        
        [cnt, idx, val] = step(hpeaks, dd_spectra2);
        idx = idx(1:cnt)+1; val = val(1:cnt); val(val>0) = 0;
        [~,maxidx2] = max(abs(val));
        peakidx2 = idx(maxidx2);
        
        k = peakidx2;
        while sign(dd_spectra(k)) == -1
            k = k-1;
        end
        beforepeak2a = k;
        beforepeak2b = k+1;
        x2a = zero_cross_discrete([freq_9_16_lowres(beforepeak2a) freq_9_16_lowres(beforepeak2b)],[dd_spectra(beforepeak2a) dd_spectra(beforepeak2b)]);
        
        k = peakidx2;
        while sign(dd_spectra(k)) == -1
            k = k+1;
        end
        afterpeak2b = k;
        afterpeak2a = k-1;
        x2b = zero_cross_discrete([freq_9_16_lowres(afterpeak2a) freq_9_16_lowres(afterpeak2b)],[dd_spectra(afterpeak2a) dd_spectra(afterpeak2b)]);
        
        % To avoid manuel correction of peak findings
        if x1b < 12.4 && x2b < 12.4 || x1a > 11.95 && x2a > 11.95
            if x1b < 12.4 && x2b < 12.4
                dd_spectra3 = dd_spectra2; dd_spectra3(freq_9_16_lowres<12.4) = 0;
            elseif x1a > 11.95 && x2a > 11.95
                dd_spectra3 = dd_spectra2; dd_spectra3(freq_9_16_lowres>11.95) = 0;
            end
            
            [cnt, idx, val] = step(hpeaks, dd_spectra3);
            idx = idx(1:cnt)+1; val = val(1:cnt); val(val>0) = 0;
            [~,maxidx3] = max(abs(val));
            peakidx3 = idx(maxidx3);
            
            k = peakidx3;
            while sign(dd_spectra(k)) == -1
                k = k-1;
            end
            beforepeak2a = k;
            beforepeak2b = k+1;
            x2a = zero_cross_discrete([freq_9_16_lowres(beforepeak2a) freq_9_16_lowres(beforepeak2b)],[dd_spectra(beforepeak2a) dd_spectra(beforepeak2b)]);
            
            k = peakidx3;
            while sign(dd_spectra(k)) == -1
                k = k+1;
            end
            afterpeak2b = k;
            afterpeak2a = k-1;
            x2b = zero_cross_discrete([freq_9_16_lowres(afterpeak2a) freq_9_16_lowres(afterpeak2b)],[dd_spectra(afterpeak2a) dd_spectra(afterpeak2b)]);
        end
        
        % Rounding to the closest bin within the high-resolution spectra
        [~,index1a] = min(abs(freq_9_16-x1a)); boundary1a = freq_9_16(index1a);
        [~,index1b] = min(abs(freq_9_16-x1b)); boundary1b = freq_9_16(index1b);
        [~,index2a] = min(abs(freq_9_16-x2a)); boundary2a = freq_9_16(index2a);
        [~,index2b] = min(abs(freq_9_16-x2b)); boundary2b = freq_9_16(index2b);
        
        if boundary1a < boundary2a
            slow_bond_a = boundary1a; slow_idx_a = index1a;
            slow_bond_b = boundary1b; slow_idx_b = index1b;
            fast_bond_a = boundary2a; fast_idx_a = index2a;
            fast_bond_b = boundary2b; fast_idx_b = index2b;
        elseif boundary2a < boundary1a
            slow_bond_a = boundary2a; slow_idx_a = index2a;
            slow_bond_b = boundary2b; slow_idx_b = index2b;
            fast_bond_a = boundary1a; fast_idx_a = index1a;
            fast_bond_b = boundary1b; fast_idx_b = index1b;
        else
            error('The slow and fast boundary is the same')
        end
        
        %% Obtaining the amplitude criteria of slow and fast sleep spindles
        slow_bin = slow_idx_b-slow_idx_a+1;
        slow_ac = slow_bin*( average_spectraC(slow_idx_a+round(9/0.0608))+average_spectraC(slow_idx_b+round(9/0.0608)) )/2;
        
        fast_bin = fast_idx_b-fast_idx_a+1;
        fast_ac = fast_bin*( average_spectraC(fast_idx_a+round(9/0.0608))+average_spectraC(fast_idx_b+round(9/0.0608)) )/2;
        
        SpindleInfo.slow_bond_a = slow_bond_a;
        SpindleInfo.slow_bond_b = slow_bond_b;
        SpindleInfo.fast_bond_a = fast_bond_a;
        SpindleInfo.fast_bond_b = fast_bond_b;
        SpindleInfo.slow_ac = slow_ac;
        SpindleInfo.fast_ac = fast_ac;
    end

    function x = zero_cross_discrete(xvalues,yvalues)
        % ZERO_CROSS_DISCRETE linear interpolation to find the x-value of
        % zero-crossing given the x-values and the y-values surrounding a
        % zero-crossing.
        % Input is a vector x containing the x-value before and after the crossing
        % and a vector y containing the y-value before and after the crossing (the
        % x's must be given in increasing order no matter of the y-values).
        % The output is a single number x describing the x-value of zero-crossing.
        delta = ( yvalues(2)-yvalues(1) )/( xvalues(2)-xvalues(1) );
        x = -yvalues(1)/delta+xvalues(1);
    end

    function detection = bodizs(C3,fs,SpindleInfo)
        % BODIZS Detect sleep spindles in EEG given the slow and fast frequency
        % boundaries and amplitude criteria.
        % Input is the EEG signal we wish to detect spindles in, the sampling
        % frequency and a structure contained slow and fast frequency boundaries
        % and corresponding amplitude criteria.
        % Output is a structure containing the detection of slow and fast spindles.
        
        %% Obtaining the envelope of the rectified slow and fast sleep spindle activity
        fft_points = round(fs/0.0608);
        x = [0:0.0608:fs/2]';
        
        % Defining the bandpass filter for slow spindles
        w = SpindleInfo.slow_bond_b-SpindleInfo.slow_bond_a;
        xm = w/2+SpindleInfo.slow_bond_a;
        gauss = exp( -abs(x-xm)/(w/2) );
        gauss_slow = [gauss;gauss(end:-1:2)];
        
        % Defining the bandpass filter for fast spindles
        w = SpindleInfo.fast_bond_b-SpindleInfo.fast_bond_a;
        xm = w/2+SpindleInfo.fast_bond_a;
        gauss = exp( -abs(x-xm)/(w/2) );
        gauss_fast = [gauss;gauss(end:-1:2)];
        
        vector = 0:fft_points:length(C3);
        C3band_slow = zeros(size(C3)); C3band_fast = C3band_slow;
        for i = 1:length(vector)-1 % Going thru the signal in 4 s windows without overlap
            window = C3(1+vector(i):vector(i+1));
            C3fft = fft(window,fft_points);
            
            C3band_sloww = ifft(C3fft.*gauss_slow,fft_points,'symmetric');
            C3band_sloww = C3band_sloww(1:fft_points);
            
            C3band_fastw = ifft(C3fft.*gauss_fast,fft_points,'symmetric');
            C3band_fastw = C3band_fastw(1:fft_points);
            
            C3band_slow(1+vector(i):vector(i+1)) = C3band_sloww;
            C3band_fast(1+vector(i):vector(i+1)) = C3band_fastw;
        end
        C3band_slow_abs = abs(C3band_slow);
        C3band_fast_abs = abs(C3band_fast);
        
        hanning22 = hann(22); hanning22sum = sum(hanning22);
        C3hanning_slow = zeros(size(C3)); C3hanning_fast = C3hanning_slow;
        for j = 11:length(C3)-11
            C3hanning_slow(j) = sum(C3band_slow_abs(j-10:j+11).*hanning22 )/hanning22sum;
            C3hanning_fast(j) = sum(C3band_fast_abs(j-10:j+11).*hanning22 )/hanning22sum;
        end
        C3hanning.slow = C3hanning_slow*(pi/2);
        C3hanning.fast = C3hanning_fast*(pi/2);
        
        %% Detection of sleep spindles
        detection.slow = zeros(size(C3)); detection.fast = detection.slow;
        detection.slow(C3hanning.slow>SpindleInfo.slow_ac) = 1;
        detection.fast(C3hanning.fast>SpindleInfo.fast_ac) = 1;
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