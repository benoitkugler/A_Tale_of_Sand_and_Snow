AB = {}
local location_set = wesnoth.require "lua/location_set.lua"

-- Allied defense (Xavier). Called on move event
-- We first remove passed defense bonus
-- Then we find the unit who should benefit from Xavier ability
-- Then we apply a trait modification with id _tmp_allies_defense_bonus
function AB.allies_defense()
    local xavier = wesnoth.get_unit("xavier")
    local lvl = get_ability(xavier, "allies_defense")
    if not lvl then
        return
    end

    local trait_id = "_tmp_allies_defense_bonus"
    local us = wesnoth.get_units {trait = trait_id}
    for i, u in pairs(us) do
        u:remove_modifications({id = trait_id}, "trait")
    end
    local adj_xavier = wesnoth.get_units {
        T.filter_adjacent {id = "xavier"},
        T.filter_side {T.allied_with {side = xavier.side}}
    }
    local bonus_def = DB_AMLAS.xavier.values.ALLIES_DEFENSE_RATIO * lvl
    for i, u in pairs(adj_xavier) do
        u:add_modification(
            "trait",
            {
                id = trait_id,
                name = _ "Xavier's defense",
                description = fmt(_ "Xavier is so strong! He grants us <b>%d%%</b> bonus defense", bonus_def),
                add_defenses(bonus_def)
            })
    end
end

-- Renvoie true si la case x,y est à coté d'un ennemi de unit
local function next_to(unit, x, y)
    local s = false
    for a, b in H.adjacent_tiles(x, y) do
        if not is_empty(a, b) then
            s = s or wesnoth.is_enemy(wesnoth.get_units {x = a, y = b}[1].side, unit.side)
        end
    end
    return s
end


local function tiles_bloque(unit)
    local pourrait = location_set.of_pairs(wesnoth.find_reach(unit, {ignore_units = true}))
    local peut = location_set.of_pairs(wesnoth.find_reach(unit))
    local bloque =
        pourrait:filter(
        function(x, y, v)
            return (is_empty(x, y) and next_to(unit, x, y) and (peut:get(x, y) == nil))
        end
    )
    return bloque:to_pairs()
end

local function pourrait(unit)
    local pourrait = location_set.of_pairs(wesnoth.find_reach(unit, {ignore_units = true}))
    local peut = location_set.of_pairs(wesnoth.find_reach(unit))
    pourrait =
        pourrait:filter(
        function(x, y, v)
            return (is_empty(x, y) and (peut:get(x, y) == nil))
        end
    )
    return pourrait:to_pairs()
end

--Appelée sur sélection d'une unité
function AB.select()
    wesnoth.fire("set_menu_item", {id = "movement", T.show_if {{"false", {}}}})
    local u = get_pri()
    if has_ab(u, "war_jump") and u.moves > 0 then
        AB.war_jump(u)
    end

    if has_ab(u, "elusive") and u.moves > 0 then
        AB.elusive(u)
    end

    if u.id == "xavier" then
        AB.show_formations(u)
    end
end

function AB.war_jump(unit)
    local bloque = tiles_bloque(unit)

    local listx, listy = "", ""
    for i, v in pairs(bloque) do
        listx = listx .. "," .. v[1]
        listy = listy .. "," .. v[2]
    end
    listx = string.sub(listx, 2)
    listy = string.sub(listy, 2)
    wesnoth.fire(
        "set_menu_item",
        {
            id = "movement",
            description = _ "War jump here with " .. unit.name .. " !",
            image = "menu/war_jump.png",
            {"show_if", {{"have_location", {x = "$x1", y = "$y1", {"and", {x = listx, y = listy}}}}}},
            {"command", {{"lua", {code = 'MI.war_jump("' .. unit.id .. '",' .. unit.x .. "," .. unit.y .. ")"}}}}
        }
    )

    ANIM.hover_tiles(bloque, "Right-click here")
end

function AB.elusive(unit)
    local pou = pourrait(unit)
    local listx, listy = "", ""
    for __, v in ipairs(pou) do
        listx = listx .. "," .. v[1]
        listy = listy .. "," .. v[2]
    end
    listx = string.sub(listx, 2)
    wesnoth.fire(
        "set_menu_item",
        {
            id = "movement",
            description = _ "Sneak here with " .. unit.name .. " !",
            image = "menu/elusive.png",
            {"show_if", {{"have_location", {x = "$x1", y = "$y1", {"and", {x = listx, y = listy}}}}}},
            {"command", {{"lua", {code = 'MI.elusive("' .. unit.id .. '",' .. unit.x .. "," .. unit.y .. ")"}}}}
        }
    )

    ANIM.hover_tiles(pou, "Right-click here")
end


-- ------------------------------------ Formations (Xavier) ------------------------------------
-- A formation is defined by a function taking the center tile, ie xaviers'tile, and returning
-- a table of table of tiles, (an inner table being a possible formation)

local function Y_position(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_tiles(center)
    local formations = {}
    for __, c in ipairs({c1, c2, c3, c4, c5, c6}) do
        local front = wesnoth.map.rotate_right_around_center(center, c, 3) -- in front of xavier
        local Y_1 = wesnoth.map.rotate_right_around_center(front, c, 1)
        local Y_2 = wesnoth.map.rotate_right_around_center(front, c, -1)
        table.insert(formations, { center, Y_1, Y_2 })
    end
    return formations
end

local function A_position(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_tiles(center)
    local formations = {}
    for __, c in ipairs({c1, c2, c3, c4, c5, c6}) do
        local adj = wesnoth.map.rotate_right_around_center(c, center, 2)
        table.insert(formations, {center, c, adj})
    end
    return formations
end

local function I_position(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_tiles(center)
    local formations = {}
    for __, c in ipairs({c1, c2, c3, c4, c5, c6}) do
        local behind = wesnoth.map.rotate_right_around_center(center, c, 3)
        table.insert(formations, {center, c, behind})
    end
    return formations
end

-- Returns true if all tiles of the formation are allied (and occupied)
local function _check_formation(xavier, formation)
    local side = xavier.side
    for __, tile in ipairs(formation) do
        local u = wesnoth.get_unit(tile[1], tile[2])
        if u == nil or wesnoth.is_enemy(side, u.side) then
            return false
        end
    end
    return true
end

function AB.show_formations(xavier)
    local show = location_set.create()

    for __, pos in ipairs(Y_position {xavier.x, xavier.y}) do
        if _check_formation(xavier, pos) then
            show:of_pairs(pos)
        end
    end
    for __, pos in ipairs(I_position {xavier.x, xavier.y}) do
        if _check_formation(xavier, pos) then
            show:of_pairs(pos)
        end
    end
    for __, pos in ipairs(A_position {xavier.x, xavier.y}) do
        if _check_formation(xavier, pos) then
            show:of_pairs(pos)
        end
    end
    ANIM.hover_tiles(show:to_pairs(), "Formation")
end
