function [currentVersion, changeLog, markdown] = getSpindlerVersion()

    changeLog = getChangeLog();
    currentVersion = ['Spindler' changeLog(end).version]; 
    markdown = getMarkdown(changeLog);
end

function changeLog = getChangeLog()
 
   changeLog(4) = ...
     struct('version', '0', 'status', 'Unreleased', 'date', '', 'changes', '');

    changeLog(4).version = '1.0.4';
    changeLog(4).status = 'Released';
    changeLog(4).date = '09/04/2017';
    changeLog(4).changes = { ...
       'Fixed isempty misspelling on removeChannels'; ...
       'Added a runSpindleStats function'; ...
       'Fixed removing channelLabel field in saving params'; ...
       'Added function for plotting statistics'};

   changeLog(3) = ...
     struct('version', '0', 'status', 'Unreleased', 'date', '', 'changes', '');

    changeLog(3).version = '1.0.3';
    changeLog(3).status = 'Released';
    changeLog(3).date = '09/02/2017';
    changeLog(3).changes = { ...
       'Fixed resampling issue in spindlerExtractSpindles when ICA present'; ...
       'Added warningCodes to spindlerExtractSpindles'; ...
       'Added a generic spindlerAllChannels with example run functions'; ...
       'Improved documentation on various functions'};
   
    changeLog(2) = ...
   struct('version', '0', 'status', 'Unreleased', 'date', '', 'changes', '');
    changeLog(2).version = '1.0.2';
    changeLog(2).status = 'Released';
    changeLog(2).date = '08/25/2017';
    changeLog(2).changes = { ...
       'Renamed getChannelNumbers as getChannelNumbersFromLabels'};

    changeLog(1).version = '1.0.1';
    changeLog(1).status = 'Released';
    changeLog(1).date = '08/25/2017';
    changeLog(1).changes = { ...
       'Changed params and spindlerExtractSpindles to just handle a single channel'; ...
       'Added ''basic'' figureLevel value that only plots key curves'; ...
       'Added getSpindlerVersion function'; ...
       'Now treat invalid atomRange as an error in spindlerGetParameterCurves'};

end

function markdown = getMarkdown(changeLog)
   markdown = '';
   for k = length(changeLog):-1:1
       tString = sprintf('Version %s %s %s\n', changeLog(k).version, ...
           changeLog(k).status, changeLog(k).date);
       changes = changeLog(k).changes;
       for j = 1:length(changes)
           cString = sprintf('* %s\n', changes{j});
           tString = [tString cString]; %#ok<*AGROW>
       end
       markdown = [markdown tString sprintf('  \n')];
   end
end