function [x, s, cost] = mcsleepSeparateSignal(y, lambda2, params)
%% Separate transients and oscillations in multichannel EEG
%
% This function separates transients and oscillations in multichannel EEG
% using the proposed McSleep algorithm. The algorithm assumes that the
% transients are sparse piecewise constant with a lowpass additive
% component. The consecutive blocks formed from the oscillatory component
% are assumed to be of low-rank. Please see the citation information below
% for details and usage rights. 
%
% Input :
%        y  channels x frames of multichannel sleep EEG

%        params - parameters struct. Members are as below
%            mcsleepLambda0 - sparsity of transient component
%            mcsleepLambda1 - sparsity of derivative of transient component
%            lambda2 - rank of coefficient array c. 
%            mcsleepK - length of overlapping blocks
%            mcsleepMu - scaled Lagrangian step size parameter
%            mcsleepO - overlap between consecutive blocks. (default = 50%)
%            mcsleepNit - number of iterations
% 
% Output:
%        x   Estimated transient component (may contain a lowpass
%            component)
%        s   Estimated oscillatory component
%        cost - Cost function history
%
% Contact: Ankit Parekh (ankit.parekh@nyu.edu)
% Last Edit: 1/19/2017. 
%
% Copyright (c) 2017. Ankit Parekh 
% 
% Please cite as: Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint 2017, doi: https://doi.org/10.1101/104414
%
% Modified by: Kay Robbins, UTSA, 2017
%
%% Create H and HT transforms. See paper for details.
%        H - Forward transform. H(y) results in overlapping blocks of user
%            defined length from the signal Y.
%        HT - Adjoint (Inverse) transform. HT(c) returns the multichannel
%        signal formed from the coefficient array c. HT(H(y)) = y. 
    H = @(x,s,k) Op_A(x,s,k);
    HT = @(x,s,k) Op_AT(x,s,k);
   
    %% Set the parameters
    defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
    params = processParameters('mcsleepSeparateSignal', nargin, 3, ...
        params, defaults);
    
    %% Initialize the outputs
    cost = zeros(params.mcsleepNit, 1);
    [m, n] = size(y);
    x = zeros(m, n);
    u = x;
    v = H(x, params.mcsleepK, params.mcsleepO);
    d1 = x;
    d2 = v;
    Hy = 1/params.mcsleepMu * H(y, params.mcsleepK, params.mcsleepO);
   
    %% Iterate to calculate transients
    for i = 1:params.mcsleepNit      
        %% Fused Lasso Step
        for j = 1:m
            x(j,:) = soft(tvd(u(j, :) - d1(j, :), n, ...
                params.mcsleepLambda1/params.mcsleepMu), ...
                params.mcsleepLambda0/params.mcsleepMu);
        end        
        %% Singular Value Thresholding step
        c = SVT_Blocks(v - d2, lambda2/params.mcsleepMu);
        
        %% Least-Squares step
        g1 = 1/params.mcsleepMu * y + x + d1;
        g2 = Hy + c + d2;
        HTg2 = HT(g2, params.mcsleepK, params.mcsleepO);
        u = g1 - 1/(params.mcsleepMu + 2) * (g1 + HTg2);
        v = g2 - 1/(params.mcsleepMu + 2) * ...
            H(g1 + HTg2, params.mcsleepK, params.mcsleepO);
        
        %% Update auxillary variables
        d1 = d1 - (u - x);
        d2 = d2 - (v - c);
        
        %% Calculate cost
        if params.mcsleepCalculateCost
            cost(i) = 0.5 * norm(y - (x + ...
                HT(c, params.mcsleepK, params.mcsleepO)), 'fro')^2 + ...
                params.mcsleepLambda0 * norm(x, 1) + ...
                params.mcsleepLambda1 * norm(diff(x, 2), 1) + ...
                lambda2 * sum_of_nuc_norm(c);
        end
    
    end
    
    %% Return oscillatory component calculated using estiamted coefficients
    s = HT(c, params.mcsleepK, params.mcsleepO);
end
