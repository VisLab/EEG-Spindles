function [nbr_kc,pos_kc] = kc_detection(x,seuil,fs)   
x=x-mean(x);       
f=fs/2;
wn=[0.8 4]./f;
b=fir1(100,wn,'bandpass');
xfilt = filter(b,1,x);
kcomp=xfilt;
distance=1.5*fs;
DataInv = 1.01*max(kcomp) - kcomp;
[pks,locs] = findpeaks(DataInv,'MINPEAKDISTANCE',distance);
Minima = kcomp(locs);
%seuillage 
mm=Minima(Minima<=seuil);
[~,pos]= ismember(mm,Minima);
indk=locs(pos);
indx=[];
n=1;
indk=indk(indk>fs);
for i=1:length(indk)
   if kcomp(indk(i))<2.5*kcomp(indk(i)-fs) %2.5
      indx(n)=indk(i);
      n=n+1;
   end
end
pos_kc=indx/fs;
nbr_kc=length(indx);



end

