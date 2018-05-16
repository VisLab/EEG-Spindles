function  [spindles, allMetrics, additionalInfo, params] =  ...
                              spinky(data, expertEvents, imageDir, params) 
%% Run the spinky algorithm on the data.  Given
%
%  Parameters:
%     data
    %% Set the epoch size and number of training frames and epoch the data
    defaults = concatenateStructs(getGeneralDefaults(), spinkyGetDefaults());
    params = processParameters('spinky', nargin, 4, params, defaults);   
    [spindles, params, oscil] = spinkyExtractSpindles(data, [], params);
    parameterCurves = spinkyGetParameterCurves(spindles, imageDir, params);
  
    %% Process the expert events if available
    metrics = struct('count', NaN, 'hit', NaN, 'intersect', NaN, ...
                        'onset', NaN, 'time', NaN); 
    if ~isempty(expertEvents)
        totalTime = length(data)/params.srate;
        numExp = length(spindles);
        allMetrics(numExp) = metrics;
        for n = 1:numExp
            allMetrics(n) = getPerformanceMetrics(expertEvents, spindles(n).events, ...
                totalTime, params);
        end
        thresholds = params.thresholds;
        for n = 1:length(params.metricNames)
            spinkyShowMetric(thresholds, allMetrics, params.metricNames{n}, ...
                imageDir, params);
        end
      
    end
    additionalInfo.spindles = spindles;
    additionalInfo.parameterCurves = parameterCurves;
    additionalInfo.metrics = metrics;
    additionalInfo.thresholds = params.thresholds;
    additionalInfo.oscil = oscil;