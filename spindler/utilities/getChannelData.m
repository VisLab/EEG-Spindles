function [data, srateOriginal, channelNumber, channelLabel] = ...
                      getChannelData(fileName, channelLabels, srateTarget)
%% Extracts a resampled channel of data from an EEG data file
%
%  Parameters:
%     fileName         full path of an EEG structure
%     channelLabels    cell array of potential channel label matches
%                        will take the first one
%     srateTarget      target sampling rate for data or 0 if no resampling
%     data             (output) time series with the data
%     srateOriginal    (output) sampling rate for the original data
%     channelNumber    (output) channel number of the data
%     channelLabel     (output) channel label of the data
%
%%  Read the EEG file
    EEG = pop_loadset(fileName);
    srateOriginal = EEG.srate;

    %% Get the channel number to extract the
    [channelNumber, channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(channelNumber)
        warning('----Dataset %s does not have needed channels', fileName);
        data = [];
        return;   
    end
 
    %% Resample EEG if required
    EEG.data = EEG.data(channelNumber, :);
    EEG.chanlocs = EEG.chanlocs(channelNumber);
    EEG.nbchan = 1;
    if ~isempty(srateTarget) && srateTarget > 0
        EEG =  pop_resample(EEG, srateTarget);
    end
    data = EEG.data;
end