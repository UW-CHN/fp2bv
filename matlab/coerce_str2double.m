function [d] = coerce_str2double(x)

if ischar(x)
    d = cellfun(@str2double, num2cell(x,2));
elseif isnumeric(x)
    d = double(x);
end