-- [ Decap Scripting Kit ] --

--[[
    vec2 represents a 2D Vector. This class comes with pretty much any math
    or utility function you might need. 
    
    Functions include:
    add, sub, mul, div, mod, negate, length/magnitude, normalize, dot, cross, floor, ceil, round
    
    They can also be compared with <, >, <=, >=, and ==
]]

---@class vec2 2D vector, XY
---@field x number
---@field y number
vec2 = {}

local components = { "x", "y" }

function vec2:__index(name)
    if type(name) == "number" then
        name = components[name]
    end

    return rawget(self, name) or rawget(vec2, name)
end

function vec2:add(...)
    other = vec2(...)
    return vec2(self.x + other.x, self.y + other.y)
end

function vec2:__add(other)
    return self:add(other)
end

function vec2:sub(...)
    local other = vec2(...)
    return vec2(self.x - other.x, self.y - other.y)
end

function vec2:__sub(other)
    return self:sub(other)
end

function vec2:mul(...)
    local other = vec2(...)
    return vec2(self.x * other.x, self.y * other.y)
end

function vec2:__mul(other)
    return self:mul(other)
end

function vec2:div(...)
    local other = vec2(...)
    return vec2(self.x / other.x, self.y / other.y)
end

function vec2:__div(other)
    return self:div(other)
end

function vec2:mod(...)
    local other = vec2(...)
    return vec2(self.x % other.x, self.y % other.y)
end

function vec2:__mod(other)
    return self:mod(other)
end

function vec2:negate()
    return vec2(-self.x, -self.y)
end

function vec2:__unm()
    return self:negate()
end

function vec2:equals(...)
    local other = vec2(...)
    return self.x == other.x and self.y == other.y
end

function vec2:__eq(other)
    return self:equals(other)
end

function vec2:__lt(other)
    other = vec2(other)
    return self:length() < other:length()
end

function vec2:__le(other)
    other = vec2(other)
    return self:length() <= other:length()
end

function vec2:__tostring()
    return "{x=" .. self.x .. ", y=" .. self.y .. "}"
end

function vec2:length_squared()
    return self.x * self.x + self.y * self.y
end

function vec2:length()
    return math.sqrt(self:length_squared())
end

function vec2:magnitude()
    return self:length()
end

function vec2:normalize()
    return self / self:length()
end

function vec2:cross(...)
    local other = vec2(...)
    return self.x * other.y - self.y * other.x
end

function vec2:dot(...)
    local other = vec2(...)
    return self.x * other.x + self.y * other.y
end

function vec2:angle_to(...)
    local other = vec2(...)
    local dot = self:dot(other)
    local det = self:cross(other)
    return math.atan2(det, dot)
end

function vec2:angle()
    return math.atan2(self.y, self.x)
end

function vec2:floor()
    return vec2(math.floor(self.x), math.floor(self.y))
end

function vec2:ceil()
    return vec2(math.ceil(self.x), math.ceil(self.y))
end

function vec2:round()
    return vec2(math.round(self.x), math.round(self.y))
end

function vec2:look_at(other)
    return (other - self):normalize()
end

function vec2.new(x_or_table, y, z)
    if x_or_table == nil then
        return vec2(0, 0)
    end

    local result = nil
    local xType = type(x_or_table)

    if xType == "table" then
        if getmetatable(x_or_table) == vec2 then
            result = table.shallow_copy(x_or_table)
        elseif all_keys_present(x_or_table, "x", "y") then
            result = {
                x = x_or_table.x,
                y = x_or_table.y
            }
        elseif all_keys_present(x_or_table, 1, 2) then
            result = {
                x = x_or_table[1],
                y = x_or_table[2]
            }
        elseif all_keys_present(x_or_table, "1", "2") then
            result = {
                x = x_or_table["1"],
                y = x_or_table["2"]
            }
        else
            return nil
        end
    else
        if xType == "number" then
            if y ~= nil then
                result = { x = x_or_table, y = y }
            else
                result = { x = x_or_table, y = x_or_table }
            end
        end
    end

    setmetatable(result, vec2)
    return result
end

setmetatable(vec2, {
    __call = function(self, ...)
        local args = { ... }
        return vec2.new(table.unpack(args))
    end
})