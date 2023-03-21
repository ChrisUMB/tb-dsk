---@class HookData

---@generic T : HookData
---@class HookType<T>
---@field id string The ID of the event type

---@generic T : HookData
---@type HookType<T>
local EventType = {}

EventType.__index = EventType

---@class Hook
---@field id string The ID of the hook
---@field hook_type HookType The hook type/event to listen for
local Hook = {}
Hook.__index = Hook

---@type table<HookType, table<string, fun(event:HookData, listener:Hook)>>
local hooks = {}

---@return Hook
local function listener_new(event, id)
    local l = {
        id = id,
        event = event
    }

    setmetatable(l, Hook)
    return l
end

--- Cancels the listener
function Hook:cancel()
    if hooks[self.hook_type] then
        hooks[self.hook_type][self.id] = nil
    end
end

---@generic T : HookData
---@param self HookType<T>
---@param data T The hook data to pass to the listeners
function EventType.call(self, data)
    if not data then
        data = {}
    end

    local hook_listeners = hooks[self]
    if not hook_listeners then
        return
    end

    for listener, callback in pairs(hook_listeners) do
        local s, e = pcall(function()
            callback(data, listener)
        end)

        if not s then
            println(e)
        end
    end
end

---@generic T : HookData
---@param self HookType<T>
---@param hook_id string The ID of the hook
---@param callback fun(event:T, listener: Hook) The callback to call when the event is fired
---@return Hook The listener object
function EventType.listen(self, hook_id, callback)
    local others = hooks[self] or {}
    others[hook_id] = callback
    hooks[self] = others
    return listener_new(self, hook_id)
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

--[[

void new_game()
void new_mp_game()
void enter_frame()
void end_game(int end_type)
void leave_game()
void enter_freeze()
void exit_freeze()
void player_select(int player)
void spec_select_player(int player, int body, int joint)
void draw2d()
void draw3d()
void play()
void match_begin()
void bout_update()
void spec_update()
void text_input(string text)
void post_draw3d()
void draw_viewport()
void pre_draw()
void new_game_mp() // wait, what is the difference between this and new_mp_game?
void network_complete()
void network_error()
void downloader_complete(string filename)
void replay_integrity_fail(int frame) // no idea
void filebrowser_select(string filename)
void mod_trigger(int p1, int p2, int b1, int b2) // bad parameter names
void resolution_changed()
void unload()
void roomlist_update(string error)

// parameters are just called "i", not sure what they are
void spec_mouse_outside(int i)
void spec_mouse_over(int i)
void spec_mouse_up(int i)
void spec_mouse_down(int i)
void bout_mouse_outside(int i)
void bout_mouse_over(int i)
void bout_mouse_up(int i)
void bout_mouse_down(int i)

// returns "discard"
int key_up(int key, int scancode)
int key_down(int key, int scancode)
int mouse_button_up(int button, int x, int y)
int mouse_button_down(int button, int x, int y)
int mouse_move(int x, int y)
int joint_select(int player, int joint)
int body_select(int player, int body)
int key_hold(int key, int scancode)
int console(string s, int type, int tab)
int command(string command)
int camera()

// code indicates that it has 1 return value, but the type
// isn't specified and it isn't used, this is probably a bug
unknown console_post(string msg, int type, int tab)

]]

---@type table<string, HookType>
Hooks = {
    ---@class GameStart : HookData
    ---@type HookType<GameStart>
    --- Called when a replay or a match has started.
    GAME_START = new_hook("game-start"),

    ---@class GameFrame : HookData
    ---@type HookType<GameFrame>
    --- Called when a replay or a match frame is entered.
    GAME_FRAME = new_hook("game-frame"),

    ---@class GameEnd : HookData
    ---@type HookType<GameEnd>
    --- Called when a replay or a match is ended.
    GAME_END = new_hook("game-end"),


    ---@class MatchStart : HookData
    ---@type HookType<MatchStart>
    --- Called when a match starts.
    MATCH_START = new_hook("match-start"),

    ---@class MatchFrame : HookData
    ---@type HookType<MatchFrame>
    --- Called when a frame is entered during a match.
    MATCH_FRAME = new_hook("match-frame"),

    ---@class MatchEnd : HookData
    ---@type HookType<MatchEnd>
    --- Called when a match ends.
    MATCH_END = new_hook("match-end"),

    ---@class PostMatchStart : HookData
    ---@type HookType<PostMatchStart>
    --- Called at the same time as match-end. Start of the frames between the match ending and the replay starting.
    POST_MATCH_START = new_hook("post-match-start"),

    ---@class PostMatchFrame : HookData
    ---@type HookType<PostMatchFrame>
    --- Called when a frame is entered in the post-match stage.
    POST_MATCH_FRAME = new_hook("post-match-frame"),

    ---@class PostMatchEndEvent : HookData
    ---@type HookType<PostMatchEndEvent>
    --- Called at the end of the post match stage.
    POST_MATCH_END = new_hook("post-match-end"),

    ---@class ReplayStartEvent : HookData
    ---@type HookType<ReplayStartEvent>
    --- Called when a replay starts.
    REPLAY_START = new_hook("replay-start"),

    ---@class ReplayFrameEvent : HookData
    ---@type HookType<ReplayFrameEvent>
    --- Called when a frame is entered during a replay.
    REPLAY_FRAME = new_hook("replay-frame"),

    ---@class ReplayEndEvent : HookData
    ---@type HookType<ReplayEndEvent>
    --- Called when a replay ends.
    REPLAY_END = new_hook("replay-end"),

    ---@class WindowResizeEvent : HookData
    ---@field new_size vec2 The new size of the window.
    ---@field old_size vec2 The old size of the window.
    ---@type HookType<WindowResizeEvent>
    --- Called whenever the window is resized.
    WINDOW_RESIZE = new_hook("window-resize"),

    ---@class Draw2DEvent : HookData
    ---@type HookType<Draw2DEvent>
    --- Called when the 2D drawing hook is called.
    DRAW_2D = new_hook("draw2d"),

    ---@class KeyDownEvent : HookData
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
    --local state = get_world_state()
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