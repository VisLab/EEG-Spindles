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
leftOvers = matchFiles;
matchedFiles = cell(size(baseFiles));
matchList = inf(length(baseFiles), length(matchFiles));
for k = 1:length(baseFiles)
    [~, theName, ~] = fileparts(baseFiles{k});
    for n = 1:length(matchFiles)
        [~, thisName, ~] = fileparts(matchFiles{n});
        matchPos = strfind(thisName, theName);
        if ~isempty(matchPos)
            matchList(k, n) = matchPos(1);
        end
    end
end

%% Match those with a base that has only one match
matchCount = 0;
while(matchCount < length(matchedFiles))
    possibleRow = sum(~isinf(matchList), 2);
    posRow = find(possibleRow == 1, 1, 'first');
    if ~isempty(posRow)
        match = find(~isinf(matchList(posRow, :)), 1, 'first');
        matchedFiles{posRow} = matchFiles{match(1)};
        leftOvers{match(1)} = '';
        matchList(posRow, :) = inf;
        matchList(:, match(1)) = inf;
        matchCount = matchCount + 1;
        continue;
    end
    possibleCol = sum(~isinf(matchList), 1);
    posCol = find(possibleCol == 1, 1, 'first');
    if ~isempty(posCol)
        match = find(~isinf(matchList(:, posCol)), 1, 'first');
        matchedFiles{match(1)} = matchFiles{posCol};
        leftOvers{posCol} = '';
        matchList(:, posCol) = inf;
        matchList(match(1), :) = inf;
        matchCount = matchCount + 1;
        continue;
    end
end

% for k = 1:length(baseFiles) 
%     posRow = find(~isinf(matchList(k, :)));
%     if isempty(posRow)
%         continue;
%     elseif length(posRow) == 1
%         matchedCount = matchedCount + 1;
%         matchedFiles{k} = matchFiles{posRow};
%         leftOvers{posRow} = '';
%         matchList(k, :) = inf;
%         matchList(:, posRow) = inf;
%     end
% end
% 
% %% Match the remaining where the match file only has one match
% for k = 1:length(matchFiles)
%     posRow = find(~isinf(matchList(:, k)));
%     if isempty(posRow)
%         continue;
%     elseif length(posRow) == 1
%         matchedCount = matchedCount + 1;
%         matchedFiles{posRow} = matchFiles{k};
%         leftOvers{k} = '';
%         matchList(posRow, :) = inf;
%         matchList(:, k) = inf;
%     end
% end

%% See if everything is matched
for k = 1:length(baseFiles)
    if ~isempty(matchedFiles{k})
        continue;
    elseif sum(~isinf(matchList(k, :))) == 0
        continue;
    end
    [~, posInd] = min(matchList(k, :));
    matchedCount = matchedCount + 1;
    matchFiles{k} = matchFiles{posInd};
    leftOvers{posInd} = '';
    matchList(k, :) = inf;
    matchList(:, posInd) = inf;
end

%% Fix the unused
unusedMask = cellfun(@isempty, leftOvers);
leftOvers(unusedMask) = [];
