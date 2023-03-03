-- [ Decap Scripting Kit ] --

--[[
    vec4 represents a 4D Vector. This class comes with pretty much any math
    or utility function you might need. 
    
    Functions include:
    add, sub, mul, div, mod, negate, length/magnitude, normalize, dot, floor, ceil, round
    
    They can also be compared with <, >, <=, >=, and ==
]]

---@class vec4 4D vector, XYZW
vec4 = {}

local components = { "x", "y", "z", "w" }

function vec4:__index(name)
    if type(name) == "number" then
        name = components[name]
    end

    return rawget(self, name) or rawget(vec4, name)
end

function vec4:add(...)
    other = vec4(...)
    return vec4(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w)
end

function vec4:__add(other)
    return self:add(other)
end

function vec4:sub(...)
    local other = vec4(...)
    return vec4(self.x - other.x, self.y - other.y, self.z - other.z, self.w + other.w)
end

function vec4:__sub(other)
    return self:sub(other)
end

function vec4:mul(...)
    local other = vec4(...)
    return vec4(self.x * other.x, self.y * other.y, self.z * other.z, self.w * other.w)
end

function vec4:__mul(other)
    return self:mul(other)
end

function vec4:div(...)
    local other = vec4(...)
    return vec4(self.x / other.x, self.y / other.y, self.z / other.z, self.w / other.w)
end

function vec4:__div(other)
    return self:div(other)
end

function vec4:mod(...)
    local other = vec4(...)
    return vec4(self.x % other.x, self.y % other.y, self.z % other.z, self.w % other.w)
end

function vec4:__mod(other)
    return self:mod(other)
end

function vec4:negate()
    return vec4(-self.x, -self.y, -self.z, -self.w)
end

function vec4:__unm()
    return self:negate()
end

function vec4:equals(...)
    local other = vec4(...)
    return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w
end

function vec4:__eq(other)
    return self:equals(other)
end

function vec4:__lt(other)
    other = vec4(other)
    return self:length() < other:length()
end

function vec4:__le(other)
    other = vec4(other)
    return self:length() <= other:length()
end

function vec4:__tostring()
    return "{x=" .. self.x .. ", y=" .. self.y .. ", z=" .. self.z .. ", w=" .. self.w .. "}"
end

function vec4:length_squared()
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

function vec4:length()
    return math.sqrt(self:length_squared())
end

function vec4:magnitude()
    return self:length()
end

function vec4:normalize()
    return self / self:length()
end

function vec4:dot(...)
    local other = vec4(...)
    return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w
end

function vec4:floor()
    return vec4(math.floor(self.x), math.floor(self.y), math.floor(self.z), math.floor(self.w))
end

function vec4:ceil()
    return vec4(math.ceil(self.x), math.ceil(self.y), math.ceil(self.z), math.ceil(self.w))
end

function vec4:round()
    return vec4(math.round(self.x), math.round(self.y), math.round(self.z), math.round(self.w))
end

function vec4:look_at(other)
    return (other - self):normalize()
end

function vec4.new(x_or_table, y, z, w)
    if x_or_table == nil then
        return nil
    end

    local result = nil
    local xType = type(x_or_table)

    if xType == "table" then
        if getmetatable(x_or_table) == vec4 then
            result = table.shallow_copy(x_or_table)
        elseif getmetatable(x_or_table) == vec3 then
            result = vec4(x_or_table.x, x_or_table.y, x_or_table.z, y or 0)
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

    setmetatable(result, vec4)
    return result
end

setmetatable(vec4, {
    __call = function(self, ...)
        local args = { ... }
        return vec4.new(table.unpack(args))
    end
})