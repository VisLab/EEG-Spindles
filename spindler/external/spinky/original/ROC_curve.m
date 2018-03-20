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

function[ optimal_thresh]=ROC_curve(fdr,sen,threshold,showplot)
mm=sen-fdr;
optimal_thresh=threshold(mm==max(mm));
optimal_thresh=optimal_thresh(1);
if strcmp(showplot,'On')
    figure;
plot(fdr,sen,'r.-');
xlabel('False detection Rate (%) ');ylabel('Sensitivity (%) ');
hold on; 
plot([0;100],[0 100]);
grid on;
hold off;
figure;plot(threshold,mm); xlabel('Threshold (MicroVolt)');ylabel('Sensitivity-FDR (%)');
hold on 
plot([optimal_thresh(1),optimal_thresh(1)],[0,max(mm)+0.05],'r--');
hold off;
end





