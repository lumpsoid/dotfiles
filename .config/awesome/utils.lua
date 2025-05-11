local M = {}

-- Deep copy a table
M.deep_copy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deep_copy(orig_key)] = M.deep_copy(orig_value)
        end
        setmetatable(copy, M.deep_copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Create an array of numbers from 'from' to 'to' with optional step
M.range = function(from, to, step)
    local t = {}
    step = step or 1
    for i = from, to, step do
        t[#t + 1] = i
    end
    return t
end

-- Merge two tables with deep merge capability
-- t2 values override t1 values when keys collide
M.merge_tables = function(t1, t2)
    local merged = M.deep_copy(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(merged[k]) == "table" then
            merged[k] = M.merge_tables(merged[k], v)
        else
            merged[k] = v
        end
    end
    return merged
end

M.rounded_rect = function(radius)
	radius = radius or beautiful.border_radius
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, radius)
	end
end

return M
