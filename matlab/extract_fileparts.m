function [filePath,name,ext] = extract_fileparts(fileName)
% [filePath,name,ext] = EXTRACT_FILEPARTS(fileName)
% 
% Extracts the given file name's path, base name, and extension including
% compression extensions (e.g., '.gz', '.zip').
%
%
% Argument:
%   fileName            String, file name.
%                       Example: '/path/to/filename.nii.gz'
%
%
% Outputs:
%   filePath            String, file paths.
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
 
fileName = char(fileName); 
[filePath,name,ext] = fileparts(fileName);

% if compressed file, extract base name again
if any(strcmp(ext, {'.gz', '.zip'})) 
    [~,name,baseExt] = fileparts(name);
    ext = [baseExt, ext];
end