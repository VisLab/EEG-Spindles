function  u = Op_A(y, s, k)
% function  u = Op_A(y, s, k)
%
% k = overlap, y = m by n matrix (m < n), s = segment size
% u = s by p by m matrix
%
% m is the number of channels
% Ankit Parekh (ankit.parekh@nyu.edu)
% Last Edit: 1/19/2017
%
% Copyright (c) 2017. Ankit Parekh 
% 
% Please cite as: Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint 2017, doi: https://doi.org/10.1101/104414

[m,n] = size(y);

if s == k
    fprintf('Segment size and overlap cannot be same. \n')
    return;
end

if k == 0
    u = zeros(n/s,m,s);
    for i = 1:n/s
        u(i,:,:) = y(:,(i-1)*s + 1:i*s);
    end
elseif (s/k == 2)
   u = zeros(n/(s-k)-1, m, s);
    for i = 1:(n/(s-k)-1)
        u(i,:,:) = y(:,(i-1)*(s-k) + 1:(i-1)*(s-k) + s);
    end
else
    if mod(n/(s-k),2) == 0
        numBlocks = floor(n/(s-k)) + 1;
        u = zeros(numBlocks, m, s);
        y = [y, zeros(m, n/(s-k))];
        for i = 1:numBlocks
            u(i,:,:) = y(:, (i-1)*(s-k) + 1: (i-1)*(s-k) + s);
        end
    else
        disp('This combination of segment size and overlap is not tested')
        numBlocks = ceil(n/(s-k));
        u = zeros(numBlocks, m, s);
        y = [y, zeros(m, ceil(n/(s-k)))];
        for i = 1:numBlocks
            u(i,:,:) = y(:, (i-1)*(s-k) + 1: (i-1)*(s-k) + s);
        end    
    end
    
end
    
