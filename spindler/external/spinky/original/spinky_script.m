clear 
clc
%% Parametres
epoch_length=30; 
fs=1000;         
detection_mode='spindles';  
subj_name='xxxx';         
user_defined_thresholds_4_ROC =0;   
train_data_file='training_data.mat';
spindles_visual_score='Spindles_visual_score_test_data.txt';
test_data_file='test_data.mat';    
showRoc='Off';
%% Load training, test data and visual scores 
 x=load(train_data_file);  
 X=fieldnames(x);
 train_data=x.(X{1});    
 tr_data=data_epoching(train_data,fs*epoch_length); 
 [sp_train_score] = load_visual_score(spindles_visual_score,length(tr_data));  
 xt=load(test_data_file); 
 Xt=fieldnames(xt);
 data=xt.(Xt{1});
 test_d=data_epoching(data,fs*epoch_length);
%% Run event automatic detection
if (user_defined_thresholds_4_ROC)==1
    switch detection_mode
        case 'spindles'
           sp_thresh=sp_thresh_user;
           [op_thr_sp] = training_process(tr_data,fs,detection_mode,sp_thresh,sp_train_score,showRoc);
           [nbr_sp,pos_sp]=test_process(test_d,fs,subj_name,detection_mode,op_thr_sp);
        case 'kcomplex' 
           kp_thresh=kp_thresh_user; 
           [op_thr_kp] = training_process(tr_data,fs,detection_mode,kp_thresh,kp_train_score,showRoc);
           [nbr_kp,pos_kp]=test_process(test_d,fs,subj_name,detection_mode,op_thr_kp);
        case 'both'
           sp_thresh=sp_thresh_user;
           kp_thresh=kp_thresh_user;  
           [op_thr_sp,op_thr_kp] = training_process(train_data,fs,detection_mode,sp_thresh,sp_train_score,kp_thresh,kp_train_score,showRoc);
           [nbr_sp,pos_sp,nbr_kc,pos_kc]=test_process(data,fs,subj_name,detection_mode,op_thr_sp,op_thr_kp);
    end
else
    switch detection_mode
        case 'spindles'
            [sp_thresh] =sp_thresholds_ranges(tr_data,fs);
            [op_thr_sp] = training_process(tr_data,fs,detection_mode,sp_thresh,sp_train_score,showRoc);
            [nbr_sp,pos_sp]=test_process(test_d,fs,subj_name,detection_mode,op_thr_sp);
        case 'kcomplex' 
            [kp_thresh] =kp_thresholds_ranges(tr_data,fs);
            [op_thr_kp] = training_process(tr_data,fs,detection_mode,kp_thresh,kp_train_score,showRoc);
            [nbr_kp,pos_kp]=test_process(test_d,fs,subj_name,detection_mode,op_thr_kp);
        case 'both'
            [kp_thresh] =kp_thresholds_ranges(tr_data,fs);
            [sp_thresh] =sp_thresholds_ranges(tr_data,fs);
            [op_thr_sp,op_thr_kp] = training_process(train_data,fs,detection_mode,sp_thresh,sp_train_score,kp_thresh,kp_train_score,showRoc);
            [nbr_sp,pos_sp,nbr_kc,pos_kc]=test_process(data,fs,subj_name,detection_mode,op_thr_sp,op_thr_kp);
    end    
end    