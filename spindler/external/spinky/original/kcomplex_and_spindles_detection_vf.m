function [nbr_kc,pos_kc,nbr_sp,sp_pos] =kcomplex_and_spindles_detection_vf(sig,kp_thr,sp_thr,fs)
%TQWT & MCA decompostion,   nbr_sp,sp_pos, inputs: sp_thr
[transit,oscil] = signal_decomposition(sig,fs);

%spindles detection
[nbr_sp,sp_pos] = sp_detection(oscil,sp_thr,fs);
%Kcomplex detection
[nbr_kc,pos_kc] = kc_detection(transit,kp_thr,fs);
end

