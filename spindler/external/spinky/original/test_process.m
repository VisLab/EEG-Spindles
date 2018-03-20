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

function [varargout]=test_process(data,fs,subj_name,detection_mode,varargin)


                                                              
%--------------------------------------------------------------------------------------------------------------------------------------
display('Test Process');
display('Signal decomposition....')

for k=1:length(data)
    [transit{k},oscil{k}]=signal_decomposition(data{k},fs);  
end
switch detection_mode
   case 'spindles'
       display('Spindles detection....')

        for j=1:length(data)
        [nbr_sp,pos_sp] = sp_detection(oscil{j},varargin{1},fs);
         nb(j)=nbr_sp;
        pos{j}=pos_sp;
        varargout{1}=nb;
        varargout{2}=pos;
         if nbr_sp==0

                pos_sp=[];
        else  
            y=pos_sp;
            sa=sign(diff([-inf y]));
            sb=sign(diff([-inf y(end:-1:1)]));
            sb=sb(end:-1:1);
            d=find(sb==-1);
            f=find(sa==-1);
            

            for i=1:length(f)
                gh(2*i-1)=d(i)/fs;
                gh(2*i)=f(i)/fs;
            end
            pos_sp=gh;
            gh=[];

        end
        file_namesp=['score_auto_spindles_' subj_name '.txt'];
        fid1=fopen(file_namesp,'a+');
        fprintf(fid1,'%d %d ',j,nbr_sp);
            for l2=1:length(pos_sp)
            fprintf(fid1,'  %4.2f ',pos_sp(l2));    
            end
            fprintf(fid1,' \n'); 
        fclose(fid1);  
        end
        
   case 'kcomplex'
       display('Kcomplex detection....')

        for j=1:length(data)
        [nbr_kc,pos_kc] = kc_detection(transit{j},varargin{1},fs); 
         nbkc(j)=nbr_kc;
         poskc{j}=pos_kc;
        varargout{1}=nbkc;
        varargout{2}=poskc;
        
        file_name=['score_auto_Kcomplex_' subj_name '.txt'];
        fid=fopen(file_name,'a+');
        fprintf(fid,' %d %d ',j,nbr_kc);
            for l1=1:length(pos_kc)
            fprintf(fid,' %4.2f  ',pos_kc(l1));    
            end
                        fprintf(fid,' \n'); 

        fclose(fid);
        end
       
   case 'both'
       display('Spindles and Kcomplex detection....')

       for j=1:length(data)
        [nbr_sp,pos_sp] = sp_detection(oscil{j},varargin{1},fs);
        nb(j)=nbr_sp;
        pos{j}=pos_sp;
        varargout{1}=nb;
        varargout{2}=pos;
         if nbr_sp==0

                pos_sp=[];
        else  
            y=pos_sp;
            sa=sign(diff([-inf y]));
            sb=sign(diff([-inf y(end:-1:1)]));
            sb=sb(end:-1:1);
            d=find(sb==-1);
            f=find(sa==-1);
            for i=1:length(f)
            gh(2*i-1)=d(i)/fs;
            gh(2*i)=f(i)/fs;
            end
            pos_sp=gh;
            gh=[];

        end
        file_namesp=['score_auto_spindles_' subj_name '.txt'];
        fid1=fopen(file_namesp,'a+');
        fprintf(fid1,'%d %d ',j,nbr_sp);
            for l2=1:length(pos_sp)
            fprintf(fid1,'  %4.2f ',pos_sp(l2));    
            end
            fprintf(fid1,' \n'); 
        fclose(fid1);  
        [nbr_kc,pos_kc] = kc_detection(transit{j},varargin{2},fs);
        nbkc(j)=nbr_kc;
        poskc{j}=pos_kc;
        varargout{3}=nbkc;
        varargout{4}=poskc;
        
        file_name=['score_auto_Kcomplex_' subj_name '.txt'];
        fid=fopen(file_name,'a+');
        fprintf(fid,'%d %d ',j,nbr_kc);
            for l1=1:length(pos_kc)
            fprintf(fid,' %4.2f ',pos_kc(l1));    
            end
                        fprintf(fid1,' \n'); 

        fclose(fid);
       end
        
          
        
        
   otherwise
       error('detection mode msut be within this list : "kcomplex" , "spindles" or "both" ')
end

end
%%
% See also
% <matlab:doc('sp_detection') sp_detection> <matlab:doc('kc_detection') kc_detection>  
