function tf = structCompare(a, b)
% structCompare  True if structures a and b have the same fields and contents.
%   tf = structCompare(a,b) returns logical 1 if a and b have identical field
%   names (including nested fields) and identical contents. Field order does
%   not matter. Uses isequaln for leaf comparison (NaN == NaN).
%
%   Works for scalar and non-scalar struct arrays (requires same size),
%   nested structs, cell arrays, numeric, char, logical, etc.

    tf = compareRecursive(a, b);
end

function ok = compareRecursive(x, y)
    % Quick class/size mismatch checks
    if ~isequal(class(x), class(y))
        ok = false; return
    end
    if ~isequal(size(x), size(y))
        ok = false; return
    end

    % If both are structs, compare field names and each element/field recursively
    if isstruct(x)
        fnx = sort(fieldnames(x));
        fny = sort(fieldnames(y));
        if ~isequal(fnx, fny)
            ok = false; return
        end
        % Compare each element of struct array
        ok = true;
        for idx = 1:numel(x)
            for i = 1:numel(fnx)
                fld = fnx{i};
                if ~compareRecursive(x(idx).(fld), y(idx).(fld))
                    ok = false; return
                end
            end
        end
        return
    end

    % If cells, compare elementwise recursively
    if iscell(x)
        ok = true;
        for idx = 1:numel(x)
            if ~compareRecursive(x{idx}, y{idx})
                ok = false; return
            end
        end
        return
    end

    % For other types (numeric, char, logical, tables, etc.) use isequaln
    ok = isequaln(x, y);
end