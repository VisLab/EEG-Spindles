function h = showEventPlots(EEG, channelNumbers, spindles, events, ...
                            theTitle, expertEvents, otherEvents)

% Last updated: January 2017, J. LaRocco, K. Robbins

% Details: runPlotEvents generates a figure showing EEG superimposed upon
% the results from different parameters.
% Usage:
% [events, output] = STAMP(EEG, channelList, numberAtoms, ...
%                                 freqBounds, atomScales, expertEvents)
% [events, output] = STAMP(EEG, channelList, numberAtoms, freqBounds, atomScales)
%
%  EEG:            Input EEG structure (EEGLAB format)
%  channelNumbers: Vector of channel numbers to analyze
%  spindles:       Struct containing MP info, and if relevant, performance.
%  events:         Cell array of STAMP event outputs, detailing start and end times in seconds.
%  theTitle:       String containing the title of the document
%  expertEvents:   Struct with expert-rated times and durations for spindles (scalar or vector of positive integers).
%
% Output:
%  h:              Output figure with selected channel plotted with outputs
%                  above it. Expert events will be in red. Main output will
%                  be in yellow. The remainder will be in shades of green.
%
%--------------------------------------------------------------------------


yCoord=1;


EEGOrigData = EEG.data(channelNumbers, :);
EEGOrigTimes = (0:size(EEGOrigData, 2) - 1)/EEG.srate;
theScale = max(max(abs(EEGOrigData)));
eventScale = theScale/max(yCoord);

h=figure;
hold on;

plot(EEGOrigTimes, EEGOrigData, 'k');


yMPCoord = 2;
yMPCoords = repmat(yMPCoord, size(expertEvents));
line(expertEvents, yMPCoords.*eventScale, 'LineWidth', 3, 'Color', [0, 0, 1]);


if nargin>=6
    
    if isempty(expertEvents)==0
        eventTimes = cellfun(@double, expertEvents(:, 2:3))';
        %numberEvents = size(eventTimes, 1);
        yCoords = repmat(yCoord, size(eventTimes));
        line(eventTimes, yCoords.*eventScale, 'LineWidth', 3, 'Color', [1, 0, 0]);
    end
    
    
    if isempty(otherEvents)==0
        [~,eventCats]=size(otherEvents);
        for k=1:eventCats;
           events=otherEvents{k};
           yCoord1=-1.2+(-.5*k);
           eventTimes1 = cellfun(@double, events(:, 2:3))';
           yCoords1 = repmat(yCoord1, size(eventTimes1));
        line(eventTimes1, yCoords1.*eventScale, 'LineWidth', 3, 'Color', [k/length(otherEvents), 0, 1]); 
        end
        
        
    end
    

end


params=1:1:size(spindles,2);

for j=1:size(spindles,2)
    
    id=size(spindles,2)-j+1;
    eve1=spindles(1,params(id));
    eve=eve1.events;
    yMPCoord = 2+(.1*j);
    expertEvents = cellfun(@double, eve(:, 2:3))';
    yMPCoords = repmat(yMPCoord, size(expertEvents));
    line(expertEvents, yMPCoords.*eventScale, 'LineWidth', 3, 'Color', [0, j/length(params), 0]);
    
end
hold off
box on
xlabel('Seconds')
ylabel('uV')
title(theTitle)

end
