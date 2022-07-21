function convert_surf_to_srf(saveName, fileName, trf)
% CONVERT_SURF_TO_SRF(saveName, fileName [, trf])
%
% Converts fMRIPrep's surface anatomical files to BrainVoyager's 
% compatiable files.
%
% Accepted fMRIPrep file extensions: 
%   GIfTI: .gii, .gii.gz
%   FreeSurfer surface extentions: .midthick, .pial, .smoothwm
% Resulting BrainVoyager file extension: .srf
% 
%
% Arguments:
%   saveName            String, name to save the BrainVoyager file as.
%                       Example:
%                           '[...]_hemi-L_smoothwm.srf'
%
%   fileName            String, name of the fMRIPrep file to be converted
%                       Example:
%                           '[...]_hemi-L_smoothwm.surf.gii'
%
%   [trf]               A 4x4 transformation matrix that is applied to the
%                       surface, optional.
%
%
% Dependencies: 
%    GIfTI             https://www.artefact.tk/software/matlab/gifti/
%    FreeSurfer        https://surfer.nmr.mgh.harvard.edu/
%    NeuroElf          https://neuroelf.net/
%
%
% See also CONVERT_ANAT_TO_VMR, CONVERT_FUNC_TO_VTC, CONVERT_FUNC_TO_MTC, 
%          CONVERT_CONFOUNDS_TO_SDM

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
    error('The neuroelf dependency was not found on path.');
end

%%% Dependency: check if FreeSurfer's freesurfer_read_surf is available.
flag = which('freesurfer_read_surf'); 
if isempty(flag)
    error('The FreeSurfer ''freesurfer_read_surf'' dependency was not found on path.');
end

%%% Exist: Check is 'saveName' exists.
if ~exist('saveName', 'var') || isempty(saveName)
    error('Cannot provide empty ''saveName''.');
end

%%% Format: Check 'saveName' data type.
if ~ischar(saveName)
    error('Invalid data type. Supplied ''fileName'' must be a character.');
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

%%% Optional: assign default value for 'trf' matrix.
if ~exist('trf', 'var') || isempty(trf)
    trf = eye(4); % identity matrix
end

%%% Format: Check for accepted BrainVoyager file formats.
[~,~,saveExt] = extract_fileparts(saveName);
if ~strcmp(saveExt, '.srf')
    errMsg = sprintf([
        'Unrecognized ''saveName'' extension format (%s).\n', ...
        'Extension must be .srf.'
    ], saveExt);
    error(errMsg, saveExt);
end

%%% Format: Check for accepted FreeSurfer file formats.
[~,~,fileExt] = extract_fileparts(fileName);
if ~strcmp(fileExt, {'.gii', '.gii.gz', '.midthick', '.pial', '.smoothwm'})
    errMsg = sprintf([
        'Unrecognized ''fileName'' extension (%s).\n', ...
        'Accepted extensions: .gii, .gii.gz, .midthick, .pial, .smoothwm'
    ], fileExt);
    error(errMsg, fileExt);
end

%% Convert fMRIPrep Surface Anatomical Files to BrainVoyager

switch fileExt
    case {'.gii', '.gii.gz'} % GIfTI files
        gii = gifti(fileName);
        faces = gii.faces;
        vertices = gii.vertices;
    case {'.midthick', '.pial', '.smoothwm'}
        % FreeSurfer surface files
        filePath = format_escaped_path(fileName);
        [vertices,faces] = freesurfer_read_surf(filePath);
end

% coerce data to type
faces = double(faces);
vertices = double(vertices);

% save surface file, reduce mesh complexity until savable
prop = 1; 
savedStatus = false;
while ~savedStatus
    try
        if prop ~= 1 % if any reduction performed
            propStr = sprintf('res-reduce%2d', prop * 100);
            saveName = regexprep(saveName, '_(\w+)\.srf$', ...
                ['_', propStr, '_$1.srf']);
        end
        savedStatus = save_srf(faces, vertices, trf, saveName); 
    catch
        prop = 1 - 0.05; % reduction factor
        if prop < 0.25; break; end % minimum reduction limit = 25%
        [faces,vertices] = reducepatch(faces, vertices, prop);
    end
end


end

%% Helper Functions

function [status] = save_srf(faces, vertices, trf, saveName)
    status = false; % initalize save status

    srf = xff('new:srf'); % initialize srf file
    srf.ExtendedNeighbors = 1; % enable additional resampling methods

    % LPI to ASR transformation matrix
    lpi2asr = [0 0 -1; -1 0 0; 0 -1 0];

    srf.NrOfVertices = size(vertices, 1); % number of vertices
    srf.VertexCoordinate = (vertices - 128) * lpi2asr; % assign vertex coordinates

    srf.NrOfTriangles = size(faces, 1); % number of faces
    srf.TriangleVertex = faces; % assign triangle faces

    srf.Neighbors = srf.TrianglesToNeighbors(); % calculate neighbors
    srf = srf.RecalcNormals(); % calculate vertex normals

    % surface color options
    srf.VertexColor = zeros(size(vertices,1), 4);
    srf.ConvexRGBA = [0.322 0.733 0.98 1];
    srf.ConcaveRGBA = [0.322 0.733 0.98 1];

    % apply transformation matrix to surface
    srf = srf.Transform(trf); 

    srf.SaveAs(saveName); % save srf file
    srf.ClearObject; clear srf; % clear srf handle
    status = true; % if saved srf file
end

function decimate_surface(face, vertices, prop)
end