-- [ Decap Scripting Kit ] --

--[[
    This is the events module. It's a sort of wrapper/addition to hooks,
    and uses them internally. The goal of the events system is to pre-handle
    all of the possible if checks you usually might have to make to differentiate
    between a specific state a hook was called in, i.e the difference between
    entering a frame of a replay, and entering the frame of a match.

    In order to listen for events, it will look like:
        listen("game-start", "id", function()
            println("A game has started!")
        end)

    The "id" parameter is not particularly important for functionality,
    however it is advised you choose a unique ID for your events that
    relates to your script, that way you don't possibly override somebody
    elses listener for that event. A good practice to follow is to do:
        listen("event", "SCRIPT_NAME", function() end)

    The only time this might be a problem is if you have multiple listeners
    for the same event throughout your script, so you might append the event
    name or listener purpose after your script name to prevent overriding.
]]

EVENTS = {
    GAME_START = "game-start",                  -- Called when a replay or a match has started.
    GAME_FRAME = "game-frame",                  -- Called when a replay or a match frame is entered.
    GAME_END = "game-end",                      -- Called when a replay or a match is ended.

    MATCH_START = "match-start",                -- Called when a match starts.
    MATCH_FRAME = "match-frame",                -- Called when a frame is entered during a match.
    MATCH_END = "match-end",                    -- Called when a match ends.
    POST_MATCH_START = "post-match-start",      -- Called at the same time as match-end. Start of the frames between the match ending and the replay starting.
    POST_MATCH_FRAME = "post-match-frame",      -- Called when a frame is entered in the post-match stage.
    POST_MATCH_END = "post-match-end",          -- Called at the end of the post match stage.

    REPLAY_START = "replay-start",              -- Called when a replay is started.
    REPLAY_FRAME = "replay-frame",              -- Called when a frame is entered during a replay.
    REPLAY_END = "replay-end",                  -- Called when a replay ends.

    WINDOW_RESIZE = "window-resize",            -- Called when the window is resized.
    DRAW2D = "draw2d"                           -- Called when the 2D drawing hook is called.
}

---@class listener
---@field id string The ID of the listener
---@field event string The event to listen for
local listener = {}
listener.__index = listener

---@type listener[]
local listeners = {}

local function listener_new(event, id)
    local l = {
        id = id,
        event = event
    }

    setmetatable(l, listener)
    println(tostring(l))
    return l
end

--- Cancels the listener
function listener:cancel()
    println("disabling listener: " .. tostring(self.event) .. " " .. tostring(self.id))
    unlisten(self.event, self.id)
end

---@param event string The event to listen for
---@param id string The ID of the listener
function unlisten(event, id)
    if listeners[event] then
        listeners[event][id] = nil
    end
end

---@param event string The event to listen for
---@param id string The ID of the listener
---@param func function The function to call when the event is fired
---@return listener The listener
function listen(event, id, func)
    local others = listeners[event] or {}
    others[id] = func
    listeners[event] = others
    return listener_new(event, id)
end

function call_event(event, ...)
    local event_listeners = listeners[event]
    if not event_listeners then
        return
    end

    local args = ...

    for i, listener_func in pairs(event_listeners) do
        local s, e = pcall(function()
            listener_func(args)
        end)

        if not s then
            println(e)
        end
    end
end

local HOOK_ID = "dsk-event-system"
remove_hooks(HOOK_ID)

local MODE_MATCH = 0
local MODE_REPLAY = 1
local MODE = {
    [MODE_REPLAY] = "replay",
    [MODE_MATCH] = "match"
}

local match_over = false
local post_match_over = false

local previous_frame = get_world_state().match_frame
-- Using pre_draw eliminated frame delta variance with lower framerates
-- and seems more consistent overall.

local last_size = vec2(get_window_size())

add_hook("pre_draw", HOOK_ID, function()
    local state = get_world_state()
    local mode = state.replay_mode
    local frame = state.match_frame

    local cache_last_size = last_size
    last_size = vec2(get_window_size())
    if cache_last_size ~= last_size then
        -- last_size here is the new size, cached is the old.
        call_event("window-resize", last_size, cache_last_size)
    end

    local frame_delta = frame - previous_frame
    if frame_delta == 0 then
        return
    elseif frame_delta > 1 then
        -- TODO: Why was this printing all the time
        --println("Frame delta was greater than 1.")
    end

    if frame == 0 then
        if mode == MODE_REPLAY then
            if not post_match_over then
                post_match_over = true
                call_event("post-match-end", state)
            end

            call_event("replay-start", state)
        end

    end

    call_event("game-frame", state)

    if not post_match_over and match_over then
        call_event("post-match-frame", state)
    elseif mode == MODE_REPLAY then
        call_event("replay-frame", state)
    elseif mode == MODE_MATCH then
        call_event("match-frame", state)
    end

    previous_frame = frame
end)

add_hook("leave_game", HOOK_ID, function()
    local state = get_world_state()
    local mode = state.replay_mode
    if mode ~= MODE_REPLAY then
        return
    end
    call_event("replay-end", state)
end)

add_hook("end_game", HOOK_ID, function()
    if match_over then
        return
    end
    match_over = true
    local state = get_world_state()
    call_event("match-end", state)
    call_event("post-match-start", state)
end)

add_hook("match_begin", HOOK_ID, function()
    match_over = false
    post_match_over = false
    local state = get_world_state()
    call_event("match-start", state)
end)

add_hook("draw2d", HOOK_ID, function()
    call_event("draw2d", get_world_state())
end)