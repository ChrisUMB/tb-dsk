-- [ Decap Scripting Kit ] --

--[[
    This is the world module, it's responsible for maintaining the state of the world.

    Data that it maintains includes;
        1. uke/tori data
            - all body positions/rotations/linear and angular velocity
            - all joint positions
            - all joint states
            - all joint damages
            - current score

        2. object data
            - object positions/rotations/linear and angular velocity

        3. turn/frame data
            - current frame
            - total frames
            - current turn

        4. state data
            - replay/match boolean
]]

-- This is the table responsible for maintaining information about the game.
-- Data like the uke/tori data will be stored, keyed by the frame, like:
-- frame_data[10].players = {...}

-- Similarly for world objects;
-- frame_data[10].objects = {...}

---@class fd_part Frame data body part
---@field position vec3 Position of the body part
---@field rotation quat Rotation of the body part
---@field angular_velocity vec3 Angular velocity of the body part
---@field linear_velocity vec3 Linear velocity of the body part

---@class fd_player Frame data player
---@field parts fd_part[] Body parts
---@field joints JointInfoState[] Joints

---@class fd_frame
---@field players fd_player[] Players

---@type fd_frame[] Frame data, keyed by frame index
local frame_data = {}

-- Unsure if this is needed or not.
-- local match_frame_data = {}
-- local replay_frame_data = {}

-- This will store data like game rules, winner, etc.
local world_data = {}

local function log_object_data(object_index, state, frame, table)
    local s, e = pcall(function()
        get_obj_pos(object_index)
    end)

    -- There's literally no other way to detect
    -- if an environment object actually exists.
    if not s then
        return
    end

    local object_data = {
        pos = vec3(get_obj_pos(object_index)),
        rot = mat4(get_obj_rot(object_index)):to_quaternion(),
        angvel = vec3(get_obj_angular_vel(object_index)),
        linvel = vec3(get_obj_linear_vel(object_index))
    }

    local table = table[frame] or {}
    local objects = table.objects or {}

    objects[object_index + 1] = object_data
    table.objects = objects
    table[frame] = table
end

local function log_player_data(player, state, frame)
    local player_data = {}

    ---@type fd_part[]
    local parts = {}

    local joints = {}
    local grips = {}

    local fighter = fighter.get(player + 1)
    for i, v in pairs(PART.NAME) do
        local part = fighter:get_part(i)

        parts[v] = {
            position = part:get_position(),
            rotation = part:get_rotation(),
            angular_velocity = part:get_angular_velocity(),
            linear_velocity = part:get_linear_velocity()
        }
    end

    local damages = nil

    for v = 0, 19 do
        local info = get_joint_info(player, v)
        local state = info.state

        if get_joint_dismember(player, v) then
            if damages == nil then
                damages = {}
            end
            damages[v] = 1
        elseif get_joint_fracture(player, v) then
            if damages == nil then
                damages = {}
            end
            damages[v] = 0
        end

        joints[v] = state
    end

    grips = { get_grip_info(player, 12), get_grip_info(player, 11) }

    player_data.parts = parts
    player_data.joints = joints

    player_data.score = get_score(player)

    local data = frame_data[frame] or {}
    if data.players == nil then
        data.players = {}
    end

    -- We have to apply these to the last frame.
    local last_frame_data = frame_data[frame - 1]

    if last_frame_data ~= nil then
        -- last_frame_data = last_frame_data.players or {}
        local last_player_data = last_frame_data.players or {}
        last_player_data[player + 1].grips = grips
        last_player_data[player + 1].damages = damages
        last_frame_data.players = last_player_data
        frame_data[frame - 1] = last_frame_data
    end

    local new_data = frame_data[frame] or {}
    local players = new_data.players or {}
    players[player + 1] = player_data
    new_data.players = players
    frame_data[frame] = new_data
end

---@class world World data class, contains all the data about the world.
world = {}

---@param frame number|nil Frame to get data for
---@return fd_frame|nil Frame data for the given frame, or the last frame if no frame is given. Returns nil if no frame data is available.
function world.get_frame_data(frame)


    if not frame then
        frame = get_world_state().match_frame + 1
    end

    if frame < 1 then
        return nil
    end

    if frame > get_world_state().match_frame + 1 then
        return nil
    end

    return frame_data[frame]
end

local function log_match_frame()
    local state = get_world_state()
    local frame = state.match_frame


    for i = 1, state.num_players do
        log_player_data(i - 1, state, frame + 1, frame_data)
    end
end

listen("match-start", "dst-world", function(state)
    frame_data = {}
    world_data.game_rules = get_game_rules()
    log_match_frame()
end)

listen("match-frame", "dst-world", function(state)
    log_match_frame()
end)

-- We want the current frame to be logged when the script starts.
log_match_frame()

