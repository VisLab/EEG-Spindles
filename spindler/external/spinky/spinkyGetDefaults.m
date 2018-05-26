function defaults = spinkyGetDefaults()
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
    'spinkyDefaultThreshold', ...
     getRules(265.7, ...
     {'numeric'}, {'positive'}, ... 
    'Spinky default threshold.'), ...
    'spinkyShowROC', ...
    getRules(true, ...
    {'logical'}, {}, ... 
    'If true show the ROC plot for the training data.') ...
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