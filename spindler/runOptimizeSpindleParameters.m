%% Show the curves for selecting the paramters
%% Run the spindle parameter selection
resultsDir = 'D:\TestData\Alpha\spindleData\BCIT\resultsSpindler';
imageDir = 'D:\TestData\Alpha\spindleData\BCIT\imagesSpindler';

% resultsDir = 'D:\TestData\Alpha\spindleData\dreams\resultsSpindler';
% imageDir = 'D:\TestData\Alpha\spindleData\dreams\imagesSpindler';

% spindleDir = 'D:\TestData\Alpha\spindleData\nctu\spindles';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\images';

%% Make sure the outDir exists
if ~exist(imageDir, 'dir')
    mkdir(imageDir);
end

%% Load the data and initialize variables
resultsFiles = getFiles('FILES', resultsDir, '.mat');
for k = 1:length(resultsFiles)
    results = load(resultsFiles{k});
    [~, theName, ~] = fileparts(resultsFiles{k});
    totalSeconds = results.params.frames./results.params.srate;
    [atoms, threshold] = getSpindleParameters(results.spindles, ...
                                         totalSeconds, theName, imageDir);
end