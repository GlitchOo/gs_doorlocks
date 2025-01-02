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

---Returns the index of a value in a table
---@param tbl table
---@param val any
local function indexof(tbl, val)
    for i, v in next, tbl do
        if v == val then return i end
    end

    return false
end

---Concatenates a k:v table into a string
---@param tbl table
---@param kDelim string
---@param vDelim string
---@return string
local function kvconcat(tbl, kDelim, vDelim)
    local str = ''

    for k, v in next, tbl do
        if str ~= '' then
            str = str .. kDelim .. k .. vDelim .. v
        else
            str = k .. vDelim .. v
        end
    end

    return str
end

table.contains = contains
table.indexof = indexof
table.kvconcat = kvconcat

