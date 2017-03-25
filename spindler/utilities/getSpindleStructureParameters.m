function p = getSpindleStructureParameters(mystruct, myfield, value)
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
