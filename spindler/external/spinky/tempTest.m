% test = load('training_data.mat');
% data = test.mat;
% thresholds = [];
% defaults = concatenateStructs(getGeneralDefaults(), spinkyGetDefaults());
% paramsInit = processParameters('runSpinky', 0, 0, struct(), defaults);
% paramsInit.srate = 1000;
% paramsInit.name = 'SpinkyTrain';
% [spinkySpindles, thresholds, oscil] = spinky(data, thresholds, paramsInit);

load('d:\temp\asp\spinkyT.mat'); 
%%
numThresholds = length(thresholds);
numEpochs = size(oscil, 1);
spindles_visual_score='Spindles_visual_score_training_data.txt';
sp_train_score = load_visual_score(spindles_visual_score, numEpochs);
sp_Sen = zeros(numThresholds, 1);
sp_FDR = zeros(numThresholds, 1);
for n = 1:numThresholds
  theseSpindles = spinkySpindles(n).spindleList;
  nbr_sp = zeros(numEpochs, 1);
  for m = 1:length(theseSpindles)
     nbr_sp(m) = size(theseSpindles{m}, 1); 
  end
  [sp_Sen(n),sp_FDR(n)] = performances_measure(sp_train_score, nbr_sp);
end

%%
show_plot = 'On';
[sp_optimal_thresh]=ROC_curve(sp_FDR,sp_Sen,thresholds,show_plot);