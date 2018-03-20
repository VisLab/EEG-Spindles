function [pos_kcomp,nbre] = kp_detection(epoch,threshold,fs,N)
 
[~,x] = signal_decomp(epoch,fs,N);
x=x-mean(x);       
wn=[0.8 5]./(fs/2);
b=fir1(100,wn,'bandpass');
xfilt = filter(b,1,x);
kcomp=xfilt;
    [Maxima,MaxIdx] = findpeaks(kcomp,'MINPEAKDISTANCE',2500);
    DataInv = 1.01*max(kcomp) - kcomp;
        [pks,locs] = findpeaks(DataInv,'MINPEAKDISTANCE',2500);
    Minima = kcomp(locs);

mm=Minima(Minima<=threshold);
[a,pos]= ismember(mm,Minima);

indk=locs(pos);

pos_kcomp=indk;

nbre=length(mm);

end

