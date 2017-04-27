function  EEGPart = splitEEG(EEG, startFrame, endFrame)
%% Extract a new EEG structure with frames between startFrame and endFrame
EEGPart = EEG;
EEGPart.data = EEG.data(:, startFrame:endFrame);
EEGPart.event = [];
EEGPart.pnts = size(EEGPart.data, 2);
EEGPart.xmin = 0;
EEGPart.xmax = (EEGPart.pnts - 1)/2;

