function [trf] = read_xfm(fileName)
% [trf] = READ_XFM(fileName)
%
% Reads fMRIPrep's XFM text files and return the 4x4 transformation matrix 
% stored in the given file.
%
%
% Argument:
%   fileName            String, name of the XFM text file.
%                       Example:
%                           '[...]from-[...]_to-[...]_xfm.txt'
%
% 
% Output:
%   trf                 The 4x4 transformation matrix stored in the XFM 
%                       text file.

% Written by Kelly Chang - March 16, 2022

%% Input Control

%%% Exist: Check is 'fileName' exists.
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

%% Read XFM File Transformation Matrix Contents

trf = []; % initialize transformation matrix
fid = fopen(fileName, 'r'); % open file, read only
while isempty(trf) 
    fline = fgetl(fid);
    if startsWith(fline, 'Parameters:')
        trf = regexprep(fline, 'Parameters: ', '');
    end
end

% convert and reshape transformation matrix
trf = reshape(str2num(trf), 3, 4);
trf = [trf; 0 0 0 1]; % square transformation matrix

fclose(fid); % close file