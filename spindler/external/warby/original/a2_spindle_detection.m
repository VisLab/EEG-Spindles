function detection = ferrarelli_spindle_detection(C3,fs,stage_file)
% FERRARELLI Detect sleep spindles using the Ferrarelli algorithm.
% Ferrarelli et al. "Reduced Sleep Spindle Activity in Schizophrenia
% Patients", Am J Psychiatry 164, 2007, pp 483-492
%
% Input is recorded EEG for a whole night of sleep (any channel can be
% used), the sampling frequency, a stage file (STA) that has been loaded in
% to MATLAB.
% Output is a binary vector containing ones at spindle samples.
% Syntax: detection = ferrarelli_spindle_detection(C3,fs,stage_file)
%
% Adopted from Ferrarelli by Sabrina Lyngbye Wendt, July 2013

%% Initialize and load data
sleep = stage_file(:,2);
lower_thresh_ratio = 2;
upper_thresh_ratio = 8;
epochsize = 30;

%% Redefine sleep stage numbers and get the nrem samples
sleep(sleep==1)=-1;sleep(sleep==2)=-2;sleep(sleep==3)=-3;sleep(sleep==4)=-4;
sleepsamp = reshape(repmat(sleep,1,epochsize*fs)',1,length(sleep)*epochsize*fs)';
nremsamples = find(sleepsamp<=-2); % Use data from stage S2+S3+S4

%% Bandpass filter from 11-15 Hz and rectify filtered signal
BandFilteredData = bandpass_filter_ferrarelli(C3,fs);
RectifiedData = abs(BandFilteredData);

%% Create envelope from the peaks of rectified signal (peaks found using zero-crossing of the derivative)
datader = diff(RectifiedData); % x(2)-x(1), x(3)-x(2), ... + at increase, - at decrease
posder = zeros(length(datader),1);
posder(datader>0) = 1; % index of all points at which the rectified signal is increasing in amplitude
diffder = diff(posder); % -1 going from increase to decrease, 1 going from decrease to increase, 0 no change
envelope_samples = find(diffder==-1)+1; % peak index of rectified signal
Envelope = RectifiedData(envelope_samples); % peak amplitude of rectified signal

%% Finds peaks of the envelope
datader = diff(Envelope);
posder = zeros(length(datader),1);
posder(datader>0) = 1; % index of all points at which the rectified signal is increasing in amplitude
diffder = diff(posder);
envelope_peaks = envelope_samples(find(diffder==-1)+1); % peak index of Envelope signal
envelope_peaks_amp = RectifiedData(envelope_peaks); % peak amplitude of Envelope signal

%% Finds troughs of the envelope
envelope_troughs = envelope_samples(find(diffder==1)+1); % trough index of Envelope signal
envelope_troughs_amp = RectifiedData(envelope_troughs); % peak trough of Envelope signal

%% Determine upper and lower thresholds
nrem_peaks_index=sleepsamp(envelope_peaks)<=-2; % extract samples that are in NREM stage S2+S3+S4
[counts amps] = hist(envelope_peaks_amp(nrem_peaks_index),120); % divide the distribution peaks of the Envelope signal in 120 bins
[~,maxi] = max(counts); % select the most numerous bin
ampdist_max = amps(maxi); % peak of the amplitude distribution
lower_threshold = lower_thresh_ratio*ampdist_max;
upper_threshold = upper_thresh_ratio*mean(RectifiedData(nremsamples));

%% Find where peaks are higher/lower than threshold
below_troughs = envelope_troughs(envelope_troughs_amp<lower_threshold); % lower threshold corresponding to 4* the power of the most numerous bin
%above_peaks=envelope_peaks(envelope_peaks_amp>upper_threshold & sleepsamp(envelope_peaks)<=-2); % Use this line insted of no. 60 if spindles should only be detected in S2+S3+S4
above_peaks = envelope_peaks(envelope_peaks_amp>upper_threshold);

%% For each of peaks above threshold
spistart = NaN(length(above_peaks),1); % start of spindle (in 100Hz samples)
spiend = NaN(length(above_peaks),1); % end of spindle (in 100Hz samples)

nspi=0; % spindle count
% for all indexes of peaks (peaks of peaks)
i = 1;
while i <= length(above_peaks)
    current_peak = above_peaks(i);
    % find troughs before and after current peak
    trough_before = below_troughs(find(below_troughs > 1 & below_troughs < current_peak,1,'last'));
    trough_after  = below_troughs(find(below_troughs < length(RectifiedData) & below_troughs > current_peak,1,'first'));
    
    if ~isempty(trough_before) && ~isempty(trough_after)  % only count spindle if it has a start and end
        nspi=nspi+1;
        spistart(nspi)=trough_before;
        spiend(nspi)=trough_after;
        % if there are multiple peaks, pick the highest and skip the rest
        potential_peaks = above_peaks(above_peaks > trough_before & above_peaks < trough_after);
        [~, maxpki]=max(RectifiedData(potential_peaks));
        current_peak=potential_peaks(maxpki);
        
        i = i+length(potential_peaks); % adjust the index to account for different max
    else
        i = i+1;
    end
end

scoring = NaN(nspi,1);  % sleep state where end lies
for j=1:nspi
    scoring(j) = sleepsamp(spiend(j));
end

%% Create the binary output vector
detection = zeros(size(C3));
spistart = spistart(isnan(spistart)~=1);
spiend = spiend(isnan(spiend)~=1);

duration = spiend-spistart;
spistart(duration<0.3*fs | duration>3*fs) = NaN;
spiend(duration<0.3*fs | duration>3*fs) = NaN;

spistart = spistart(isnan(spistart)~=1);
spiend = spiend(isnan(spiend)~=1);

for k = 1:length(spistart)
    detection(spistart(k):spiend(k)) = 1;
end

%% Functions
    function out = bandpass_filter_ferrarelli(in,Fs)
        % BANDPASS_FILTER_FERRARELLI Bandpass filter used by Ferrarelli et al.
        % This function creates a 12th order (if the sampling frequency is 100 Hz)
        % Chebyshev Type II bandpass filter with passband between 10 and 16 Hz. The
        % filter is -3 dB at 10.7 and 15 Hz.
        % The input signal is filtered with the created filter and the filtered
        % signal is returned as output.
        Wp=[11 15]/(Fs/2);
        Ws=[10 16]/(Fs/2);
        Rp=3;
        Rs=40;
        [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
        [bbp, abp]=cheby2(n,Rs,Wn);
        out=filtfilt(bbp, abp, in);
    end

end