-- [ Decap Scripting Kit ] --

--[[
    mat4 represents a 4x4 Matrix. This comes with some relatively
    barebones functionality but should get most of the job done.
    
    Functions include:
    mul, transform, print (for debugging purposes)
    
    to_tb_matrix() converts this to the format toribash expects.

    The constructor is quite lenient and allows for:
        - m00 through m33
        - 4x vec4's
        - quaternion
        - toribash rot table
]]

mat4 = {}

local components = {
    "m00", "m01", "m02", "m03",
    "m10", "m11", "m12", "m13",
    "m20", "m21", "m22", "m23",
    "m30", "m31", "m32", "m33"
}

function mat4:__index(name)
    if type(name) == "number" then
        name = components[name]
    end

    return rawget(self, name) or rawget(mat4, name)
end

function mat4:print()
    for x = 0, 3 do
        local line = ""
        for y = 0, 3 do
            local key = "m" .. x .. y
            local value = self[key]
            line = line .. key .. "=" .. value .. " "
        end
        println(line)
    end
end

function mat4:mul(...)
    local other = mat4(...)
    local nm00 = math.fma(self.m00, other.m00, math.fma(self.m10, other.m01, math.fma(self.m20, other.m02, self.m30 * other.m03)))
    local nm01 = math.fma(self.m01, other.m00, math.fma(self.m11, other.m01, math.fma(self.m21, other.m02, self.m31 * other.m03)))
    local nm02 = math.fma(self.m02, other.m00, math.fma(self.m12, other.m01, math.fma(self.m22, other.m02, self.m32 * other.m03)))
    local nm03 = math.fma(self.m03, other.m00, math.fma(self.m13, other.m01, math.fma(self.m23, other.m02, self.m33 * other.m03)))
    local nm10 = math.fma(self.m00, other.m10, math.fma(self.m10, other.m11, math.fma(self.m20, other.m12, self.m30 * other.m13)))
    local nm11 = math.fma(self.m01, other.m10, math.fma(self.m11, other.m11, math.fma(self.m21, other.m12, self.m31 * other.m13)))
    local nm12 = math.fma(self.m02, other.m10, math.fma(self.m12, other.m11, math.fma(self.m22, other.m12, self.m32 * other.m13)))
    local nm13 = math.fma(self.m03, other.m10, math.fma(self.m13, other.m11, math.fma(self.m23, other.m12, self.m33 * other.m13)))
    local nm20 = math.fma(self.m00, other.m20, math.fma(self.m10, other.m21, math.fma(self.m20, other.m22, self.m30 * other.m23)))
    local nm21 = math.fma(self.m01, other.m20, math.fma(self.m11, other.m21, math.fma(self.m21, other.m22, self.m31 * other.m23)))
    local nm22 = math.fma(self.m02, other.m20, math.fma(self.m12, other.m21, math.fma(self.m22, other.m22, self.m32 * other.m23)))
    local nm23 = math.fma(self.m03, other.m20, math.fma(self.m13, other.m21, math.fma(self.m23, other.m22, self.m33 * other.m23)))
    local nm30 = math.fma(self.m00, other.m30, math.fma(self.m10, other.m31, math.fma(self.m20, other.m32, self.m30 * other.m33)))
    local nm31 = math.fma(self.m01, other.m30, math.fma(self.m11, other.m31, math.fma(self.m21, other.m32, self.m31 * other.m33)))
    local nm32 = math.fma(self.m02, other.m30, math.fma(self.m12, other.m31, math.fma(self.m22, other.m32, self.m32 * other.m33)))
    local nm33 = math.fma(self.m03, other.m30, math.fma(self.m13, other.m31, math.fma(self.m23, other.m32, self.m33 * other.m33)))
    local result = mat4()
    result.m00 = nm00
    result.m01 = nm01
    result.m02 = nm02
    result.m03 = nm03
    result.m10 = nm10
    result.m11 = nm11
    result.m12 = nm12
    result.m13 = nm13
    result.m20 = nm20
    result.m21 = nm21
    result.m22 = nm22
    result.m23 = nm23
    result.m30 = nm30
    result.m31 = nm31
    result.m32 = nm32
    result.m33 = nm33
    return result
end

function mat4:__mul(other)
    return self:mul(other)
end

function mat4:transform(other)
    local x = other.x
    local y = other.y
    local z = other.z
    local nx = math.fma(self.m00, x, math.fma(self.m10, y, math.fma(self.m20, z, self.m30)))
    local ny = math.fma(self.m01, x, math.fma(self.m11, y, math.fma(self.m21, z, self.m31)))
    local nz = math.fma(self.m02, x, math.fma(self.m12, y, math.fma(self.m22, z, self.m32)))
    return vec3(nx, ny, nz)
end

function mat4:transposed()
    local result = mat4()
    result.m00 = self.m00
    result.m01 = self.m10
    result.m02 = self.m20
    result.m03 = self.m30
    result.m10 = self.m01
    result.m11 = self.m11
    result.m12 = self.m21
    result.m13 = self.m31
    result.m20 = self.m02
    result.m21 = self.m12
    result.m22 = self.m22
    result.m23 = self.m32
    result.m30 = self.m03
    result.m31 = self.m13
    result.m32 = self.m23
    result.m33 = self.m33
    return result
end

