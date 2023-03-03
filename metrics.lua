-- [ Decap Scripting Kit ] --

--[[
    metrics.lua is a utility file for measuring the amount of time
    a function takes. It's pretty simple in nature but allows you
    to further optimize your code and figure out what is slowing
    it down if you run into that issue.

    To measure the time it takes for a function to run:
        measure(function() println("Hello, world!") end)

    To do dynamic measuring, use the start/stop system:

        measure_start("example")
        -- Do a bunch of stuff, get lost in call back hell, etc.
        local time = measure_end("example")
]]

local TIMESTAMPS = {}

function measure(func)
    if not func then
        assert("measure(func) received a nil function.")
        return nil
    end
    
    local type = type(func)

    if type ~= "function" then
        assert("measure(func) received something other than a function: " .. tostring(type))
    end
    
    local start_time = os.clock()
    func()
    local end_time = os.clock()

    return end_time - start_time
end

function measure_start(id)
    if not id then
        assert("measure_start(id) received a nil ID.")
        return nil
    end

    local type = type(id)
    if type(id) ~= "string" then
        assert("measure_start(id) received an ID that was not a string, but instead was: " .. tostring(type))
        return nil
    end

    TIMESTAMPS[id] = os.clock()
end

function measure_end(id)
    if not id then
        assert("measure_end(id) received a nil ID.")
        return nil
    end

    local type = type(id)
    if type(id) ~= "string" then
        assert("measure_end(id) received an ID that was not a string, but instead was: " .. tostring(type))
        return nil
    end

    local time = TIMESTAMPS[id]

    if not time then
        assert("measure_end(id) received an ID that did not have a timestamp (called without measure_start() before): " .. tostring(id))
        return nil
    end

    return time
end