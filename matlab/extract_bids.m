function [value] = extract_bids(fileName, key, withKey)
% [value] = EXTRACT_BIDS(fileName, key [, withKey])
%
% Extracts the BIDS value from the file name based on the key specified.
% (i.e., <key>-<value>). If the key entity is not found in the file name,
% returns an empty string.
%
% Argument:
%   fileName            String, file name.
%                       Example: 'sub-XXX_ses-01_acq-mprage_T1w.nii.gz'
%
%   key                 String, BIDS entity key name. 
%                       Example: 'acq'
%
%   withKey             Boolean, flag indicating if the returning value
%                       should include the BIDS key (Default: false).
%                       Example:
%                           false -> 'mprage'
%                           true  -> 'acq-mprage'
%
%
% Output:
%   value               String, BIDS value associated with the given key
%                       extacted from the file name. If the given key is
%                       not found in the file name, returns an empty
%                       string.
%
%
% Notes:
% - See BIDS documentation for more information on BIDS entities:
%   https://bids-specification.readthedocs.io/en/stable/


% Written by Kelly Chang - February 10, 2022

%% Input Control

%%% Exist: Check if 'fileName' exists.
if ~exist('fileName', 'var') || isempty(fileName)
    error('Cannot provide empty ''fileName''.');
end

%%% Exist: Check if 'key' exists.
if ~exist('key', 'var') || isempty(key)
    error('Cannot provide empty ''key''.');
end

%%% Optional: assign default value for 'withKey'.
if ~exist('withKey', 'var') || isempty(withKey)
    withKey = false;
end

%%% Format: Check for accepted BIDS key' entities.
key = lower(key); % force lowercase
validKeys = {'sub', 'ses', 'task', 'acq', 'ce', 'rec', 'dir', 'run', ...
    'mod', 'echo', 'flip', 'inv', 'mt', 'part', 'recording', 'space', ...
    'hemi', 'label', 'desc', 'modality'};
if ~any(strcmp(key, validKeys))
    error('Unrecognized BIDS ''key'' entity (%s).', key);
end

%% Extract BIDS Information from File Name

[~,fileName,~] = extract_fileparts(fileName);
fileBids = strsplit(fileName, '_');

if strcmp(key, 'modality')
    % modality is always the last value
    value = fileBids{end};
else % all other key entities
    keyIndx = contains(fileBids, sprintf('%s-', key));
    if any(keyIndx) % file name contains key-value
        value = fileBids{keyIndx};
    else % else, key is not found
        value = ''; 
    end
end

%% (Optional) Remove Key from Return String

if ~withKey % if return without key
    value = regexprep(value, '.*-', '');
end