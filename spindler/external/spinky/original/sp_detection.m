function [nbr_sp,pos_sp] = sp_detection(sig,seuil,fs)
sc=1./((10.5:0.15:16.5)/fs); %selon AASM sleep spindles dans la bande [11 16] 62:91;%
wname='fbsp 20-0.5-1';  
W=cwt(sig,sc,wname);
CTF=abs(W);
[CTF_s] = seuillage_CTF(CTF,seuil);
%maximum locaux
[nbr_sp,pos_sp]=CTF_loc_max(CTF_s,fs);
% if nbr_sp==0
%    
%         pos_sp=[];
% else  
%     y=pos;
%     sa=sign(diff([-inf y]));
%     sb=sign(diff([-inf y(end:-1:1)]));
%     sb=sb(end:-1:1);
%     d=find(sb==-1);
%     f=find(sa==-1);
%     %spindle_duration=(f-d)/fs;
%     
%     for i=1:length(f)
%     gh(2*i-1)=d(i)/fs;
%     gh(2*i)=f(i)/fs;
%     end
%     pos_sp=gh;
%     gh=[];
%     
% end

end
