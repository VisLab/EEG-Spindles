function metrics = getConfusionMetrics(confusion)
%% Compute performance metrics based on the confusion matrix
% 
%  Parameters:
%    confusion   structure with tp, fn, fp, and tn fields
%    metrics  (Output) Structure containing the following performance metrics
%      accuracy
%      precision
%      recall
%      sensitivity
%      specificity 
%      ppv
%      npv
%      tpr
%      fpr
%      roc
%      auc 
%      phi
%      fdr
%      f1
%      f2
%      G
%      kappa
%
%  Written by:  John La Rocco and Kay Robbins, UTSA, 2016-2018

%% Initialize the metrics structure
    metrics = struct('tp', NaN, 'tn', NaN, 'fn', NaN, 'fp', NaN, ...
                     'accuracy', NaN, 'precision', NaN, 'recall', NaN, ...
                     'sensitivity', NaN, 'specificity', NaN, ...
                     'ppv', NaN, 'npv', NaN, 'tpr', NaN, 'fpr', NaN, ...
                     'roc', NaN, 'auc', NaN, 'phi', NaN, 'fdr', NaN, ...
                     'f1', NaN, 'f2', NaN, 'G', NaN, 'kappa', NaN);

%% Make sure that a confusion structure has been passed
    if ~isfield(confusion, 'tp') || ~isfield(confusion, 'fn') || ...
            ~isfield(confusion, 'fp') || ~isfield(confusion, 'tn')
        warning('getConfusionMetrics:InvalidConfusion', ...
            'confusion must be a structure with tp, fn, fp, and tn fields');
        return;
    end
%% Compute auxillary variables
    tp = confusion.tp;
    fn = confusion.fn;
    fp = confusion.fp;
    tn = confusion.fn;
    metrics.tp = tp;
    metrics.fn = fn;
    metrics.fp = fp;
    metrics.tn = tn;

    checkSum = tp + tn + fn + fp;
    predPositives = tp + fp;
    predNegatives = tn + fn;
    truePositives = tp + fn;
    trueNegatives = fp + tn;
    
%% Compute the metrics
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
    if metrics.precision + metrics.recall == 0
        metrics.f1 = 0;
        metrics.f2 = 0;
    else
       metrics.f1 = 2*metrics.precision*metrics.recall/(metrics.precision + metrics.recall);
       metrics.f2 = 5.*metrics.precision*metrics.recall ...
        ./(4.*metrics.precision + metrics.recall);
    end
    metrics.G = sqrt(metrics.precision*metrics.recall);
    Po = metrics.accuracy;
    Pe = ((tp + tn)*(tp + fp) + (fp + tn)*(fn + tn))/checkSum;
    metrics.kappa = (Po - Pe)/(1 - Pe);
    metrics.fdr = fp/(fp + tp);
end