function mat4:to_quaternion()
    local tr = self.m00 + self.m11 + self.m22
    local quat = quat()

    if tr > 0 then
        local S = math.sqrt(tr + 1.0) * 2
        quat.w = 0.25 * S
        quat.x = (self.m21 - self.m12) / S
        quat.y = (self.m02 - self.m20) / S
        quat.z = (self.m10 - self.m01) / S
    elseif ((self.m00 > self.m11) and (self.m00 > self.m22)) then
        local S = math.sqrt(1.0 + self.m00 - self.m11 - self.m22) * 2
        quat.w = (self.m21 - self.m12) / S
        quat.x = 0.25 * S
        quat.y = (self.m01 + self.m10) / S
        quat.z = (self.m02 + self.m20) / S
    elseif self.m11 > self.m22 then
        local S = math.sqrt(1.0 + self.m11 - self.m00 - self.m22) * 2
        quat.w = (self.m02 - self.m20) / S
        quat.x = (self.m01 + self.m10) / S
        quat.y = 0.25 * S
        quat.z = (self.m12 + self.m21) / S
    else
        local S = math.sqrt(1.0 + self.m22 - self.m00 - self.m11) * 2
        quat.w = (self.m10 - self.m01) / S
        quat.x = (self.m02 + self.m20) / S
        quat.y = (self.m12 + self.m21) / S
        quat.z = 0.25 * S
    end

    return quat
end

function mat4:to_tb_matrix()
    local rot = {}

    local i = 0
    for x = 0, 3 do
        for y = 0, 3 do
            local key = "m" .. x .. y
            local v = self[key]
            rot["r" .. i] = v
            i = i + 1
        end
    end

    return rot
end

local function is_vec4(t)
    if not t or type(t) ~= "table" then
        return false
    end
    return getmetatable(t) == vec4
end

function mat4.new(
        m00_or_table, m01_or_table, m02_or_table, m03_or_table,
        m10, m11, m12, m13,
        m20, m21, m22, m23,
        m30, m31, m32, m33
)
    local result = nil

    local m00_type = type(m00_or_table)
    if m00_type == "table" then
        local meta = getmetatable(m00_or_table)
        -- If the first value passed is already a mat4, just return it.
        if meta == mat4 then
            local copy = table.shallow_copy(m00_or_table)
            setmetatable(copy, mat4)
            return copy
            -- Otherwise, if it's a vec4, the following 3 must be vec4's and need to be parsed.
        elseif meta == vec4 then
            if not is_vec4(m01_or_table) or not is_vec4(m02_or_table) or not is_vec4(m03_or_table) then
                return nil
            end

            local v = { m00_or_table, m01_or_table, m02_or_table, m03_or_table }
            result = {}
            for x = 1, 4 do
                for y = 1, 4 do
                    result["m" .. y - 1 .. x - 1] = v[x][y]
                end
            end
        elseif meta == quat then
            local quat = m00_or_table
            result = {
                m03 = 0.0,
                m13 = 0.0,
                m23 = 0.0,
                m30 = 0.0,
                m31 = 0.0,
                m32 = 0.0,
                m33 = 1.0,
            }
            local w2 = quat.w * quat.w
            local x2 = quat.x * quat.x
            local y2 = quat.y * quat.y
            local z2 = quat.z * quat.z
            local zw = quat.z * quat.w
            local dzw = zw + zw
            local xy = quat.x * quat.y
            local dxy = xy + xy
            local xz = quat.x * quat.z
            local dxz = xz + xz
            local yw = quat.y * quat.w
            local dyw = yw + yw
            local yz = quat.y * quat.z
            local dyz = yz + yz
            local xw = quat.x * quat.w
            local dxw = xw + xw
            result.m00 = w2 + x2 - z2 - y2
            result.m01 = dxy + dzw
            result.m02 = dxz - dyw
            result.m10 = -dzw + dxy
            result.m11 = y2 - z2 + w2 - x2
            result.m12 = dyz + dxw
            result.m20 = dyw + dxz
            result.m21 = dyz - dxw
            result.m22 = z2 - y2 - x2 + w2
        else
            local tb_mat = m00_or_table

            if all_keys_present(tb_mat,
                    "r0", "r1", "r2", "r3",
                    "r4", "r5", "r6", "r7",
                    "r8", "r9", "r10", "r11",
                    "r12", "r13", "r14", "r15"
            ) then
                result = {}
                for i = 0, 15 do
                    local x = math.floor(i / 4)
                    local y = i % 4
                    local key = "m" .. x .. y

                    result[key] = tb_mat["r" .. i]
                end
            elseif all_keys_present(tb_mat,
                    1, 2, 3, 4,
                    5, 6, 7, 8,
                    9, 10, 11, 12,
                    13, 14, 15, 16
            ) then
                result = {}
                for i = 0, 15 do
                    local x = math.floor(i / 4)
                    local y = i % 4
                    local key = "m" .. x .. y
                    result[key] = tb_mat[i + 1]
                end
            else
                return nil
            end
        end
    elseif m00_type == "number" then
        result = {
            m00 = m00_or_table, m01 = m01_or_table, m02 = m02_or_table, m03 = m03_or_table,
            m10 = m10, m11 = m11, m12 = m12, m13 = m13,
            m20 = m20, m21 = m21, m22 = m22, m23 = m23,
            m30 = m30, m31 = m31, m32 = m32, m33 = m33
        }

        for k, v in pairs(result) do
            if type(v) ~= "number" then
                return nil
            end
        end
    elseif not m00_or_table then
        -- Return identity matrix.
        result = {
            m00 = 1.0, m01 = 0.0, m02 = 0.0, m03 = 0.0,
            m10 = 0.0, m11 = 1.0, m12 = 0.0, m13 = 0.0,
            m20 = 0.0, m21 = 0.0, m22 = 1.0, m23 = 0.0,
            m30 = 0.0, m31 = 0.0, m32 = 0.0, m33 = 1.0
        }
    end

    setmetatable(result, mat4)
    return result
end

setmetatable(mat4, {
    __call = function(self, ...)
        local args = { ... }
        return mat4.new(table.unpack(args))
    end
})