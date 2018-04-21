function [data, params] = getChannelData(fileName, channelLabels, params)
%% Extracts a resampled channel of data from an EEG data file
%
%  Parameters:
%     fileName         full path of an EEG structure
%     channelLabels    cell array of potential channel label matches
%                        will take the first one
%     params           param structure for Spindler
%
%%  Read the EEG file
    defaults = getGeneralDefaults();
    params = processParameters('getChannelData', nargin, 3, params, defaults);
    [~, theName, ~] = fileparts(fileName);
    EEG = pop_loadset(fileName);

    %% Get the channel number to extract the
    [params.channelNumber, params.channelLabel] = getChannelNumber(EEG, channelLabels);
    if isempty(params.channelNumber)
        warning('----Dataset %s does not have needed channels', fileName);
        data = [];
        return;   
    end
 
    %% Resample EEG if required
    EEG.data = EEG.data(params.channelNumber, :);
    EEG.chanlocs = EEG.chanlocs(params.channelNumber);
    EEG.nbchan = 1;
    params.srateOriginal = EEG.srate;
    EEG =  pop_resample(EEG, params.srateTarget);
    params.srate = EEG.srate;
    params.name = [theName '_channel ' params.channelLabel];
    data = EEG.data;
end