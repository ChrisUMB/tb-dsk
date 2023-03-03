---@class raycast
raycast = {}

MAX_RAYCAST_BODIES = 512

-- Sets up the raycast system. This must be called before any raycast can be performed.
local function prepare_raycast(include_objects, include_joints, include_parts, convert_to_boxes)

    -- map of raycast bodies to either part, joint, or object
    local bodies = {}

    if include_objects then
        for i = 1, 128 do
            local obj = object.get(i - 1)
            if obj then
                local pos = obj:get_position()
                local rot = obj:get_rotation()
                local shape = obj:get_shape()
                local scale = obj:get_scale()

                if convert_to_boxes then
                    -- These multipliers are fucking magic numbers.
                    if shape == SHAPE.SPHERE then
                        scale = vec3(scale.x, scale.x, scale.x) * 2.0
                    end

                    if shape == SHAPE.CAPSULE then
                        scale = vec3(scale.x * 2, scale.x * 2, scale.y * 3)
                    end

                    shape = SHAPE.BOX
                end

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
---@param convert_to_boxes boolean|nil Whether to convert all shapes to boxes.
---@return object|joint|part|nil,number The object, joint, or part that was hit by the raycast, or nil, and the distance to the hit.
function raycast.screen(x, y, include_objects, include_joints, include_parts, convert_to_boxes)

    if not include_objects and not include_joints and not include_parts then
        -- What are you, stupid?
        return nil, 0
    end

    local bodies = prepare_raycast(include_objects, include_joints, include_parts, convert_to_boxes)
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