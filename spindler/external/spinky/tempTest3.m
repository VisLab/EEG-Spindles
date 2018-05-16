outDir = 'temp';
spindleCurves = spinkyGetParameterCurves(spindles, outDir, params);
totalTime = size(oscil, 1)*30;
   metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                        'onset', NaN, 'time', NaN); 
  numExp = length(spindles);
        allMetrics(numExp) = metrics;
        for n = 1:numExp
            allMetrics(n) = getPerformanceMetrics(expertEvents, spindles(n).events, ...
                totalTime, params);
        end
        
        
       for n = 1:length(params.metricNames)
            spinkyShowMetric(thresholds, allMetrics, params.metricNames{n}, ...
                outDir, params);
        end