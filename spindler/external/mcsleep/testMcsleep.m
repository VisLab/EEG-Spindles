defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
params = processParameters('runMcSleep', 0, 0, struct(), defaults); 
load('EEGSample.mat');

[x, s, cost] = mcsleepSeparateSignal(Y, params);