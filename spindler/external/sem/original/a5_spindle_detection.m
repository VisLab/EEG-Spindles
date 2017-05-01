function detection = wamsley_spindle_detection(C3_N2,C3,fs)
% WAMSLEY Detect sleep spindles using the Wamsley algorithm.
% E. Wamsley et al. "Reduced Sleep Spindles and Spindle Coherence in 
% Schizophrenia: Mechanisms of Impaired Memory Consolidation", 
% Biol Psychiatry 71, 2012, pp 154-161
%
% First input is a structure containing EEG from C3-M2 during all NREM
% (S2) episodes, each cell in the structure is a continuous NREM
% segment [muV].
% Second input is EEG from C3-M2 from the entire night [muV].
% Last input is the sampling frequency [Hz].
% Syntax: detection = wamsley_spindle_detection(C3_N2,C3,fs)
%
% Adopted from Wamsley by M.Sc. Sabrina Lyngbye Wendt, July 2013

signalmean = threshold_wamsley(C3_N2,fs);
detection = wamsley(C3,fs,signalmean);

    function signalmean = threshold_wamsley(C3nrem2,fs)
        % THRESHOLD_WAMSLEY Calculates the amplitude criteria for spindle detection
        % using the wamsley method.
        % Input is a structure where each entry contains a continuous segment of
        % EEG data recorded at C3-M2 during S2. The sampling frequency is the
        % final input.
        
        %% Define parameters for the wavelet analysis
        fb = 13.5;
        fc = 0.5;
        scale = 3.7;
        
        Ltotal = 0;
        for k = 1:length(C3nrem2)
            signal = C3nrem2{k}; L = length(signal);
            %% Perform wavelet transformation
            EEGWave = cwt(signal,scale,['cmor' num2str(fb) '-' num2str(fc)]);
            EEGData = real(EEGWave.^2);
            
            %% Take Moving Average
            EEGData = EEGData.^2;
            window = ones((fs/10),1)/(fs/10); % create 100ms window to convolve with
            EEGData2 = filter(window,1,EEGData); % take the moving average using the above window
            MA(Ltotal+1:Ltotal+L) = EEGData2;
            Ltotal = Ltotal+L;
        end
        
        %% Determine amplitude threshold
        signalmean = mean(MA);
    end

    function detection = wamsley(C3,fs,signalmean)
        % WAMSLEY Detect sleep spindles in EEG given the amplitude criteria.
        % Input is the EEG signal we wish to detect spindles in, the sampling
        % frequency and the amplitude criteria.
        % Output is a vector containing the detection of spindles.
        
        %% Define parameters for the wavelet analysis
        fb = 13.5;
        fc = 0.5;
        scale = 3.7;
        
        EEGWave = cwt(C3,scale,['cmor' num2str(fb) '-' num2str(fc)]);
        EEGData = real(EEGWave.^2);
        
        %% Take Moving Average
        EEGData = EEGData.^2;
        window = ones((fs/10),1)/(fs/10); % create 100ms window to convolve with
        EEGData2 = filter(window,1,EEGData); % take the moving average using the above window
        
        %% Determine amplitude threshold
        threshold = signalmean.*4.5; % defines the threshold
        
        %% Find Peaks in the MS Signal
        current_data=EEGData2;
        
        over=current_data>threshold; % Mark all points over threshold as '1'
        detection = zeros(length(current_data),1);
        detection(over) = 1;
        [begins,ends] = find_spindles(detection);
        [detection,begins,ends] = maximum_duration(detection,begins,ends,3,fs);
        [detection,begins_03,ends_03] = minimum_duration(detection,begins,ends,0.3,fs);
        
        locs_03=(zeros(1,length(current_data)))';  % Create a vector of zeros the length of the MS signal
        for i=1:((length(current_data))-(fs*0.3));  % for the length of the signal, if the sum of 30 concurrent points = Fs*0.3, mark a spindle
            if sum(over(i:(i+((fs*0.3)-1))))==(fs*0.3);
                locs_03(i,1)=1;
            end
        end
        
        spin_03=zeros((length(locs_03)),1);  % only mark a spindle in vector 'spin' at the end of a 300ms duration peak
        for i=1:length(locs_03);
            if locs_03(i,1)==1 && locs_03(i+1,1)==0;
                spin_03(i,1)=1;
            end
        end
        
        for i=201:length(spin_03);  % for every spindle marked in 'spin', delete the spindle if there is also a spindle within the second preceeding it
            if spin_03(i,1)==1 && sum(spin_03((i-fs):(i-1)))>0;
                spin_03(i,1)=0;
                idx = find(i>=begins_03 & i<=ends_03);
                if isempty(idx) == 0
                    detection(begins_03(idx):ends_03(idx)) = 0;
                else
                    error('Did not find spindle beginning and ending around a spin point')
                end
            end
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