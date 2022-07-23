function [subjectInfo] = find_fmriprep_files(fmriPrepPath, subjectSubset, saveLabel)
% [subjectInfo] = FIND_FMRIPREP_FILES(fmriprepPath [, subjectSubset])
%
% Locates fMRIPrep files to be converted from the given fMRIPrep
% derivatives directory.
%
%
% Arguments:
%   fmriPrepPath        String, path to fMRIPrep output directory.
% 
%   [subjectSubset]     Cell or string, list of subject labels to locate
%                       (default: all subjects in fmriPrepPath will be 
%                       processed). Optional.
%
%   [saveLabel]         String, additional label added to the output 
%                       directory name (e.g., 'brainvoyager[-<label>]')
%                       (default: no label). Optional.
%
%
% See also CONVERT_FP2BV

% Written by Kelly Chang - February 15, 2022

%% Input Control

%%% Exist: Check is 'fmriPrepPath' exists. 
if ~exist('fmriPrepPath', 'var') || isempty(fmriPrepPath)
    error('Cannot provide empty ''fmriPrepPath''.');
end

%%% Format: Check 'fmriPrepPath' data type.
if ~ischar(fmriPrepPath)
    error('Invalid data type. Supplied ''fmriPrepPath'' must be a character.');
end

%%% Exists: Check if 'fmriPrepPath' exists on disk.
if ~isfolder(fmriPrepPath)
    error('Unable to locate directory ''%s''.', fmriPrepPath);
end

%%% Exists: Check if 'subjectSubset' exists.
if ~exist('subjectSubset', 'var') || isempty(subjectSubset)
    subjectSubset = {}; 
end

%%% Format: Check 'subjectSubset' data type.
if ~iscell(subjectSubset) && ~ischar(subjectSubset)
    error('Invalid data type. Supplied ''subjectSubset'' must be a cell or character.');
end

%%% Format: Convert 'subjectSubset' data type.
if ischar(subjectSubset)
    subjectSubset = {subjectSubset}; 
end

%%% Exists: Check if 'saveLabel' exists.
if ~exist('saveLabel', 'var') || isempty(saveLabel)
    saveLabel = '';
end

