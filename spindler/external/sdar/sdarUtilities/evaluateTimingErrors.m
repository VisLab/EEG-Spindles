function [results, errorInfo, timeInfo] = evaluateTimingErrors(inputData, ...
                              labeledSet1, labeledSet2, timingError, srate)
%compareLabels  Compares two sets of labeled data
%
% Syntax:
%  results = compareLabels(inputData, labeledSet1, labeledSet2, timingError, srate)
%
%  results = compareLabels(inputData, labeledSet1, labeledSet2, timingError, srate)
%  returns an event structure with three columns:
%
%        [agreement type]      [startTime]      [endTime]
%
%  Agreement Type can take one of the following:
%    'Agreement'      -  the labels of the two label sets are
%                        the same and in type agreement
%    'TypeError'      -  the labels from the two label sets are the
%                        same in time but not in type agreement
%    'FalsePositive'  -  a label in label set 2 was not found in
%                        label set 1 at that time 
%    'FalseNegative'   - a label in label set 1 was not found in
%                        label set 2 at that time
%    'NullAgreement'   - neither label set was labeled that time
%
%    'startTime' and 'endTime' are in seconds.
%
%  Inputs:
%    inputData     either a 2-D matrix input or an EEGLAB EEG structure
%                  containing 2-D data. Dimensions are channels x frames
%  labeledSet1     the output of either markEvents or plotLabeledData
%                  (treated as ground truth)
%  labeledSet2     the output of either markEvents or plotLabeledData
%  timingError     allowable timing error to still consider two regions as
%                  the same (in seconds). See examples below for
%                  further details.
%       srate      sampling rate of data in Hz 
%
%  Outputs:
%     results      Cell array with three columns:
%                  [agreement type]      [startTime]      [endTime]
%
%     errorInfo     For events with 'TypeError', 'FalsePositive' or
%                   'FalseNegative', will give the following output:
%
%                   [type1]    [type2]     [startTime]    [endTime]
%
%                   For example, if type1 = 'Blink' and type2 = 'Muscle',
%                   this will generate an event with 'TypeError', with
%                   'startTime' and 'endTime' being the start and end time,
%                   in seconds, of the disagreement.
%
%      timeInfo     A structure output with fields
%         
%                   .agreement        
%                   .typeError 
%                   .falsePositive 
%                   .falseNegative 
%                   .totalTime     
%
%                   Each field represents the amount of time (in seconds)
%                   of being in that category and .totalTime is the total
%                   length of the dataset. A sample output looks like this:
%
%                     agreement: 461.9297
%                     typeError: 3.2578
%                 falsePositive: 9.1719
%                 falseNegative: 5.0195
%                     totalTime: 480
%
%                   This denotes that the total length of the data is 480
%                   seconds, the amount of the data falling into the
%                   "agreement" category is 461.9297 seconds, which
%                   corresponds to 96.24% of the data. Percentages can be
%                   calculated for all the other conditions. Note that
%                   ".agreement" is the combination of "Agreement" and
%                   "NullAgreement" from the output of results (above).
%
% EXAMPLES:
%
%         -------------------------------      first region
%
%       *****--------------------------****    second region
%
%   Suppose there are two event types: * and -. Blank spaces in the first
%   region denote frames with no event type associated with them. Below is
%   a table of results for different values of timingError:
%
%    timingError 0        =  1 agreement, 2 false positives, 2 type errors
%    timingError 1        =  1 agreement, 2 fales positives, 2 type errors
%    timingError 2        =  1 agreement, 2 false positives, 1 type error
%    timingError 3        =  1 agreement, 2 false positives
%    timingError 4        =  1 agreement, 1 false positive
%    timingError 5        =  1 agreement
%
%
%   We use unique event types for determing type agreement/disagreement.
%   They are:
%
%       0 - 'Null' event, or absence of an event
%     111 - Type error (regions 1 and 2 are labeled, but incorrect type)
%     222 - Agreement  (regions 1 and 2 are labeled and of correct type)
%     444 - False Positives (events in region 2 not in region 1)
%     555 - False Negatives (events in region 1 not in region 2)
%
%
%      Example: Compare the labelings using two different channel sets to
%      train an artifact discrimination model:
%
%      training = pop_loadset('data/training.set');
%      load('data/labels.mat');
%      
%      % build model using all 64 EEG Channels
%      model1 = getModel(training, labels, 1:64);
%      
%      % now build model using only 32 EEG channels
%      model2 = getModel(training, labels, 1:32);
%      
%      % now load testing dataset
%      testing = pop_loadset('data/testing.set');
% 
%      % Use sliding window of .125s for data sampled at 256hz
%      results1 = labelData(testing, model1, 256, .125);
%      results2 = labelData(testing, model2, 256, .125);
% 
%      % apply a certainty policy to remove false positives
% 
%      results1 = thresholdPolicy(results1, 'None', .5);
%      results2 = thresholdPolicy(results2, 'None', .5);
% 
%      % plot the data and get an event list ignoring the category 'None'
% 
%      classes = {'Eye Blink', 'Eye Left Movement', 'Eye Up Movement', 'Eyebrow Movement', 'Jaw Clench', 'Jaw Movement'}
%      events1 = plotLabeledData(testing, model1, results1, 'srate', 256, 'includeClasses', classes);
%      events2 = plotLabeledData(testing, model2, results2, 'srate', 256, 'includeClasses', classes);
% 
%      % compare the labelings, allowing for up to .100s timing error, for
%      % data sampled at 256hz. 
% 
%      [results, errorInfo, timeInfo] = compareLabels(testing, events1,...
%      events2, .1, 256);    

