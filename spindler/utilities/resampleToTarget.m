function EEG = resampleToTarget(EEG, srateTarget, channelNumber)
%% Determines an appropriate resampling strategy based on srateTarget
%
%  Parameters:
%     EEG            EEGLAB EEG structure
%     srateTarget    target sampling rate
%
%  If srateTarget < EEG.srate, don't resample otherwise resample at the
%  best event divisor for the srateTarget.
%
%

%% Create a single signal EEG from channelNumber
    EEG.data = EEG.data(channelNumber, :);
    EEG.chanlocs = EEG.chanlocs(channelNumber);
    EEG.nbchan = 1;
    EEG =  pop_resample(EEG, srateNew);
end