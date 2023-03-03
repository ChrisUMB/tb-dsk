-- [ Decap Scripting Kit ] --

--[[
    quat represents a Quaternion, a mathematical construct often used to represent rotations.
    This class comes with pretty much any math or utility function you might need. 
    
    Functions include:
    add, sub, mul, div, mod, negate, length/magnitude, normalize, dot, floor, ceil, round
    
    They can only be compared with ==

    For multiplicative purposes involving vec3, there is quat:mul_vec3(other).
]]

---@class quat A quaternion.
quat = {}

local components = { "x", "y", "z", "w" }

function quat:__index(name)
    if type(name) == "number" then
        name = components[name]
    end

    return rawget(self, name) or rawget(quat, name)
end

function quat:add(...)
    other = quat(...)
    return quat(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w)
end

function quat:__add(other)
    return self:add(other)
end

function quat:sub(...)
    local other = quat(...)
    return quat(self.x - other.x, self.y - other.y, self.z - other.z, self.w + other.w)
end

function quat:__sub(other)
    return self:sub(other)
end


--[[

public Quaternionf mul(Quaternionfc q, Quaternionf dest) {
        return dest.set(Math.fma(w, q.x(), Math.fma(x, q.w(), Math.fma(y, q.z(), -z * q.y()))),
                        Math.fma(w, q.y(), Math.fma(-x, q.z(), Math.fma(y, q.w(), z * q.x()))),
                        Math.fma(w, q.z(), Math.fma(x, q.y(), Math.fma(-y, q.x(), z * q.w()))),
                        Math.fma(w, q.w(), Math.fma(-x, q.x(), Math.fma(-y, q.y(), -z * q.z()))));
    }

    --]]

function quat:mul(...)
    local other = quat(...)
    local nx = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y
    local ny = self.w * other.y + self.y * other.w + self.z * other.x - self.x * other.z
    local nz = self.w * other.z + self.z * other.w + self.x * other.y - self.y * other.x
    local nw = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z
    return quat(nx, ny, nz, nw)
end


-- function quat:mul_vec3(...)
--     local other = vec3(...)
--     println(other)
--     --val nw = -self.x * other.x - self.y * other.y - self.z * other.z
--     local nw = -self.x * other.x - self.y * other.y - self.z * other.z
--     println("NW: " .. tostring(nw))
--     local nx = self.w * other.y + self.z * other.x - self.x * other.z
--     println("NX: " .. tostring(nx))
--     local ny = self.w * other.y + self.z * other.x - self.x * other.z
--     println("NY: " .. tostring(ny))
--     local nz = self.w * other.z + self.x * other.y - self.y * other.x
--     println("NZ: " .. tostring(nz))
--     local q = quat(nx, ny, nz, nw)
--     println("QUAT: " .. tostring(q))
--     return quat(nx, ny, nz, nw)
-- end

math.fma = function(a, b, c)
    return a * b + c
end

function quat:transform(...)
    local other = vec3(...)
    local x = other.x
    local y = other.y
    local z = other.z
    local xx = self.x * self.x
    local yy = self.y * self.y
    local zz = self.z * self.z
    local ww = self.w * self.w
    local xy = self.x * self.y
    local xz = self.x * self.z
    local yz = self.y * self.z
    local xw = self.x * self.w
    local zw = self.z * self.w
    local yw = self.y * self.w
    local k = 1.0 / (xx + yy + zz + ww)

    return vec3(
            math.fma((xx - yy - zz + ww) * k, x, math.fma(2.0 * (xy - zw) * k, y, (2.0 * (xz + yw) * k) * z)),
            math.fma(2.0 * (xy + zw) * k, x, math.fma((yy - xx - zz + ww) * k, y, (2.0 * (yz - xw) * k) * z)),
            math.fma(2.0 * (xz - yw) * k, x, math.fma(2.0 * (yz + xw) * k, y, ((zz - xx - yy + ww) * k) * z))
    )
end

function quat:__mul(other)
    return self:mul(other)
end

function quat:div(...)
    local other = quat(...)
    return self:mul(other:conjugate())
end

function quat:__div(other)
    return self:div(other)
