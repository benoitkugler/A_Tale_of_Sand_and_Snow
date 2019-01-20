ES = {}

local LIMBE_FLOOR = "Yli"
local LIMBE_WALL = "Wli"
local LIMBE_WIDTH = 10
local LIMBE_HEIGHT = 10
local LIMBE_TERRAIN_VARIABLE = "lt" -- short to "compress" saves

VAR.objets_joueur = {ceinture_geant = "brinx", bottes_celerite = 0, ring_haste = "vranken", shield_myrom = "drumar"}
wesnoth.set_variable("heros_joueur", "brinx,vranken,drumar")

-- local br = wesnoth.get_unit("brinx")
-- br.variables.status_shielded_hp = 15
-- br.status.shielded = true

function ES.kill()
end
function ES.atk()
end

-- Put all units in their recall lists, except Morgane, and the Otchigins
-- Apply a custom l_imbe_recall status to be able to recall them afterwards
-- Store the location, which will be erased on save/load otherwise.
function _in_limbe_units()
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

function _out_limbe_units()
    for __, u in pairs(wesnoth.get_recall_units {status = "limbe_recall"}) do
        u:to_map(u.variables.x, u.variables.y)
    end
end

-- Saves the current terrain information in variable array limbe_terrains
-- and apply limbe terrain
function _set_limbe_terrain()
    local width, height, border  = wesnoth.get_map_size()
    local xstart = (width - LIMBE_WIDTH) // 2
    if xstart % 2 == 0 then xstart = xstart + 1 end  -- wall better looking
    local xstop = (width + LIMBE_WIDTH) // 2
    local ystart = (height - LIMBE_HEIGHT) // 2
    local ystop = (height + LIMBE_HEIGHT) // 2

    local var = {}

    for x = 0, width + border do
        for y = 0, height + border do
            local new_terrain
            if (y == ystart and (x == xstart or x == xstop)) then
                new_terrain = LIMBE_FLOOR
            elseif ((x == xstart or x == xstop) and (ystart <= y and y <= ystop)) or 
                    ((y == ystart or y == ystop) and (xstart <= x and x <= xstop))  then   
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

function _remove_limbe_terrain()
    for __, v in ipairs(H.get_variable_array(LIMBE_TERRAIN_VARIABLE)) do
        wesnoth.set_terrain(v.x, v.y, v.t)
    end
end

function test(x, y)
    -- _set_limbe_terrain()
    _remove_limbe_terrain()
    -- ES.dump_amla()
    -- _in_limbe()
    -- _out_limbe()
end

local function _table_to_string(tab)
    local s, v_s = "", ""
    for i, v in pairs(tab) do
        if not (type(i) == "number") then
            if type(v) == "number" or type(v) == "boolean" then
                v_s = tostring(v)
            else
                v_s = '"' .. v .. '"'
            end
            if i == "description" then
                v_s = "_ " .. v_s
            end
            s = s .. i .. " = " .. v_s .. ",\n"
        end
    end
    for i, v in ipairs(tab) do
        tag = v[1]
        s = s .. "T." .. tag .. " { \n"
        s = s .. _table_to_string(v[2])
        s = s .. "}, \n"
    end
    return s
end

function ES.dump_amla()
    local types = {"amla_vranken", "amla_brinx", "amla_drumar", "amla_xavier"}
    local s = ""
    for i, t in pairs(types) do
        local u = wesnoth.create_unit {type = t}
        s = s .. "\n \n" .. t .. " = { \n"
        for adv in H.child_range(u.__cfg, "advancement") do
            s = s .. "\n { \n " .. _table_to_string(adv) .. "\n },"
        end
        s = s .. "\n } \n"
    end
    wesnoth.message(s)
end

local s = wesnoth.theme_items.edit_left_button_function
function wesnoth.theme_items.edit_left_button_function()
    local r = s()
    wesnoth.message(wesnoth.debug(r))
    return r
end
--     wesnoth.add_modification(u,"object",{{"effect",{apply_to="attack",{"set_specials", { {"isHere",{id="slow_zone",name="test"} }  }}  }}},false)
