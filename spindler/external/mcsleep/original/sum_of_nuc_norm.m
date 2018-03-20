function nrm = sum_of_nuc_norm(u)
% function nrm = sum_of_nuc_norm(u)
%
% This function calculates the sum of singular values of the blocks of c
% i.e., nrm = sum_{i=1}^{no. of blocks} ||c_i||_*, where * represents the
% nuclear norm. 
%
% Ankit Parekh (ankit.parekh@nyu.edu)
% Last Edit: 1/19/2017

nrm = 0;
[blocks,~,~] = size(u);
for i = 1:blocks
    %Extract a block from the signal y
    nrm = nrm + sum(svd(permute(u(i,:,:), [2 3 1]),'econ'));
end

    
