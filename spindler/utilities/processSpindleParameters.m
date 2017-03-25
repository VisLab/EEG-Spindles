function params = processSpindleParameters(functionName, actualArgs, reqArgs, params)
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

    defaults = getSpindleDefaults();
    [params, errors] = checkSpindleDefaults(params, struct(), defaults);
    if ~isempty(errors)
        error([functionName ':BadParameters'], ['|' sprintf('%s|', errors{:})]);
    end
end