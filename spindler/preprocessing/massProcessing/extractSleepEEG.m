function [EEG, hdr, data] = extractSleepEEG(fileName)
% Extract the Dreams sleep data
%
%  Parameters:
%     fileName  name of the EDF file

%   Output:
%     EEG             EEGLAB EEG structure with the output
%
%   Written by:  Kay Robbins, 2016 UTSA
%
%

%% Read the data from the EDF file
    [hdr, data] = edfread(fileName);

    %% Set basic information fields of the EEG structure
    EEG = eeg_emptyset();
    EEG.fileName = fileName;
    EEG.comments = 'File source MASS database';
    EEG.nbchan = size(data, 1);
    EEG.trials = 1;
    EEG.pnts = size(data, 2);

    %% Fix the channel names and types.
    labels = hdr.label;
    chanlocs(1, length(labels)) = struct( 'labels', [], ...,
        'type', [], 'ref', [], 'urchan', []);

    for k = 1:length(labels)
        [newLabel, newType] = regularizeLabelMass(labels{k}, k);
        chanlocs(k).labels = newLabel;
        chanlocs(k).type = newType;
    end

    %% Rearrange channels and data to have EEG, followed by EOG followed by EXT
    chanlocs = chanlocs(:)';  % make sure row not column
    for k = 1:length(chanlocs)
        chanlocs(k).urchan = k;
    end
    EEG.chanlocs = chanlocs;
    EEG.urchanlocs = rmfield(chanlocs, 'urchan');
    EEG.data = data;
    EEG.nbchan = length(chanlocs);

    %% Now compute the EEG srate
    EEGChanMask = strcmpi({chanlocs.type}, 'eeg') | strcmpi({chanlocs.type}, 'eog');
    fprintf('Dataset has %d EEG and eog channels\n', sum(EEGChanMask));
    EEGsRates = hdr.samples(EEGChanMask);
    EEGLabels = {chanlocs.labels};
    EEGLabels = EEGLabels(EEGChanMask);
    for k = 2:length(EEGsRates)
        if abs(EEGsRates(k) - EEGsRates(1)) > 10e-12
            warning('EEG channel %s has sampling rate %g which does not match channel %s', ...
                EEGLabels{k}, EEGsRates(k), EEGLabels{1});
        end
    end
    %% Check the sampling rate for the EEG channels now we know which are EEG
    EEG.srate = round(EEGsRates(1)/hdr.duration);
    EEG.xmin = 0;
    EEG.xmax = (EEG.pnts - 1)/EEG.srate;
    EEG.times = 1000*(0:EEG.pnts-1)/EEG.srate;
    EEG.data = EEG.data(EEGChanMask, :);
    EEG.chanlocs = EEG.chanlocs(EEGChanMask);
    EEG.nbchan = length(EEG.chanlocs);
end