function [filePath,name,ext] = extract_fileparts(fileName)
% [filePath,name,ext] = extract_fileparts(fileName)

% Written by Kelly Chang - February 10, 2022

%%
 
fileName = char(fileName); 
[filePath,name,ext] = fileparts(fileName);

if strcmp(ext, '.gz') % if gzip compressed file
    [~,name,baseExt] = fileparts(name);
    ext = [baseExt, ext];
end
