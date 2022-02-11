function [value] = extract_bids(fileName, key, withTag)
% [value] = extract_bids(fileName, key, withTag)

% Written by Kelly Chang - February 10, 2022

%%

switch lower(key)
    case 'modality'
        extNum = regexp(fileName, '\.', 'once');
        fileName = fileName(1:(extNum-1));
        value = regexp(fileName, '._(\w+)$', 'tokens', 'once'); 
    case 'space'
        value = regexp(fileName, '.*_space-(\w+)_.*', 'tokens', 'once');
        if isempty(value); value = 'T1w'; end
    case 'session'
        value = regexp(fileName, '.*_ses-(\w+)_.*', 'tokens', 'once'); 
        if withTag; value = ['ses-', char(value)]; end
    case 'subject'
        value = regexp(fileName, 'sub-(\w+)_.*', 'tokens', 'once'); 
        if withTag; value = ['ses-', char(value)]; end
    otherwise
        regstr = sprintf('.*_%s-(\\w+)_.*', lower(key));
        value = regexp(fileName, regstr, 'tokens', 'once'); 
end
value = char(value); 