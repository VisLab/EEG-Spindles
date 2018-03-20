function [train_data,varargout] = data_split(x,nb_seg_training,detection_mode,varargin)
    
%x=data_epoching(data,fs,epoch_length); % divide EEG data into "epoch_length" segments (the function output is a cell array)
L=length(x);
indx_tr=randperm(L,nb_seg_training); 
train_data=x(indx_tr);
switch detection_mode
    case 'spindles'
        expert_score=varargin{1};
        varargout{1}= expert_score(indx_tr);
    case 'kcomplex'
         expert_score=varargin{1};
        varargout{1}= expert_score(indx_tr);
    case 'both'
        sp_expert_score=varargin{1};
        varargout{1}= sp_expert_score(indx_tr);
        kp_expert_score=varargin{2};
        varargout{2}= kp_expert_score(indx_tr);
end
end

