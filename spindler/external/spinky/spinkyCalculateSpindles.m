function spinkySpindles = spinkyCalculateSpindles(oscil, srate, thresholds,  params)
%% Calculate spinky spindles for a set of thresholds given oscil representation
    numThresholds = length(thresholds);
    spinkySpindles(numThresholds) = ...
        struct('threshold', NaN, 'spindleList', NaN);
    for k = 1:numThresholds
        spinkySpindles(k) = spinkySpindles(end);
        spinkySpindles(k).threshold = thresholds(k);
        spinkySpindles(k).spindleList = ...
            getSpindlesForThreshold(oscil, thresholds(k), params);
    end

    function spindleList = getSpindlesForThreshold(oscil, t, params)
        numEpochs = size(oscil, 1);
        spindleList = cell(numEpochs, 1);
        for j = 1:numEpochs
            [numSpindles, pos_sp] = spDetect(oscil(j, :), srate, t, params);
            if numSpindles == 0
                continue;
            else
                y = pos_sp;
                sa = sign(diff([-inf y]));
                sb = sign(diff([-inf y(end:-1:1)]));
                sb = sb(end:-1:1);
                d = find(sb==-1);
                f = find(sa==-1);
                spindleList{j} = [d(:), f(:)]./srate;
            end
        end
    end
end
