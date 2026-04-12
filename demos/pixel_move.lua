-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/
--
-- SPDX-License-Identifier: CC0-1.0

x = 128
y = 96
color = 4
timer = 0

function TIC()
    cls(0)

    local moved = false
    
    if btn(0) then 
        y = y - 1
        moved = true
    end
    
    if btn(1) then 
        y = y + 1
        moved = true
    end
    
    if btn(2) then 
        x = x - 1
        moved = true
    end
    
    if btn(3) then 
        x = x + 1 
        moved = true
    end

    if moved then
        sfx(220, 50, 1)
    end
    
    if btnp(4) then
        color = color + 1
        if color > 15 then color = 1 end
        
        timer = 10
    end
    
    if timer > 0 then
        sfx(500, 50, 3)
        timer = timer - 1
    elseif not moved and not btnp(4) then
        sfx(0, 0, 0)
    end

    if x > 256 then x = 0 end
    if x < 0 then x = 256 end

    if y > 192 then y = 0 end
    if y < 0 then y = 192 end

    pix(x, y, color)
end