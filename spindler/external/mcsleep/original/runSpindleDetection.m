%% This script provides a demo for the McSleep spindle detection method
%
% Last EDIT: 4/25/17
% Ankit Parekh
% Perm. Contact: ankit.parekh@nyu.edu
%
% To run the spindle detection on your EDF, replace the filename below
% with your EDF file. 
% The sample EDF used in this script has only 3 channels. Modify the script
% accordingly for your EDF in case of more than 3 channels (Fp1-A1, Cz-A1, O1-A1).
%
% The script downloads the EDF files from the DREAMS database. Please cite
% the authors of the DREAMS database appropriately when using this code. 
% 
% The visual detection by experts are stored as vd1 and vd2. These are
% obtained from the DREAMS Database. 
%
% Please cite as: 
% Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint, doi: https://doi.org/10.1101/104414
%
% Note: In the paper above, we discard epochs where body movement artifacts were visible. 
%       Since this script is for illustration purposes only, we do not reject any epochs here

%% Initialize
clear; close all; clc;
warning('off','all')
%% Download data from DREAMS database

% EDF files
params.filename = 'excerpt2';
url = ['http://www.tcts.fpms.ac.be/~devuyst/Databases/DatabaseSpindles/',params.filename,'.edf'];
websave([params.filename,'.edf'],url);
[data, header] = lab_read_edf([params.filename,'.edf']);
N = length(data);
n = 0:N-1;
fs = header.samplingrate;   

% Visual detections
url = ['http://www.tcts.fpms.ac.be/~devuyst/Databases/DatabaseSpindles/Visual_scoring1_',params.filename,'.txt'];
websave(['Visual_scoring1_',params.filename,'.txt'],url);

url = ['http://www.tcts.fpms.ac.be/~devuyst/Databases/DatabaseSpindles/Visual_scoring2_',params.filename,'.txt'];
websave(['Visual_scoring2_',params.filename,'.txt'],url);

% Load the visual detections
fid = fopen(['Visual_scoring1_',params.filename,'.txt'],'r');
visualScorer1 = textscan(fid,'%f %f','headerlines',1,'Delimiter','%n');
visualScorer1 = [visualScorer1{1}, visualScorer1{2}];
fclose(fid);
vd1 = obtainVisualRecord(visualScorer1,fs,N);   

fid = fopen(['Visual_scoring2_',params.filename,'.txt'],'r');
visualScorer2 = textscan(fid,'%f %f','headerlines',1,'Delimiter','%n');
visualScorer2 = [visualScorer2{1}, visualScorer2{2}];
fclose(fid);
vd2 = obtainVisualRecord(visualScorer2,fs,N);  
%% Select parameters for McSleep
% Adjust parameters to improve performance 
params.lam1 = 0.3;
params.lam2 = 6.5;
params.lam3 = 36;
params.mu = 0.5;
params.Nit = 80;
params.K = 200;
params.O = 100;

% Bandpass filter & Teager operator parameters
params.f1 = 11;
params.f2 = 17;
params.filtOrder = 4;
params.Threshold = 0.5; 

% Other function parameters
params.channels = [2 3 14];
% Don't calculate cost to save time
% In order to see cost function behavior, run demo.m
params.calculateCost = 0;   
%% Run parallel detection for transient separation
% Start parallel pool. Adjust according to number of virtual
% cores/processors. Starting the parallel pool for the first time may take
% few seconds. 

if isempty(gcp) 
        p = parpool(8); 
end

spindles = parallelSpindleDetection(params);
%% F1 Score calculation

% Change the filename and sampling frequency according to your visual 
% detection filenames
format long g
N = length(spindles);
fs = 200;

Score = F1score(spindles, vd1, vd2);
Score{1}'; Score{2}

%% Plot the results

figure(3), clf
gap = 60;
plot(n/fs, data(params.channels(1),:), n/fs, data(params.channels(2),:)-gap, ...
    n/fs, data(params.channels(3),:)-2*gap, n/fs, spindles*20-3*gap, n/fs, vd1*20-4*gap,...
    n/fs, vd2*20-5*gap);
box off
xlabel('Time (s)')
ylabel('\mu V')
title('Spindle detection using McSleep')
ylim([-6*gap gap])
xlim([1 N/fs])
set(gca,'YTick',[])
legend('Channel 1', 'Channel 2', 'Channel 3', 'McSleep detection', ...
       'Expert 1', 'Expert 2')

