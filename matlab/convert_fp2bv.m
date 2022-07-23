function convert_fp2bv(subjectInfo, overwrite)
% CONVERT_FP2BV(subjectInfo [, overwrite])
%
% Converts fMRIPrep output files to BrainVoyager compatiable file formats.
%
%
% Arguments:
%   subjectInfo         Structure, output from FIND_FMRIPREP_FILES.
% 
%   [overwrite]         Logical, flag to overwrite existing BrainVoyager 
%                       files or not (default: false). Optional. 
%
%
% See also FIND_FMRIPREP_FILES

% Written by Kelly Chang - March 16, 2022

%% Input Control

%%% Exist: Check is 'overwrite' exists.
if ~exist('overwrite', 'var') || isempty(overwrite)
    overwrite = false; % assign default
end

%%% Format: Check 'overwrite' data type.
if ~islogical(overwrite)
    error('Invalid data type. Supplied ''overwrite'' must be a logical.');
end

%% Convert fMRIPrep to BrainVoyager Files

for i = 1:length(subjectInfo) % for each subject
    p = subjectInfo(i); % current subject
    
    fprintf('[SUBJECT]: %s\n', p.subject);
    
    fprintf('Converting Anatomical Volumes\n');
    convert_wrapper(p, 'anat');
    
    fprintf('Converting Surfaces\n');
    convert_wrapper(p, 'surf');
    
    fprintf('Converting Volume Time Courses\n');
    convert_wrapper(p, 'vtc');
    
    fprintf('Converting Surface Time Courses\n');
    convert_wrapper(p, 'mtc');
    
    fprintf('Converting Functional Confounds\n');
    convert_wrapper(p, 'confounds');
    
    fprintf('[COMPLETED]: %s\n\n', p.subject);
end

%% Helper Function

function [tf] = contains_regexp(str, pat)
    patternMatch = regexp(str, pat, 'once');
    tf = ~cellfun(@isempty, patternMatch);
end

function [fun] = get_convert_function(modality)
    switch modality
        case 'anat'; fun = @convert_anat_to_vmr;
        case 'surf'; fun = @convert_surf_to_srf;
        case 'vtc';  fun = @convert_func_to_vtc;
        case 'mtc';  fun = @convert_func_to_mtc;
        case 'confounds'; fun = @convert_confounds_to_sdm;
    end
end

function [srfFile] = find_reduce_srf(f)
    [fpath,fname] = fileparts(f);
    srfPattern = regexprep(fname, '_(\w+)$', '(_res-reduce\\d{2})?_$1');
    srfList = dir(fullfile(fpath, '*.srf')); srfList = {srfList.name};
    srfFile = srfList(contains_regexp(srfList, srfPattern));
end

function [tf] = issrf(f)
    tf = ~isempty(find_reduce_srf(f));
end

function [fname] = filename(f)
    [~,name,ext] = fileparts(f); 
    fname = [name ext]; 
end

function convert_wrapper(p, suffix)
    suffix = lower(suffix);
    inputFiles = p.(suffix); outputFiles = p.save.(suffix);
    convert_function = get_convert_function(suffix); 

    if length(inputFiles) < 1 % if no files to convert
        fprintf('  No files to convert, skipping conversion process\n');
    else % convert files
        for f = 1:length(inputFiles)
            %%% if file *exists* AND do *not* overwrite, skip
            if isfile(outputFiles{f}) && ~overwrite
                fprintf('  Exists: %s\n', filename(outputFiles{f}));
            %%% if surface file *exists* AND do *not* overwrite, skip  
            elseif issrf(outputFiles{f}) && ~overwrite
                srfFile = find_reduce_srf(outputFiles{f});
                fprintf('  Exists: %s\n', filename(srfFile));
            else % all other conditions
                fprintf('  Converting: %s\n', filename(inputFiles{f}));
                if strcmp(suffix, 'surf')
                    trf = read_xfm(p.surf2anat); % extract transformation matrix
                    outputFiles{f} = convert_function(outputFiles{f}, ...
                        inputFiles{f}, trf);
                else
                    convert_function(outputFiles{f}, inputFiles{f});
                end
                fprintf('  Converted:  %s\n', filename(outputFiles{f}));
            end
        end
    end
end

end