function [structOut, errors] = checkSpindleDefaults(structIn, structOut, defaults)
% Check structIn input parameters against defaults and update structOut
%
% Parameters:
%    structIn     a structure whose field names are parameter names and
%                    values are parameter values
%    structOut    a structure whose field names are parameter names and
%                    values are parameter values
%    defaults     a structure whose field names are parameter names and
%                    values are structures in the following form:
%                      value: default value
%                      classes:   classes that parameter belongs to
%                      attributes:  attributes of the parameter
%                      description: description of parameter
%  Output:
%    structOut     updated parameter structure
%    errors        cell array of error messages
%
%  Written by:  Kay Robbins, UTSA 2015-2017
%
errors = cell(0);
fNames = fieldnames(defaults);
for k = 1:length(fNames)
    try
       nextValue = getSpindleStructureParameters(structIn, fNames{k}, ...
                                          defaults.(fNames{k}).value);
       validateattributes(nextValue, defaults.(fNames{k}).classes, ...
                         defaults.(fNames{k}).attributes);
       structOut.(fNames{k}) = nextValue;
    catch mex
        errors{end+1} = [fNames{k} ' invalid: ' mex.message]; %#ok<AGROW>
    end
end