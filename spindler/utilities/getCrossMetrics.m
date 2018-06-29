function crossMetrics = getCrossMetrics(fileName, crossFraction, ...
                         methodName, baseMetricName, metricNames)

   crossMetrics = struct(...
         'fileName', NaN, 'crossFraction', NaN, 'methodName',  NaN, ...
         'baseMetricName', NaN, 'metricNames', NaN, ...
         'valueAll', NaN, 'indicesAll', NaN, ...
         'metricsAll', NaN, 'propertiesAll', NaN, ...
         'valueFirst', NaN, 'indicesFirst', NaN, ...
         'metricsFirst', NaN,'propertiesFirst', NaN,  ...
         'valueSecond', NaN, 'indicesSecond', NaN, ...
         'metricsSecond', NaN, 'propertiesSecond', NaN, ...
         'metricsFirstFromSecond', NaN, 'propertiesFirstFromSecond', NaN, ...
         'metricsSecondFromFirst', NaN, 'propertiesSecondFromFirst', NaN);
                        
%% Make sure file exists
   if isempty(fileName) || ~exist(fileName, 'file')
       warning('%s: has no cross metrics', fileName);
       return;
   end
   crossMetrics.fileName = fileName;
   crossMetrics.crossFraction = crossFraction;
   crossMetrics.methodName = methodName;
   crossMetrics.baseMetricName = baseMetricName;
   crossMetrics.metricNames = metricNames;
   numMetrics = length(metricNames);
   
   %% Load the file and make sure that the metrics exist
   test = load(fileName);
   allMetrics = test.additionalInfo.allMetrics;
   expertEvents = test.expertEvents;
   if isempty(allMetrics) || isempty(expertEvents)
       warning('File: %s has no metrics or ratings', fileName);
       return
   end
   if isfield(test.additionalInfo, 'totalTime')
       totalTime = test.additionalInfo.totalTime;
   else 
       totalTime = (test.additionalInfo.endFrame - test.additionalInfo.startFrame)./ ...
                    test.additionalInfo.srate;
   end
   %% Get optimal metrics for entire interval
   baseMetric = getMetric(allMetrics, methodName, baseMetricName);
   [crossMetrics.valueAll, crossMetrics.indicesAll] = ...
                getMetricOptimal(baseMetric);
   [sFraction, sLength, sRate] = ...
       getEventProperties(test.expertEvents, totalTime); 
   crossMetrics.propertiesAll = [sFraction, sLength, sRate];

      
   %% Now extract the optimal metric for the first part
   [allMetricsFirst, expertFirst, eventsFirst, timeFirst] = ...
       getPerformanceMetricsOnInterval(expertEvents, test.spindles, ...
                               0, totalTime*crossFraction, test.params); 
   firstMetric = getMetric(allMetricsFirst, methodName, baseMetricName);
   [crossMetrics.valueFirst, crossMetrics.indicesFirst] = ...
       getMetricOptimal(firstMetric);
   [sFraction, sLength, sRate] = ...
       getEventProperties(eventsFirst{crossMetrics.indicesFirst(1), ...
                          crossMetrics.indicesFirst(2)}, timeFirst); 
   crossMetrics.propertiesFirst = [sFraction, sLength, sRate];
   
     %% Now extract the optimal metric for the second part
   [allMetricsSecond, expertSecond, eventsSecond, timeSecond] = ...
       getPerformanceMetricsOnInterval(test.expertEvents, ...
       test.spindles, totalTime*crossFraction, totalTime, test.params);
   secondMetric = getMetric(allMetricsSecond, methodName, baseMetricName);
   [crossMetrics.valueSecond, crossMetrics.indicesSecond] = ...
       getMetricOptimal(secondMetric);
   [sFraction, sLength, sRate] = ...
       getEventProperties(eventsSecond{crossMetrics.indicesSecond(1), ...
                          crossMetrics.indicesSecond(2)}, timeSecond); 
   crossMetrics.propertiesSecond = [sFraction, sLength, sRate];
   
   %% Get optimal metrics and properties for first and second pieces
   metricsAll =  nan(numMetrics, 1);
   metricsFirst = nan(numMetrics, 1);
   metricsSecond = nan(numMetrics, 1);
   metricsFirstFromSecond = nan(numMetrics, 1);
   metricsSecondFromFirst = nan(numMetrics, 1);
   for j = 1:numMetrics
       mAll = getMetric(allMetrics, methodName, metricNames{j});
       metricsAll(j) = ...
           mAll(crossMetrics.indicesAll(1), crossMetrics.indicesAll(2));
       mFirst = getMetric(allMetricsFirst, methodName, metricNames{j});
       metricsFirst(j) = ...
           mFirst(crossMetrics.indicesFirst(1), crossMetrics.indicesFirst(2));
       mSecond = getMetric(allMetricsSecond, methodName, metricNames{j});
       metricsSecond(j) = ...
           mSecond(crossMetrics.indicesSecond(1), crossMetrics.indicesSecond(2));
       metricsFirstFromSecond(j) = ...
           mFirst(crossMetrics.indicesSecond(1), crossMetrics.indicesSecond(2));
       metricsSecondFromFirst(j) = ...
           mSecond(crossMetrics.indicesFirst(1), crossMetrics.indicesFirst(2));
   end
   crossMetrics.metricsAll = metricsAll;
   crossMetrics.metricsFirst = metricsFirst;
   crossMetrics.metricsSecond = metricsSecond;
   crossMetrics.metricsFirstFromSecond = metricsFirstFromSecond;
   crossMetrics.metricsSecondFromFirst =metricsSecondFromFirst;
   [sFraction, sLength, sRate] = ...
       getEventProperties(eventsFirst{crossMetrics.indicesSecond(1), ...
                          crossMetrics.indicesSecond(2)}, timeFirst); 
   crossMetrics.propertiesFirstFromSecond =  [sFraction, sLength, sRate];

   [sFraction, sLength, sRate] = ...
       getEventProperties(eventsSecond{crossMetrics.indicesFirst(1), ...
                          crossMetrics.indicesFirst(2)}, timeSecond); 
   crossMetrics.propertiesSecondFromFirst =  [sFraction, sLength, sRate];
end