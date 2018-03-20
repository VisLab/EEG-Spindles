function [nbr_sp,pos_sp,pos_kcomp,nbr_kp] = sp_kp_detection( epoch,thr1,thr2,fs,N )
[y,x] = signal_decomp(epoch,fs,N);
%%
sc=62:91; %selon AASM sleep spindles dans la bande [11 16]
wname='fbsp 20-0.5-1';  
W=cwt(y,sc,wname);
CTF=abs(W);
%time frequency map thresholding
[CTF_s] = seuillage_CTF(CTF,thr1);
%maximum locaux
[nbr_sp,pos_sp]=CTF_loc_max(CTF_s);
%%
x=x-mean(x);       
wn=[0.8 5]./500;
b=fir1(100,wn,'bandpass');
xfilt = filter(b,1,x);
kcomp=xfilt;
    [Maxima,MaxIdx] = findpeaks(kcomp,'MINPEAKDISTANCE',2500);
    DataInv = 1.01*max(kcomp) - kcomp;
        [pks,locs] = findpeaks(DataInv,'MINPEAKDISTANCE',2500);
    Minima = kcomp(locs);
mm=Minima(Minima<=thr2);
[a,pos]= ismember(mm,Minima);
indk=locs(pos);
pos_kcomp=indk;
nbr_kp=length(mm);
end

