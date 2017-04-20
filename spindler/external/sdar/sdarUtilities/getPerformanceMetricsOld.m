function metrics = getPerformanceMetricsOld(tp, tn, fp, fn)

%--------------------------------------------------------------------------
% correctOutputs

% Last updated: July 2016, J. LaRocco

% Details: Calculates performance metrics from confusion matrix.

% Usage:
%   metrics = getPerformanceMetrics(tp, tn, fp, fn)

% Input:
%  tp: True positives (positive number)
%  tn: True negatives (positive number)
%  fp: False positives (positive number)
%  fn: False negatives (positive number)

% Output:
%  phi: phi correlation
%  roc: roc coefficients
%  auc_roc: product of roc coefficients
%  accuracy: accuracy
%  sensitivity: sensitivity
%  specificity: specificity
%  acc2: accuracy
%  ppv: positive predictive value
%  npv: negative predictive value
%  f1: f1 measure with 2 as beta
%  kappa: Cohen's kappa


%--------------------------------------------------------------------------
    metrics = struct('tp', tp, 'tn', tn, 'fn', fn, 'fp', fp, ...
                     'accuracy', NaN, 'sensitivity', NaN, 'specificity', NaN, ...
                     'ppv', NaN, 'npv', NaN, 'tpr', NaN, 'fpr', NaN, ...
                     'roc', NaN, 'auc', NaN, 'phi', NaN, ...
                     'precision', NaN, 'recall', NaN, ...
                     'f1', NaN, 'f1Mod', NaN, 'G', NaN, 'kappa', NaN);
    %should equal 'instances' value
    checkSum = tp + tn + fn + fp;
    predPositives = tp + fp;
    predNegatives = tn + fn;
    truePositives = tp + fn;
    trueNegatives = fp + tn;

    metrics.accuracy = (tp + tn)/checkSum;
    metrics.sensitivity = tp/truePositives;
    metrics.specificity = tn/trueNegatives;
    metrics.ppv = tp/predPositives;
    metrics.npv = tn/predNegatives;
    metrics.tpr = metrics.sensitivity;
    metrics.fpr = 1 - metrics.specificity;
    metrics.roc= [metrics.fpr, metrics.tpr];
    metrics.auc = metrics.fpr*metrics.tpr;
    metrics.phi = 0;
    phi_denom = sqrt(truePositives*trueNegatives*predPositives*predNegatives);
    if ~isinf(phi_denom) && ~isnan(phi_denom) && phi_denom ~= 0
        metrics.phi = (tp*tn - fp*fn)/phi_denom;
    end
    metrics.precision = metrics.ppv;
    metrics.recall = metrics.sensitivity;
    metrics.f1 = 2*metrics.precision*metrics.recall/(metrics.precision + metrics.recall);
    beta1 = 2;
    metrics.f1Mod = (1 + beta1^2).*metrics.precision*metrics.recall ...
        ./(beta1^2.*metrics.precision + metrics.recall);

    metrics.G = sqrt(metrics.precision*metrics.recall);
    Po = metrics.accuracy;
    Pe = ((tp + tn)*(tp + fp) + (fp + tn)*(fn + tn))/checkSum;
    metrics.kappa = (Po - Pe)/(1 - Pe);
end