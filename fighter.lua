-- [ Decap Scripting Kit ] --

--[[
    fighter.lua is meant to help streamline fighter accessing and manipulating.
    It wraps the usually available methods into one place with consistent
    naming conventions and math library wrapped return values to make
    interfacing with parts, joints, dismemberments, et cetera easier.

    IMPORTANT: Remember, everything throughout DSK is meant to be one-indexed.
    This is to follow the pattern of Lua, a one-indexed programming language.
    If you forget or get confused, check out "constants.lua" as it has useful
    global variables like TORI, UKE, and some tables like JOINT, PART so that
    you don't have to think back and forth about what should be zero-indexed
    and what should be one-indexed.

    "fighter" is just a term for the body that either uke or tori controls.
    Getting an instance of a fighter is as simple as:
        local uke = fighter.get(UKE)
        uke:get_joint(...)

    This fighter instance is littered with utility and functionality found
    in other places in the Toribash scripting SDK, like joint/body part
    manipulation, dismemberments, fractures, et cetera. These instances
    are primarily just tables full of functions for interfacing with
    Toribash's built in functions to do so, but just in a more
    streamlined fashion that automatically converts all mathematical
    values like their matrix rotations and table vectors to our
    mathematical representations quat(), vec3(), et cetera.

    Furthermore, we have instanced tables representing joints and parts,
    each containing every utility/necessary method reasonable for any
    form of manipulation or reading that might be needed.
]]

joint = {}

function joint:__index(name)
    return rawget(joint, name)
end

function joint.get(fighter_id, joint_id)
    --if fighter_id ~= TORI_ID and fighter_id ~= UKE_ID then
    --    assert("joint.get(fighter_id, joint_id) received an invalid fighter ID: " .. tostring(fighter_id))
    --    return nil
    --end

    if joint_id < 1 or joint_id > 20 then
        assert("joint.get(fighter_id, joint_id) received an invalid joint ID: " .. tostring(joint_id))
        return nil
    end

    local result = {
        fighter_id = fighter_id,
        joint_id = joint_id
    }
    
    setmetatable(result, joint)
    return result
end

function joint:get_position()
    if self == joint then
        assert("joint:get_position() illegally called statically.")
        return nil
    end

    return vec3(get_joint_pos(self.fighter_id - 1, self.joint_id - 1))
end

function joint:set_position(...)
    if self == joint then
        assert("joint:set_position(...) illegally called statically.")
        return
    end

    local position = vec3(...)
    set_joint_pos(self.fighter_id - 1, self.joint_id - 1, position.x, position.y, position.z)
end

function joint:get_screen_position()
    if self == joint then
        assert("joint:get_screen_position() illegally called statically.")
        return
    end

    return vec3(get_joint_screen_pos(self.fighter_id - 1, self.joint_id - 1))
end

function joint:dismember()
    if self == joint then
        assert("joint:dismember() illegally called statically.")
        return
    end

    dismember_joint(self.fighter_id - 1, self.joint_id - 1)
end

function joint:is_dismembered()
    if self == joint then
        assert("joint:is_dismembered() illegally called statically.")
        return
    end

    return get_joint_dismember(self.fighter_id - 1, self.joint_id - 1)
end

function joint:fracture()
    if self == joint then
        assert("joint:fracture() illegally called statically.")
        return
    end

    fracture_joint(self.fighter_id - 1, self.joint_id - 1)
end

function joint:is_fractured()
    if self == joint then
        assert("joint:is_fractured() illegally called statically.")
        return
    end

    return get_joint_fracture(self.fighter_id - 1, self.joint_id - 1)
end

function joint:get_state()
    if self == joint then
        assert("joint:get_state() illegally called statically.")
        return
    end

    return get_joint_info(self.fighter_id - 1, self.joint_id - 1).state
end

function joint:get_name()
    return JOINT.ID[self.joint_id]
end

part = {}

function part:__index(name)
    return rawget(part, name)
end

function part.get(fighter_id, part_id)
    --if fighter_id ~= TORI_ID and fighter_id ~= UKE_ID then
    --    assert("part.get(fighter_id, part_id) received an invalid fighter ID: " .. tostring(fighter_id))
    --    return nil
    --end

    if part_id < 1 or part_id > 21 then
        assert("part.get(fighter_id, part_id) received an invalid part ID: " .. tostring(part_id))
        return nil
    end
    
    local result = {
        fighter_id = fighter_id,
        part_id = part_id
    }

    setmetatable(result, part)
    return result
end

function part:get_position()
    if self == part then
        assert("part:get_position() illegally called statically.")
        return nil
    end

    return vec3(get_body_info(self.fighter_id - 1, self.part_id - 1).pos)