end

function quat:mod(...)
    local other = quat(...)
    return quat(self.x % other.x, self.y % other.y, self.z % other.z, self.w % other.w)
end

function quat:__mod(other)
    return self:mod(other)
end

function quat:conjugate()
    return quat(-self.x, -self.y, -self.z, self.w)
end

function quat:length_squared()
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

function quat:length()
    return math.sqrt(self:length_squared())
end

function quat:normalize()
    local q_length = self:length()

    return quat(self.x / q_length, self.y / q_length, self.z / q_length, self.w / q_length)
end

function quat:set_normalized()
    local q_length = self:length()
    self.x = self.x / q_length
    self.y = self.y / q_length
    self.z = self.z / q_length
    self.w = self.w / q_length
    return self
end

--function quat:rotate(angle, ...)
--    local axis = vec3(...)
--    local n = axis:normalize()
--    local sh = math.sin(angle / 2.0)
--    local ch = math.cos(angle / 2.0)
--    return quat(n.x * sh, n.y * sh, n.z * sh, ch) * self
--end

--[[
 public Quaternionf rotateAxis(float angle, float axisX, float axisY, float axisZ, Quaternionf dest) {
        float hangle = angle / 2.0f;
        float sinAngle = Math.sin(hangle);
        float invVLength = Math.invsqrt(Math.fma(axisX, axisX, Math.fma(axisY, axisY, axisZ * axisZ)));
        float rx = axisX * invVLength * sinAngle;
        float ry = axisY * invVLength * sinAngle;
        float rz = axisZ * invVLength * sinAngle;
        float rw = Math.cosFromSin(sinAngle, hangle);
        return dest.set(Math.fma(this.w, rx, Math.fma(this.x, rw, Math.fma(this.y, rz, -this.z * ry))),
                        Math.fma(this.w, ry, Math.fma(-this.x, rz, Math.fma(this.y, rw, this.z * rx))),
                        Math.fma(this.w, rz, Math.fma(this.x, ry, Math.fma(-this.y, rx, this.z * rw))),
                        Math.fma(this.w, rw, Math.fma(-this.x, rx, Math.fma(-this.y, ry, -this.z * rz))));
    }
    --]]

function quat:rotate(angle, ...)
    local axis = vec3(...)
    local hangle = angle / 2.0
    local sin_angle = math.sin(hangle)
    local inv_v_length = 1.0 / math.sqrt(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z)
    local rx = axis.x * inv_v_length * sin_angle
    local ry = axis.y * inv_v_length * sin_angle
    local rz = axis.z * inv_v_length * sin_angle
    local rw = math.cos(hangle)
    return quat(
            math.fma(self.w, rx, math.fma(self.x, rw, math.fma(self.y, rz, -self.z * ry))),
            math.fma(self.w, ry, math.fma(-self.x, rz, math.fma(self.y, rw, self.z * rx))),
            math.fma(self.w, rz, math.fma(self.x, ry, math.fma(-self.y, rx, self.z * rw))),
            math.fma(self.w, rw, math.fma(-self.x, rx, math.fma(-self.y, ry, -self.z * rz)))
    )
end

function quat:to_euler()
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    local t0 = 2.0 * (w * x + y * z)
    local t1 = 1.0 - 2.0 * (x * x + y * y)
    local roll = math.atan(t0, t1)

    local t2 = 2.0 * (w * y - z * x)
    if t2 > 1.0 then
        t2 = 1.0
    elseif t2 < -1.0 then
        t2 = -1.0
    end

    local pitch = math.asin(t2)

    local t3 = 2.0 * (w * z + x * y)
    local t4 = 1.0 - 2.0 * (y * y + z * z)
    local yaw = math.atan(t3, t4)

    local dr = math.abs(roll - math.pi * 2)
    if dr < 0.001 then
        roll = 0
    end

    if math.abs(pitch - math.pi * 2) < 0.001 then
        pitch = 0
    end

    if math.abs(yaw - math.pi * 2) < 0.001 then
        yaw = 0
    end

    return vec3(roll, pitch, yaw)
end

