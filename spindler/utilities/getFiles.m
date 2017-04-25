function fileList = getFiles(type, pathName, ext)
%% Returns a list of EEG set file names for different file organizations


if strcmpi(type, 'FILES')    
    thisList = dir(pathName);
    fileList= {thisList(:).name};
    fileTypes = [thisList(:).isdir];
    fileList = fileList(~fileTypes);
    goodFiles = true(length(fileList), 1);
    for k = 1:length(goodFiles)
        [~, ~, myExt ] = fileparts(fileList{k});
        if ~strcmpi(myExt, ext)
            goodFiles(k) = false;
        end
        fileList{k} = [pathName filesep fileList{k}];
    end
    fileList = fileList(goodFiles);
    fileList = fileList(:);
elseif strcmpi(type, 'FILES2')
    inList = dir(pathName);
    dirNames = {inList(:).name};
    dirTypes = [inList(:).isdir];
    dirNames = dirNames(dirTypes);
    dirNames(strcmpi(dirNames, '.')| strcmpi(dirNames, '..')) = [];
    
    %% Step through the individual subdirectories
    totalFiles = 0;
    tempFiles = cell(length(dirNames), 1);
    for k = 1:length(dirNames)
        thisDir = [pathName filesep dirNames{k}];
        thisList = dir(thisDir);
        fileList = {thisList(:).name};
        theseTypes = [thisList(:).isdir];
        fileList = fileList(~theseTypes);
        goodFiles = true(length(fileList), 1);
        for j = 1:length(fileList)
            [~, ~, myExt ] = fileparts(fileList{j});
            if ~strcmpi(myExt, ext)
                goodFiles(j) = false;
            end
            fileList{j} = [thisDir filesep fileList{j}];
        end
        fileList = fileList(goodFiles);
        totalFiles = totalFiles + length(fileList);
        tempFiles{k} = fileList;
    end
    fileListFinal = cell(totalFiles, 1);
    thisStart = 1;
    for k = 1:length(dirNames)
        thisEnd = thisStart + length(tempFiles{k}) - 1;
        fileListFinal(thisStart:thisEnd) = tempFiles{k};
        thisStart = thisEnd + 1;
    end
    fileList = fileListFinal;
end