-- [ Decap Scripting Kit ] --

--[[
    This is our random utility module full of functions we need that
    don't really fit anywhere in particular but are needed.
]]

-- Standard lua has table.unpack, Toribash has just "unpack", not very cool.
table.unpack = unpack

-- This is just because println() is a standard elsewhere, and this also does automatically apply tostring().
function println(v)
    echo(tostring(v) .. "\n")
end

function tab_string(tabs)
    return string.rep("\t", tabs)
end

function is_empty(table)
    for _, _ in pairs(table) do
        return false
    end
    return true
end

-- This will convert a table to a readable string. Useful for writing things to files during testing.
function table_to_string(table, tabs, prefix, result, seen_tables, write_line)
    result = result or ""
    tabs = tabs or 0
    seen_tables = seen_tables or {}

    local ts = tab_string(tabs)
    local line = write_line or function(value)
        result = result .. value .. "\n"
    end

    if seen_tables[table] then
        line(ts .. "<recursive>")
        return result
    end

    seen_tables[table] = true

    if prefix ~= nil then
        if is_empty(table) then
            return ts .. prefix .. " {}"
        end
        line(ts .. prefix .. " {")
        tabs = tabs + 1
    end

    for i, v in pairs(table) do
        if type(i) ~= "string" or i:sub(1, 2) ~= "__" then
            if type(v) == "table" then
                local meta = getmetatable(v)

                if meta and rawget(meta, "__tostring") then
                    line(ts .. i .. " = " .. tostring(v))
                elseif is_empty(v) then
                    line(ts .. i .. " = {} ")
                elseif not seen_tables[v] then
                    line(ts .. i .. " = {")
                    result = table_to_string(v, tabs + 1, nil, result, seen_tables)
                    line(ts .. "}")
                else
                    line(ts .. i .. " = <recursive>")
                end
            else
                line(ts .. i .. " = " .. tostring(v))
            end
        end
    end

    if prefix ~= nil then
        line(tab_string(tabs - 1) .. "}")
    end
    return result
end

-- This will print the table to chat. Also helpful for testing.
function print_table(table)
    local s = table_to_string(table)

    for token in s:gmatch("[^\n]+") do
        println(token:gsub("\t", "  "))
    end
end

string.split = function(self, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local t = {}
    local i = 1
    for str in string.gmatch(self, "([^" .. seperator .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

-- This will return true if every key in ... is present in the given table.
function all_keys_present(table, ...)
    if not table or type(table) ~= "table" then
        return false
    end

    local keys = { ... }
    for i = 1, #keys do
        if rawget(table, keys[i]) == nil then
            return false
        end
    end

    return true
end

function math.sign(v)
    if v < 0 then
        return -1
    elseif v > 0 then
        return 1
    else
        return 0
    end
end

function math.copysign(a, b)
    return math.abs(a) * math.sign(b)
end

-- Shallow copy for tables.
function table.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function is_finite(number)
    return number ~= math.huge and number ~= -math.huge and number == number
end

function hsv_to_rgb(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    if i == 0 then
        r = v
        g = t
        b = p
    elseif i == 1 then
        r = q
        g = v
        b = p
    elseif i == 2 then
        r = p
        g = v
        b = t
    elseif i == 3 then
        r = p
        g = q
        b = v
    elseif i == 4 then
        r = t
        g = p
        b = v
    elseif i == 5 then
        r = v
        g = p
        b = q
    end

    return vec3(r, g, b)
end

-- function io.write_line(line)
--     local line = line:find("\n$") and line or (line .. "\n")
--     io.write(line)
-- end