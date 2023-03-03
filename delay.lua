-- [ Decap Scripting Kit ] --

--[[
    delay.lua implements some helpful features for delaying by draw frames or match frames.
    Also comes with repeat() variants, like match_repeat() and draw_repeat().
    When calling repeat, it'll pass the call count to the function you ask for.

    draw frames are what happen every draw call of the game.
    match frames are when you hit space and the counter in the middle of your screen counts down.
]]

local HOOK_ID = "dsk-delay-system"
remove_hooks(HOOK_ID)

local draw_delayed_tbl = {}
local draw_frame = -1

local match_delayed_tbl = {}
local match_frame = -1

local draw_repeated_tbl = {}
local match_repeated_tbl = {}

local function delay(tbl, frame, delay, func)
    local time = frame + delay
    local list = tbl[time] or {}
    table.insert(list, func)
    tbl[time] = list
end

function match_delayed(d, func)
    delay(match_delayed_tbl, match_frame, d, func)
end

function draw_delayed(d, func)
    delay(draw_delayed_tbl, draw_frame, d, func)
end

local function repeated(tbl, count, func)
    table.insert(tbl, {
        iteration = 0,
        count = count,
        func = func
    })
end

function match_repeated(count, func)
    repeated(match_repeated_tbl, count, func)
end

function draw_repeated(count, func)
    repeated(draw_repeated_tbl, count, func)
end

local function call_delays(tbl, frame)
    local list = tbl[frame]

    if not list then
        return
    end

    for i = 1, #list do
        local s, e = pcall(function()
            list[i]()
        end)

        if not s then
            println(e)
        end
    end

    tbl[frame] = nil
end

local function call_repeats(tbl)

    local removed = {}

    for i = 1, #tbl do
        local repeated = tbl[i]

        local iter = tbl.iteration
        local count = tbl.count

        if iter > count then
            table.insert(removed, i)
        else
            iter = iter + 1
            repeated.func(iter)
            tbl.iteration = iter
        end
    end

    for i = 1, #removed do
        table.remove(tbl, removed[i])
    end
end

add_hook("enter_frame", HOOK_ID, function()
    call_delays(match_delayed_tbl, match_frame)
    call_repeats(match_repeated_tbl)
    match_frame = match_frame + 1
end)

add_hook("draw2d", HOOK_ID, function()
    call_delays(draw_delayed_tbl, draw_frame)
    call_repeats(draw_repeated_tbl)
    draw_frame = draw_frame + 1
end)