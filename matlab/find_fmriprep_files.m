function [subjectFiles] = find_fmriprep_files(fmriPrepPath)
%% [subjectFiles] = FIND_FMRIPREP_FILES(fmriprepPath)

% Written by Kelly Chang - February 15, 2022

%% Input Control

%%% Exist: Check is 'fmriPrepPath' exists. 
if ~exist('fmriPrepPath', 'var') || isempty(fmriPrepPath)
    error('Cannot provide empty ''fmriPrepPath''.');
end

%%% Exists: check if 'fmriPrepPath' exists on disk.
if ~isfolder(fmriPrepPath)
    error('Unable to locate directort ''%s''.', fmriPrepPath);
end

%% File Type Patterns

% valid fMRIPrep surfaces file types
surfTypes = {'midthickness', 'pial', 'smoothwm'}; 

% file types and corresponding matching regular expression patterns.
filePat.anat = ['anat\', filesep, '[\w-]+_desc-preproc_T1w\.nii\.gz'];
filePat.surf = ['anat\', filesep, '[\w-]+_(', strjoin(surfTypes,'|'), ')\.surf\.gii'];
filePat.vtc = ['func\', filesep, '[\w-]+_desc-preproc_bold\.nii\.gz'];
filePat.mtc = ['func\', filesep, '[\w-]+_bold\.func\.gii'];
filePat.confounds = ['func\', filesep, '[\w-]+_desc-confounds_timeseries\.tsv'];

%% Locate fMRIPrep Files by Subject

subjectList = dir(fullfile(fmriPrepPath, 'sub-*'));
subjectList = subjectList([subjectList.isdir]);
subjectList = fullfile({subjectList.folder}, {subjectList.name});

for i = 1:length(subjectList) % for each subject
    [~,subjectName] = extract_fileparts(subjectList);
    
    fileList = dir(fullfile(subjectList{i}, '**', '*.*'));
    fileList = fileList(~[fileList.isdir]); % exclude directories
    fileList = fullfile({fileList.folder}, {fileList.name});
    
    subjectFiles(i).subject = subjectName;
    p = structfun(@(x) fileList(regexp_contains(fileList,x)), ...
        filePat, 'UniformOutput', false);
    subjectFiles(i) = structassign(subjectFiles(i), p);
end

%% Helper Functions

function [tf] = regexp_contains(str, pat)
    patternMatch = regexp(str, pat, 'once');
    tf = ~cellfun(@isempty, patternMatch);
end


function [targetStruct] = structassign(targetStruct, inputStruct)
    flds = fieldnames(inputStruct);
    for f = 1:length(flds) % for each field
        targetStruct.(flds{f}) = inputStruct.(flds{f});
    end
end