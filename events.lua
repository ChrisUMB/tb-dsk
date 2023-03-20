local listen

---@class Event

---@generic T : Event
---@class EventType<T>
---@field id string The ID of the event type

---@generic T : Event
---@type EventType<T>
local EventType = {}
EventType.__index = EventType

---@generic T : Event
---@param self EventType<T>
---@param hook_id string The ID of the hook
---@param callback fun(event:T) The callback to call when the event is fired
function EventType.listen(self, hook_id, callback)

end

---@generic T : Event
---@param self EventType<T>
---@param event T The event to pass to the listeners
function EventType.call(self, event)

end

---@param id string The ID of the event
---@return EventType
local function create_event_type(id)
    local event_type = {
        id = id
    }

    event_type.__index = event_type

    setmetatable(event_type, event_type)
    return event_type
end

---@type table<string, EventType>
Events = {
    GAME_START = "game-start", -- Called when a replay or a match has started.
    GAME_FRAME = "game-frame", -- Called when a replay or a match frame is entered.
    GAME_END = "game-end", -- Called when a replay or a match is ended.

    MATCH_START = "match-start", -- Called when a match starts.
    MATCH_FRAME = "match-frame", -- Called when a frame is entered during a match.
    MATCH_END = "match-end", -- Called when a match ends.
    POST_MATCH_START = "post-match-start", -- Called at the same time as match-end. Start of the frames between the match ending and the replay starting.
    POST_MATCH_FRAME = "post-match-frame", -- Called when a frame is entered in the post-match stage.
    POST_MATCH_END = "post-match-end", -- Called at the end of the post match stage.

    REPLAY_START = "replay-start", -- Called when a replay is started.
    REPLAY_FRAME = "replay-frame", -- Called when a frame is entered during a replay.
    REPLAY_END = "replay-end", -- Called when a replay ends.

    ---@class WindowResizeEvent : Event
    ---@field new_size vec2 The new size of the window.
    ---@field old_size vec2 The old size of the window.
    ---@type EventType<WindowResizeEvent>
    --- Called whenever the window is resized.
    WINDOW_RESIZE = "window-resize",

    ---@class Draw2DEvent : Event
    ---@type EventType<Draw2DEvent>
    --- Called when the 2D drawing hook is called.
    DRAW_2D = "draw2d",

    ---@class KeyDownEvent : Event
    ---@field x number The x position of the mouse.
    ---@field y number The y position of the mouse.
    ---@field key number The key that was pressed.
    ---@type EventType<KeyDownEvent>
    --- Called whenever a key is pressed.
    KEY_DOWN = "key-down"
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
    return l
end

--- Cancels the listener
function listener:cancel()
    unlisten(self.event, self.id)
end

---@param event string The event to listen for
---@param id string The ID of the listener
function unlisten(event, id)
    if listeners[event] then
        listeners[event][id] = nil
    end
end

---@generic T : Event
---@param event EventType<T> The event to listen for
---@param id string The ID of the listener
---@param func fun(event:T) The function to call when the event is fired
---@return listener The listener
function listen(event, id, func)
    local others = listeners[event] or {}
    others[id] = func
    listeners[event] = others
    return listener_new(event, id)
end

Events.WINDOW_RESIZE:listen("dsk-event-system", function(event)

end)

---@generic T : Event
---@param event_type EventType<T> The event to call
---@param event T The event to pass to the listeners
function call_event(event_type, event)
    local event_listeners = listeners[event_type]
    if not event_listeners then
        return
    end

    for _, listener_func in pairs(event_listeners) do
        local s, e = pcall(function()
            listener_func(event)
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

add_hook("enter_frame", HOOK_ID, function()
    local state = get_world_state()
    local frame = state.match_frame
    local mode = state.replay_mode

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

add_hook("resolution_changed", HOOK_ID, function()
    call_event(Events.WINDOW_RESIZE, {
        new_size = vec2(get_window_size()),
        old_size = last_size
    })

    last_size = vec2(get_window_size())
end)

--add_hook("pre_draw", HOOK_ID, function()
--    local state = get_world_state()
--    local mode = state.replay_mode
--    local frame = state.match_frame
--
--    --local cache_last_size = last_size
--    --last_size = vec2(get_window_size())
--    --if cache_last_size ~= last_size then
--    --    -- last_size here is the new size, cached is the old.
--    --    call_event("window-resize", last_size, cache_last_size)
--    --end
--
--    local frame_delta = frame - previous_frame
--    if frame_delta == 0 then
--        return
--    elseif frame_delta > 1 then
--        -- TODO: Why was this printing all the time
--        --println("Frame delta was greater than 1.")
--    end
--
--    if frame == 0 then
--        if mode == MODE_REPLAY then
--            if not post_match_over then
--                post_match_over = true
--                call_event("post-match-end", state)
--            end
--
--            call_event("replay-start", state)
--        end
--
--    end
--
--    call_event("game-frame", state)
--
--    if not post_match_over and match_over then
--        call_event("post-match-frame", state)
--    elseif mode == MODE_REPLAY then
--        call_event("replay-frame", state)
--    elseif mode == MODE_MATCH then
--        call_event("match-frame", state)
--    end
--
--    previous_frame = frame
--end)

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
    call_event(EVENTS.DRAW2D)
end)