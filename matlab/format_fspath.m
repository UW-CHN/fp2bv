function [fileName] = format_fspath(fileName)
% [fileName] = format_fspath(fileName)

% Written by Kelly Chang - February 10, 2022

%%

fileName = regexprep(fileName, ' ', '\\ '); 