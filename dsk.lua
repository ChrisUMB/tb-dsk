-- [ Decap Scripting Kit ] --

--local s, e = pcall(function()
--    function println(...) end

dofile("dsk/util.lua")
dofile("dsk/delay.lua")
dofile("dsk/math/vec2.lua")
dofile("dsk/math/vec3.lua")
dofile("dsk/math/vec4.lua")
dofile("dsk/math/quat.lua")
dofile("dsk/math/mat4.lua")

dofile("dsk/metrics.lua")
dofile("dsk/constants.lua")

dofile("dsk/cmd.lua")
dofile("dsk/keyboard.lua")
dofile("dsk/events.lua")
dofile("dsk/fighter.lua")
dofile("dsk/objects.lua")
dofile("dsk/world.lua")
dofile("dsk/raycast.lua")
dofile("dsk/config.lua")

DSK = {} -- Just to know if DSK has been loaded.

--end)
--
--if not s then
--    if not echo then
--        print(tostring(e) .. "\n")
--    else
--        echo(tostring(e) .. "\n")
--    end
--    return
--end
--println("^72Decap Scripting Kit has been successfully initiated.")

-- [ Testing ] --

-- remove_hooks("dsk-test")

-- local f = io.open("replay/system/temp/temp.rpl", "w", true)
-- f:write("FUCk")
-- f:close()

-- local foot_pos = vec3(get_body_info(0, BODYPARTS.R_FOOT).pos)
-- local head_pos = vec3(get_body_info(1, BODYPARTS.HEAD).pos)

-- local dir = foot_pos:look_at(head_pos)

-- local velocity = 20.0
-- local force = dir * velocity
-- set_body_force(0, BODYPARTS.R_FOOT, force.x, force.y, force.z)


-- [ Shaking Orbs of Doom ] --
-- local object_count = 2

-- local origins = {}
-- for i = 0,object_count do
--     origins[i] = vec3(get_obj_pos(i))
-- end

-- add_hook("enter_frame", "dst-test", function() 
--     local state = get_world_state()
--     local frame = state.match_frame

--     local shake_start = 50
--     local shake_dur = 100
--     local shake_end = shake_start + shake_dur
--     for obj_index = 0,object_count do
--         local origin = origins[obj_index]

--         if frame > shake_start and frame < shake_end then
--             -- shake
--             local percent = (frame - shake_start) / shake_dur
--             local shake = 0.05 * percent

--             local offset = vec3(
--                 math.random() * 2.0 - 1.0,
--                 math.random() * 2.0 - 1.0,
--                 math.random()
--             ) * shake

--             local new_pos = origin + offset
--             set_obj_pos(obj_index, new_pos.x, new_pos.y, new_pos.z)

--         elseif frame == shake_end then
--             local s, e = pcall(function() 
--                 local part = BODYPARTS.HEAD
--                 local part_pos = vec3(get_body_info(0, part).pos)
--                 part_pos.z = part_pos.z + 1.0

--                 local dir = (part_pos - origin):normalize()
--                 local velocity = 1250
--                 local force = dir * velocity
--                 set_obj_force(obj_index, force.x, force.y, force.z)
--             end)

--             if not s then println(e) end

--         elseif frame < shake_end then
--             set_obj_pos(obj_index, origin.x, origin.y, origin.z)
--         end
--     end

--     for obj_index = 0,object_count do
--         local origin = vec3((obj_index * 0.5) - 3.0, 0, 0.225)

--         local z = math.sin(frame * 0.05 + obj_index * 0.4)

--         local pos = origin + vec3(0.0, 0.0, 1.0 + z)
--         set_obj_pos(obj_index, pos.x, pos.y, pos.z)
--         set_obj_force(obj_index, 0.0, 0.0, 1.0)
--     end

-- end)

-- local origin = {}
-- for i = 0,1 do
--     origin[i] = vec3(get_obj_pos(i))
-- end

-- add_hook("enter_frame", "dst-test", function() 
--     local state = get_world_state()
--     local frame = state.match_frame

--     for i=0,1 do
--         local pos = origin[i]
--         local new_pos = pos + vec3(0, 0, math.sin(frame * 0.1))
--         set_obj_pos(i, new_pos.x, new_pos.y, new_pos.z)
--     end

-- end)

--[ Environment Object Rumble ] --
-- add_hook("enter_frame", "dst-test", function() 
--     for i=0,4 do

--         local s, e = pcall(function() 
--             get_obj_pos(i)
--         end)

--         if s then
--             local status, error = pcall(function() 
--                 local rot = mat4(get_obj_rot(i)):to_quaternion()
--                 local v = vec3(math.random() * 2.0 - 1.0, math.random() * 2.0 - 1.0, math.random() * 2.0 - 1.0):normalize()

--                 local rotation = rot:rotate(math.random() * 0.01, v)
--                 local euler = rotation:to_euler()

--                 set_obj_rot(i, euler.x, euler.y, euler.z)
--             end)

--             if not status then println(error) end
--         end
--     end
-- end)

-- [ Camera Grid Step Functionality ] --
-- remove_hooks("dst-test")
-- local old_pos = vec3(get_camera_info().pos)
-- local grid_pos = vec3()

