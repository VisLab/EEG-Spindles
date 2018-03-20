%%  Training process function 
% This function allows to compute, depending on detection_mode value, optimal thresholds for Kcomplex and / or spindle detection 
%%  Inputs
%%
% sig=EEG training data 
%%
% fs: sampling freaquency (Hz)
%% 
% epoch_length: EEG epoch duration (sec) 
%%
% detection mode:string variable defining events to detect, this variable must be either:
%%
% * 'spindles':  to detect only spindles 
%%
% * 'kcomplex':  to detect only kcomplex
%%
% * 'both': to detect spindles and kcomplex
%% 
% varargin depending on detection mode varargin must be : 
%%
% * sp_thresh,sp_train_score if detection mode = 'spindles'
%%
% * kp_thresh,kp_train_score if detection mode= 'kcomplex' 
%%
% * sp_thresh,sp_train_score, kp_thresh,kp_train_score if detection mode = 'both'
%%
%  where: 
%       sp_thresh is the threshold range for spindles detection
%       sp_train_score is the  visual score of training data for spindles detection 
%       kp_thresh is the threshold range for kcomplex detection
%       kp_train_score  is the  visual score of training data for kcomlex detection 
%%
%  Important: 
%
% * These vaules must be defined /loaded previously in the script 
% * They must be put in the correct order 

%%  Output
%
%  varargout: depending on detection mode value this variable contains:
% 
%  # "sp_optimal_thresh" and/or "kp_optimal_thresh" which are the optimal thresholds values computed in the training process 
%

%% Code
function [varargout] = training_process(data,fs,detection_mode,varargin)
%%
% TQWT decomposition
display('signal decomposition....')
for j=1:length(data)
    [transit{j},oscil{j}]=signal_decomposition(data{j},fs);
end

%%
% Training and threshold choice
display('Optimal threshold selection...')
switch detection_mode
    case 'spindles' 
    [sp_optimal_thresh] = sp_train(oscil,varargin{1},fs,varargin{2},varargin{3});
    varargout{1}=sp_optimal_thresh;
    fprintf('The optimal threshold for spindles detection is %i uVolt^2',sp_optimal_thresh);
    case 'kcomplex'
        [kp_optimal_thresh] = kp_train(transit,varargin{1},fs,varargin{2},varargin{3});
        varargout{1}=kp_optimal_thresh;
        fprintf('The optimal threshold for kcomplex detection is %i uVolt',kp_optimal_thresh);
    case 'both'
        [sp_optimal_thresh] = sp_train(oscil,varargin{1},fs,varargin{2},varargin{5});
        [kp_optimal_thresh] = kp_train(transit,varargin{3},fs,varargin{4},varargin{5});
        varargout{1}=sp_optimal_thresh;
        varargout{2}=kp_optimal_thresh;
        fprintf('The optimal threshold for spindles detection is %i uVolt^2 \n',sp_optimal_thresh);
        fprintf('The optimal threshold for kcomplex detection is %i  uVolt \n',kp_optimal_thresh);
    otherwise 
        display('wrong detection mode');
end
end

%% Example
%  [op_thr_sp,op_thr_kp] = training_process(train_data,fs,detection_mode,sp_thresh,sp_train_score,kp_thresh,kp_train_score);
%%
% See also
% <matlab:doc('sp_train') sp_train> <matlab:doc('kp_train') kp_train>  
