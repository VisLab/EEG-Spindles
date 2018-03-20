function [fData] = filter_fir(seg,wp,p,Fe)

wp=wp./(Fe/2);
b=fir1(p,wp,'bandpass'); 
fData = filtfilt(b,1,seg);

% [h,o] = freqz(b,1,256);
% m = 20*log10(abs(h));
% figure;
% plot(o/pi,m);
end

