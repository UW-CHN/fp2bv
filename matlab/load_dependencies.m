function load_dependencies(paths)
% LOAD_DEPENDENCIES(paths)

% Written by Kelly Chang - February 15, 2022

%% Input Control

%%% Exist: Check is 'paths' exists.
if ~exist('paths', 'var') || isempty(paths)
    error('Cannot provide empty ''paths''.');
end

%%% Exists: check if 'paths' has all dependencies as fields.
flds = fieldnames(paths);
allDependencies = {'gifti', 'neuroelf', 'freesurfer'};
if ~all(ismember(allDependencies, flds))
    missingFlds = strjoin(setdiff(allDependencies, flds), ', ');
    error('Missing dependency field in ''path'' for: %s', missingFlds);
end

%% Check and Load gifti Dependency

giftiFlag = which('gifti'); % check gifti
if isempty(giftiFlag) && (isempty(paths.gifti) || ~isfolder(paths.gifti))
    error('Unable to locate gifti dependency from given path.');
else
    addpath(genpath(paths.gifti)); % add gifti to path
end

%% Check and Load neuroelf Dependency

neFlag = which('neuroelf'); % check neuroelf
if isempty(neFlag) && (isempty(paths.neuroelf) || ~isfolder(paths.neuroelf))
    error('Unable to locate neuroelf dependency from given path.');
else
    addpath(genpath(paths.gifti)); % add neuroelf to path
end

%% Check and Load FreeSurfer Dependency

fsMatFlag = which('freesurfer_read_surf'); % check freesurfer matlab
[fsBinFlag,~] = system('mri_convert --help'); % check freesurfer binaries
fsFlag = isempty(fsMatFlag) || (fsBinFlag > 0); % combined freesurfer check

fsMatPath = fullfile(paths.freesurfer, 'matlab'); % freesurfer matlab path
fsBinPath = fullfile(paths.freesurfer, 'bin'); % freesurfer binaries path

if fsFlag && (isempty(paths.freesurfer) || ~isfolder(paths.freesurfer))
    error('Unable to locate FreeSurfer dependency from given path.');
elseif isempty(fsMatFlag) && ~isfolder(fsMatPath)
    error('Unable to locate FreeSurfer''s ''matlab'' subdirectory from given FreeSurfer path.');
elseif (fsBinFlag > 0) && ~isfolder(fsBinPath)
    error('Unable to locate FreeSurfer''s ''bin'' subdirectory from given FreeSurfer path'); 
end

if isempty(fsMatFlag)
    addpath(genpath(fsMatPath)); % add freesurfer matlab scripts to path
end

if (fsBinFlag > 0)
    PATH = getenv('PATH'); % get system PATH
    fsBinPath = format_escaped_path(fsBinPath); % format binaries path
    setenv('PATH', sprintf('%s:%s', PATH, fsBinPath)); % set system PATH
end

%% Final Dependency Check

dependencyFlags = true(1, length(allDependencies) + 1);
dependencyFlags(1) = isempty(which('gifti')); 
dependencyFlags(2) = isempty(which('neuroelf')); 
dependencyFlags(3) = isempty(which('freesurfer_read_surf')); 
[flag,~] = system('mri_convert --help');
dependencyFlags(4) = flag > 0; 

if any(dependencyFlags)
    if dependencyFlags(4)
        dependencyFlags(3) = true; 
        dependencyFlags = dependencyFlags(1:3);
    end
    errorDependencies = strjoin(allDependencies(dependencyFlags), ', '); 
    error('Unable to load dependencies: %s', errorDependencies); 
end