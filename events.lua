---@class Hook

---@generic T : Hook
---@class HookType<T>
---@field id string The ID of the event type

---@generic T : Hook
---@type HookType<T>
local EventType = {}

EventType.__index = EventType

---@class Listener
---@field id string The ID of the listener
---@field hook_type HookType The event to listen for
local Listener = {}
Listener.__index = Listener

---@type Listener[]
local listeners = {}

---@return Listener
local function listener_new(event, id)
    local l = {
        id = id,
        event = event
    }

    setmetatable(l, Listener)
    return l
end

--- Cancels the listener
function Listener:cancel()
    if listeners[self.hook_type] then
        listeners[self.hook_type][self.id] = nil
    end
end

---@generic T : Hook
---@param self HookType<T>
---@param event T The event to pass to the listeners
function EventType.call(self, event)
    if not event then
        event = {}
    end

    local hook_listeners = listeners[self]
    if not hook_listeners then
        return
    end

    for listener, callback in pairs(hook_listeners) do
        local s, e = pcall(function()
            callback(event, listener)
        end)

        if not s then
            println(e)
        end
    end
end

---@generic T : Hook
---@param self HookType<T>
---@param listener_id string The ID of the hook
---@param callback fun(event:T, listener: Listener) The callback to call when the event is fired
---@return Listener The listener object
function EventType.listen(self, listener_id, callback)
    local others = listeners[self] or {}
    others[listener_id] = callback
    listeners[self] = others
    return listener_new(self, listener_id)
end

---@param id string The ID of the event
---@return HookType
local function new_hook(id)
    local event_type = {
        id = id
    }

    event_type.__index = event_type

    setmetatable(event_type, event_type)
    return event_type
end

---@type table<string, HookType>
Hooks = {
    GAME_START = new_hook("game-start"), -- Called when a replay or a match has started.
    GAME_FRAME = new_hook("game-frame"), -- Called when a replay or a match frame is entered.
    GAME_END = new_hook("game-end"), -- Called when a replay or a match is ended.

    MATCH_START = new_hook("match-start"), -- Called when a match starts.
    MATCH_FRAME = new_hook("match-frame"), -- Called when a frame is entered during a match.
    MATCH_END = new_hook("match-end"), -- Called when a match ends.
    POST_MATCH_START = new_hook("post-match-start"), -- Called at the same time as match-end. Start of the frames between the match ending and the replay starting.
    POST_MATCH_FRAME = new_hook("post-match-frame"), -- Called when a frame is entered in the post-match stage.

    ---@class PostMatchEndEvent : Hook
    ---@type HookType<PostMatchEndEvent>
    --- Called at the end of the post match stage.
    POST_MATCH_END = new_hook("post-match-end"),

    REPLAY_START = new_hook("replay-start"), -- Called when a replay is started.
    REPLAY_FRAME = new_hook("replay-frame"), -- Called when a frame is entered during a replay.
    REPLAY_END = new_hook("replay-end"), -- Called when a replay ends.

    ---@class WindowResizeEvent : Hook
    ---@field new_size vec2 The new size of the window.
    ---@field old_size vec2 The old size of the window.
    ---@type HookType<WindowResizeEvent>
    --- Called whenever the window is resized.
    WINDOW_RESIZE = new_hook("window-resize"),

    ---@class Draw2DEvent : Hook
    ---@type HookType<Draw2DEvent>
    --- Called when the 2D drawing hook is called.
    DRAW_2D = new_hook("draw2d"),

    ---@class KeyDownEvent : Hook
    ---@field x number The x position of the mouse.
    ---@field y number The y position of the mouse.
    ---@field key number The key that was pressed.
    ---@type HookType<KeyDownEvent>
    --- Called whenever a key is pressed.
    KEY_DOWN = new_hook("key-down")
}

local HOOK_ID = "dsk-events"
remove_hooks(HOOK_ID)

local MODE_MATCH = 0
local MODE_REPLAY = 1
local MODE = {
    [MODE_REPLAY] = "replay",
    [MODE_MATCH] = "match"
}

local match_over = false
local post_match_over = false


add_hook("enter_frame", HOOK_ID, function()
    local state = get_world_state()
    local frame = state.match_frame
    local mode = state.replay_mode

    if frame == 0 then
        if mode == MODE_REPLAY then
            if not post_match_over then
                post_match_over = true
                Hooks.POST_MATCH_END:call()
            end

            Hooks.REPLAY_START:call()
        end
    end

    Hooks.GAME_FRAME:call()

    if not post_match_over and match_over then
        Hooks.POST_MATCH_FRAME:call()
    elseif mode == MODE_REPLAY then
        Hooks.REPLAY_FRAME:call()
    elseif mode == MODE_MATCH then
        Hooks.MATCH_FRAME:call()
    end
end)

local last_size = vec2(get_window_size())

add_hook("resolution_changed", HOOK_ID, function()
    Hooks.WINDOW_RESIZE:call({
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
    if get_world_state().replay_mode ~= MODE_REPLAY then
        return
    end

    Hooks.REPLAY_END:call()
end)

add_hook("end_game", HOOK_ID, function()
    if match_over then
        return
    end
    match_over = true
    Hooks.MATCH_END:call()
    Hooks.POST_MATCH_START:call()
end)

add_hook("match_begin", HOOK_ID, function()
    match_over = false
    post_match_over = false
    Hooks.MATCH_START:call()
end)

add_hook("draw2d", HOOK_ID, function()
    Hooks.DRAW_2D:call()
end)

Hooks.REPLAY_FRAME:listen("test", function()

end)