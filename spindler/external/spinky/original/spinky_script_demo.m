%% Scirpt Version Of spinky toolbox
% This script uses "spinky" toolbox to automatically detect spindles and/or kcomplex on EEG data 
% For more details about the method please refer to our papers 
%
% # Lajnef, T., Chaibi, S., Eichenlaub, J. B., Ruby, P. M., Aguera, P. E., Samet, M.Kachouri A  Jerbi, K. (2015).Sleep spindle and K-complex detection using tunable Q-factor wavelet transform and morphological component analysis. Frontiers in human neuroscience,9.
% # Lajnef,T. O'reilly C, Coombrisson E, Chaibi S, Eichenlaub J.B, Ruby, P M,Aguera P.E Samet, M. Kachouri A, Frenette S,  Carrier J, Jerbi, K. (2016) Meet Spinky: An open-source Spindle and K-complex detection toolbox validated on the open-access Montreal Archive of Sleep Studies (MASS) (under review)

%% Parameters 
% _epoch_length_ : Data window (sec); This is often the duration of an epoch used for e.g. in sleep staging, i.e. 30s or 20s
%%
% _fs_ : Sampling frequency (Hz)
%% 
% _detection_mode_ : Select what event you want to detect
% # 'kcopmlex' to detect only kcopmlex 
% # 'spindles' to detect only spindles events
% # 'both' to detect spindles and kcomplex
%%
% _subj_name_ : Subject or data name; this value will be the name of the text file in which automatic detection results will be saved 
%%
% _user_defined_thresholds_4_ROC_ : This parametre define the way you choose to select the optimal threshold: 
%
% * 0 if you wish to estimate thresholds range based on data properties.
% * 1 if you wish to define your own range
%%
% _sp_thresh_user and/ or kp_thresh_user_ :  Manually selected spindle and/ or kcomplex thresholds ranges which will be used in the training porcess (ROC generation) 
% example: sp_thresh_user=280:5:300;   
%%
% _train_data_file_:  Training data loading format required: (1xN) vector EEG training data for one channel (e.g time series for channel C3) 
%%
% 'kcomplex_visual_score' and/or 'spindles_visual_score' .mat file path containing the number of kcomplex visually marked by an expert in each segment of data (duration defined by param "epoch_length", eg. 30s);       
%%
% _test_data_file_ :
% .mat file containing EEG data of one subject and one electrode (1xN vector) 

%% Outputs
% This script will generate one or two text files (depending on detection_mode option) containing the automatic detection results: 
%
% * score_auto_spindles_subjectx.txt
% * score_auto_kcomplex_subjectx.txt


%% Example
% Set parametres 
clear 
clc
epoch_length=30; 
fs=1000;         
detection_mode='spindles';  
subj_name='subject1';         
user_defined_thresholds_4_ROC =0;   
train_data_file='training_data.mat';
spindles_visual_score='Spindles_visual_score_training_data.txt';
test_data_file='test_data.mat';        
%%
%  Load training data and visual scores 
%
 x=load(train_data_file);  
 X=fieldnames(x);
 train_data=x.(X{1});    
 tr_data=data_epoching(train_data,fs*epoch_length); 
 [sp_train_score] = load_visual_score(spindles_visual_score,length(tr_data));
%% 
% Define the threshold range that will be used to generate the pseudo ROC
if (user_defined_thresholds_4_ROC)==1
    switch detection_mode
        case 'spindles'
           sp_thresh=sp_thresh_user;
        case 'kcomplex' 
           kp_thresh=kp_thresh_user; 
        case 'both'
           sp_thresh=sp_thresh_user;
           kp_thresh=kp_thresh_user; 
    end
else
    switch detection_mode
        case 'spindles'
            [sp_thresh] =sp_thresholds_ranges(tr_data,fs);
        case 'kcomplex' 
            [kp_thresh] =kp_thresholds_ranges(tr_data,fs);
        case 'both'
            [kp_thresh] =kp_thresholds_ranges(tr_data,fs);
            [sp_thresh] =sp_thresholds_ranges(tr_data,fs);
    end    
end

%% 
% Optimal threshold selection using pseudo ROC curve on "training data"
[op_thr_sp] = training_process(tr_data,fs,detection_mode,sp_thresh,sp_train_score,'On');
%% 
% Use selected threshold on remaining data ("test" set)
%
% * Load the data set for automatic detection
x=load(test_data_file); 
X=fieldnames(x);
data=x.(X{1});
test_d=data_epoching(data,fs*epoch_length);
%%
% * spindles detection on test data
[nbr_sp,pos_sp]=test_process(test_d,fs,subj_name,detection_mode,op_thr_sp);


%%
% See also
% <matlab:doc('test_process') test_process> <matlab:doc('training_process') training_process>  

%% This added by Kay
spindles_visual_score='Spindles_visual_score_test_data.txt';
[sp_test_score] = load_visual_score(spindles_visual_score,length(test_d));
[Sen,FDR] = performances_measure(sp_test_score,nbr_sp);    