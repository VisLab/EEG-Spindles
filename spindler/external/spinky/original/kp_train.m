%% Training for Kcomplex detection
% This function perform the trainining process to choose the optimal threshold for kcomplex detection 

%% Input 
% * sig : EEG signal to use for training 
% * kp_thresh : kcomple thresholds range defined on the main script 
% * fs: sampling frquency 
% * kp_expert_score: expert visual score of Kcomplex events
% * show_plot: set it to 'on' or 'off' to choose either you want or not to display figure for ROC curve

%% Output 
% * kp_optimal_thresh: optimal threshold for kcomplex detection

%% Code 

function [kp_optimal_thresh] = kp_train(sig,kp_thresh,fs,kp_expert_score,show_plot)

   m=1;
for kk=kp_thresh
    for i=1:length(sig)
        [nbr_kc(i),pos_kc] = kc_detection(sig{i},kk,fs);
    end
       [kp_Sen(m),kp_FDR(m)] = performances_measure(kp_expert_score,nbr_kc);
        m=m+1;
end
[kp_optimal_thresh]=ROC_curve(kp_FDR,kp_Sen,kp_thresh,show_plot);

end

