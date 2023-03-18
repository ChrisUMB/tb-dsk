---@class raycast
raycast = {}

MAX_RAYCAST_BODIES = 512

-- Sets up the raycast system. This must be called before any raycast can be performed.
local function prepare_raycast(include_objects, include_joints, include_parts)

    -- map of raycast bodies to either part, joint, or object
    local bodies = {}

    local player_count = get_world_state().num_players

    if include_joints then
        for i = 1, 20 do
            for p = 1, player_count do
                local joint = fighter.get(p):get_joint(i)
                local pos = joint:get_position()
                local radius = joint:get_radius()
                local scale = vec3(radius, radius, radius)
                local body = create_raycast_body(SHAPE.SPHERE - 1, pos.x, pos.y, pos.z, scale.x, scale.y, scale.z)
                bodies[body] = joint
            end
        end
    end

    if include_parts then
        for i = 1, 21 do
            for p = 1, player_count do
                local part = fighter.get(p):get_part(i)
                local pos = part:get_position()
                local rot = part:get_rotation()
                local shape = part:get_shape()
                local scale = part:get_scale()

                local body = create_raycast_body(shape - 1, pos.x, pos.y, pos.z, scale.x, scale.y, scale.z)
                set_raycast_body_rot_m(body, mat4(rot):to_tb_matrix())
                bodies[body] = part
            end
        end
    end

    if include_objects then
        for i = 1, 128 do
            local obj = object.get(i - 1)
            if obj then
                local pos = obj:get_position()
                local rot = obj:get_rotation()
                local shape = obj:get_shape()
                local scale = obj:get_scale()

                local body = create_raycast_body(shape - 1, pos.x, pos.y, pos.z, scale.x, scale.y, scale.z)
                set_raycast_body_rot_m(body, mat4(rot):to_tb_matrix())
                bodies[body] = obj
            end
        end
    end

    return bodies
end

---@param x number The X coordinate on the screen to shoot the ray from.
---@param y number The Y coordinate on the screen to shoot the ray from.
---@param include_objects boolean|nil Whether to include objects in the raycast.
---@param include_joints boolean|nil Whether to include joints in the raycast.
---@param include_parts boolean|nil Whether to include parts in the raycast.
---@return object|joint|part|nil,number The object, joint, or part that was hit by the raycast, or nil, and the distance to the hit.
function raycast.screen(x, y, include_objects, include_joints, include_parts)

    if not include_objects and not include_joints and not include_parts then
        -- What are you, stupid?
        return nil, 0
    end

    local bodies = prepare_raycast(include_objects, include_joints, include_parts)
    local body, distance = shoot_camera_ray(x, y, 100) -- Might make length configurable later

    for i = 0, MAX_RAYCAST_BODIES - 1 do
        if bodies[i] then
            destroy_raycast_body(i)
        end
    end

    if bodies[body] then
        return bodies[body], distance
    end

    return nil, 0
end