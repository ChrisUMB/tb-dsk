-- [ Decap Scripting Kit ] --

--[[
    This is the command module, mostly written by Tom.

    It handles commands, sub commands, argument separating, and error printing.

    To create your own command, you add it to the cmd table as a function like so:
        function cmd.hello()
            println("Hello, world!")
        end

    You also have immediate access to "args":
        function cmd.position(args)
            local x = args[1]
            local y = args[2]
            local z = args[3]
            println("XYZ: " .. x .. " " .. y .. " " .. z)
        end

    Furthermore, the arguments are passed as unpacked after the initial args table is passed:
        -- This example just brings you the arguments in 'args' in order. Mild utility.
        function cmd.position(args, x, y, z)
            println("XYZ: " .. x .. " " .. y .. " " .. z)
        end

    Finally, adding sub commands is as simple as adding some periods:
        -- /position add 1.0 1.0 1.0
        function cmd.position.add(args, x, y, z)
            println("Do stuff!")
        end
    
    This class comes with a built-in "lua" command for simple lua testing. You can call /run
    and follow it with any lua code, like `/lua get_joint_info(0, 0)` and it will print the
    return value. It will also automatically "pretty print" it if it's a table.
]]

cmd = {}

local metatable = {}
metatable.__index = function(table, name)
    local existing = rawget(table, name)
    if existing ~= nil then return existing end
    local new = {}
    rawset(table, name, new)
    setmetatable(new, metatable)
    return new
end
metatable.__newindex = function(table, name, value)
    local sub = table[name]
    rawset(sub, "_name", name)
    rawset(sub, "_base", value)
    rawset(sub, "_parent", table)
end

setmetatable(cmd, metatable)

local function dispatch(split)
    if #split == 0 then
        return 0
    end

    local sub = cmd

    local function do_end(limit)
        local base = rawget(sub, "_base")

        while sub ~= nil and base == nil do
            sub = rawget(sub, "_parent")
            if sub ~= nil then
                base = rawget(sub, "_base")
            end
            limit = limit - 1
        end

        if sub == nil then
            return 0
        end

        local args = {}
        for i = limit, #split do
            args[i - limit + 1] = split[i]
        end
        
        local s, e = pcall(function() 
            base(args, unpack(args))
        end)
        
        if not s then println(e) end
        
        return 1
    end

    for i=1,#split do
        local new_sub = rawget(sub, split[i])
        if new_sub == nil then
            return do_end(i)
        else
            sub = new_sub
        end
    end

    return do_end(#split + 1)
end

function cmd.lua(args)
    if #args <= 0 then
        println("Runs lua code.")
        return
    end

    local raw = ""
    for i=1,#args do
        if i ~= 1 then 
            raw = raw .. " " 
        end

        raw = raw .. args[i]
    end

    local s, e = pcall(function() 
        local code = loadstring("return " .. raw)
        if code then return {code()} end
    end)

    -- if not s then println(e) end

    if e then
        if type(e) == "table" then
            print_table(e)
        else
            println(e)
        end
     end
end

remove_hooks("util-command")
add_hook("command", "util-commands", function(in_cmd)
    
    local split = in_cmd:split(' ')
    
    local s, e = pcall(function()
        return dispatch(split)
    end)

    if not s then println(e) end
    return e
end)