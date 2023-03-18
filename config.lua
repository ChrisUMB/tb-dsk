--[[
    DSK utility for interacting with INI config files.
]]

---@class config
config = {}

function config.write(data, path)
    --local comments = {} -- a table to store comments
    --for section, properties in pairs(data) do
    --    for key, value in pairs(properties) do
    --        if type(key) == "string" and key:sub(1, 1) == "#" then -- it's a comment
    --            comments[section] = comments[section] or {}
    --            comments[section][key:sub(2)] = value -- store the comment
    --        end
    --    end
    --end

    local section_names = {} -- a table to store the section names so we can sort them
    for section, _ in pairs(data) do
        table.insert(section_names, section) -- add the section name to the table
    end

    table.sort(section_names) -- sort the section names alphabetically

    local file = io.open(path, "w") -- open the file for writing
    for _, section in ipairs(section_names) do
        local properties = data[section]
        file:write(string.format("[%s]\n", section)) -- write the section name
        local keys = {} -- a table to store the keys so we can sort them
        for key, _ in pairs(properties) do
            if type(key) ~= "string" or key:sub(1, 1) ~= "#" then -- it's a property
                table.insert(keys, key) -- add the key to the table
            end
        end

        table.sort(keys) -- sort the keys alphabetically

        for _, key in ipairs(keys) do
            --local comment = comments[section] and comments[section][key] -- look up the comment
            local comment = properties["#" .. key]
            if comment then
                local lines = {}
                for line in comment:gmatch("[^\r\n]+") do
                    table.insert(lines, line)
                end
                for _, line in ipairs(lines) do
                    file:write(string.format("# %s\n", line)) -- write the comment
                end
                --file:write(string.format("# %s\n", comment)) -- write the comment
            end
            local value = properties[key]
            local value_str = tostring(value)
            --if type(value) == "string" then -- quote the string value
            --    value_str = string.format('"%s"', value_str)
            --end
            file:write(string.format("%s = %s\n", key, value_str)) -- write the property
        end
        file:write("\n") -- add an empty line between sections
    end
    file:close() -- close the file
end

local function convert_string_to_type(value)
    --tonumber(value_str) or value_str:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^\"", ""):gsub("\"$", "") -- parse the value
    if value == "true" then
        return true
    elseif value == "false" then
        return false
    elseif value:sub(1, 1) == "\"" and value:sub(-1) == "\"" then
        return value:sub(2, -2)
    else
        return tonumber(value) or value
    end
end

function config.read(path)
    local file = io.open(path, "r") -- open the file for reading
    local data = {}
    local section = nil
    local comment_str = "" -- a string to accumulate comments

    for line in file:lines() do
        -- trim leading and trailing whitespace
        line = line:gsub("^%s+", ""):gsub("%s+$", "")

        if line ~= "" then -- ignore empty lines
            if line:sub(1, 1) == "[" and line:sub(-1) == "]" then -- it's a section
                section = line:sub(2, -2)
                data[section] = {}
                comment_str = "" -- reset the comment string
            elseif line:sub(1, 1) == "#" or line:sub(1, 1) == ";" then -- it's a comment
                if comment_str ~= "" then
                    comment_str = comment_str .. "\n" -- add a newline if there's already a comment
                end
                comment_str = comment_str .. line:sub(2):gsub("^%s+", "")
            else -- it's a property
                local key, value_str = line:match("^([^=]+)=(.*)$")
                if key then
                    key = key:gsub("^%s+", ""):gsub("%s+$", "") -- trim leading and trailing whitespace
                    value_str = value_str:gsub("^%s+", ""):gsub("%s+$", "") -- trim leading and trailing whitespace
                    --data[section][key] = value -- store the property
                    data[section][key] = convert_string_to_type(value_str) -- store the property
                    if comment_str ~= "" then
                        data[section]["#" .. key] = comment_str:gsub("^%s+", "") -- store the comment
                        comment_str = "" -- reset the comment string
                    end
                end
            end
        end
    end

    file:close() -- close the file

    return data, comments -- return the data and comments tables
end
