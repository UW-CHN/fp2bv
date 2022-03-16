function [trf] = read_xfm(filename)

fid = fopen(filename, 'r');

trf = []; 
while isempty(trf)
    fline = fgetl(fid);
    if startsWith(fline, 'Parameters:')
        trf = regexprep(fline, 'Parameters: ', '');
    end
end

trf = reshape(str2num(trf), 3, 4);
trf = [trf; 0 0 0 1];

fclose(fid); 
