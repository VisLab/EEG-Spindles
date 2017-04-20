function hitInfo = evaluateHits(trueEvents, labeledEvents)

%   Copyright (C) 2012  Vernon Lawhern, UTSA, vlawhern@cs.utsa.edu
%                       Kay Robbins, UTSA, krobbins@cs.utsa.edu
%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% must have at least 3 inputs
hitInfo = struct('tp', NaN, 'tn', NaN, 'fp', NaN, 'fn', NaN);
if nargin ~= 2
    help evaluateHitsAndMisses;
    return;
end

trueStarts = cellfun(@double, trueEvents(:, 2));
trueEnds = cellfun(@double, trueEvents(:, 3));
labeledStarts = cellfun(@double, labeledEvents(:, 2));
labeledEnds = cellfun(@double, labeledEvents(:, 3));

numberTrue = size(trueEvents, 1);
numberLabeled = size(labeledEvents, 1);

%% Match hits on true events
trueMarks = zeros(numberTrue, 1);
labeledPos = 1;
for k = 1:numberTrue
    while labeledPos <= numberLabeled && labeledEnds(labeledPos) < trueStarts(k)
        labeledPos = labeledPos + 1;
    end
    if labeledPos <= numberLabeled && labeledStarts(labeledPos) <= trueEnds(k)
        trueMarks(k) = labeledPos;
    end
end

%% Match hits on labeled events
labeledMarks = zeros(numberLabeled, 1);
truePos = 1;
for k = 1:numberLabeled
    while truePos <= numberTrue && trueEnds(truePos) < labeledStarts(k)
        truePos = truePos + 1;
    end
    if truePos <= numberTrue && trueStarts(truePos) <= labeledEnds(k)
        labeledMarks(k) = truePos;
    end
end

hitInfo.fp = sum(labeledMarks == 0);
hitInfo.tp = sum(trueMarks ~= 0);
hitInfo.fn = sum(trueMarks == 0);