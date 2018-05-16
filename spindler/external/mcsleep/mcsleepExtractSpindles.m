function [spindles, params] = mcsleepExtractSpindles(y, params)
% Please cite as: 
% Multichannel Sleep Spindle Detection using Sparse Low-Rank Optimization 
% A. Parekh, I. W. Selesnick, R. S. Osorio, A. W. Varga, D. M. Rapoport and I. Ayappa 
% bioRxiv Preprint 2017, doi: https://doi.org/10.1101/104414
%
% Last EDIT: 4/22/2017
% Ankit Parekh
% Perm. Contact: ankit.parekh@nyu.edu
%
% Copyright (c) 2017. Ankit Parekh 

%% Calculate the spindle masks
defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
params = processParameters('mcsleepExtractSpindles', nargin, 2, params, defaults);
thresholds = params.mcsleepThresholds;
lambda2s = params.mcsleepLambda2s;
mcsleepSpindles = mcsleepCalculateSpindles(y, thresholds, lambda2s, params);

%% Set up the parameters
numParms = length(mcsleepSpindles);
spindles(numParms) = struct('lambda2', 0, 'threshold', 0, ...
    'numberSpindles', 0, 'spindleTime', 0, 'events', NaN);
posMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:numParms
    keyString = [num2str(mcsleepSpindles(k).lambda2) ',' ...
                 num2str(mcsleepSpindles(k).threshold)];
    posMap(keyString) = k;
end

%% Now create the spindles
pos = 0;
for k = 1:length(thresholds)
    for m = 1:length(lambda2s)
        pos = pos + 1;
        spindles(pos) = spindles(end);
        keyString = [num2str(lambda2s(m)) ',' num2str(thresholds(k))];
        if ~isKey(posMap, keyString)
            warning('threshold-lambda combination not available');
            continue;
        end
        thisValue = posMap(keyString);   
        spindles(pos).threshold = mcsleepSpindles(thisValue).threshold;
        spindles(pos).lambda2 = mcsleepSpindles(thisValue).lambda2;
        events = combineEvents(mcsleepSpindles(thisValue).spindles, ...
            params.spindleLengthMin, params.spindleSeparationMin);
        spindles(pos).events = events;
        if ~isempty(events)
            spindles(pos).numberSpindles = size(events, 1);
            spindles(pos).spindleTime = sum(events(:, 2) - events(:, 1));
        end
    end
end
%% This is a test
fprintf('Finished\n');