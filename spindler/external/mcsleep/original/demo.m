%% This script is a demo of the McSleep spindle detection method
%
% Last Edit: 4/25/2017
% Perm. Contact: ankit.parekh@nyu.edu
% 
% This is a very basic demo of the proposed mcsleep method. 
% For a full fledged parallel version as in the paper, see 
% runSpindleDetection.m
%
% Copyright (c) 2017. Ankit Parekh 
% 
% Please cite as: Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint 2017, doi: https://doi.org/10.1101/104414


%% Load EDF and Expert annotation
clear; close all; clc;
set(0,'defaultaxeslinewidth',0.5)
Y = load('EEGSample.mat');
Y = Y.Y;
N = 6000;                   % Length of EEG
fs = 200;                   % Sampling frequency
n = 0:N-1;                  % time axis


% Plot the multichannel data
figure(1), clf
gap = 200;
plot(n/fs, Y(1,:), n/fs, Y(1,:) - gap, n/fs, Y(3,:) - 2*gap)
title('Raw EEG channels')
set(gca, 'YTick', [])
legend('FP1-A1', 'CZ-A1','O1-A1')
box off
xlabel('Time(s)')


%% Run McSleep transient separation on EEG data given by Y

% Define operators for block low rank property 
H = @(x,s,k) Op_A(x,s,k);
HT = @(x,s,k) Op_AT(x,s,k);

% Define parameters
param = struct('lam1',0.3, 'lam2',6.5,'lam3',36,'K',200,...
                'mu', 0.5,'O',100,'Nit',80); 
param.calculateCost = 1;

tic, [x,s,cost] = mcsleep(Y, H, HT, param); toc

% Calculate the residual
r = Y - (x+s);
% Plot the cost function history
figure(2), clf
plot(cost, 'k')
title('Cost function history')
box off
xlabel('Iteration (k)')
%% Plot the estimated signal using only low rank regularizer
figure(3), clf

gap = 125;
plot(n/fs, Y(1,:), 'color','k')
hold on
plot(n/fs, Y(2,:)-gap, 'color','k')
plot(n/fs, Y(3,:)-2*gap, 'color','k')
plot(n/fs, x(1,:)-3*gap,'color','k')
plot(n/fs, x(2,:)-4*gap, 'color','k')
plot(n/fs, x(3,:)-5*gap,'color','k')
plot(n/fs, s(1,:)-6*gap, 'color', 'k')
plot(n/fs, s(2,:)-7*gap, 'color', 'k')
plot(n/fs, s(3,:)-8*gap,'color', 'k')
plot(n/fs, r(1,:)-9*gap, 'color', 'k')
plot(n/fs, r(2,:)-10*gap, 'color', 'k')
plot(n/fs, r(3,:)-11*gap,'color', 'k')
title('Separation of transients and oscillations using McSleep')
xlim([15 30])
box off
xlabel('Time (s)')
ylabel('Amplitude ($\mu$V)', 'Interpreter','LaTex','fontName','Arial')
ylim([-11.3*gap gap])
set(gca,'YTick',[-11.2*gap -11*gap -10.8*gap -10.2*gap -10*gap -9.8*gap, ...
                 -9.2*gap -9*gap -8.8*gap,...
                 -8.2*gap -8*gap -7.8*gap -7.2*gap -7*gap -6.8*gap ,...
                 -6.2*gap -6*gap -5.8*gap -5.2*gap -5*gap -4.8*gap -4.2*gap, ...
                 -4*gap, -3.8*gap -3.2*gap -3*gap -2.8*gap,...
                 -275 -250 -225 -150 -125 -100 -25 0 25], ...
        'YTickLabel', [-25 0 25], 'XTick', 0:3:30)

text(29,50,'FP1-A1','horizontalalignment','right','fontsize',7)
text(29,50-gap,'CZ-A1','horizontalalignment','right','fontsize',7)
text(29,50-2*gap,'O1-A1','horizontalalignment','right','fontsize',7)

text(29,40-3*gap,'Transient (FP1-A1)','horizontalalignment','right','fontsize',7)
text(29,40-4*gap,'Transient (CZ-A1)','horizontalalignment','right','fontsize',7)
text(29,40-5*gap,'Transient (O1-A1)','horizontalalignment','right','fontsize',7)

text(29,30-6*gap,'Oscillatory (FP1-A1)','horizontalalignment','right','fontsize',7)
text(29,30-7*gap,'Oscillatory (CZ-A1)','horizontalalignment','right','fontsize',7)
text(29,30-8*gap,'Oscillatory (O1-A1)','horizontalalignment','right','fontsize',7)

text(29,30-9*gap,'Residual (FP1-A1)','horizontalalignment','right','fontsize',7)
text(29,30-10*gap,'Residual (CZ-A1)','horizontalalignment','right','fontsize',7)
text(29,30-11*gap,'Residual (O1-A1)','horizontalalignment','right','fontsize',7)
set(gcf, 'PaperPosition', [0 0 8.5 11])

%print -dpdf demo
