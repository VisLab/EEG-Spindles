function [ Score ] = F1score( bD, vd1, vd2 )
%[ Score ] = F1score (( bD, vd1, vd2 )
% Computes the F1 score by sample of a sleep spindle detection algorithm
% Input : 
%           bD:         Binary vectors containing 1's where a spindle
%                       is recorded and 0's where no spindle is detected           
%           vd1,2:      Binary vector depicting the spindles marked
%                       by visual expert 1,2 respectively
% Output :  
%           Score:      2x1 score cell structure. Each cell is a type of
%                       statistic for sleep spindle detection. Score.label describes
%                       the type of statistic
%
% Note: All definitions of tp,fp,tn,f1, are from - Sleep-spindle detection: 
% crowdsourcing and evaluating performance of experts, non-experts and automated methods
% Warby S.C, et al 2014.
% Ankit Parekh
% NYU-Poly
% 06/20/14

Score = cell(2,1);
Score{1} = {'True Positive','True Negative', 'False Positive', 'False Negative', ...
            'Recall', 'Precision', 'F1 Score', 'Specificity', ...
            'Negative Predictive Value', 'Accuracy', 'Cohens Kappa', ...
            'Matthews Correlation Coefficient'};
Score{2} = zeros(12,1);        
tp = 0;
tn = 0;
fp = 0;
fn = 0;

%Make sure that the lengths of vd1,vd2 are same

maxLength = max(length(vd1),length(vd2));

vd1 = [vd1; zeros(maxLength-length(vd1),1)];
vd2 = [vd2; zeros(maxLength-length(vd2),1)];

for i = 1:length(bD)
    if bD(i) && (vd1(i) || vd2(i))
        tp = tp + 1;
    elseif ~bD(i) && (~vd1(i) && ~vd2(i))
        tn = tn + 1;
    elseif bD(i) && (~vd1(i) && ~vd2(i))
        fp = fp + 1;
    elseif ~bD(i) && (vd1(i) || vd2(i))
        fn = fn + 1;   
    end
end

Score{2}(1) = tp;
Score{2}(2) = tn;
Score{2}(3) = fp;
Score{2}(4) = fn;

recall = tp/(tp + fn); 
Score{2}(5) = recall;

precision = tp/(tp + fp); 
Score{2}(6) = precision;

f1 = 2*(recall*precision)/(recall + precision);
Score{2}(7) = f1;

spc = tn/(fp + tn);
Score{2}(8) = spc;

npv = tn/(tn + fn);
Score{2}(9) = npv;

n = (tp + tn + fp + fn);
acc = (tp + tn)/n;
Score{2}(10) = acc;

pr = (((tp + fn)/n)*((tp + fp)/n)) + (1-((tp + fn)/n)) * (1-((tp + fp)/n));
kappa = (((tp+tn)/n)-pr)/(1-pr);
Score{2}(11) = kappa;

mcc = (tp*tn-fp*fn)/sqrt((tp+fn)*(tp+fp)*(tn+fp)*(tn+fn));
Score{2}(12) = mcc;






