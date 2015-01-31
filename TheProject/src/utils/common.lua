local M = {}

--
-- deep copy for tables
--

function M.deepCopy(t)
    if type(t) ~= 'table' then
        return t
    end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = M.deep_copy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end



return M
