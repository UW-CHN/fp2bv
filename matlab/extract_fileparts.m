function [fpath,name,ext] = extract_fileparts(fname)
% [fpath,name,ext] = EXTRACT_FILEPARTS(fileName)
% 
% Extracts the given file name's path, base name, and extension including
% compression extensions (e.g., '.gz', '.zip').
%
%
% Argument:
%   fname               String, file name.
%                       Example: '/path/to/filename.nii.gz'
%
%
% Outputs:
%   fpath               String, file paths.
%                       Example: '/path/to'
% 
%   name                String, file base name.
%                       Example: 'filename'
% 
%   ext                 String, file extension, includes compression
%                       extensions.
%                       Example: '.nii.gz'


% Written by Kelly Chang - February 10, 2022

%% Extract File Parts
 
fname = char(fname); 
[fpath,name,ext] = fileparts(fname);

% if compressed file, extract base name again
if any(strcmp(ext, {'.gz', '.zip'})) 
    [~,name,baseExt] = fileparts(name);
    ext = [baseExt, ext];
end