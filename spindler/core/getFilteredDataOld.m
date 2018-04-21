function [dataBand, dataBase] = getFilteredDataOld(data, params)
%% Filter a timeseries by using EEGLAB's filter

atomFrequencies = params.spindlerGaborFrequencies;
EEG = eeg_emptyset();
EEG.data = data(:)';
EEG.nbchan = 1;
EEG.srate = params.srate;
EEG.pnts = length(data);
EEG.xmax = (EEG.pnts - 1)/EEG.srate;
EEG.times = 1000*((1:EEG.pnts) - 1)/EEG.srate;
lowFreq = max(1, min(atomFrequencies));
highFreq = min(ceil(params.srate/2.1), max(atomFrequencies));
EEGFilt = pop_eegfiltnew(EEG, lowFreq, highFreq);
baseFreq = params.spindlerBaseFrequencies;
if max(baseFreq) >= EEG.srate/2
    EEGBase = pop_eegfiltnew(EEG, baseFreq(1));
else
    EEGBase = pop_eegfiltnew(EEG, baseFreq(1), baseFreq(2));
end
dataBand = EEGFilt.data;
dataBase = EEGBase.data;