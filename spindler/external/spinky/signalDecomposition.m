function [oscil, transit] = signalDecomposition(x, fs)

% Set example parameters
    N=length(x);
    wn=[0.2 45];
    x=filtrage_fir(x,wn,105,fs);
    % High Q-factor wavelet transform parameters
    Q1 =5.5;
    r1 = 3;
    J1 = MaxLevels(Q1,r1,N);

    % Low Q-factor wavelet transform parameters
    Q2 = 1;
    r2 = 3;
    J2= MaxLevels(Q2,r2,N);

    % Set MCA parameters
    Nit = 500;          % Number of iterations
    mu = 0.005;           % SALSA parameter
    theta = 0.5;
    now1 = ComputeNow(N,Q1,r1,J1);
    now2 = ComputeNow(N,Q2,r2,J2);
    lam1 = theta * now1;
    lam2 = (1-theta) * now2;
    [oscil, transit] = dualQ(x,Q1,r1,J1,Q2,r2,J2,lam1,lam2,mu,Nit);
end

