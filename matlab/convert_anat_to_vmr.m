function convert_anat_to_vmr(saveName, fileName)
% CONVERT_ANAT_TO_VMR(saveName, fileName)
%
% Converts fMRIPrep's volumetric anatomical files to BrainVoyager's
% compatiable files.
%
% Accepted fMRIPrep file extensions: .mgz, .nii, .nii.gz
% Resulting BrainVoyager file extension: .vmr
%
%
% Arguments:
%   saveName            String, name to save the BrainVoyager file as.
%                       Example:
%                           '[...]_acq-mprage_desc-preproc_T1w.vmr'
%
%   fileName            String, name of the fMRIPrep file to be converted
%                       Example: 
%                           '[...]_acq-mprage_desc-preproc_T1w.nii.gz'
%
%
% Notes:
% - Converted BrainVoyager files will by default have the header indicate
%   the anatomical data have a Talairach (TAL) reference space even if this
%   is not true. This is a only header designation and can be changed in
%   BrainVoyager by editing the 'File > VMR Properties...'.
%
%
% Dependencies:
%    FreeSurfer        https://surfer.nmr.mgh.harvard.edu/
%    neuroelf          https://neuroelf.net/
%
%
% See also CONVERT_SURF_TO_SRF, CONVERT_FUNC_TO_VTC, CONVERT_FUNC_TO_MTC, 
%          CONVERT_CONFOUNDS_TO_SDM

% Written by Kelly Chang - February 10, 2022

%% Input Control

%%% Dependency: check if neuroelf is available.
flag = which('neuroelf');
if isempty(flag)
    error('The neuroelf dependency was not found on path.');
end

%%% Dependecy: check if FreeSurfer's mri_convert is available.
[status,~] = system('mri_convert --help');
if status > 0
    errMsg = sprintf([
        'The FreeSurfer ''mri_convert'' dependency was not found on path.\n\n', ...
        'Check if environment variable PATH contains the path to FreeSurfer binaries.'
        ]);
    error(errMsg);
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
if ~strcmp(saveExt, '.vmr')
    errMsg = sprintf([
        'Unrecognized ''saveName'' extension format (%s).\n', ...
        'Extension must be .vmr.'
    ], saveExt);
    error(errMsg, saveExt);
end

%%% Format: Check for accepted fMRIPrep file formats.
[~,name,fileExt] = extract_fileparts(fileName);
if ~strcmp(fileExt, {'.mgz', '.nii', '.nii.gz'})
    errMsg = sprintf([
        'Unrecognized ''fileName'' extension (%s).\n', ...
        'Accepted extensions: .mgz, .nii, .nii.gz'
    ], fileExt);
    error(errMsg, fileExt);
end

%% Convert fMRIPrep Volumetric Anatomical Files to BrainVoyager

% assign neuroelf
n = neuroelf;

switch fileExt
    case {'.mgz'}
        
        filePath = format_escaped_path(fileName);
        
        [savePath,~,~] = extract_fileparts(saveName);
        niiName = fullfile(savePath, [name, '.nii.gz']);
        niiPath = format_escaped_path(niiName);
        
        mriConvert = sprintf('mri_convert %s %s', filePath, niiPath);
        system(mriConvert); % convert .mgz to .nii.gz
        
        % recursive call to process .nii.gz file
        convert_anat_to_vmr(saveName, niiName);
        
        try % delete .nii.gz file when completed.
            delete(niiName);
        catch
        end
        
    case {'.nii', '.nii.gz'}
        
        anatSpace = extract_bids(fileName, 'space');
        
        referenceSpace = 0; % UNKNOWN
        if isempty(anatSpace) || strcmp(anatSpace, 'T1w') 
            referenceSpace = 1; % NATIVE
        elseif contains(anatSpace, 'MNI')
            referenceSpace = 4; % MNI
        end
        
        vmr = n.importvmrfromanalyze(fileName);
        vmr.ReferenceSpace = referenceSpace;
        vmr.SaveAs(saveName); % save vmr file
        vmr.ClearObject; clear vmr; % clear handle
end