-- local delay = 0
-- add_hook("camera", "dst-test", function()
--     local s, e = pcall(function()
--         delay = delay - 1

--         if delay > 0 then
--             set_camera_pos(grid_pos.x, grid_pos.y, grid_pos.z) 
--             return 
--         end

--         local cam = get_camera_info()
--         local new_pos = vec3(cam.pos)

--         local delta_pos = new_pos - old_pos

--         if delta_pos:length_squared() < 0.005 then
--             set_camera_pos(old_pos.x, old_pos.y, old_pos.z)
--             return
--         end

--         local direction = delta_pos:normalize()

--         local step_direction = nil

--         local highest_dot = -1
--         for v in axis do
--             local l = v:dot(direction)
--             if l > highest_dot then
--                 highest_dot = l
--                 step_direction = v
--             end
--         end

--         grid_pos = grid_pos + step_direction * 0.25
--         new_pos = grid_pos
--         set_camera_pos(new_pos.x, new_pos.y, new_pos.z)
--         delay = 15
--         old_pos = new_pos
--     end)

--     if not s then 
--         println(e) 
--         remove_hooks("dst-test")
--     end
-- end)


-- local time = 0

-- remove_hooks("dst-test")
-- add_hook("draw3d", "dst-test", function()
--     local s, e = pcall(function() 

--         -- local part = get_body_info(0, 0)

--         -- local part_pos = vec3(part.pos)
--         -- local part_rot = mat4(part.rot):to_quaternion()

--         -- local relative = part_rot:positive_z()
--         -- local rotated = part_rot:rotate(time / 20.0, relative):conjugate()

--         -- local positions = {
--         --     rotated:positive_y(), 
--         --     rotated:negative_y(), 
--         --     rotated:positive_x(), 
--         --     rotated:negative_x()
--         -- }

--         -- set_color(0.0, 0.33, 1.0, 0.5)
--         -- for i=1,#positions do
--         --     local pos = positions[i] / 2.0
--         --     draw_sphere(pos.x + part_pos.x, pos.y + part_pos.y, pos.z + part_pos.z, 0.1)
--         -- end

--         -- local pos = rotated:positive_y() / 2


--         --[ Lock Object Position to in front of Tori's Face ] --
--         local part = get_body_info(0, 0)
--         local part_pos = vec3(part.pos)
--         local part_rot = mat4(part.rot):to_quaternion()
--         local obj_pos = vec3(get_obj_pos(0))
--         local obj_rot = mat4(get_obj_rot(0)):to_quaternion()

--         local p = part_rot:negative_y()

--         set_obj_pos(0, part_pos.x + p.x, part_pos.y + p.y, part_pos.z + p.z)
--         local euler = obj_rot:conjugate():to_euler()
--         set_obj_rot(0, euler.x, euler.y, euler.z)
--         set_obj_force(0, 0, 0, 0)
--         set_obj_mass(0, 10000)

--         time = time + 1
--     end)

--     if not s then
--         println(e)
--         remove_hooks("dst-test")
--     end
-- end)

-- local q = quat(0.0, 0.0, 0.0, 1.0)
-- local t = 0

-- remove_hooks("dst-test")
-- add_hook("draw3d", "dst-test", function()
--     local s, e = pcall(function() 
--         local a = math.sin(t * 0.01) * 0.1
--         q = q:rotate(a, vec3(0, 0, 1))

--         local matrix = mat4(q)

--         set_color(0.0, 0.33, 1.0, 1.0)
--         draw_box_m(0.0, 0.0, 1.0, 0.5, 0.5, 0.5, matrix:to_tb_matrix())
--     end)

--     if not s then
--         println(e)
--         remove_hooks("dst-test")
--     end

--     t = t + 1

-- local pos = vec3(1.0, -0.1, 4.5)

-- local pos_x = q:positive_x() + pos
-- local neg_x = q:negative_x() + pos

-- local pos_y = q:positive_y() + pos
-- local neg_y = q:negative_y() + pos

-- local pos_z = q:positive_z() + pos
-- local neg_z = q:negative_z() + pos

-- set_color(1.0, 0.5, 0.5, 1.0)
-- draw_sphere(pos_x.x, pos_x.y, pos_x.z, 0.1)

-- set_color(0.0, 0.5, 0.5, 1.0)
-- draw_sphere(neg_x.x, neg_x.y, neg_x.z, 0.1)

-- set_color(0.5, 1.0, 0.5, 1.0)
-- draw_sphere(pos_y.x, pos_y.y, pos_y.z, 0.1)

-- set_color(0.5, 0.0, 0.5, 1.0)
-- draw_sphere(neg_y.x, neg_y.y, neg_y.z, 0.1)

-- set_color(0.5, 0.5, 1.0, 1.0)
-- draw_sphere(pos_z.x, pos_z.y, pos_z.z, 0.1)

-- set_color(0.5, 0.5, 0.0, 1.0)
-- draw_sphere(neg_z.x, neg_z.y, neg_z.z, 0.1)
-- t = t + 1
-- end)