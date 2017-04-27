function [events1, events2, frameSplitFirst, frameSplitLast] = splitEvents(events, totalFrames, srate, params)
%% Split the events in two pieces
     
params = processParameters('showSpindlerMetric', nargin, 1, params, getGeneralDefaults());
events1 = [];
events2 = [];
splitFraction = params.supervisedSplitFraction;
% gapFrames = round(params.supervisedEventGap/srate);
% removeMethod = params.supervisedEventRemovalMethod;
frameMask = getFrameMask();
[frameSplitFirst, frameSplitLast, eFirst, eLast] = getSplit();
if isempty(eFirst) || isempty(eLast)
    warning('splitEvent:NoSplit', 'Could not find a valid of events');
    return;
end
events1 = events(1:frameMask(eFirst), :);
events2 = events(frameMask(eLast):end, :);
% if splitTime <= 0
%     error('splitEvents:NoFrames', 'Could not split total frames by indicated fraction');
% end



% if  ~strcmpi(removeMethod, 'remove')
%     events1 = [];
%     events2 = [];
%     frameSplitPoint = [];
%     return;
% end




    function mask = getFrameMask()
    %% Create a frame mask with the event number in the position.
       mask = zeros(totalFrames, 1);
       frames = round(events*srate) + 1;
       for k = 1:length(events)
           for j = frames(k, 1):frames(k, 2)
               mask(j) = k;
           end
       end
    end

    function [frameSplitFirst, frameSplitLast, eFirst, eLast] = getSplit()
        splitFrame = floor(splitFraction*totalFrames);
        if frameMask(splitFrame) == 0
            frameSplitFirst = splitFrame;
            frameSplitLast = splitFrame + 1;
            eFirst = find(frameMask(1:splitFrame) > 0, 1, 'last');
            eLast = find(frameMask(splitFrame + 1:end) > 0, 1, 'first') + splitFrame;
            return;
        end
        frameSplitFirst = [];
        frameSplitLast = [];
        eFirst = [];
        eLast = [];
%         splitEvent = frameMask(splitFrame);
%             eventNumber = splitEvent - 1;
%             if isempty(previousEventFrame)
%                 error('splitEvents:NoEvents', 'No events in the leading part');
%             end
%             frameSplitPoint = find(frameMask(1:splitFrame) == 0, 1, 'last');
%             
%             previousEventFrame = find(frameMask(1:splitFrame) > 0, 1, 'last');
%             if isempty(previousEventFrame)
%                 error('splitEvents:NoEvents', 'No events in the leading part');
%             end
%             eventNumber = frameMask(previousEventFrame);
    end
end

 