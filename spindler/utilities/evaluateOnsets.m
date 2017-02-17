function onsetInfo = evaluateOnsets(trueEvents, labeledEvents, tolerance)

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
onsetInfo = struct('tp', NaN, 'tn', NaN, 'fp', NaN, 'fn', NaN);
if nargin ~= 3
    help evaluateOnsets;
    return;
end

trueStarts = cellfun(@double, trueEvents(:, 2));
labeledStarts = cellfun(@double, labeledEvents(:, 2));

tp = 0;
fp = 0;
fn = 0;
for k = 1:length(labeledStarts)
   distTrue = abs(trueStarts - labeledStarts(k)) < 3*tolerance;
   if sum(distTrue) > 0
       tp = tp + 1;
   else
       fp = fp + 1;
   end
end

for k = 1:length(trueStarts)
   distTrue = abs(labeledStarts - trueStarts(k)) < 3*tolerance;
   if sum(distTrue) == 0
       fn = fn + 1;
   end
end

onsetInfo.fp = fp;
onsetInfo.tp = tp;
onsetInfo.fn = fn;
