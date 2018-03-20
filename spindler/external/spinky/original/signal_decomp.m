function [lowy,highy] = signal_decomp(x,fs,N)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Set example parameters
%        N=length(x);             
%        fs=1000;
        wn=[0.2 40];
       x=filtrage_fir(x,wn,105,fs);
       % High Q-factor wavelet transform parameters
        Q1 = 5.5;
        r1 = 3; 
        J1 = 36;
        % Low Q-factor wavelet transform parameters
        Q2 = 1;
        r2 = 3;
        J2 = 20;
        % Set MCA parameters
        Nit = 500;          % Number of iterations
        mu = 0.005;           % SALSA parameter
        theta = 0.5;
        
%Verify perfect reconstruction
% Check that transforms with selected parameters satisfy perfect
% reconstruction. (It is not really needed; just to double check.)

 %Peform MCA (decomposition)

now1 = ComputeNow(N,Q1,r1,J1);
now2 = ComputeNow(N,Q2,r2,J2);
lam1 = theta * now1;
lam2 = (1-theta) * now2;
[lowy,highy,w1s,w2s,costfn] = dualQ(x,Q1,r1,J1,Q2,r2,J2,lam1,lam2,mu,Nit);

end

