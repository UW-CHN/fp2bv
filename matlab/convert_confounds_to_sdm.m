function convert_confounds_to_sdm(saveName, fileName)
% CONVERT_CONFOUNDS_TO_SDM(saveName, fileName)
%
% Converts fMRIPrep's functional confound files to BrainVoyager's
% compatiable files.
%
% Accepted fMRIPrep file extension: .tsv
% Resulting BrainVoyager file extension: .sdm
%
%
% Arguments:
%   saveName            String, name to save the BrainVoyager file as.
%                       Example:
%                           '[...]_desc-confounds_timeseries.sdm'
%
%   fileName            String, name of the fMRIPrep file to be converted
%                       Example:
%                           '[...]_desc-confounds_timeseries.tsv'
%
%
% Dependencies:
%    neuroelf          https://neuroelf.net/
%
%
% See also CONVERT_ANAT_TO_sdm, CONVERT_SURF_TO_SRF, CONVERT_FUNC_TO_VTC,
%          CONVERT_FUNC_TO_MTC

% Written by Kelly Chang - February 11, 2022

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

%%% Format: Check 'saveName' data type.
if ~ischar(saveName)
    error('Invalid data type. Supplied ''saveName'' must be a character.');
end

%%% Exist: Check if 'fileName' exists.
if ~exist('fileName', 'var') || isempty(fileName)
    error('Cannot provide empty ''fileName''.');
end

%%% Format: Check 'fileName' data type.
if ~ischar(fileName)
    error('Invalid data type. Supplied ''fileName'' must be a character.');
end

%%% Exists: check if 'fileName' exists on disk.
if ~isfile(fileName)
    error('Unable to locate file ''%s''.', fileName);
end

%%% Format: Check for accepted BrainVoyager file formats.
[~,~,saveExt] = extract_fileparts(saveName);
if ~strcmp(saveExt, '.sdm')
    errMsg = sprintf([
        'Unrecognized ''saveName'' extension format (%s).\n', ...
        'Extension must be .sdm.'
        ], saveExt);
    error(errMsg, saveExt);
end

%%% Format: Check for accepted fMRIPrep file formats.
[~,~,fileExt] = extract_fileparts(fileName);
if ~strcmp(fileExt, '.tsv')
    errMsg = sprintf([
        'Unrecognized ''fileName'' extension (%s).\n', ...
        'Accepted extension: .tsv'
        ], fileExt);
    error(errMsg, fileExt);
end

%% Convert fMRIPrep Functional Confound Files to BrainVoyager

% read confound file and coerce data type
tsv = tdfread(fileName);
tsv = structfun(@coerce_to_double, tsv, 'UniformOutput', false);

flds = fieldnames(tsv);
sdmMatrix = struct2array(tsv);
[nt,np] = size(sdmMatrix);

sdm = xff('new:sdm'); % initialize sdm
sdm.NrOfPredictors = np;
sdm.NrOfDataPoints = nt;
sdm.IncludesConstant = false; % does not include constant
sdm.PredictorColors = ones(np,3) .* 211; % light gray
sdm.PredictorNames = flds';
sdm.SDMMatrix = sdmMatrix;
sdm.SaveAs(saveName); % save sdm file
sdm.ClearObject; clear sdm; % clear handle

%% Helper Functions

function [d] = coerce_to_double(x)
% Coerces input 'x' into doubles, operating row-wise for strings.

if ischar(x)
    d = cellfun(@str2double, num2cell(x,2));
else
    d = double(x);
end