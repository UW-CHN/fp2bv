% example_script.m

clear all; close all; clc;

%% Directories
 
%%% fmriprep-to-brainvoyager package
paths.fp2bv = 'path/to/fp2bv/directory';
addpath(genpath(fullfile(paths.fp2bv, 'matlab'))); 

%%% external dependencies
paths.freesurfer = '/path/to/freesurfer/directory';
paths.gifti = 'path/to/gifti/directory';
paths.neuroelf = 'path/to/neuroelf/directory';
load_dependencies(paths);

%%% local directories
paths.fmriprep = 'path/to/fmriprep/derivatives';

%% Convert fMRIPrep Files (Basic Commands)

% locates fmriprep files from the given path
subjectInfo = find_fmriprep_files(paths.fmriprep); 

% converts fmriprep files to brainvoyager files
convert_fp2bv(subjectInfo);

%% Convert fMRIPrep Files on a Subset of Subjects

% in case of large datasets, if is possible to subset subjects to process
subjectSubset = 'sub-01'; % one subject
% subjectSubset = {'sub-01', 'sub-02', 'sub-n'}; % multiple subjects

% locates fmriprep files of the subset of subjects
subjectInfo = find_fmriprep_files(paths.fmriprep, subjectSubset); 

% converts fmriprep files to brainvoyager files
convert_fp2bv(subjectInfo);

%% Convert fMRIPrep Files with Overwrite

% locates fmriprep files of the subset of subjects
subjectInfo = find_fmriprep_files(paths.fmriprep); 

% converts fmriprep files to brainvoyager files *WITH* overwrite of
% existing files
overwrite = true; % turn overwrite on
convert_fp2bv(subjectInfo, overwrite);
