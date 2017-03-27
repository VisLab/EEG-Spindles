%% Show the curves for selecting the paramters
%% Run the spindle parameter selection
% spindlesDir = 'D:\TestData\Alpha\spindleData\BCIT\spindles';
% imageDir = 'D:\TestData\Alpha\spindleData\BCIT\images';

spindleDir = 'D:\TestData\Alpha\spindleData\dreams\spindles';
imageDir = 'D:\TestData\Alpha\spindleData\dreams\images';

% spindleDir = 'D:\TestData\Alpha\spindleData\nctu\spindles';
% imageDir = 'D:\TestData\Alpha\spindleData\nctu\images';

%% Make sure the outDir exists
if ~exist(imageDir, 'dir')
    mkdir(imageDir);
end

%% Load the data and initialize variables
spindleFiles = getFiles('FILES', spindleDir, '.mat');
for k = 1%:length(spindleFiles)
    results = load(spindleFiles{k});
    [~, theName, ~] = fileparts(spindleFiles{k});
    totalSeconds = results.params.frames./results.params.srate;
    showSpindleParameters(results.spindles, totalSeconds, theName, imageDir);
end