end

function part:set_position(...)
    if self == part then
        assert("part:set_position(...) illegally called statically.")
        return nil
    end

    local position = vec3(...)
    set_body_pos(self.fighter_id - 1, self.part_id - 1, position.x, position.y, position.z)
end

function part:translate_position(...)
    if self == part then
        assert("part:translate_position(...) illegally called statically.")
        return nil
    end

    local offset = vec3(...)
    self:set_position(self:get_position() + offset)
end

function part:get_screen_position()
    if self == part then
        assert("part:get_screen_position() illegally called statically.")
        return nil
    end

    return vec3(get_body_screen_pos(self.fighter_id - 1, self.part_id - 1))
end

function part:get_rotation()
    if self == part then
        assert("part:get_rotation() illegally called statically.")
        return nil
    end

    return mat4(get_body_info(self.fighter_id - 1, self.part_id - 1).rot):to_quaternion()
end

function part:set_rotation(...)
    if self == part then
        assert("part:set_rotation(...) illegally called statically.")
        return nil
    end

    local rotation = quat(...)
    set_body_rotation_m(self.fighter_id - 1, self.part_id - 1, mat4(rotation):to_tb_matrix())
end

function part:rotate(...)
    if self == part then
        assert("part:rotate(...) illegally called statically.")
        return nil
    end

    local rotation = quat(...)
    local current_rotation = self:get_rotation()
    local new_rotation = current_rotation * rotation
    self:set_rotation(new_rotation)
end

function part:get_angular_velocity()
    if self == part then
        assert("part:get_angular_velocity() illegally called statically.")
        return nil
    end

    return vec3(get_body_angular_vel(self.fighter_id - 1, self.part_id - 1))
end

function part:set_angular_velocity(...)
    if self == part then
        assert("part:set_angular_velocity(...) illegally called statically.")
        return nil
    end

    local velocity = vec3(...)
    set_body_angular_vel(self.fighter_id - 1, self.part_id - 1, velocity.x, velocity.y, velocity.z)
end

function part:get_linear_velocity()
    if self == part then
        assert("part:get_linear_velocity() illegally called statically.")
        return nil
    end

    return vec3(get_body_linear_vel(self.fighter_id - 1, self.part_id - 1))
end

function part:set_linear_velocity(...)
    if self == part then
        assert("part:set_linear_velocity(...) illegally called statically.")
        return nil
    end

    local velocity = vec3(...)
    set_body_linear_vel(self.fighter_id - 1, self.part_id - 1, velocity.x, velocity.y, velocity.z)
end

function part:set_force(...)
    if self == part then
        assert("part:set_force(...) illegally called statically.")
        return nil
    end

    local force = vec3(...)
    set_body_force(self.fighter_id - 1, self.part_id - 1, force.x, force.y, force.z)
end

function part:get_id()
    return self.part_id
end

function part:get_name()
    return PART.ID[self.part_id]
end

---@class fighter
fighter = {}

function fighter:__index(name)
    return rawget(fighter, name)
end

function fighter.get(fighter_id)
    --TODO
    --if fighter_id ~= UKE_ID and fighter_id ~= TORI_ID then
    --    assert("fighter.get(fighter_id) received a value that wasn't " .. TORI .. " [tori] or " .. UKE .. " [uke]: " .. tostring(fighter_id) .. "")
    --    return nil
    --end

    local result = {
       fighter_id = fighter_id
    }

    setmetatable(result, fighter)
    return result
end

function fighter.tori()
    return fighter.get(TORI_ID)
end

function fighter.uke()
    return fighter.get(UKE_ID)
end

function fighter:get_score()
    if self == fighter then
        assert("fighter:get_score() illegally called statically.")
        return nil
    end

    return get_score(self.fighter_id - 1)
end

function fighter:get_grip(id_or_name)
    if self == fighter then
        assert("fighter:get_grip(id_or_name) illegally called statically.")
        return nil
    end

    if id_or_name == nil then
        assert("fighter:get_grip(id_or_name) received a value that was nil.")
        return nil
    end

    local part_id = nil

    local type = type(id_or_name)

    if type == "number" then
        part_id = id_or_name
    elseif type == "string" then
        part_id = PART.NAME[id_or_name]
    else
        assert("fighter:get_grip(id_or_name) did not receive a number or a string, instead: " .. tostring(type))
        return nil
    end

    if part_id == nil then
        assert("fighter:get_grip(id_or_name) somehow resolved to a nil id when passed: " .. tostring(id_or_name))
        return nil
    end

    return get_grip_info(self.fighter_id - 1, part_id - 1)
