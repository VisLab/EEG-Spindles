%% Training for spindles detection
% This function perform the trainining process to choose the optimal threshold for spindles detection 
%% Input 
% * sig : EEG signal to use for training 
% * sp_thresh : spindles thresholds range defined on the main script 
% * fs: sampling frquency 
% * sp_expert_score: expert visual score of spindles events
% * show_plot: set it to 'on' or 'off' to choose either you want or not to display figure for ROC curve

%% Output 
% * sp_optimal_thresh: optimal threshold for spindles detection

%% Code 

function [sp_optimal_thresh] = sp_train(sig,sp_thresh,fs,sp_expert_score,show_plot)
n=1;
for kk=sp_thresh;
   for i=1:length(sig)
      
        [nbr_sp(i),pos_sp] = sp_detection(sig{i},kk,fs);
   end
   
   [sp_Sen(n),sp_FDR(n)] = performances_measure(sp_expert_score,nbr_sp);
   n=n+1;
end

[sp_optimal_thresh]=ROC_curve(sp_FDR,sp_Sen,sp_thresh,show_plot);

end

