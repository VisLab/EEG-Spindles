function dataFiltered = getFilteredData(data, srate, lowFreq, highFreq)
%% Filter a timeseries by using EEGLAB's filter
%
%  Parameters:
%      data           time series to be filtered
%      srate          sampling frequency in Hz
%      lowFreq        lower end of band pass (empty or zero if no lower end)
%      highFreq       high end of band pass (empty or zero if no upper end)
%      dataFiltered   (output) filtered data

%% Convert data to a one-channel EEG dataset.
EEG = eeg_emptyset();
EEG.data = data(:)';
EEG.nbchan = 1;
EEG.srate = srate;
EEG.pnts = length(data);
EEG.xmax = (EEG.pnts - 1)/EEG.srate;
EEG.times = 1000*((1:EEG.pnts) - 1)/EEG.srate;

%% Now filter the data using EEGLAB
lowFreqValid = ~isempty(lowFreq) && lowFreq ~= 0;
highFreqValid = ~isempty(highFreq) && highFreq ~= 0 && highFreq <= srate/2.0;

if lowFreqValid && highFreqValid
    EEGFilt = pop_eegfiltnew(EEG, lowFreq, highFreq);
elseif lowFreqValid && ~highFreqValid
    EEGFilt = pop_eegfiltnew(EEG, lowFreq, []);
elseif ~lowFreqValid && highFreqValid
    EEGFilt = pop_eegfiltnew(EEG, [], highFreq);
else
    EEGFilt = EEG;
    warning('getFilteredData:BadFrequencies', ...
        'Filter frequencies were invalid so signal was not changed');
end

%% Now reextract the filtered data as a time series
dataFiltered = EEGFilt.data;
dataFiltered = reshape(dataFiltered, size(data));