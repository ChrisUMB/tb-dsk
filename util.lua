-- [ Decap Scripting Kit ] --

--[[
    This is our random utility module full of functions we need that
    don't really fit anywhere in particular but are needed.
]]

-- Standard lua has table.unpack, Toribash has just "unpack", not very cool.
if not table.unpack then
    table.unpack = unpack
end

-- This is just because println() is a standard elsewhere, and this also does automatically apply tostring().
if echo then
    function println(v)
        echo(tostring(v) .. "\n")
    end
else
    function println(v)
        print(tostring(v))
    end
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

---@param x number The x position of the quad.
---@param y number The y position of the quad.
---@param width number The width of the quad.
---@param height number The height of the quad.
---@param color vec4 The color of the quad.
---@param u number The u coordinate of the texture.
---@param v number The v coordinate of the texture.
---@param s number The s coordinate of the texture.
---@param t number The t coordinate of the texture.
---@param texture_id number The texture id to use.
function draw_quad_coords(x, y, width, height, color, u, v, s, t, texture_id)
    color = color or vec4(1, 1, 1, 1)
    draw_quad(x, y, width, height, texture_id, 2, color[1], color[2], color[3], color[4], s - u, t - v, u, v)
end

CLIP_RESULT = {
    FULLY_VISIBLE = 1,
    FULLY_HIDDEN = 2,
    PARTIALLY_VISIBLE = 3
}

---@param x number The x position of the quad.
---@param y number The y position of the quad.
---@param width number The width of the quad.
---@param height number The height of the quad.
---@param color vec4 The color of the quad.
---@param texture_id number The texture id to use.
---@param texture_width number The width of the texture.
---@param texture_height number The height of the texture.
---@param area_x number The x position of the area to clip within.
---@param area_y number The y position of the area to clip within.
---@param area_width number The width of the area to clip within.
---@param area_height number The height of the area to clip within.
function draw_clipped_quad(x, y, width, height, color, texture_id, texture_width, texture_height, area_x, area_y, area_width, area_height)
    if x > area_x + area_width or y > area_y + area_height then
        return CLIP_RESULT.FULLY_HIDDEN
    end

    local lx = x - area_x
    local hx = area_x + area_width - x

    local ly = y - area_y
    local hy = area_y + area_height - y

    local u = math.min(math.max(-lx / width, 0), 1)
    local v = math.min(math.max(-ly / height, 0), 1)
    local s = math.min(math.max(hx / width, 0), 1)
    local t = math.min(math.max(hy / height, 0), 1)

    x = x + u * width
    y = y + v * height

    width = width * (s - u)
    height = height * (t - v)

    if texture_id ~= nil then
        draw_quad_coords(x, y, width, height, color, u * texture_width, v * texture_height, s * texture_width, t * texture_height, texture_id)
    else
        set_color(color[1], color[2], color[3], color[4])
        draw_quad(x, y, width, height)
    end

    if u == 0 and v == 0 and s == 1 and t == 1 then
        return CLIP_RESULT.FULLY_VISIBLE
    else
        return CLIP_RESULT.PARTIALLY_VISIBLE
    end
end

-- function io.write_line(line)
--     local line = line:find("\n$") and line or (line .. "\n")
--     io.write(line)
-- end