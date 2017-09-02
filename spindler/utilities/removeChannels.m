function EEG  = removeChannels(EEG, requireLocations, excludeLabels, validTypes)
%% Remove channels that don't meet requirements
%
%  Parameters:
%     EEG                EEG structure to have channels removed
%     requireLocations   if true, channels must have spatial locations
%     excludeLabels      cell array of channel labels to explicitly exclude
%     validTypes         cell array of allowed types (if type is present)
%     EEG                (output) revised with specified channels removed
%
%  To do:  this doesn't handle EEG with ICA correctly yet
%
%  Written by: Kay Robbins, UTSA, 2017
%
%%  Find the channel mask of channels to eliminate
    chanlocs = EEG.chanlocs;
    channelMask = false(length(chanlocs), 1);
    for k = 1:length(chanlocs)
        if ~isempty(excludeLabels) && ...
                sum(strcmpi(excludeLabels, chanlocs(k).labels)) > 0
            channelMask(k) = true;
        elseif requireLocations && ...
                isempty(chanlocs(k).X) && isempty(chanlocs(k).sph_theta) ...
                && isemtpy(chanlocs(k).radius)
            channelMask(k) = true;
        elseif isfield(chanlocs(k), 'type') && ...
                ~isempty(chanlocs(k).type) && ~isempty(validTypes) && ...
                sum(strcmpi(validTypes, chanlocs(k).type)) == 0
            channelMask(k) = true;
        end
    end
%% Eliminate channels if needed
if sum(channelMask) == 0
    return;
end

EEG.data(channelMask, :) = [];
EEG.chanlocs(channelMask) = [];
EEG.nbchan = length(EEG.chanlocs);