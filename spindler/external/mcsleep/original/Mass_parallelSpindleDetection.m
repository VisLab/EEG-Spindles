%% This script provides a demo for the McSleep spindle detection method
%
% Last EDIT: 5/1/17
% Ankit Parekh
% Perm. Contact: ankit.parekh@nyu.edu
%
% This script uses the Montreal Archive of Sleep Studies (MASS) dataset
% Please ensure that the relevant PSG files are in the same directory or
% added to the MATLAB path. 
%
% Please cite as: 
% Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint, doi: https://doi.org/10.1101/104414
%
% Note: In the paper above, we discard epochs where body movement artifacts were visible. 
%       Since this script is for illustration purposes only, we do not reject any epochs here
%% 
clear; close all; clc
format long g
warning('off','all')
%%
[hdr, data] = edfread('01-02-0001 PSG.edf');
channels = [23 22 5 14 24 9];

fs = hdr.frequency(channels(1));
Y = zeros(length(channels), size(data,2));
j = 1;
for i = channels
    Y(j,:) = data(i,:); 
    j = j+1;
end
N = size(Y,2);
visualScorer2 = load('01-02-0001 SpindleE2_annotations.txt');
vd2 = obtainVisualRecord(visualScorer2,fs,N);

visualScorer1 = load('01-02-0001 SpindleE1_annotations.txt');
vd1 = obtainVisualRecord(visualScorer1,fs,N);

clear visualScorer2 visualScorer1 data

%% Try low pass filtering
params.y = Y;
params.lam1 = 0.6;
params.lam2 = 7;
params.lam3 = 45;
params.mu = 0.5;
params.Nit = 40;
params.K = 256;
params.O = 128;
params.fs = fs;

% Bandpass filter & Teager operator parameters
params.f1 = 11;
params.f2 = 16;
params.filtOrder = 4;
params.Threshold = 0.5; 
params.meanEnvelope = 0;
params.desiredChannel = 4;

% Other function parameters
params.channels = channels;
params.plot = 0;
params.epoch = 1;
params.calculateCost = 1;
params.Full = 1;
params.Entire = 0;
params.ROC = 0;
params.data = 0;
%% Run the multichannel spindle detector
if params.Full && isempty(gcp)
% %     % Start parallel pool
    if isempty(gcp) 
        p = parpool(12); 
    end
end     
spindles = analyzeSpindles(params);

%% F1 score calculation

Score = F1score(spindles, vd1,vd2);
Score{2}

