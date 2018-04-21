function [newLabel, newType] = regularizeLabelMass(oldLabel, k)
    if strncmpi(oldLabel, 'EOG', 3)
        newType = 'EOG';
        newLabel = oldLabel;
    elseif strncmpi(oldLabel, 'EEG', 3)
        newType = 'EEG';
        newLabel = oldLabel(4:end);
        endMatch = newLabel(end-2:end);
        if ~strncmpi(endMatch, 'LER', 3) && ~strncmpi(endMatch, 'CLE', 3)
            warning('Old label %s does not conform to EEG on channel %d', ...
                oldLabel, k);
        else
            newLabel = newLabel(1:end-3);
        end
    else
        newType = 'EXT';
        newLabel = oldLabel;
    end
end