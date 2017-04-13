function params = processParameters(functionName, actualArgs, reqArgs, params, defaults)
% Check the specified parameters for functionName against defaults
    if nargin < 1  %% display help if not enough arguments
        eval(['help ' functionName]);
        return;
    elseif actualArgs < reqArgs 
        error([functionName ':TooFewArguments'], ...
              'Had %d requires at least %d', actualArgs, reqArgs);
    elseif ~exist('params', 'var')
        params = struct();
    end

    [params, errors] = checkDefaults(params, struct(), defaults);
    if ~isempty(errors)
        error([functionName ':BadParameters'], ['|' sprintf('%s|', errors{:})]);
    end
end

function [structOut, errors] = checkDefaults(structIn, structOut, defaults)
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
    defaultNames = fieldnames(defaults);
    inNames = fieldnames(structIn);
    remainNames = setdiff(inNames, defaultNames);
    for k = 1:length(defaultNames)
        try
            nextValue = getStructureParameters(structIn, defaultNames{k}, ...
                defaults.(defaultNames{k}).value);
            validateattributes(nextValue, defaults.(defaultNames{k}).classes, ...
                defaults.(defaultNames{k}).attributes);
            structOut.(defaultNames{k}) = nextValue;
        catch mex
            errors{end+1} = [defaultNames{k} ' invalid: ' mex.message]; %#ok<AGROW>
        end
    end
    for k = 1:length(remainNames)
        structOut.(remainNames{k}) = structIn.(remainNames{k});
    end
end

function p = getStructureParameters(mystruct, myfield, value)
%% Sets p to mystruct.myfield if it exists, other assigns it to value
%
%  Parameters
%       mystruct    the structure to test
%       myfield     the field to test
%       value       value to use as the default
%       p           (output) mystruct.myfield if it exists, otherwise value
%
%
    if  ~exist('value', 'var') && ~isfield(mystruct, myfield)
        error('Either value of mystruct.myfield must exist');
    elseif exist('value', 'var') && ~isfield(mystruct, myfield)
        p = value;
    else
        p = mystruct.(myfield);
    end
end