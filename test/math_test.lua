dofile("dsk/math/vec3.lua")

local v = vec3(1, 2, 3)

v[1] = 0

echo("Vector: " .. v.x .. ", " .. v.y .. ", " .. v.z)