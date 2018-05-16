%% Wrapper for calling the Spinky Demo code


%% Set up the directory spinky demo data
dataDir = 'D:\Research\AlphaCharacterization\alphaWorking\EEG-Spindles\spindler\external\spinky';
eventDir = 'D:\Research\AlphaCharacterization\alphaWorking\EEG-Spindles\spindler\external\spinky';
epochLength = 30;
srate = 1000;
isEpoched = true;
trainingData = load([dataDir filesep 'training_data.mat']);
testData = load([dataDir filesep 'test_data.mat']);
trainingData = trainingData.mat;
testData = testData.mat;
trainingEvents = readEvents([eventDir filesep 'training_data.txt'], ...
    isEpoched, epochLength);
testEvents = readEvents([eventDir filesep 'test_data.txt'], ...
    isEpoched, epochLength);
numTrainEpochs = round(length(trainingData)/srate/epochLength);
data = [trainingData, testData];
expertEvents = [trainingEvents; testEvents + numTrainEpochs*epochLength];
theName = 'SpinkyDemo';
%% Set the parameters
defaults = concatenateStructs(getGeneralDefaults(), spinkyGetDefaults());
paramsInit = processParameters('runSpinky', 0, 0, struct(), defaults);
paramsInit.srateTarget = 0;
paramsInit.srate = srate;
paramsInit.epochLength = epochLength;
paramsInit.name = theName;
numTrainEpochs = 15;
paramsInit.supervisedTrainingDataLength = numTrainEpochs*epochLength;

%% Metrics to calculate and methods to use
paramsInit.metricNames = {'f1', 'f2', 'G'};
paramsInit.methodNames = {'countMetrics', 'hitMetrics', 'intersectMetrics', 'onsetMetrics', 'timeMetrics'};
paramsInit.spindleLengthMin = 0.2;
%% Run the algorithm
params = paramsInit;
%[labeledEvents, metrics, additionalInfo, params] =  ...
labeledEvents =   spinky(data, expertEvents,  params);

%     theFile = [resultsDir filesep theName '_spinky.mat'];
%     save(theFile, 'labeledEvents', 'expertEvents', 'metrics', ...
%         'params', 'additionalInfo', '-v7.3');
%  end
% 
% % %% Now create a summary of the performance results
% % if ~isempty(summaryFile)
% %    [results, dataNames] = consolidateResults(resultsDir, methodNames, metricNames);
% %     save(summaryFile, 'results', 'dataNames', 'methodNames', 'metricNames', '-v7.3');
% % end