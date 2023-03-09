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

---@class fd_fighter Frame data player
---@field parts fd_part[] Body parts
---@field joints JointInfoState[] Joints

---@class fd_frame
---@field players fd_fighter[] Players

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

local function log_player_data(player, frame)
    local player_data = world.get_fighter_data(fighter.get(player + 1))

    local current_frame_data = frame_data[frame] or {}
    if current_frame_data.players == nil then
        current_frame_data.players = {}
    end

    -- We have to apply these to the last frame.
    local last_frame_data = current_frame_data[frame - 1]

    if last_frame_data ~= nil then
        -- last_frame_data = last_frame_data.players or {}
        local last_player_data = last_frame_data.players or {}
        last_player_data[player + 1].grips = player_data.grips
        last_player_data[player + 1].damages = player_data.damages
        last_frame_data.players = last_player_data
        current_frame_data[frame - 1] = last_frame_data
    end

    local new_data = frame_data[frame] or {}
    local players = new_data.players or {}
    players[player + 1] = player_data
    new_data.players = players

    frame_data[frame] = new_data
end

---@class world World data class, contains all the data about the world.
world = {}

---@param fighter fighter Player index
---@return fd_fighter Fighter data
function world.get_fighter_data(fighter)
    local fighter_data = {}
    local part_data = {}

    local joints = {}
    local grips = {}

    for i, v in pairs(PART.NAME) do
        local part = fighter:get_part(i)

        part_data[v] = {
            position = part:get_position(),
            rotation = part:get_rotation(),
            angular_velocity = part:get_angular_velocity(),
            linear_velocity = part:get_linear_velocity()
        }
    end

    local damages = nil

    for i, v in pairs(JOINT.NAME) do
        local joint = fighter:get_joint(v)
        local state = joint:get_state()

        if joint:is_dismembered() then
            if damages == nil then
                damages = {}
            end
            damages[v] = 1
        elseif joint:is_fractured() then
            if damages == nil then
                damages = {}
            end
            damages[v] = 0
        end

        joints[v] = state
    end

    grips = { fighter:get_grip(PART.NAME.R_HAND), fighter:get_grip(PART.NAME.L_HAND) }

    fighter_data.parts = part_data
    fighter_data.joints = joints
    fighter_data.grips = grips
    fighter_data.damages = damages
    fighter_data.score = fighter:get_score()
    return fighter_data
end

function world.set_fighter_data(fighter, fighter_data)
    local player = fighter.fighter_id - 1
    for i, v in pairs(PART.NAME) do
        local part = fighter:get_part(v)
        local part_data = fighter_data.parts[v]

        part:set_position(part_data.position)
        part:set_rotation(part_data.rotation)
        part:set_angular_velocity(part_data.angular_velocity)
        part:set_linear_velocity(part_data.linear_velocity)
    end

    for i, v in pairs(JOINT.NAME) do
        if fighter_data.damages ~= nil then
            if fighter_data.damages[v] == 1 then
                set_joint_dismember(player, v - 1)
            elseif fighter_data.damages[v] == 0 then
                set_joint_fracture(player, v - 1)
            end
        end

        set_joint_state(player, v - 1, fighter_data.joints[v])
    end

    set_grip_info(player, 12, fighter_data.grips[1])
    set_grip_info(player, 11, fighter_data.grips[2])
end

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
        log_player_data(i - 1, frame + 1)
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
frame_data = {}
world_data.game_rules = get_game_rules()
log_match_frame()

