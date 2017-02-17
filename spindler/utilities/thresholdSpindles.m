function [events, threshold, timeInfo] = thresholdSpindles(EEG, ...
        reconstructed, finalThres, channelList, timeError, minLength, ...
        minTime, expertEvents)


% Last updated: November 2016, J. LaRocco

% Details: MP reconstruction of EEG with restricted dictionary.

% Usage:
% [events,performance,threshold]=thresholdSTAMP(EEG, expert_events, smoothed, thresholds)

% Input:
%  EEG: Input EEG struct. (EEGLAB format)
%  reconstructed: reconstruction of EEG data (vector)
%  finalThres: vector of values to explore for threshold (vector)
%  timeThreshold: time of merged events to reject (in s)
%  timeError: timing error (in s)
%  minLenth: min length (in s) of events to combine
%  minTime: min time (in s) of events to combine. Should be same as minLength.
%  expertEvents: struct with expert-rated times and durations for spindles (scalar or vector of positive integers).
% Output:
%  events: final events
%  performance: struct with final results
%  threshold: final threshold

%--------------------------------------------------------------------------
%% Set the voting scale
if length(channelList) > 3
    vote = 1/3;
else
    vote = 1/length(channelList);   
end

%% Apply threshold for classification
threshold = finalThres;
timeInfo = [];
events = applyThreshold(reconstructed, EEG.srate, finalThres, vote);
if isempty(events)
    return;
end
newEvents = combineEvents(events, minLength, minTime);

if nargin > 7
    [~, ~, timeInfo] = compareLabels(EEG, expertEvents, newEvents, ...
                                        timeError, EEG.srate);
    labels = zeros(1,length(reconstructed));
    [keyEvents, ~] = size(expertEvents);
    [newEvents, ~] = size(newEvents);
    outEvents = zeros(size(newEvents, 1), 2);
    for j = 1:keyEvents;
        keystart = expertEvents{j, 2};
        keyend = expertEvents{j, 3};
        outEvents(j, 1) = keystart;
        outEvents(j, 2) = keyend;
        lb = ceil(EEG.srate*keystart);
        ub = ceil(EEG.srate*keyend);
        labels(lb:ub) = 1;    
    end
    
%     for jb=1:newEvents    
%         lb=ceil(EEG.srate*keystart);
%         ub=ceil(EEG.srate*keyend);
%         scores(lb:ub)=1;
%     end
 
    %% Set the expert event structure for comparison
    numberEvents = size(expertEvents, 1);
    EEG.event = [];
    temp1(numberEvents).type = [];
    temp1(numberEvents).latency = [];
    
    for i = 1:numberEvents
        temp1(i).type = 'start';
        temp1(i).latency = cell2mat(expertEvents(i, 2))*EEG.srate;
    end
    
    for j = numberEvents + 1 : 2*size(expertEvents, 1)
        temp1(j).type = 'end';
        temp1(j).latency = cell2mat(expertEvents(j - numberEvents, 3))*EEG.srate;     
    end
    events = outEvents;
    EEG.event = temp1;
    
else  
    outEvents = zeros(size(newEvents,1),2);  
    for k = 1:size(newEvents,1)
        keys = newEvents{k,2};
        keye = newEvents{k,3};
        outEvents(k,1) = keys;
        outEvents(k,2) = keye;
    end
    events = outEvents;
end

end