%%% Format: Check 'saveLabel' data type
if ~ischar(saveLabel)
    error('Invalid data type. Supplied ''saveLabel'' must be a character.'); 
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
filePat.surf2anat = ['anat\', filesep, '[\w-]+_from-fsnative_to-T1w_mode-image_xfm\.txt'];

%% Locate fMRIPrep Files by Subject

subjectList = dir(fullfile(fmriPrepPath, 'sub-*'));
subjectList = subjectList([subjectList.isdir]);
subjectList = {subjectList.name}; % extract subject labels

if ~isempty(subjectSubset) % extract subject subset (optional)
    subjectIndx = ismember(subjectList, subjectSubset); 
    subjectList = subjectList(subjectIndx); 
end

subjectList = fullfile(fmriPrepPath, subjectList);

for i = 1:length(subjectList) % for each subject
    [~,subjectName] = extract_fileparts(subjectList{i});
    
    fileList = dir(fullfile(subjectList{i}, '**', '*.*'));
    fileList = fileList(~[fileList.isdir]); % exclude directories
    fileList = fullfile({fileList.folder}, {fileList.name});
    
    clear s; s.subject = subjectName; % temporary structure
    p = structfun(@(x) fileList(contains_regexp(fileList,x)), ...
        filePat, 'UniformOutput', false); 
    if ~isempty(p.surf2anat); p.surf2anat = char(p.surf2anat); end
    subjectInfo(i) = structassign(s, p);
end

%% Create BrainVoyager Derivatives Directories and File Names

[basePath,~,~] = extract_fileparts(fmriPrepPath);
bvDirName = 'brainvoyager'; % initialize brainvoyager output directory name
if ~isempty(saveLabel); bvDirName = sprintf('%s-%s', bvDirName, saveLabel); end
bvPath = fullfile(basePath, bvDirName); % brainvoyager output directory
mkfolder(bvPath); % create brainvoyager directory

for i = 1:length(subjectInfo) % for each subject
    p = subjectInfo(i); % current subject
    
    out = struct(); % initialize 
    
    % subject brainvoyager directory
    out.subject = fullfile(bvPath, p.subject);
    
    if ~isempty(p.anat) || ~isempty(p.surf)
        anatDir = fullfile(out.subject, 'anat');
        mkfolder(anatDir); % create anatomical directory
        
        % brainvoyager volumetric anatomical file names
        bvAnat = convert_filenames(p.anat, 'anat');
        out.anat = fullfile(anatDir, bvAnat); 
        
        % brainvoyager surface file names
        bvSurf = convert_filenames(p.surf, 'surf');
        out.surf = fullfile(anatDir, bvSurf);
    end
    
    if ~isempty(p.vtc) || ~isempty(p.mtc)
        % brainvoyager volumetric functional file names
        vtcSession = cellfun(@(x) extract_bids(x,'ses',true), p.vtc, ...
            'UniformOutput', false);
        bvVtc = convert_filenames(p.vtc, 'vtc'); 
        out.vtc = cellfun(@(x,y) fullfile(out.subject,x,y), ...
            vtcSession, bvVtc, 'UniformOutput', false);
        
        % brainvoyager surface functional file names
        mtcSession = cellfun(@(x) extract_bids(x,'ses',true), p.mtc, ...
            'UniformOutput', false);
        bvMtc = convert_filenames(p.mtc, 'mtc'); 
        out.mtc = cellfun(@(x,y) fullfile(out.subject,x,y), ...
            mtcSession, bvMtc, 'UniformOutput', false);
        
        % brainvoyager functional confounds file names
        confoundSession = cellfun(@(x) extract_bids(x,'ses',true), ...
            p.confounds, 'UniformOutput', false);
        bvConfounds = convert_filenames(p.confounds, 'confounds'); 
        out.confounds = cellfun(@(x,y) fullfile(out.subject,x,y), ...
            confoundSession, bvConfounds, 'UniformOutput', false); 
        
        funcFile = cat(2, out.vtc, out.mtc, out.confounds);
        funcDir = cellfun(@extract_fileparts, funcFile, 'UniformOutput', false);
        cellfun(@mkfolder, unique(funcDir)); % create functional directories
    end
    
    subjectInfo(i).save = out;
end

%% Helper Functions

function [tf] = contains_regexp(str, pat)
    patternMatch = regexp(str, pat, 'once');
    tf = ~cellfun(@isempty, patternMatch);
end

function [targetStruct] = structassign(targetStruct, inputStruct)
    flds = fieldnames(inputStruct);
    for f = 1:length(flds) % for each field
        targetStruct.(flds{f}) = inputStruct.(flds{f});
    end
end

function mkfolder(filepath)
    if ~isfolder(filepath)
        mkdir(filepath);
    end
end

function [saveNames] = convert_filenames(fileNames, modality) 
    if ischar(fileNames); fileNames = {fileNames}; end
    
    [~,baseNames,~] = cellfun(@extract_fileparts, fileNames, ...
        'UniformOutput', false);
    
    cstrcat = @(fn,ext) cellfun(@(x) [x,ext], fn, 'UniformOutput', false); 
    
    switch lower(modality)
        case 'anat'
            saveNames = cstrcat(baseNames, '.vmr');
        case 'surf'
            saveNames = regexprep(baseNames, '\.surf', '.srf'); 
        case 'vtc'
            saveNames = cstrcat(baseNames, '.vtc'); 
        case 'mtc'
            saveNames = regexprep(baseNames, '\.func', '.mtc');
        case 'confounds'
            saveNames = cstrcat(baseNames, '.sdm'); 
    end
end

end