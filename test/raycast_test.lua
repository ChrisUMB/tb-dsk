dofile("dsk/dsk.lua")

remove_hooks("test-raycast")

local cache = {}

local resolution = 6

--for x = 0, WIN_W - 1, resolution do
--    cache[x] = {}
--    for y = 0, WIN_H - 1, resolution do
--        local obj, dist = raycast.screen(x, y, true, false, false, true)
--
--        cache[x][y] = { obj, dist }
--    end
--end

--add_hook("draw2d", "test-raycast", function()
--
--    local s, e = pcall(function()
--
--
--        for x = 0, WIN_W - 1, resolution do
--            for y = 0, WIN_H - 1, resolution do
--                local obj, dist = unpack(cache[x][y])
--
--                if obj then
--                    set_color(dist / 10, dist / 10, dist / 10, 0.85)
--                    draw_quad(x, y, resolution, resolution)
--                end
--            end
--        end
--
--    end)
--
--    if not s then
--        println(e)
--    end
--end)

dofile("gizmo/gizmo.lua")

local g = nil
add_hook("mouse_button_down", "test-raycast", function(button, x, y)
    if button ~= 1 then
        return
    end
    local obj, dist = raycast.screen(x, y, true, false, false)

    local s, e = pcall(function()


        if obj then
            if g then
                gizmo.remove(g)
            end
            g = gizmo.bound_translate(function()
                return obj:get_position()
            end, function(value)
                obj:set_position(value)
                set_ghost(2)
            end)
        end
    end)

    if not s then
        println(e)
    end
end)