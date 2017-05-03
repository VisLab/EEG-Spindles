dreamsAlgs = {'Spindler', 'Asd', 'Cwt_a7', 'Cwt_a8', 'Sem'};
drivingAlgs = {'Spindler', 'Asd', 'Cwt_a7', 'Cwt_a8'};
drivingAlgsSupervised = {'Spindler', 'Sdar'};
drivingDirBase = {'D:\TestData\Alpha\spindleData\bcit\results'; ...
                  'D:\TestData\Alpha\spindleData\nctu\results'};
dreamsDirBase = {'D:\TestData\Alpha\spindleData\dreams\results'};

drivingEvents = getSummaryEventLists(drivingDirBase, drivingAlgs);
dreamsEvents = getSummaryEventLists(dreamsDirBase, dreamsAlgs);

%%
dlabels = {'D1-ICA', 'D1', 'D2', 'N-S1', 'N-S32', 'N-S36', 'N-S39', 'N-S42', 'N-S47', 'N-S4'};
allDrivingLengths = cell(length(drivingAlgs), 1);
allDrivingStarts = cell(length(drivingAlgs), 1);
allDrivingLabels = cell(length(drivingAlgs), 1);
for k = 1:length(drivingAlgs)
    markLabel = 1;
    eventLabels = [];
    eventLengths = [];
    for m = 1:size(drivingEvents, 2);
        mEvents = drivingEvents{k, m};
        for j = 1:length(mEvents)
            theseLengths = mEvents(j).events(:, 2) - mEvents(j).events(:, 1);
            theseLabels = repmat(markLabel, size(theseLengths));
            eventLabels = [eventLabels; theseLabels]; %#ok<*AGROW>
            eventLengths = [eventLengths; theseLengths];
            markLabel = markLabel + 1;        
        end
    end
    allDrivingLengths{k} = eventLengths;
    allDrivingLabels{k} = eventLabels;
end

%%
for k = 1:length(drivingAlgs)
    theTitle = [drivingAlgs{k} ': event lengths']; 
    eventLengths = allDrivingLengths{k};
    eventLabels = allDrivingLabels{k};
    figure('Name', theTitle')
    boxplot(eventLengths, eventLabels, 'labels', dlabels, 'DataLim', [0, 6]);
    xlabel('Dataset')
    ylabel('Spindle length (s)');
    title(theTitle, 'Interpreter', 'None');
end  
%%
dlabels = {'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8'};
algIndex = 2;
allDreamsLengths = cell(length(dreamsAlgs), 1);
allDreamsStarts = cell(length(dreamsAlgs), 1);
allDreamsLabels = cell(length(dreamsAlgs), 1);
for k = 1:length(dreamsAlgs)
    markLabel = 1;
    eventLabels = [];
    eventLengths = [];
    for m = 1:size(dreamsEvents, 2);
        mEvents = squeeze(dreamsEvents{k, m});
        for j = 1:length(mEvents) - 2
            if ~isempty(mEvents(j).events)
                theseLengths = mEvents(j).events(:, 2) - mEvents(j).events(:, 1);
                theseLabels = repmat(markLabel, size(theseLengths));
                eventLabels = [eventLabels; theseLabels]; %#ok<*AGROW>
                eventLengths = [eventLengths; theseLengths];
            end
            markLabel = markLabel + 1;        
        end
    end
    allDreamsLengths{k} = eventLengths;
    allDreamsLabels{k} = eventLabels;
end

%%
for k = 1:length(dreamsAlgs)
    theTitle = [dreamsAlgs{k} ': event lengths']; 
    eventLengths = allDreamsLengths{k};
    eventLabels = allDreamsLabels{k};
    uniqueLabels = unique(eventLabels);
    figure('Name', theTitle')
    boxplot(eventLengths, eventLabels, 'labels', dlabels(uniqueLabels(:)'), 'DataLim', [0, 6]);
    xlabel('Dataset')
    ylabel('Spindle length (s)');
    title(theTitle, 'Interpreter', 'None');
end  