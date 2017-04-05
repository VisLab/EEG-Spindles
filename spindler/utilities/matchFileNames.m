function [matchedFiles, leftOvers] = matchFileNames(baseFiles, matchFiles)
% Find the best matches of matchFiles names with file names in baseFiles
%
% Parameters
%    baseFiles     cell array of files to match substrings
%    matchFiles    cell array of files in which to look for matches
%    matchedFiles  (output) cell array of same size as baseFiles with matching
%                  file name in matchFiles (or empty of unmatched)
%    leftOvers     (output) files in matchFiles that were unmatched
%
%  Notes: Uses the first match as the best match if multiple matches
%
%  Written by:  Kay Robbins, UTSA 2017
%
%% Perform the matches
matchedFiles = cell(size(baseFiles));
for k = 1:length(baseFiles)
    [~, theName, ~] = fileparts(baseFiles{k});
    bestPos = inf;
    bestMatch = 0;
    for n = 1:length(matchFiles)
        [~, thisName, ~] = fileparts(matchFiles{n});
        matchPos = strfind(thisName, theName);
        if matchPos == 1
            matchedFiles{k} = matchFiles{n};
            matchFiles(n) = [];
            break;
        elseif matchPos < bestPos
            bestMatch = n;
            bestPos = matchPos;
        end
    end
    if matchPos ~= 1 && bestMatch > 0
        matchedFiles{k} = bestMatch;
        matchFiles(bestMatch) = [];
    end
end
leftOvers = matchFiles;
