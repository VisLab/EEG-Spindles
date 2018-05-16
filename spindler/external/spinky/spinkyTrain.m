function [optimalThreshold, bestFDR, bestSen, thresholdRange] = ...
                               spinkyTrain(trainData, expertCounts, params)
%% Train spinky on the number of epochs in trainData
    fs = params.srate;
    frequencyRange = params.spinkySpindleFrequencyRange;
    thresholdRange = getThresholdRange(trainData, fs, frequencyRange);
    oscil = zeros(size(trainData));
    numEpochs = size(trainData, 1);
    for j = 1:numEpochs
        oscil(j, :) = signalDecomposition(trainData(j, :), fs);
    end
    [optimalThreshold, bestFDR, bestSen] = ...
        train(oscil, thresholdRange, expertCounts, params);
end


function  [optimalThreshold, bestFDR, bestSen] = ...
             train(sig, thresholdRange, expertScore, params)
%% Find an optimal threshold based on training data
    numSignals = size(sig, 1);
    numThresholds = length(thresholdRange);
    sensitivity = zeros(numThresholds, 1);
    FDR = zeros(numThresholds, 1);
    for k = 1:numThresholds
       numSpindles = zeros(numSignals, 1);
       for i = 1:numSignals 
          numSpindles(i) = spDetect(sig(i, :), thresholdRange(k), params);
       end
       [sensitivity(k), FDR(k)] = measurePerformance(expertScore, numSpindles);
    end
    [optimalThreshold, bestFDR, bestSen] = getThresholdFromROC(FDR, ...
        sensitivity, thresholdRange, params.spinkyShowROC);
end

function [Sen,FDR] = measurePerformance(numTrue, numLabeled)
    tp = 0;
    fp = 0;
    fn = 0;
    for m = 1:length(numTrue)
        tp = tp + min(numLabeled(m), numTrue(m));
        fp = fp + max(0, numLabeled(m) - numTrue(m));
        fn = fn + max(0, numTrue(m) - numLabeled(m));
    end
    Sen = 0.0;
    if tp + fn > 0
        Sen=100.*(tp/(tp + fn));
    end
    FDR = 0;
    if fp + tp > 0
        FDR=100.*(fp/(fp + tp));
    end
end