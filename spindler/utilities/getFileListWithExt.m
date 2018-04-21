function fileList = getFileListWithExt(dirType, pathName, extType)
%% Get a list of file names for different file organizations 
%
%  Parameters:
%     dirType  string indicating type of organization:
%               ESSDERIVED, ESSLEVEL2, ESSLEVEL1, FILES, FILES2
%     pathName string giving root path relative to organization
%     extType  string indicating type of file ('.set') or empty of all
%     fileList  cell array with full path names of the files
%
% 
%% Find the right type

if strcmpi(dirType, 'ESSDERIVED')  
    obj = levelDerivedStudy('levelDerivedXmlFilePath', pathName);
    [filesUnsorted, ~, ~, sessionNumbers] =  getFilename(obj);
    %% Make sure that these are in sorted order
    sessions = zeros(length(sessionNumbers), 1);
    for k = 1:length(sessions)
        sessions(k) = str2double(sessionNumbers{k});
    end
    [~, sortedIndices] = sort(sessions); 
    fileList = filesUnsorted(sortedIndices);
elseif strcmpi(dirType, 'ESSLEVEL2')
    obj = level2Study('level2XmlFilePath', pathName);
    [filesUnsorted, ~, ~, sessionNumbers] =  getFilename(obj);
    %% Make sure that these are in sorted order
    sessions = zeros(length(sessionNumbers), 1);
    for k = 1:length(sessions)
        sessions(k) = str2double(sessionNumbers{k});
    end
    [~, sortedIndices] = sort(sessions);  
    fileList = filesUnsorted(sortedIndices);  
elseif strcmpi(dirType, 'ESSLEVEL1')
    obj = level1Study(pathName);
    [filesUnsorted, ~, ~, sessionNumbers] =  getFilename(obj);
    %% Make sure that these are in sorted order
    sessions = zeros(length(sessionNumbers), 1);
    for k = 1:length(sessions)
        sessions(k) = str2double(sessionNumbers{k});
    end
    [~, sortedIndices] = sort(sessions);   
    fileList = filesUnsorted(sortedIndices);    
elseif strcmpi(dirType, 'FILES')    
    thisList = dir(pathName);
    fileList= {thisList(:).name};
    fileTypes = [thisList(:).isdir];
    fileList = fileList(~fileTypes);
    for k = 1:length(fileList)
       fileList{k} = [pathName filesep fileList{k}];
    end
elseif strcmpi(dirType, 'FILES2')
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

%% Do we need to check the extension of the file?
if nargin < 3 || isempty(extType)
    return;
end

%% Filter out the files without the correct extension
goodFiles = true(length(fileList), 1);
for k = 1:length(goodFiles)
    [~, ~, myExt ] = fileparts(fileList{k});
    if ~strcmpi(myExt, extType)
        goodFiles(k) = false;
    end
end
    fileList = fileList(goodFiles);
