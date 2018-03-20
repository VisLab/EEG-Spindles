%% Test Process function
% This function allows to detect, depending on detection_mode value,spindles and/or Kcomplex. 
%% Inputs:
% * sig=EEG data 
% * fs: sampling freaquency (Hz)
% * detection mode:string variable defining events to detect, this variable must be either:
%%
   % # 'spindles':  to detect only spindles 
   % # 'kcomplex':  to detect only kcomplex
   % # 'both': to detect spindles and kcomplex
%%
% * subj_name:name for EEG data, this name will be used to generate results in .txt files  
% * epoch_length: length of data winodw in secons (e.g: 30 sec)
% * varargin depending on detection mode varargin must be :
%%
   % # op_thr_sp if detection mode = 'spindles'
   % # op_thr_kp if detection mode= 'kcomplex' 
   % # op_thr_sp,op_thr_kp if detection mode = 'both'
%%
% Where: 
% op_thr_sp and op_thr_kp are optimal thresholds for respectively spindles and kcomplex detection; these values are comupted in the training process

%% Output:
% * varargout: depending on detection mode, the output of this function could be
% * nbr_sp,pos_sp if detection mode=spindles
% * nbr_kc,pos_kc if detection mode=kcomplex
% * nbr_sp,pos_sp,nbr_kc,pos_kc if detection_mode=both
% * depending on detection mode also one or two txt files will be generated: 
% * score_auto_subjname_kcomplex.txt: a txt file containing automatic detection results for Kcomplex, the file contain three columns: 
%%
% # segment number,
% # number of kcomplex detected in this segment,
% # the date of event occurence in the segment (sec)
%%
% * score_auto_subjname_spindles.txt a txt file containing automatic detection results for spindes, the file contain four columns:
%%
% # segment number
% # number of spindles detected in this segment,
% # spindle start time 
% # spindles stop time

%% Example: 
% [nbr_sp,pos_sp,nbr_kc,pos_kc]=test_process(data,fs,subj_name,detection_mode,op_thr_sp,op_thr_kp);

%% Code 

function [spindleCounts, spindleMasks, spindleList] = ...
                                    spinkyTest(data, optimalThreshold, params)
    fs = params.srate;
    numEpochs = size(data, 1);
    oscil = zeros(size(data));
    for k = 1:numEpochs
        oscil(k, :) = signalDecomposition(data(k, :), fs);
    end
    spindleCounts = zeros(numEpochs, 1);
    spindleMasks = zeros(size(data));
    spindleList = cell(numEpochs, 1);
    for j = 1:numEpochs
        [numSpindles,pos_sp] = spDetect(oscil(j, :), optimalThreshold, params);
        spindleCounts(j)= numSpindles;   
        if numSpindles == 0
            continue;
        else
            spindleMasks(j, :) = pos_sp;
            y=pos_sp;
            sa=sign(diff([-inf y]));
            sb=sign(diff([-inf y(end:-1:1)]));
            sb=sb(end:-1:1);
            d=find(sb==-1);
            f=find(sa==-1);
            spindleList{j} = [d(:), f(:)]./fs;
        end
    end

end
%%
% See also
% <matlab:doc('sp_detection') sp_detection> <matlab:doc('kc_detection') kc_detection>  
