-- Implement the special dimension called Limbes

Limbes = {}

local LIMBE_FLOOR = "Yli"
local LIMBE_WALL = "Wli"
local LIMBE_WIDTH = 10
local LIMBE_HEIGHT = 10
local LIMBE_TERRAIN_VARIABLE = "lt" -- short to "compress" saves

-- Put all units in their recall lists, except Morgane, and the Otchigins
-- Apply a custom limbe_recall status to be able to recall them afterwards
-- Store the location, which will be erased on save/load otherwise.
local function _in_limbe_units()
    local morgane = wesnoth.get_unit("morgane")
    morgane.canrecruit = true
    local och = wesnoth.get_units {type = "otchigin1"}[1]
    och.canrecruit = true
    for __, u in pairs(wesnoth.get_units()) do
        u.variables.x = u.x
        u.variables.y = u.y
        if not (u.id == "morgane" or u.type == "otchigin1" or u.type == "otchigin2" or u.type == "otchigin3") then
            u.status._limbe_recall = true
            u:to_recall()
        end
    end
end

local function _out_limbe_units()
    for __, u in pairs(wesnoth.get_recall_units {status = "_limbe_recall"}) do
        u:to_map(u.variables.x, u.variables.y)
    end
end

-- Saves the current terrain information in variable array limbe_terrains
-- and apply limbe terrain
local function _set_limbe_terrain()
    local width, height, border = wesnoth.get_map_size()
    local xstart = (width - LIMBE_WIDTH) // 2
    if xstart % 2 == 0 then
        xstart = xstart + 1
    end -- wall better looking
    local xstop = (width + LIMBE_WIDTH) // 2
    local ystart = (height - LIMBE_HEIGHT) // 2
    local ystop = (height + LIMBE_HEIGHT) // 2

    local var = {}

    for x = 0, width + border do
        for y = 0, height + border do
            local new_terrain
            if (y == ystart and (x == xstart or x == xstop)) then
                new_terrain = LIMBE_FLOOR
            elseif
                ((x == xstart or x == xstop) and (ystart <= y and y <= ystop)) or
                    ((y == ystart or y == ystop) and (xstart <= x and x <= xstop))
             then
                new_terrain = LIMBE_WALL
            else
                new_terrain = LIMBE_FLOOR
            end
            local terrain = wesnoth.get_terrain(x, y)
            table.insert(var, {x = x, y = y, t = terrain})
            wesnoth.set_terrain(x, y, new_terrain)
        end
    end

    H.set_variable_array(LIMBE_TERRAIN_VARIABLE, var)

    -- wesnoth.set_terrain(10,10, LIMBE_FLOOR)
    -- wesnoth.set_terrain(10,11, LIMBE_WALL)
end

local function _remove_limbe_terrain()
    for __, v in ipairs(H.get_variable_array(LIMBE_TERRAIN_VARIABLE)) do
        wesnoth.set_terrain(v.x, v.y, v.t)
    end
end

function Limbes.enter()
    _set_limbe_terrain()
    _in_limbe_units()
end

function Limbes.close()
    _out_limbe_units()
    _remove_limbe_terrain()
end
