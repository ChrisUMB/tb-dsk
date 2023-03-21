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
    ---@class NewGameEvent : HookData
    ---@type HookType<NewGameEvent>
    --- Called on new game or world initialization
    NEW_GAME = new_hook("new_game"),

    ---@class NewMPGameEvent : HookData
    ---@type HookType<NewMPGameEvent>
    --- Called when user joins a multiplayer room
    NEW_MP_GAME = new_hook("new_mp_game"),

    ---@class EnterFrameEvent : HookData
    ---@type HookType<EnterFrameEvent>
    --- Called in physics stepper before running frame events
    ENTER_FRAME = new_hook("enter_frame"),

    ---@class EndGameEvent : HookData
    ---@field end_type number The type of end game.
    ---@type HookType<EndGameEvent>
    --- Called on game end
    END_GAME = new_hook("end_game"),

    ---@class LeaveGameEvent : HookData
    ---@type HookType<LeaveGameEvent>
    --- Called before leaving current game. May be triggered before new game, on replay load, etc.
    LEAVE_GAME = new_hook("leave_game"),

    ---@class EnterFreezeEvent : HookData
    ---@type HookType<EnterFreezeEvent>
    --- Called when we enter edit mode during the fight
    ENTER_FREEZE = new_hook("enter_freeze"),

    ---@class ExitFreezeEvent : HookData
    ---@type HookType<ExitFreezeEvent>
    --- Called when we exit edit mode during the fight
    EXIT_FREEZE = new_hook("exit_freeze"),

    ---@class PlayerSelectEvent : HookData
    ---@field player number The player that was selected.
    ---@type HookType<PlayerSelectEvent>
    --- Called when a new player is selected (including empty player selection)
    PLAYER_SELECT = new_hook("player_select"),

    ---@class SpecSelectPlayerEvent : HookData
    ---@field player number The player that was selected.
    ---@field body number The body part of the player that was selected.
    ---@field joint number The joint of the player that was selected.
    ---@type HookType<SpecSelectPlayerEvent>
    --- Called when clicking on a player while being a spectator in Multiplayer
    SPEC_SELECT_PLAYER = new_hook("spec_select_player"),

    ---@class Draw2dEvent : HookData
    ---@type HookType<Draw2dEvent>
    --- Main 2D graphics loop
    DRAW_2D = new_hook("draw2d"),

    ---@class Draw3dEvent : HookData
    ---@type HookType<Draw3dEvent>
    --- Main 3D graphics loop
    DRAW_3D = new_hook("draw3d"),

    ---@class PlayEvent : HookData
    ---@type HookType<PlayEvent>
    --- Part of the old Torishop, deprecated
    PLAY = new_hook("play"),

    ---@class MatchBeginEvent : HookData
    ---@type HookType<MatchBeginEvent>
    --- Called shortly before the new game
    MATCH_BEGIN = new_hook("match_begin"),

    ---@class KeyUpEvent : HookData
    ---@field key number The key that was released.
    ---@field scancode number The scancode of the key that was released.
    --- Returns a number indicating whether the event should be discarded.
    ---@type HookType<KeyUpEvent>
    --- Called on keyboard key up event
    KEY_UP = new_hook("key-up"),

    ---@class KeyDownEvent : HookData
    ---@field key number The key that was pressed.
    ---@field scancode number The scancode of the key that was pressed.
    --- Returns a number indicating whether the event should be discarded.
    ---@type HookType<KeyDownEvent>
    --- Called on keyboard key down event
    KEY_DOWN = new_hook("key-down"),

    ---@class MouseButtonUpEvent : HookData
    ---@field button number The mouse button that was released.
    ---@field x number The x coordinate of the mouse.
    ---@field y number The y coordinate of the mouse.
    --- Returns a number indicating whether the event should be discarded.
    ---@type HookType<MouseButtonUpEvent>
    --- Called on mouse button / touch up event
    MOUSE_BUTTON_UP = new_hook("mouse-button-up"),

    ---@class MouseButtonDownEvent : HookData
    ---@field button number The mouse button that was pressed.
    ---@field x number The x coordinate of the mouse.
    ---@field y number The y coordinate of the mouse.
    --- Returns a number indicating whether the event should be discarded.
    ---@type HookType<MouseButtonDownEvent>
    --- Called on mouse button / touch down event
    MOUSE_BUTTON_DOWN = new_hook("mouse-button-down"),

    ---@class MouseMoveEvent : HookData
    ---@field x number The x coordinate of the mouse.
    ---@field y number The y coordinate of the mouse.
    --- Returns a number indicating whether the event should be discarded.
    ---@type HookType<MouseMoveEvent>
    --- Called on mouse move / swipe event
    MOUSE_MOVE = new_hook("mouse-move"),

    ---@class JointSelectEvent : HookData
    ---@field player number The player that was selected.
    ---@field joint number The joint of the player that was selected.
    ---@type HookType<JointSelectEvent>
    --- Called when new joint is selected (including empty joint selection)
    JOINT_SELECT = new_hook("joint_select"),

    ---@class BodySelectEvent : HookData
    ---@field player number The player that was selected.
    ---@field body number The body part of the player that was selected.
    ---@type HookType<BodySelectEvent>
    --- Called when new bodypart is selected (including empty bodypart selection)
    BODY_SELECT = new_hook("body_select"),

    ---@class KeyHoldEvent : HookData
    ---@field key number The key that is being held.
    ---@field scancode number The scancode of the key that is being held.
    --- Returns a number indicating whether the event should be discarded.
    ---@type HookType<KeyHoldEvent>
    --- Called when holding a keyboard key
    KEY_HOLD = new_hook("key-hold"),

    ---@class ConsoleEvent : HookData
    ---@field s string The message that was received.
    ---@field type number The type of message.
    ---@field tab number The tab the message was sent to.
    --- Returns a number indicating whether the event should be discarded.
    ---@type HookType<ConsoleEvent>
    --- Called when chat receives a new message
    CONSOLE = new_hook("console"),

    ---@class CommandEvent : HookData
    ---@field command string The command that was entered.
    --- Returns a number indicating whether the event should be discarded.
    ---@type HookType<CommandEvent>
    --- Called when an unused /command is entered
    COMMAND = new_hook("command"),

    ---@class CameraEvent : HookData
    ---@type HookType<CameraEvent>
    --- Main camera loop
    CAMERA = new_hook("camera"),

    ---@class ConsolePostEvent : HookData
    ---@field msg string The message that was received.
    ---@field type number The type of message.
    ---@field tab number The tab the message was sent to.
    ---@type HookType<ConsolePostEvent>
    --- Called after a non-discarded console hook call
    CONSOLE_POST = new_hook("console_post"),

    ---@class TextInputEvent : HookData
    ---@field text string The text that was input.
    ---@type HookType<TextInputEvent>
    --- Called when text input event is received
    TEXT_INPUT = new_hook("text_input"),

    ---@class PostDraw3dEvent : HookData
    ---@type HookType<PostDraw3dEvent>
    --- Additional 3D graphics loop, executed after all other drawing is done
    POST_DRAW_3D = new_hook("post_draw3d"),

    ---@class DrawViewportEvent : HookData
    ---@type HookType<DrawViewportEvent>
    --- Main viewport graphics loop
    DRAW_VIEWPORT = new_hook("draw_viewport"),

    ---@class PreDrawEvent : HookData
    ---@type HookType<PreDrawEvent>
    --- Called before any other drawing callbacks
    PRE_DRAW = new_hook("pre_draw"),

    ---@class NewGameMPEvent : HookData
    ---@type HookType<NewGameMPEvent>
    --- Called on new multiplayer game
    NEW_GAME_MP = new_hook("new_game_mp"),

    ---@class NetworkCompleteEvent : HookData
    ---@type HookType<NetworkCompleteEvent>
    --- Called on successful network request completion
    NETWORK_COMPLETE = new_hook("network_complete"),

    ---@class NetworkErrorEvent : HookData
    ---@type HookType<NetworkErrorEvent>
    --- Called on network request error
    NETWORK_ERROR = new_hook("network_error"),

    ---@class DownloaderCompleteEvent : HookData
    ---@field filename string The name of the file that finished downloading.
    ---@type HookType<DownloaderCompleteEvent>
    --- Called when a file from the queue has finished downloading
    DOWNLOADER_COMPLETE = new_hook("downloader_complete"),

    ---@class ReplayIntegrityFailEvent : HookData
    ---@field frame number The frame at which the replay hacking was detected.
    ---@type HookType<ReplayIntegrityFailEvent>
    --- Called when replay hacking is detected during replay playthrough with check_integrity mode enabled
    REPLAY_INTEGRITY_FAIL = new_hook("replay_integrity_fail"),

    ---@class FilebrowserSelectEvent : HookData
    ---@field filename string The name of the file that was selected.
    ---@type HookType<FilebrowserSelectEvent>
    --- Called on platform-specific file browser exit
    FILEBROWSER_SELECT = new_hook("filebrowser_select"),

    ---@class ModTriggerEvent : HookData
    ---@field p1 number The first parameter of the mod trigger.
    ---@field p2 number The second parameter of the mod trigger.
    ---@field b1 number The third parameter of the mod trigger.
    ---@field b2 number The fourth parameter of the mod trigger.
    ---@type HookType<ModTriggerEvent>
    --- Called when a mod trigger is invoked
    MOD_TRIGGER = new_hook("mod_trigger"),

    ---@class ResolutionChangedEvent : HookData
    ---@type HookType<ResolutionChangedEvent>
    --- Called when game resolution is updated
    RESOLUTION_CHANGED = new_hook("resolution_changed"),

    ---@class UnloadEvent : HookData
    ---@type HookType<UnloadEvent>
    --- Called on loading a new script
    UNLOAD = new_hook("unload"),

    ---@class BoutMouseDownEvent : HookData
    ---@field i number The index of the bout in the list.
    ---@type HookType<BoutMouseDownEvent>
    --- Called on mouse button down event for room queue bout list
    BOUT_MOUSE_DOWN = new_hook("bout_mouse_down"),

    ---@class BoutMouseUpEvent : HookData
    ---@field i number The index of the bout in the list.
    ---@type HookType<BoutMouseUpEvent>
    --- Called on mouse button up event for room queue bout list
    BOUT_MOUSE_UP = new_hook("bout_mouse_up"),

    ---@class BoutMouseOverEvent : HookData
    ---@field i number The index of the bout in the list.
    ---@type HookType<BoutMouseOverEvent>
    --- deprecated
    BOUT_MOUSE_OVER = new_hook("bout_mouse_over"),

    ---@class BoutMouseOutsideEvent : HookData
    ---@field i number The index of the bout in the list.
    ---@type HookType<BoutMouseOutsideEvent>
    --- deprecated
    BOUT_MOUSE_OUTSIDE = new_hook("bout_mouse_outside"),

    ---@class SpecMouseDownEvent : HookData
    ---@field i number The index of the spectator in the list.
    ---@type HookType<SpecMouseDownEvent>
    --- Called on mouse button down event for room queue spec list
    SPEC_MOUSE_DOWN = new_hook("spec_mouse_down"),

    ---@class SpecMouseUpEvent : HookData
    ---@field i number The index of the spectator in the list.
    ---@type HookType<SpecMouseUpEvent>
    --- Called on mouse button up event for room queue spec list
    SPEC_MOUSE_UP = new_hook("spec_mouse_up"),

    ---@class SpecMouseOverEvent : HookData
    ---@field i number The index of the spectator in the list.
    ---@type HookType<SpecMouseOverEvent>
    --- deprecated
    SPEC_MOUSE_OVER = new_hook("spec_mouse_over"),

    ---@class SpecMouseOutsideEvent : HookData
    ---@field i number The index of the spectator in the list.
    ---@type HookType<SpecMouseOutsideEvent>
    --- deprecated
    SPEC_MOUSE_OUTSIDE = new_hook("spec_mouse_outside"),

    ---@class BoutUpdateEvent : HookData
    ---@type HookType<BoutUpdateEvent>
    --- Called after bout list update is finished
    BOUT_UPDATE = new_hook("bout_update"),

    ---@class SpecUpdateEvent : HookData
    ---@type HookType<SpecUpdateEvent>
    --- Called when spectator status update is received
    SPEC_UPDATE = new_hook("spec_update"),

    ---@class RoomlistUpdateEvent : HookData
    ---@field error string The error message, if any.
    ---@type HookType<RoomlistUpdateEvent>
    --- Called on room list info request completion
    ROOMLIST_UPDATE = new_hook("roomlist_update")
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
                --Hooks.POST_MATCH_END:call()
            end

            --Hooks.REPLAY_START:call()
        end
    end

    --Hooks.GAME_FRAME:call()
    Hooks.ENTER_FRAME:call()

    if not post_match_over and match_over then
        --Hooks.POST_MATCH_FRAME:call()
    elseif mode == MODE_REPLAY then
        --Hooks.REPLAY_FRAME:call()
    elseif mode == MODE_MATCH then
        --Hooks.MATCH_FRAME:call()
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

    --Hooks.REPLAY_END:call()
end)

add_hook("end_game", HOOK_ID, function()
    if match_over then
        return
    end
    match_over = true
    --Hooks.MATCH_END:call()
    --Hooks.POST_MATCH_START:call()
    Hooks.END_GAME:call()
end)

add_hook("match_begin", HOOK_ID, function()
    match_over = false
    post_match_over = false
    --Hooks.MATCH_START:call()
    Hooks.MATCH_BEGIN:call()
end)

add_hook("draw2d", HOOK_ID, function()
    Hooks.DRAW_2D:call()
end)

--Hooks.REPLAY_FRAME:listen("test", function()
--
--end)