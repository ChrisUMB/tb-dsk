-- [ Decap Scripting Kit ] --

--[[
    objects.lua provides access to environment objects, much like fighter.lua does.
    It wraps the standard lua methods for getting/setting environment object data
    with an object oriented design.

    Like everything else in DSK, this module is one-indexed. There are useful
    variables in constants.lua, like `MAX_ENV_OBJECTS` and `MAX_DYNAMIC_ENV_OBJECTS`.
    
    Accessing environment objects is as simple as:
        local obj = object.get(1)
        obj:set_pos(0, 0, 0)
]]

---@class object
---@field object_id number
object = {}

---@class SHAPE : number
---@field SPHERE SHAPE
---@field BOX SHAPE
---@field CAPSULE SHAPE
SHAPE = {
    SPHERE = 1,
    BOX = 2,
    CAPSULE = 3,
}

function object:__index(name)
    return rawget(object, name)
end

function object.get(object_id)
    if object_id < 1 or object_id > MAX_ENV_OBJECTS then
        assert("object.get(object_id): received an invalid object ID (out of bounds): " .. tostring(object_id))
        return nil
    end

    if get_obj_pos(object_id - 1) == nil then
        --assert("object.get(object_id): received an invalid object ID (non-existing): " .. tostring(object_id))
        return nil
    end

    local result = {
        object_id = object_id
    }

    setmetatable(result, object)
    return result
end

---@return SHAPE The shape of the object.
function object:get_shape()
    if self == object then
        assert("object:get_type() illegally called statically.")
        return nil
    end

    local _, y, z = get_obj_sides(self.object_id - 1)

    if y == 0 and z == 0 then
        return SHAPE.SPHERE
    end

    if z == 0 then
        return SHAPE.CAPSULE
    end

    return SHAPE.BOX
end

function object:get_position()
    if self == object then
        assert("object:get_position() illegally called statically.")
        return nil
    end

    return vec3(get_obj_pos(self.object_id - 1))
end

function object:set_position(...)
    if self == object then
        assert("object:set_position(...) illegally called statically.")
        return
    end

    local position = vec3(...)
    set_obj_pos(self.object_id - 1, position.x, position.y, position.z)
end

function object:get_rotation()
    if self == object then
        assert("object:get_rotation() illegally called statically.")
        return nil
    end

    return mat4(get_obj_rot(self.object_id - 1)):to_quaternion():conjugate()
end

function object:set_rotation(...)
    if self == object then
        assert("object:set_rotation(...) illegally called statically.")
        return
    end

    local rotation = quat(...)
    --set_obj_rot(self.object_id - 1, rotation.x, rotation.y, rotation.z, rotation.w)
    set_obj_rot_m(self.object_id - 1, mat4(rotation):to_tb_matrix())
end

function object:get_scale()
    if self == object then
        assert("object:get_scale() illegally called statically.")
        return nil
    end

    return vec3(get_obj_sides(self.object_id - 1))
end

function object:set_scale(...)
    if self == object then
        assert("object:set_scale(...) illegally called statically.")
        return
    end

    local scale = vec3(...)
    set_obj_sides(self.object_id - 1, scale.x, scale.y, scale.z)
end

function object:get_linear_velocity()
    if self == object then
        assert("object:get_linear_velocity() illegally called statically.")
        return nil
    end

    return vec3(get_obj_linear_vel(self.object_id - 1))
end

function object:set_linear_velocity(...)
    if self == object then
        assert("object:set_linear_velocity(...) illegally called statically.")
        return
    end

    local velocity = vec3(...)
    set_obj_linear_vel(self.object_id - 1, velocity.x, velocity.y, velocity.z)
end

function object:get_angular_velocity()
    if self == object then
        assert("object:get_angular_velocity() illegally called statically.")
        return nil
    end

    return vec3(get_obj_angular_vel(self.object_id - 1))
end

function object:set_angular_velocity(...)
    if self == object then
        assert("object:set_angular_velocity(...) illegally called statically.")
        return
    end

    local velocity = vec3(...)
    set_obj_angular_vel(self.object_id - 1, velocity.x, velocity.y, velocity.z)
end

function object:get_force()
    if self == object then
        assert("object:get_force() illegally called statically.")
        return nil
    end

    return vec3(get_obj_force(self.object_id - 1))
end

function object:set_force(...)
    if self == object then
        assert("object:set_force(...) illegally called statically.")
        return
    end

    local force = vec3(...)
    set_obj_force(self.object_id - 1, force.x, force.y, force.z)
end

--TODO: This doesn't work because get_obj_color doesn't exist yet.
function object:get_color()
    if self == object then
        assert("object:get_color() illegally called statically.")
        return nil
    end

    return vec4(get_obj_color(self.object_id - 1))
end

function object:set_color(...)
    if self == object then
        assert("object:set_color(...) illegally called statically.")
        return
    end

    local color = vec4(...)
    set_obj_color(self.object_id - 1, color.x, color.y, color.z, color.w)
end

function object:get_bounce()
    if self == object then
        assert("object:get_bounce() illegally called statically.")
        return nil
    end

    return get_obj_bounce(self.object_id - 1)
end

function object:set_bounce(bounce)
    if self == object then
        assert("object:set_bounce(bounce) illegally called statically.")
        return
    end

    set_obj_bounce(self.object_id - 1, bounce)
end

function object:get_flags()
    if self == object then
        assert("object:get_flags() illegally called statically.")
        return nil
    end

    return get_obj_flag(self.object_id - 1)
end

function object:set_flags(flags)
    if self == object then
        assert("object:set_flags(flags) illegally called statically.")
        return
    end

    set_obj_flag(self.object_id - 1, flags)
end
