%% Performance measure function 
% this function allows to compute Sensitvity and FDR based on comparison
% between expert visual score and automatic detection of spindles and/or
% kcomplex 

%% Input 
% * expert_score: visual score provided by an expert 
% * detection_auto: automatic detection resulting from TQWT & MCA method 

%% Output 
% * Sen: sensitivty value 
% * FDR: False Detection Rate value 
%% Code



function [Sen,FDR] = performances_measure(expert_score,detection_auto)

TP=0;FP=0;FN=0;
 for kk=1:length(expert_score)
     
       if detection_auto(kk)>=expert_score(kk)
          yy=detection_auto(kk)-expert_score(kk);
          FP=FP+yy;
          y=expert_score(kk);
          TP=TP+y;
       elseif detection_auto(kk)<expert_score(kk)
          yy=expert_score(kk)-detection_auto(kk);
          FN=FN+yy; 
          y=detection_auto(kk);
          TP=TP+y;
      end
 end
%TN=length(find(expert_score==0 & detection_auto==0));
Sen=100.*(TP/(TP+FN));
FDR=100.*(FP/(FP+TP));
%Sp=100.*(TN/(TN+FP));
%Perf={'Tp' 'Fp' 'FN' 'TN';TP FP FN TN};
end

