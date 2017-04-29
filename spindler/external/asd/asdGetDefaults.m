function defaults = asdGetDefaults()
% Returns defaults for the amplitude spectral density (ASD) spindle detection
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
    'AsdBaseFrequencyRange', ...
    getRules([3, 40], ...
    {'numeric'}, {'row', 'positive'}, ... 
    'Frequency range in Hz for baseline computation.'), ...
    'AsdFWHMCutoff', ...
    getRules(2, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Cutoff of the ratio of spectral peak area to noise area (oscillation index)'), ...
    'AsdFWHMCutoffCombined', ...
    getRules(2, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Cutoff of mean oscillation index after overlapping windows combined'), ...
    'AsdImagePathPrefix', ...
    getRules(['.' filesep 'data'], ...
    {'char'}, {}, ... 
    'Path name for saving images of spectral windows'), ...
    'AsdPeakFrequencyRange', ...
    getRules([7, 13], ...
    {'numeric'}, {'row', 'positive'}, ... 
    'Frequency range in HZ allowed for the peaks.'), ...
    'AsdPeakWidthMax', ...
    getRules(2, ...
    {'numeric'}, {'positive'}, ... 
    'Peak width must be less than this factor times Hamming bandwidth.'), ...
    'AsdVisualize', ...
    getRules(false, ...
    {'logical'}, {}, ... 
    'If true, show figures of the candidate spindle windows.'), ...
    'AsdWindowOverlapCount', ...
    getRules(2, ...
    {'numeric'}, {'scalar', 'positive', 'integer'}, ... 
    ['Number of windows overlapping a subwindow that must have ' ...
     'oscillation index above threshold to be spindle.']), ...
    'AsdWindowSlide', ...
    getRules(0.25, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Window slide in seconds for computing spectrum.'), ...
    'AsdWindowSize', ...
    getRules(1, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Window size in seconds for computing spectrum.') ...
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