%   Copyright (C) 2012  Vernon Lawhern, UTSA, vlawhern@cs.utsa.edu
%                       Kay Robbins, UTSA, krobbins@cs.utsa.edu
%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% must have at least 3 inputs
if nargin < 3
    help evaluateTimingErrors;
    return;
end

% Must have 2D data
% first check if data is in an EEGLAB EEG structure
if isstruct(inputData) && isfield(inputData, 'data') && ...
        ndims(inputData.data) == 2 %#ok<ISMAT>
    fileType = 1; % data is of the EEG structure type
    data = inputData.data;
elseif ndims(inputData) == 2 && length(inputData) ~= 1 %#ok<ISMAT>
    fileType = 2; % data is of a matrix type
    data = inputData;
else
    error('evaluateTimingErrors:DataNot2D','Data must be 2-D')
end


% sets the default behavior.
% If EEG structure, srate = EEG.srate, else srate = 256.
if nargin == 3
    timingError = 0;
    if fileType == 1
        srate = inputData.srate;
    elseif fileType == 2
        srate = 256;
    end
elseif nargin == 4
    if fileType == 1
        srate = inputData.srate;
    elseif fileType == 2
        srate = 256;
    end
end

% convert timingError to frames. Use floor to round down.
if timingError < 0
    error('The variable timingError must be non-negative');
else
    timingError = floor(timingError * srate);
end

[nChans, nFrames] = size(data); %#ok<ASGLU>

% converting event information to frame counts
frameset_1 = zeros(1, nFrames);
frameset_2 = zeros(1, nFrames);

labels_1 = unique(labeledSet1(:,1));
labels_2 = unique(labeledSet2(:,1));

% converting labels to numeric values
labels = union(labels_1, labels_2);
nLabels = 1:length(labels);

for j = 1 : length(labels);
    temp1 = strcmpi(labeledSet1(:,1), labels(j));
    temp2 = labeledSet1(temp1,:);
    if ~isempty(temp2)
        frames = floor(cell2mat(temp2(:,2:3))*srate);
        for i = 1 : size(frames, 1)
            frameset_1(frames(i, 1):frames(i, 2)) = nLabels(j);
        end
    end
end
clear temp1 temp2 frames

for j = 1 : length(labels);
    temp1 = strcmpi(labeledSet2(:,1), labels(j));
    temp2 = labeledSet2(temp1,:);
    if ~isempty(temp2)
        frames = floor(cell2mat(temp2(:,2:3))*srate);
        for i = 1 : size(frames, 1)
            frameset_2(frames(i, 1):frames(i, 2)) = nLabels(j);
        end
    end
end

agreement_vector = zeros(1, nFrames);

