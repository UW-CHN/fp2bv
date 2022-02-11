function convert_func_to_vtc(saveName, fileName)
% CONVERT_FUNC_TO_VTC(saveName, fileName)
%
% Converts fMRIPrep's volumetric functional files to BrainVoyager's
% compatiable files.
%
% Accepted fMRIPrep file extensions: .nii, .nii.gz
% Resulting BrainVoyager file extension: .vtc
%
%
% Arguments:
%   saveName            String, name to save the BrainVoyager file as.
%                       Example:
%                           '[...]_space-T1w_desc-preproc_bold.nii.vtc'
%
%   fileName            String, name of the fMRIPrep file to be converted
%                       Example:
%                           '[...]_space-T1w_desc-preproc_bold.nii.gz'
%
%
% Dependencies:
%    neuroelf          https://neuroelf.net/
%
%
% See also CONVERT_ANAT_TO_VMR, CONVERT_SURF_TO_SRF, CONVERT_FUNC_TO_MTC

% Written by Kelly Chang - February 10, 2022

%% Input Control

%%% Dependency: check if neuroelf is available.
flag = which('neuroelf');
if isempty(flag)
    error('The neuroelf dependency was not found on path.');
end

%%% Exist: Check is 'saveName' exists.
if ~exist('saveName', 'var') || isempty(saveName)
    error('Cannot provide empty ''saveName''.');
end

%%% Exist: Check if 'fileName' exists.
if ~exist('fileName', 'var') || isempty(fileName)
    error('Cannot provide empty ''fileName''.');
end

%%% Exists: check if 'fileName' exists on disk.
if ~isfile(fileName)
    error('Unable to locate file ''%s''.', fileName);
end

%%% Format: Check for accepted BrainVoyager file formats.
[~,~,saveExt] = extract_fileparts(saveName);
if ~strcmp(saveExt, '.vtc')
    errMsg = sprintf([
        'Unrecognized ''saveName'' extension format (%s).\n', ...
        'Extension must be .vtc.'
        ], saveExt);
    error(errMsg, saveExt);
end

%%% Format: Check for accepted fMRIPrep file formats.
[~,~,fileExt] = extract_fileparts(fileName);
if ~strcmp(fileExt, {'.nii', '.nii.gz'})
    errMsg = sprintf([
        'Unrecognized ''fileName'' extension (%s).\n', ...
        'Accepted extensions: .nii, .nii.gz'
        ], fileExt);
    error(errMsg, fileExt);
end

%% Convert fMRIPrep Volumetric Functional Files to BrainVoyager

% assign neuroelf
n = neuroelf;

funcSpace = extract_bids(fileName, 'space');

referenceSpace = 0; % UNKNOWN
if strcmp(funcSpace, 'T1w')
    referenceSpace = 1; % NATIVE
elseif contains(funcSpace, 'MNI')
    referenceSpace = 4; % MNI
end

header = niftiinfo(fileName);
voxelRes = max(header.PixelDimensions(2:4));

vtc = n.importvtcfromanalyze({ fileName }, [], voxelRes);
vtc.ReferenceSpace = referenceSpace; % assign reference space
vtc.SaveAs(saveName); % save vtc file
vtc.ClearObject; clear vtc; % clear object handle