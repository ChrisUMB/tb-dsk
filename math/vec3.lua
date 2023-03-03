-- [ Decap Scripting Kit ] --

--[[
    vec3 represents a 3D Vector. This class comes with pretty much any math
    or utility function you might need. 
    
    Functions include:
    add, sub, mul, div, mod, negate, length/magnitude, normalize, dot, cross, floor, ceil, round
    
    They can also be compared with <, >, <=, >=, and ==
]]

---@class vec3 3D vector, XYZ
vec3 = {}

local components = { "x", "y", "z" }

function vec3:__index(name)
    if type(name) == "number" then
        name = components[name]
    end

    return rawget(self, name) or rawget(vec3, name)
end

function vec3:__newindex(key, value)
    if type(key) == "number" then
        key = components[key]
    end

    rawset(self, key, value)
end

function vec3:add(...)
    other = vec3(...)
    return vec3(self.x + other.x, self.y + other.y, self.z + other.z)
end

function vec3:__add(other)
    return self:add(other)
end

function vec3:sub(...)
    local other = vec3(...)
    return vec3(self.x - other.x, self.y - other.y, self.z - other.z)
end

function vec3:__sub(other)
    return self:sub(other)
end

function vec3:mul(...)
    local other = vec3(...)
    return vec3(self.x * other.x, self.y * other.y, self.z * other.z)
end

function vec3:__mul(other)
    return self:mul(other)
end

function vec3:div(...)
    local other = vec3(...)
    return vec3(self.x / other.x, self.y / other.y, self.z / other.z)
end

function vec3:__div(other)
    return self:div(other)
end

function vec3:mod(...)
    local other = vec3(...)
    return vec3(self.x % other.x, self.y % other.y, self.z % other.z)
end

function vec3:__mod(other)
    return self:mod(other)
end

function vec3:negate()
    return vec3(-self.x, -self.y, -self.z)
end

function vec3:__unm()
    return self:negate()
end

function vec3:equals(...)
    local other = vec3(...)
    return self.x == other.x and self.y == other.y and self.z == other.z
end

function vec3:__eq(other)
    return self:equals(other)
end

function vec3:__lt(other)
    other = vec3(other)
    return self:length() < other:length()
end

function vec3:__le(other)
    other = vec3(other)
    return self:length() <= other:length()
end

function vec3:__tostring()
    return "{x=" .. self.x .. ", y=" .. self.y .. ", z=" .. self.z .. "}"
end

function vec3:length_squared()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function vec3:length()
    return math.sqrt(self:length_squared())
end

function vec3:magnitude()
    return self:length()
end

function vec3:normalize()
    return self / self:length()
end

function vec3:cross(...)
    local other = vec3(...)
    local x = self.y * other.z - self.z * other.y
    local y = self.z * other.x - self.x * other.z
    local z = self.x * other.y - self.y * other.x
    return vec3(x, y, z)
end

function vec3:dot(...)
    local other = vec3(...)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

function vec3:distance_squared(...)
    local diff = self - vec3(...)
    return diff:length_squared()
end

function vec3:distance(...)
    local diff = self - vec3(...)
    return diff:length()
end

function vec3:floor()
    return vec3(math.floor(self.x), math.floor(self.y), math.floor(self.z))
end

function vec3:ceil()
    return vec3(math.ceil(self.x), math.ceil(self.y), math.ceil(self.z))
end

function vec3:round()
    return vec3(math.round(self.x), math.round(self.y), math.round(self.z))
end

function vec3:degrees()
    return vec3(math.deg(self.x), math.deg(self.y), math.deg(self.z))
end

function vec3:map(func)
    return vec3(func(self.x), func(self.y), func(self.z))
end

function vec3:look_at(other)
    return (other - self):normalize()
end

function vec3:unpack()
    return self.x, self.y, self.z
end

function vec3.new(x_or_table, y, z)
    if x_or_table == nil then
        return vec3(0, 0, 0)
    end

    local result = nil
    local xType = type(x_or_table)

    if xType == "table" then
        if getmetatable(x_or_table) == vec3 then
            result = table.shallow_copy(x_or_table)
        elseif all_keys_present(x_or_table, "x", "y", "z") then
            result = {
                x = x_or_table.x,
                y = x_or_table.y,
                z = x_or_table.z
            }
        elseif all_keys_present(x_or_table, 1, 2, 3) then
            result = {
                x = x_or_table[1],
                y = x_or_table[2],
                z = x_or_table[3]
            }
        elseif all_keys_present(x_or_table, "1", "2", "3") then
            result = {
                x = x_or_table["1"],
                y = x_or_table["2"],
                z = x_or_table["3"]
            }
        else
            return nil
        end
    else
        if xType == "number" then
            if y ~= nil and z ~= nil then
                result = { x = x_or_table, y = y, z = z }
            else
                result = { x = x_or_table, y = x_or_table, z = x_or_table }
            end
        end
    end

    setmetatable(result, vec3)
    return result
end

setmetatable(vec3, {
    __call = function(self, ...)
        local args = { ... }
        return vec3.new(table.unpack(args))
    end
})

local reference_axis = {
    positive_y = vec3(0, 1, 0),
    negative_y = vec3(0, -1, 0),
    positive_x = vec3(1, 0, 0),
    negative_x = vec3(-1, 0, 0),
    positive_z = vec3(0, 0, 1),
    negative_z = vec3(0, 0, -1)
}

reference_axis.positive_y.next = "negative_y"
reference_axis.negative_y.next = "positive_x"
reference_axis.positive_x.next = "negative_x"
reference_axis.negative_x.next = "positive_z"
reference_axis.positive_z.next = "negative_z"
reference_axis.negative_z.next = nil

-- Globally accessible.
---@class axis
---@field positive_y vec3
---@field negative_y vec3
---@field positive_x vec3
---@field negative_x vec3
---@field positive_z vec3
---@field negative_z vec3
axis = {}

setmetatable(axis, {
    __index = function(self, name)
        return vec3(rawget(reference_axis, name))
    end,

    __call = function(table, i, x)
        if x == nil then
            return axis.positive_y
        end
        if x.next == nil then
            return nil
        end

        return axis[x.next]
    end
})