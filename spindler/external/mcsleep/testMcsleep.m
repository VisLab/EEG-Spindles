defaults = concatenateStructs(getGeneralDefaults(), mcsleepGetDefaults());
params = processParameters('runMcSleep', 0, 0, struct(), defaults); 
Y = load('EEGSample.mat');
Y = Y.Y;
params.srate = 200; 
params.mcsleepMu = 0.5;
params.mcsleepNit = 80;
params.mcsleepO = 100;
params.maxsleepLambda2s = 36;

params.mcsleepLambda1 = 6.5;
params.mcsleepLambda0 = 0.3;
params.mcsleepLambda2s = 36;
lambda2s = params.mcsleepLambda2s;
params.mcsleepCalculateCost = true;
[x, s, cost] = mcsleepSeparateSignal(Y, lambda2s(1), params);

%%
test1 = load('D:\mcsleepDemo.mat');
fprintf('YDiff = %g\n', max(max(abs(Y - test1.Y))));
fprintf('xDiff = %g\n', max(max(abs(x - test1.x))));
fprintf('sDiff = %g\n', max(max(abs(s - test1.s))));
fprintf('costDiff = %g\n', max(max(abs(cost - test1.cost))));