function quat.from_euler(euler_angles)
    local yaw = euler_angles.z
    local pitch = euler_angles.y
    local roll = euler_angles.x

    local sr = math.sin(roll / 2)
    local cr = math.cos(roll / 2)
    local sp = math.sin(pitch / 2)
    local cp = math.cos(pitch / 2)
    local sy = math.sin(yaw / 2)
    local cy = math.cos(yaw / 2)

    local qx = sr * cp * cy - cr * sp * sy
    local qy = cr * sp * cy + sr * cp * sy
    local qz = cr * cp * sy - sr * sp * cy
    local qw = cr * cp * cy + sr * sp * sy

    return quat(qx, qy, qz, qw)
end

function quat:__unm()
    return self:conjugate()
end

function quat:equals(...)
    local other = quat(...)
    return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w
end

function quat:to_vec3()
    return vec3(self.x, self.y, self.z)
end

function quat:to_vec4()
    return vec4(self.x, self.y, self.z)
end

function quat:positive_z()
    return self:transform(0.0, 0.0, 1.0)
end

function quat:negative_z()
    return self:transform(0.0, 0.0, -1.0)
end

function quat:positive_y()
    return self:transform(0.0, 1.0, 0.0)
end

function quat:negative_y()
    return self:transform(0.0, -1.0, 0.0)
end

function quat:positive_x()
    return self:transform(1.0, 0.0, 0.0)
end

function quat:negative_x()
    return self:transform(-1.0, 0.0, 0.0)
end

function quat:__tostring()
    return "{x=" .. self.x .. ", y=" .. self.y .. ", z=" .. self.z .. ", w=" .. self.w .. "}"
end

function quat.rotation_between_vectors(start, dest)
    local n_start = start:normalize()
    local n_dest = dest:normalize()

    local cos_theta = n_start:dot(n_dest)
    local axis = n_start:cross(n_dest)

    local s = math.sqrt((1.0 + cos_theta) * 2.0)
    local inv_s = 1.0 / s

    return quat(axis.x * inv_s, axis.y * inv_s, axis.z * inv_s, s * 0.5)
end

--[[
public Quaternionf lookAlong(float dirX, float dirY, float dirZ, float upX, float upY, float upZ, Quaternionf dest) {
        // Normalize direction
        float invDirLength = Math.invsqrt(dirX * dirX + dirY * dirY + dirZ * dirZ);
        float dirnX = -dirX * invDirLength;
        float dirnY = -dirY * invDirLength;
        float dirnZ = -dirZ * invDirLength;
        // left = up x dir
        float leftX, leftY, leftZ;
        leftX = upY * dirnZ - upZ * dirnY;
        leftY = upZ * dirnX - upX * dirnZ;
        leftZ = upX * dirnY - upY * dirnX;
        // normalize left
        float invLeftLength = Math.invsqrt(leftX * leftX + leftY * leftY + leftZ * leftZ);
        leftX *= invLeftLength;
        leftY *= invLeftLength;
        leftZ *= invLeftLength;
        // up = direction x left
        float upnX = dirnY * leftZ - dirnZ * leftY;
        float upnY = dirnZ * leftX - dirnX * leftZ;
        float upnZ = dirnX * leftY - dirnY * leftX;

        /* Convert orthonormal basis vectors to quaternion */
        float x, y, z, w;
        double t;
        double tr = leftX + upnY + dirnZ;
        if (tr >= 0.0) {
            t = Math.sqrt(tr + 1.0);
            w = (float) (t * 0.5);
            t = 0.5 / t;
            x = (float) ((dirnY - upnZ) * t);
            y = (float) ((leftZ - dirnX) * t);
            z = (float) ((upnX - leftY) * t);
        } else {
            if (leftX > upnY && leftX > dirnZ) {
                t = Math.sqrt(1.0 + leftX - upnY - dirnZ);
                x = (float) (t * 0.5);
                t = 0.5 / t;
                y = (float) ((leftY + upnX) * t);
                z = (float) ((dirnX + leftZ) * t);
                w = (float) ((dirnY - upnZ) * t);
            } else if (upnY > dirnZ) {
                t = Math.sqrt(1.0 + upnY - leftX - dirnZ);
                y = (float) (t * 0.5);
                t = 0.5 / t;
                x = (float) ((leftY + upnX) * t);
                z = (float) ((upnZ + dirnY) * t);
                w = (float) ((leftZ - dirnX) * t);
            } else {
                t = Math.sqrt(1.0 + dirnZ - leftX - upnY);
                z = (float) (t * 0.5);
                t = 0.5 / t;
                x = (float) ((dirnX + leftZ) * t);
                y = (float) ((upnZ + dirnY) * t);
                w = (float) ((upnX - leftY) * t);
            }
        }
        /* Multiply */
        return dest.set(Math.fma(this.w, x, Math.fma(this.x, w, Math.fma(this.y, z, -this.z * y))),
                        Math.fma(this.w, y, Math.fma(-this.x, z, Math.fma(this.y, w, this.z * x))),
                        Math.fma(this.w, z, Math.fma(this.x, y, Math.fma(-this.y, x, this.z * w))),
                        Math.fma(this.w, w, Math.fma(-this.x, x, Math.fma(-this.y, y, -this.z * z))));
    }
    --]]