end

function fighter:get_part(id_or_name)
    if self == fighter then
        assert("fighter:get_part(id_or_name) illegally called statically.")
        return nil
    end

    if id_or_name == nil then
        assert("fighter:get_part(id_or_name) received a value that was nil.")
        return nil
    end

    local type = type(id_or_name)

    local part_id = nil

    if type == "number" then
        part_id = id_or_name
    elseif type == "string" then
        part_id = PART.NAME[id_or_name]
    else
        assert("fighter:get_part(id_or_name) did not receive a number or a string, instead: " .. tostring(type))
        return nil
    end

    if part_id == nil then
        assert("fighter:get_part(id_or_name) somehow resolved to a nil id when passed: " .. tostring(id_or_name))
        return nil
    end

    return part.get(self.fighter_id, part_id)
end

function fighter:get_parts()
    if self == fighter then
        assert("fighter:get_parts() illegally called statically.")
        return nil
    end

    local result = {}
    for id,name in pairs(PART.ID) do
        result[id] = self:get_part(id)
    end

    return result
end

function fighter:get_joint(id_or_name)
    if self == fighter then
        assert("fighter:get_joint(id_or_name) illegally called statically.")
        return nil
    end

    if id_or_name == nil then
        assert("fighter:get_joint(id_or_name) received a value that was nil.")
        return nil
    end

    local type = type(id_or_name)

    local joint_id = nil

    if type == "number" then
        joint_id = id_or_name
    elseif type == "string" then
        joint_id = JOINT.NAME[id_or_name]
    else
        assert("fighter:get_joint(id_or_name) did not receive a number or a string, instead: " .. tostring(type))
        return nil
    end

    if joint_id == nil then
        assert("fighter:get_joint(id_or_name) somehow resolved to a nil id when passed: " .. tostring(id_or_name))
        return nil
    end

    return joint.get(self.fighter_id, joint_id)
end

function fighter:get_joints()
    if self == fighter then
        assert("fighter:get_joints() illegally called statically.")
        return nil
    end

    local result = {}
    for id,name in pairs(PART.ID) do
        result[id] = self:get_joint(id)
    end

    return result
end

function fighter:set_position(...)
    if self == fighter then
        assert("fighter:set_position(...) illegally called statically.")
        return nil
    end

    local new_position = vec3(...)
    
    local origin = self:get_position()

    for id,name in pairs(PARTS.ID) do
        local part = self:get_part(id)
        local current_position = part:get_position()
        part:set_position((current_position - origin) + new_position)
    end
end

function fighter:get_position()
    if self == fighter then
        assert("fighter:get_position() illegally called statically.")
        return nil
    end

    local sum = vec3()
    for id,name in pairs(PARTS.ID) do
        sum = sum + self:get_part(id):get_position()
    end

    local origin = sum / #PARTS.ID
    return origin
end

function fighter:translate_position(...)
    if self == fighter then
        assert("fighter:translate_position(...) illegally called statically.")
        return nil
    end

    local offset = vec3(...)
    for id,name in pairs(PARTS.ID) do
        self:get_part(id):translate_position(offset)
    end
end

function fighter:get_rotation()
    -- TODO: AHHHHHHHHHHHHHHHHHHHHHHHHH
end

function fighter:set_rotation(...)

end

function fighter:set_force(...)
    if self == part then
        assert("fighter:set_force(...) illegally called statically.")
        return nil
    end

    local force = vec3(...)
    
    for id,name in pairs(PART.ID) do
        self:get_part(id):set_force(force)
    end
end

-- [ Testing ] --
--unlisten("fighter-test")
--
---- Create command "head_punch" that takes in an argument "force"
--function cmd.head_punch(args, force)
--    -- Grab an instance of uke/tori fighters
--    local uke = fighter.uke()
--    local tori = fighter.tori()
--
--    -- Get the head and head position of uke
--    local head = uke:get_part("HEAD")
--    local head_pos = head:get_position()
--
--    -- Get the left hand and left hand position of tori
--    local l_hand = tori:get_part("L_HAND")
--    local l_hand_pos = l_hand:get_position()
--
--    -- Get the vector that represents the direction from l_hand_pos to head_pos
--    local direction = l_hand_pos:look_at(head_pos)
--    -- Convert the command argument to a number.s
--    local force = tonumber(force)
--
--    -- Get the left wrist of tori and dismember it so we can send it flying
--    local l_wrist = tori:get_joint("L_WRIST")
--    l_wrist:dismember()
--
--    -- Set the left hand force to the direction * force, throwing the hand at
--    -- uke's face.
--    l_hand:set_force(direction * force)
--end