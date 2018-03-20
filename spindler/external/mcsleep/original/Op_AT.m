function y = Op_AT(u,s,k)
% function y = Op_AT(u,s,k)
% 
% This function forms the multichannel signal y from the coefficient array
% c. s is the segment size (must be the same used for creating c) and k is
% the overlap desired (must be the same used for creating c). 
% 
% Ankit Parekh (ankit.parekh@nyu.edu)
% Last Edit: 1/19/17
%
% Copyright (c) 2017. Ankit Parekh 
% 
% Please cite as: Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint 2017, doi: https://doi.org/10.1101/104414


if k ==0
    [blocks,channels,seg] = size(u);
    y = zeros(channels,blocks*seg);
    for i = 1:blocks
        y(:,(i-1)*seg+1:i*seg) = u(i,:,:);
    end
else
    [blocks, channels,seg] = size(u);
    y = zeros(channels, (blocks+1) * (s-k));
    w = 1 + y;
    u = permute(u, [2 3 1]);
    for i = 1:blocks
        y(:,(i-1)*(s-k) + 1:(i-1)*(s-k) + s) = u(:,:,i)+ ...
                                      y(:,(i-1)*(s-k) + 1:(i-1)*(s-k) + s);
    end
    w(:,(s-k)+1:end-(s-k)) = 2;
    y = y./w;
end