function quat.look_at(dir, up)

    local dirn = dir:normalize()
    local left = up:cross(dirn):normalize()
    local upn = dirn:cross(left)

    local x, y, z, w = 0, 0, 0, 0

    local tr = left.x + upn.y + dirn.z

    if tr >= 0 then
        local t = math.sqrt(tr + 1)
        w = t * 0.5
        t = 0.5 / t
        x = (dirn.y - upn.z) * t
        y = (left.z - dirn.x) * t
        z = (upn.x - left.y) * t
    else
        if left.x > upn.y and left.x > dirn.z then
            local t = math.sqrt(1 + left.x - upn.y - dirn.z)
            x = t * 0.5
            t = 0.5 / t
            y = (left.y + upn.x) * t
            z = (dirn.x + left.z) * t
            w = (dirn.y - upn.z) * t
        elseif upn.y > dirn.z then
            local t = math.sqrt(1 + upn.y - left.x - dirn.z)
            y = t * 0.5
            t = 0.5 / t
            x = (left.y + upn.x) * t
            z = (upn.z + dirn.y) * t
            w = (left.z - dirn.x) * t
        else
            local t = math.sqrt(1 + dirn.z - left.x - upn.y)
            z = t * 0.5
            t = 0.5 / t
            x = (dirn.x + left.z) * t
            y = (upn.z + dirn.y) * t
            w = (upn.x - left.y) * t
        end
    end

    return quat(x, y, z, w)
end

function quat.new(x_or_table, y, z, w)
    if x_or_table == nil then
        return quat(0, 0, 0, 1)
    end

    local result = nil
    local xType = type(x_or_table)
    local meta = getmetatable(x_or_table)

    if xType == "table" then
        if meta == quat then
            result = table.shallow_copy(x_or_table)
        elseif all_keys_present(x_or_table, "x", "y", "z", "w") then
            result = {
                x = x_or_table.x,
                y = x_or_table.y,
                z = x_or_table.z,
                w = x_or_table.w
            }
        elseif all_keys_present(x_or_table, 1, 2, 3, 4) then
            result = {
                x = x_or_table[1],
                y = x_or_table[2],
                z = x_or_table[3],
                w = x_or_table[4]
            }
        elseif all_keys_present(x_or_table, "1", "2", "3", "4") then
            result = {
                x = x_or_table["1"],
                y = x_or_table["2"],
                z = x_or_table["3"],
                w = x_or_table["4"]
            }
        else
            return nil
        end
    else
        if xType == "number" then
            if y ~= nil and z ~= nil and w ~= nil then
                result = { x = x_or_table, y = y, z = z, w = w }
            else
                result = { x = x_or_table, y = x_or_table, z = x_or_table, w = x_or_table }
            end
        end
    end

    setmetatable(result, quat)
    result:set_normalized()
    return result
end

setmetatable(quat, {
    __call = function(self, ...)
        local args = { ... }
        return quat.new(table.unpack(args))
    end
})