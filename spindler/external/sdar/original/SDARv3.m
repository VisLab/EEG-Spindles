function [mu, sigma, score, A] = SDARv3(data, order, r, trainIndex)
% SDAR       estimates a signal using the Sequential Discounting AR Model
%
% Input:
%     data            A vector of time series to model
%     order           order of the SDAR model. Default is order = 1.
%     r               Discounting rate, from (0,1). Default is r = .001
%     trainIndex      An index of points to estimate the initial conditions
%                     for the SDAR algorithm. 
%                     Example: trainIndex = 1 : 1000;
% Output:
%     mu              The estimated mean of the SDAR model at each time
%                     point. This is taken as an estimate of the original 
%                     signal.
%     sigma           The estimated variance of the SDAR model at each time
%                     point. Take the sqrt to get the standard deviation. 
%     loss            The predicted loss of the original signal vs the
%                     estimated signal usind SDAR. This is calculated using
%                     the quadratic loss function. Other functions can be
%                     used (see notes). 
%       A             The estimated SDAR Coefficients. 
%   
% Notes:
%
%  1. Algorithm for estimating the SDAR model is from Urabe et. al. (2012)
%     Real-Time Change-Point Detection Using Sequentially Discounting 
%     Normalized Maximum Likelihood Coding.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% data must be a column vector;
if size(data, 2) ~= 1
    data = data';
end

% data should be double
data = double(data);

% the time series must be 0 mean. 
data = data - mean(data);

% get initial estimates using Burg AR method. 
% w = mean estimate, A_burg is AR estimate, C_burg variance estimate
[w, A_burg, C_burg] = arfit2(data(trainIndex), order, order);  %#ok<ASGLU>

% pre-allocation, T, V, M, c taken from Urabe et. al. (2012)
T = length(data);
V = zeros(order, order, T);
M = zeros(order, T);
c = zeros(T, 1);
mu = zeros(T, 1);
sigma = zeros(T, 1);
score = zeros(T, 1);

% setting the initial conditions
V(:,:,order) = eye(order);
M(:,order) = A_burg';
sigma(1:order) = C_burg;
A(:, 1:order) = repmat(A_burg', 1, order);

% calculate the mean and standard deviation of signal in first time step
mu(order) = A(:,order)'*data(order : - 1 : 1);

if order == 1
    sigma(order) = C_burg;
else
    sigma(order) = (1 - r) * sigma(order - 1) + r * ...
       (data(order) - mu(order))*(data(order) - mu(order))';
end

c(order+1) = r * data(order : -1 : 1)'*V( :, :, order) * data(order : -1 : 1);

V(:,:,order+1) = (1/(1-r))*V(:,:,order) - (r/(1-r))*((V(:,:,order)*...
    (data(order:-1:1)*data(order:-1:1)')*V(:,:,order))/(1 - r + c(order+1)));


for i = order + 1: T
    xbar = data(i-1:-1:i-order);

    % now calculate the iteration to update the parameters
    M(:,i) = (1-r)*M(:,i-1) + r*xbar*data(i);
    c(i) = r*xbar'*V(:,:,i-1)*xbar;
    V(:,:,i) = (1/(1-r))*V(:,:,i-1) - (r/(1-r))*((V(:,:,i-1)*(xbar*xbar')*...
        V(:,:,i-1))/(1 - r + c(i)));
    A(:,i) = V(:,:,i)*M(:,i);

    % update the mean and variance, make one step prediction
    mu(i) = A(:,i)'*xbar;
    sigma(i) = (1-r)*sigma(i-1) + r*(data(i)-mu(i))*(data(i)-mu(i))';
    score(i) = (data(i)-mu(i)).^2;
%     score(i) = -log(normpdf(data(i), mu(i), sqrt(sigma(i))));
end

% transpose to get proper orientation
% A = A';

% calculate the quadratic loss of the predicted values. 
% loss = ((data(2:end)-predicted(1:end-1)).^2);
% loss = (log(normpdf(data(2:end), mu(1:end-1), sigma(1:end-1))));

end
