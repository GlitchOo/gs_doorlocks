U.table = table

---Checks the table fot a matching value
---@param tbl table
---@param val any
---@return boolean
local function contains(tbl, val)
    if type(val) == 'table' then
        local set = {}

        for _, v in next, tbl do
            set[v] = true
        end

        for _, v in next, val do
            if not set[v] then return false end
        end

        return true
    else
        for _, v in next, tbl do
            if v == val then return true end
        end

        return false
    end
end

table.contains = contains

