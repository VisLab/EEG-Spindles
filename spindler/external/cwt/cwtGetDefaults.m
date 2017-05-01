function defaults = cwtGetDefaults()
% Returns defaults for the continuous wavelent spindle detection
%
% Parameters:
%
%     defaults     a structure with the parameters for the default types
%                  in the form of a structure that has fields
%                     value: default value
%                     classes:   classes that the parameter belongs to
%                     attributes:  attributes of the parameter
%                     description: description of parameter
%

defaults = struct( ...
    'cwtAlgorithm', ...
    getRules('a7', ...
    {'char'}, {}, ... 
    'Either a7 or a8 indicating which version of the algorithm.'), ...
    'cwtSpindleFrequencies', ...
    getRules(11:16, ...
    {'numeric'}, {'row', 'positive'}, ... 
    'Frequencies in Hz allowed for spindles.') ...
    );
end

function s = getRules(value, classes, attributes, description)
% Construct the default structure
s = struct('value', [], 'classes', [], ...
    'attributes', [], 'description', []);
s.value = value;
s.classes = classes;
s.attributes = attributes;
s.description = description;
end