%% ROC Curve function
% This function allow to plot a Receiver Operating Characteristic (ROC)
% using False detection Rate (FDR) and Sensitivity. 

%% Input 
% * fdr: False detection rate computed using permformances_mesure function 
% * sen: sensitivity computed using permformances_mesure function 
% * threshold: threshold range defined in the main script
% * showplot: on or off to display or not ROC figure
%% output 
% * optimal_thresh: optimal threshold whcih maximize the difference between
% FDR and sensitivity 
%% Code

function [optimalThreshold, bestFDR, bestSen]= getThresholdFromROC(fdr, sen, threshold, showplot)
    if isempty(fdr)
        warning('Empty ROC curve, threshold selection failed');
        optimalThreshold = 0;
        bestFDR = 0;
        bestSen = 0;
        return;
    end
    [~, maxInd] = max(sen - fdr);
    optimalThreshold = threshold(maxInd(1));
    bestFDR = fdr(maxInd(1));
    bestSen = sen(maxInd(1));
    if  ~showplot
        return;
    end

%% Plot the ROC curve and threshold selection curve
    figure('Name', 'ROC curve for Spinky')
    plot(fdr, sen,'r.-');
    xlabel('False detection Rate (%) ')
    ylabel('Sensitivity (%) ')
    hold on; 
    plot([0;100], [0 100])
    grid on;
    hold off;
    figure('Name', 'Threshold selection for Spinky')
    mm = sen - fdr;
    plot(threshold, mm)
    xlabel('Threshold (MicroVolt)');
    ylabel('Sensitivity-FDR (%)');
    hold on 
    plot([optimalThreshold(1),optimalThreshold(1)],[0,max(mm)+0.05],'r--');
    hold off;
end