for i = 1 : size(labeledSet1, 1)
    analysis_window = floor(cell2mat(labeledSet1(i,2:3))*srate);
    % grab the corresponding frame locations for analysis_window
    analysis_frames = analysis_window(1):analysis_window(2);
    
    % extract the same region of data from both datasets.
    region_1 = frameset_1(analysis_window(1):analysis_window(2));
    region_2 = frameset_2(analysis_window(1):analysis_window(2));
    
    % need to compare second region to first region
    indices_1 = splitVector(region_1, 'equal', 'firstval');
    
    % grab the location and type of events found in the region
    loc_2 = splitVector(region_2, 'equal', 'loc');
    indices_2 = splitVector(region_2, 'equal', 'firstval');
    
    % find all matching events, set the code to be 222
    temp2 = find((indices_2 == indices_1));
    if ~isempty(temp2)
        for K = 1 : length(temp2);
            lower_edge = (analysis_frames(loc_2{temp2(K)}(1))-timingError);
            upper_edge = (analysis_frames(loc_2{temp2(K)}(end))+timingError);
            % make sure that there are no out-of-bounds errors
            if lower_edge < 0
                lower_edge = 1;
            elseif upper_edge > nFrames
                upper_edge = nFrames;
            end
            agreement_vector(lower_edge:upper_edge) = 222;
        end
    end
    
    % now find all frames where the events don't match, and determine type
    t3 = find(agreement_vector(analysis_frames) ~= 222);
    
    disagreements = frameset_2(analysis_frames(t3));
    disagreements_regions = splitVector(disagreements, 'equal', 'loc');
    disagreements_type = splitVector(disagreements, 'equal', 'firstVal');
    
    % if type == 0, then it is a false negative (555)
    % else it's a type error (111)
    for j = 1 : length(disagreements_type)
        if disagreements_type(j) == 0
            agreement_vector(analysis_frames(t3(disagreements_regions{j}))) = 555;
        else
            agreement_vector(analysis_frames(t3(disagreements_regions{j}))) = 111;
        end
    end
end

% now have to find the false positives, ignoring previously analyzed frames
set2 = find(frameset_2 ~= agreement_vector);
set3 = find(agreement_vector == 222 | agreement_vector == 111 | agreement_vector == 555);
false_positives = setdiff(set2, set3);

% sets the frames with false positives to be 444.
agreement_vector(false_positives) = 444;

% now calculate the confusion matrix
unique_regions = splitVector(agreement_vector, 'equal', 'loc');
unique_regions_type = splitVector(agreement_vector, 'equal', 'firstval');

% the confusion matrix is size (nLabels) + 1 (for the null event).
% use the confusion matrix to calculate errorInfo.
MatrixLabels = {'Null' labels{:}}'; %#ok<CCAT>
MatrixNLabels = [0 nLabels];
CFMatrix = zeros(length(MatrixNLabels));
J = 1;
numErrors = sum(unique_regions_type ~= 0 & unique_regions_type ~= 222);
errorInfo = cell(numErrors, 4);
for i = 1 : length(unique_regions_type)
    temp1 = unique_regions{i};
    if unique_regions_type(i) == 222
        t1 = mode(frameset_1(temp1(1+timingError:end-timingError)));
        t2 = mode(frameset_2(temp1(1+timingError:end-timingError)));
    else
        t1 = mode(frameset_1(temp1));
        t2 = mode(frameset_2(temp1));
    end
    CFMatrix(t1(1)+1, t2(1)+1) = CFMatrix(t1(1)+1, t2(1)+1) + 1;
    if t1 ~= t2
        errorInfo{J,1} = char(MatrixLabels(t1+1));
        errorInfo{J,2} = char(MatrixLabels(t2+1));
        errorInfo{J,3} = (temp1(1)-1)/srate;
        errorInfo{J,4} = (temp1(end)-1)/srate;
        J = J + 1;
    end
end

results = cell(length(unique_regions), 3);
for i = 1 : length(unique_regions)
    if unique_regions_type(i) == 0
        results{i,1} = 'NullAgreement';
    elseif unique_regions_type(i) == 111
        results{i,1} = 'TypeError';
    elseif unique_regions_type(i) == 222
        results{i,1} = 'Agreement';
    elseif unique_regions_type(i) == 444
        results{i,1} = 'FalsePositive';
    else results{i,1} = 'FalseNegative';
    end
    results{i, 2} = (unique_regions{i}(1)-1)/srate;
    results{i, 3} = (unique_regions{i}(end)-1)/srate;
end

% now calculating timeInfo.
t1 = strcmpi(results(:,1), 'Agreement');
t2 = strcmpi(results(:,1), 'TypeError');
t3 = strcmpi(results(:,1), 'FalsePositive');
t4 = strcmpi(results(:,1), 'FalseNegative');
t5 = strcmpi(results(:,1), 'NullAgreement');

timeInfo.agreement = sum(diff(cell2mat(results(t1,2:3))'))+sum(t1,1)/srate;
timeInfo.typeError = sum(diff(cell2mat(results(t2,2:3))'))+sum(t2,1)/srate;
timeInfo.falsePositive = sum(diff(cell2mat(results(t3,2:3))'))+sum(t3,1)/srate;
timeInfo.falseNegative = sum(diff(cell2mat(results(t4,2:3))'))+sum(t4,1)/srate;
timeInfo.nullAgreement = sum(diff(cell2mat(results(t5,2:3))'))+sum(t5,1)/srate;
timeInfo.totalTime = (nFrames-1)/srate;
end