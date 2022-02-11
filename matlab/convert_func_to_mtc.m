function convert_func_to_mtc(saveName, fileName)
% CONVERT_FUNC_TO_MTC(saveName, fileName)
%
% Converts fMRIPrep's surface functional files to BrainVoyager's
% compatiable files.
%
% Accepted fMRIPrep file extensions: .gii, .gii.gz
% Resulting BrainVoyager file extension: .mtc
%
%
% Arguments:
%   saveName            String, name to save the BrainVoyager file as.
%                       Example:
%                           '[...]_space-fsaverage_hemi-L_bold.mtc'
%
%   fileName            String, name of the fMRIPrep file to be converted
%                       Example:
%                           '[...]_space-fsaverage_hemi-L_bold.func.gii'
%
%
% Dependencies:
%    gifti             https://www.artefact.tk/software/matlab/gifti/
%    neuroelf          https://neuroelf.net/
%
%
% See also CONVERT_ANAT_TO_VMR, CONVERT_SURF_TO_SRF, CONVERT_FUNC_TO_VTC

% Written by Kelly Chang - February 10, 2022

%% Input Control

%%% Dependency: check if gifti is avaiable.
flag = which('gifti'); 
if isempty(flag)
    error('The ''gifti'' dependency was not found on path.'); 
end

%%% Dependency: check if neuroelf is available.
flag = which('neuroelf');
if isempty(flag)
    error('The ''neuroelf'' dependency was not found on path.');
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
if ~strcmp(saveExt, '.mtc')
    errMsg = sprintf([
        'Unrecognized ''saveName'' extension format (%s).\n', ...
        'Extension must be .mtc.'
        ], saveExt);
    error(errMsg, saveExt);
end

%%% Format: Check for accepted fMRIPrep file formats.
[~,~,fileExt] = extract_fileparts(fileName);
if ~strcmp(fileExt, {'.gii', '.gii.gz'})
    errMsg = sprintf([
        'Unrecognized ''fileName'' extension (%s).\n', ...
        'Accepted extensions: .gii, .gii.gz'
        ], fileExt);
    error(errMsg, fileExt);
end

%% Convert fMRIPrep Functional Surface Files to BrainVoyager

gii = gifti(fileName); % load gifti
mtcData = permute(gii.cdata, [2 1]); % permute data order

mtc = xff('new:mtc'); % initialize mtc

mtc.NrOfVertices = size(mtcData, 2);
mtc.NrOfTimePoints = size(mtcData, 1);

mtc.MTCData = mtcData; % assign time course data
mtc.SaveAs(saveName); % save mtc
mtc.ClearObject; clear mtc; % clear handle