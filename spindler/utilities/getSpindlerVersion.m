function [currentVersion, changeLog, markdown] = getSpindlerVersion()

    changeLog = getChangeLog();
    currentVersion = ['Spindler' changeLog(end).version]; 
    markdown = getMarkdown(changeLog);
end

function changeLog = getChangeLog()

    changeLog(2) = ...
     struct('version', '0', 'status', 'Unreleased', 'date', '', 'changes', '');

    changeLog(2).version = '2.0.1';
    changeLog(2).status = 'Released';
    changeLog(2).date = '03/14/2019';
    changeLog(2).changes = { ...
       'Changed return value order on spindler call';
       'Changed the name spindlerCurves to parameterCurves in additionalInfo'};
    changeLog(1).version = '2.0.0';
    changeLog(1).status = 'Released';
    changeLog(1).date = '07/08/2018';
    changeLog(1).changes = { ...
       'Reorganized toolbox and generalized parameter curves'};
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