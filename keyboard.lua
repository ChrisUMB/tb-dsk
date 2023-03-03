local HOOK_ID = "dsk-keyboard"
remove_hooks(HOOK_ID)

KB_MODIFIERS = {
    R_SHIFT = false, -- 303
    L_SHIFT = false, -- 304

    R_CTRL = false, -- 305
    L_CTRL = false, -- 306

    R_ALT = false, -- 307
    L_ALT = false, -- 308

    SHIFT = false,
    CTRL = false,
    ALT = false,
}

add_hook("key_down", HOOK_ID, function(key)
    if key == 303 then
        KB_MODIFIERS.R_SHIFT = true
        KB_MODIFIERS.SHIFT = true
    elseif key == 304 then
        KB_MODIFIERS.L_SHIFT = true
        KB_MODIFIERS.SHIFT = true
    elseif key == 305 then
        KB_MODIFIERS.R_CTRL = true
        KB_MODIFIERS.CTRL = true
    elseif key == 306 then
        KB_MODIFIERS.L_CTRL = true
        KB_MODIFIERS.CTRL = true
    elseif key == 307 then
        KB_MODIFIERS.R_ALT = true
        KB_MODIFIERS.ALT = true
    elseif key == 308 then
        KB_MODIFIERS.L_ALT = true
        KB_MODIFIERS.ALT = true
    end
end)

add_hook("key_up", HOOK_ID, function(key)
    if key == 303 then
        KB_MODIFIERS.R_SHIFT = false
        KB_MODIFIERS.SHIFT = KB_MODIFIERS.L_SHIFT
    elseif key == 304 then
        KB_MODIFIERS.L_SHIFT = false
        KB_MODIFIERS.SHIFT = KB_MODIFIERS.R_SHIFT
    elseif key == 305 then
        KB_MODIFIERS.R_CTRL = false
        KB_MODIFIERS.CTRL = KB_MODIFIERS.L_CTRL
    elseif key == 306 then
        KB_MODIFIERS.L_CTRL = false
        KB_MODIFIERS.CTRL = KB_MODIFIERS.R_CTRL
    elseif key == 307 then
        KB_MODIFIERS.R_ALT = false
        KB_MODIFIERS.ALT = KB_MODIFIERS.L_ALT
    elseif key == 308 then
        KB_MODIFIERS.L_ALT = false
        KB_MODIFIERS.ALT = KB_MODIFIERS.R_ALT
    end
end)