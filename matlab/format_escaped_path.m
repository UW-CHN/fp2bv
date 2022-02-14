function [fileName] = format_escaped_path(fileName)
% [fileName] = FORMAT_ESCAPED_PATH(fileName)
% 
% Adds escape characters ('\') to the given file name when there are
% special characters.
%
% Argument:
%   fileName            String, file name.
%                       Example:
%                           '/path/to/file name.txt'
%
% Output:
%   fileName            String, file name with escape characters.
%                       Example: 
%                           '/path/to/file\ name.txt'

% Written by Kelly Chang - February 10, 2022

%% Format File Name

fileName = regexprep(fileName, '([ \\\[\]\(\)])', '\\$1');
fileName = regexprep(fileName, '\/', ':');