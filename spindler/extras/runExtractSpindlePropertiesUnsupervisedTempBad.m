%% Extracts data for a particular collection of unsupervised algorithms
collection = 'mass';
dataDir = 'D:\TestData\Alpha\spindleData\massNew';
% collection = 'dreams';
% dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithms = {'spindler', 'cwta7', 'cwta8', 'sem'};
experts = {'combined', 'expert1', 'expert2'};
baseMetricName = 'f1';
methodName = 'time';
summaryDir = 'D:\TestData\Alpha\spindleData\summaryUnsupervised';
propertyFileBase = [summaryDir filesep collection '_properties_'];

%% Get the data files
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);

%% Extract the unsupervised properties
numAlgorithms = length(algorithms);
fractionUnsupervised = nan(numFiles, numAlgorithms);
lengthUnsupervised = nan(numFiles, numAlgorithms);
rateUnsupervised = nan(numFiles, numAlgorithms);

for k = 1:numAlgorithms  
    fileName = [propertyFileBase algorithms{k} '.mat'];
    test = load(fileName);
    fractionUnsupervised(:, k) = test.spindleFraction;
    lengthUnsupervised(:, k) = test.spindleLength;
    rateUnsupervised(:, k) = test.spindleRate;
end

%% Extract the experts properties
numExperts = length(experts);
fractionExperts = nan(numFiles, numExperts);
lengthExperts = nan(numFiles, numExperts);
rateExperts = nan(numFiles, numExperts);

for k = 1:numExperts  
    fileName = [propertyFileBase experts{k} '.mat'];
    test = load(fileName);
    fractionExperts(:, k) = test.spindleFraction;
    lengthExperts(:, k) = test.spindleLength;
    rateExperts(:, k) = test.spindleRate;
end

%% Do the pictures
yLabels = {'Spindles/min'};
expertShapes = {'^', 'v'};
unsupervi
for k = 1
    figure('Name', [collection ':' yLabels{k}];
    
    for n = 1:numExperts
        plot(