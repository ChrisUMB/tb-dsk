--dofile("dsk/dsk.lua")
dofile("dsk/util.lua")
dofile("dsk/math/vec2.lua")
dofile("dsk/math/vec3.lua")
dofile("dsk/math/vec4.lua")
dofile("dsk/math/quat.lua")
dofile("dsk/math/mat4.lua")

-- colors is a table of colors (as tables of floats 0-1)
-- {{r, g, b}, {r, g, b}, ... }
local function export_ppm_image(colors, width, height)
    local f = io.open("temp.ppm", "w", true)
    f:write("P3\n")
    f:write(width .. " " .. height .. "\n")
    f:write("255\n")
    for y = 1, height do
        for x = 1, width do
            local color = colors[(y-1)*width + x]
            local r = math.floor(color[1] * 255)
            local g = math.floor(color[2] * 255)
            local b = math.floor(color[3] * 255)
            f:write(string.format("%d %d %d ", r, g, b))
        end
        f:write("\n")
    end
end

local function rand()
    return math.random() * 2.0 - 1.0
end

local function format_vector(vec)
    return string.format("(%.3f %.3f %.3f)", vec.x, vec.y, vec.z)
end

--function quaternionFromForward(forward)
--    -- Check if forward is nil or has zero length
--    if not forward --[[or #forward == 0]] then
--        return nil
--    end
--
--    -- Choose an arbitrary up vector that is not parallel to forward
--    local up = {0, 1, 0}
--    if math.abs(forward[2]) > 0.99 then
--        up = {1, 0, 0}
--    end
--
--    -- Calculate the right vector by taking the cross product of forward and up
--    local right = {forward[2] * up[3] - forward[3] * up[2],
--                   forward[3] * up[1] - forward[1] * up[3],
--                   forward[1] * up[2] - forward[2] * up[1]}
--
--    -- Normalize the right vector
--    local length = math.sqrt(right[1]^2 + right[2]^2 + right[3]^2)
--    right = {right[1]/length, right[2]/length, right[3]/length}
--
--    -- Calculate the up vector by taking the cross product of right and forward
--    up = {right[2] * forward[3] - right[3] * forward[2],
--          right[3] * forward[1] - right[1] * forward[3],
--          right[1] * forward[2] - right[2] * forward[1]}
--
--    -- Calculate the w, x, y, z components of the quaternion
--    local w = math.sqrt(1 + right[1] + up[2] + forward[3]) / 2
--    local x = (up[3] - forward[2]) / (4*w)
--    local y = (forward[1] - right[3]) / (4*w)
--    local z = (right[2] - up[1]) / (4*w)
--
--    -- Return the quaternion as a table
--    return {w, x, y, z}
--end

--[[
    local tr = right.x + up.y + forward.z

    if tr > 0 then
        local S = math.sqrt(tr + 1.0) * 2
        return quat((up.z - forward.y) / S, (forward.x - right.z) / S, (right.y - up.x) / S, 0.25 * S)
    elseif ((right.x > up.y) and (right.x > forward.z)) then
        local S = math.sqrt(1.0 + right.x - up.y - forward.z) * 2
        return quat(0.25 * S, (up.x + right.y) / S, (forward.x + right.z) / S, (up.z - forward.y) / S)
    elseif up.y > forward.z then
        local S = math.sqrt(1.0 + up.y - right.x - forward.z) * 2
        return quat((up.x + right.y) / S, 0.25 * S, (forward.y + up.z) / S, (forward.x - right.z) / S)
    else
        local S = math.sqrt(1.0 + forward.z - right.x - up.y) * 2
        return quat((forward.x + right.z) / S, (forward.y + up.z) / S, 0.25 * S, (right.y - up.x) / S)
    end
]]

---@param forward vec3
function quaternionFromForward(forward)
    if forward:length_squared() == 0.0 then
        return quat()
    end

    forward = forward:normalize()

    local right = vec3(0,0,1)
    if right:dot(forward) > 0.9 then
        right = vec3(1,0,0)
    end

    right = forward:cross(right):normalize()
    local up = forward:cross(right):normalize()

    local m = mat4()
    m.m00 = right.x
    m.m10 = right.y
    m.m20 = right.z
    m.m01 = up.x
    m.m11 = up.y
    m.m21 = up.z
    m.m02 = forward.x
    m.m12 = forward.y
    m.m22 = forward.z

    return m:to_quaternion()
end


--local sum_dot = 0.0
--
--for i = 1,100 do
--    local original_forward = vec3(rand(), rand(), rand()):normalize()
--    --local q = quat.from_forward(original_forward)
--
--    local q_tbl = quaternionFromForward(original_forward)
--    local q = quat(q_tbl[2], q_tbl[3], q_tbl[4], q_tbl[1])
--
--    local new_forward = q:positive_z()
--    print(format_vector(original_forward) .. " -> " .. format_vector(new_forward))
--    local dot = original_forward:dot(new_forward)
--    sum_dot = sum_dot + dot
--end
--
--local average_dot = sum_dot / 100.0
--println("average dot: " .. average_dot)

local count = 0
local sum_dot = 0.0

local dim = 50
local image_width = dim*dim
local image_height = dim*2

local colors = {}
for x=1,dim do
    for y=1,dim do
        for z=1,dim do
            local fx = ((x - 1.0)/(dim - 1.0)) * 2.0 - 1.0
            local fy = ((y - 1.0)/(dim - 1.0)) * 2.0 - 1.0
            local fz = ((z - 1.0)/(dim - 1.0)) * 2.0 - 1.0

            local original_forward = vec3(fx, fy, fz):normalize()

            --print(format_vector(original_forward))
            --local length = original_forward:length()
            --if length <= 1.0 then
            --local q_tbl = quaternionFromForward(original_forward)
            --local q = quat(q_tbl[2], q_tbl[3], q_tbl[4], q_tbl[1])
            local q = quaternionFromForward(original_forward)

            local new_forward = q:positive_z()
            --local color = {new_forward.x * 0.5 + 0.5, new_forward.y * 0.5 + 0.5, new_forward.z * 0.5 + 0.5}
            --local color = {original_forward.x * 0.5 + 0.5, original_forward.y * 0.5 + 0.5, original_forward.z * 0.5 + 0.5}

            local dot = original_forward:dot(new_forward)
            sum_dot = sum_dot + dot
            count = count + 1

            --local shade = dot * 0.5 + 0.5
            --colors[(y-1)*100 + x] = {shade, shade, shade}

            --local color = nil
            --if dot < 0.0 then
            --    color = {-dot, 1 + dot, 0}
            --else
            --    color = {1 - dot, dot, 0}
            --end

            -- Z slices along the X axis
            local image_x = x + dim * (z-1)
            local image_y = y

            local color1 = original_forward * 0.5 + 0.5
            colors[(image_y-1)*image_width + image_x] = { color1.x, color1.y, color1.z }

            local color2 = new_forward * 0.5 + 0.5
            image_y = y + dim
            colors[(image_y-1)*image_width + image_x] = { color2.x, color2.y, color2.z }

            --else
            --    colors[(y-1)*100 + x] = {1, 0, 0}
            --end
        end
    end
end

local average_dot = sum_dot / count
println("average dot: " .. average_dot)

export_ppm_image(colors, image_width, image_height)
print("done")

print(vec3(0,0,1):dot(vec3(1,0,0)))
print(vec3(0,0,1):dot(vec3(0,1,0)))
print(vec3(0,0,1):dot(vec3(0,0,1)))