function [H_data] = envoloppe_hilbert_par_bande(TS,bande,subject_name,Fs)

[H,L]=size(TS);
H_data=zeros(size(TS));
for i=1:L  
Data=TS(i,:); %select 
p=4;wp=bande/(Fs/2); 
[b,a]=butter(p,wp,'bandpass'); % Generate filter coefficients
f_Ts=filtfilt(b,a,Data); % Apply filter to data using zero-phase filtering
[v_e,v_n]=bf_envhilb(f_Ts);
H_data(i,:)=v_e;
end

end


