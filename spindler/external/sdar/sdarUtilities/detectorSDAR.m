function  [new_events,output]=detectorSDAR(EEG,channel_index,expert_events)

%clear; close; clc;

%%VERNON'S BASELINE SCENARIO

if nargin==3
    doPerformance=true;
    
else
    doPerfomrance=false;
    
    
end


% order = 2;
order = 1;


for i = 1 : length(channel_index)
    tic;
    [mu(i,:), sigma(i,:), loss(i,:), A(i,1:order,:)] = SDARv3(EEG.data(channel_index(i),:), order, .001, 1:100);
    toc;
end



clear smoothed;
for k = 1 : length(channel_index)
    smoothed(k,:) = moving_average(loss(k,:), 5);
end

%%


%%
if doPerformance
    thresholds=linspace(min(min(smoothed)),max(max(smoothed)),100);
else
    thresholds=(min(min(smoothed))+max(max(smoothed)))/order;
    
end

for K = 1 : length(thresholds)
    fprintf('K = %d\n', K);
    events = applyThreshold(smoothed, EEG.srate, thresholds(K), 1/3);
    if isempty(events)
        continue
    end
    
    new_events = combineEvents(events, .25, .25);
    if doPerformance
        [~,~,c] = compareLabels(EEG, expert_events, new_events, 0.1, EEG.srate);
        
        sensitivity1(K) = c.agreement/(c.agreement + c.falseNegative);
        specificity1(K) = c.nullAgreement/(c.nullAgreement+c.falsePositive);
        precision1(K) = c.agreement/(c.agreement+c.falsePositive);
        recall1(K) = c.agreement/(c.agreement+c.falseNegative);
    end
end


if doPerformance
    beta1 = 2;
    f1 = (1 + beta1^2).*(precision1.*recall1)./((beta1^2.*precision1) + recall1);
    
    [~,b] = max(f1);
    
    
    %%
    events = applyThreshold(smoothed, EEG.srate, thresholds(b), 1/3);
    new_events = combineEvents(events, .25, .25);
    
    [~,~,c1] = compareLabels(EEG, expert_events, new_events, 0.1, EEG.srate);
    
    %% calculate hit rate
    precision2=c1.agreement/(c1.agreement+c1.falsePositive);
    recall2=c1.agreement/(c1.agreement+c1.falseNegative);
    sensitivity2=c1.agreement/(c1.agreement+c1.falseNegative);
    specificity2=c1.nullAgreement/(c1.nullAgreement+c1.falsePositive);
    
    output=struct('C1',{c1},'events',new_events,'Thresholds',thresholds(b),'Precision',precision2,'Recall',recall2,'Sensitivity',sensitivity2,'Specificity',specificity2);
    
else
    output=struct('events',new_events,'Thresholds',thresholds);
    
end

end

