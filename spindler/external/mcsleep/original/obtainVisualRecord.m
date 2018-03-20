function [visualDetection] = obtainVisualRecord(visualScoring, fs, N)
%function [visualDetection] = obtainVisualRecord(visualScoring, fs, N)
%
% Outputs a binary vector where 1 denotes the presence of a spindle
% input is a text file containing the start point of the spindle
% and its duration
%
% Last EDIT: 4/22/2017
% Ankit Parekh
% Perm. Contact: ankit.parekh@nyu.edu

v = visualScoring.*fs;
visualDetection = zeros(N,1);
for i = 1:size(v,1)
    visualDetection(v(i,1):v(i,1)+v(i,2)) = 1;
end


end

