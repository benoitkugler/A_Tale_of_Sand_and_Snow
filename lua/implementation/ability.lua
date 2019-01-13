AB = {}
local LS = wesnoth.require "lua/location_set.lua"

local FORMATION_LABEL = _ "Formation"
local TARGET_LABEL = _ "Target"

-- Allied defense (Xavier). Called on move event
-- We first remove passed defense bonus
-- Then we find the unit who should benefit from Xavier ability
-- Then we apply a trait modification with id _tmp_allies_defense_bonus
local function allies_defense()
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
    local adj_xavier =
        wesnoth.get_units {
        T.filter_adjacent {id = "xavier"},
        T.filter_side {T.allied_with {side = xavier.side}}
    }
    local bonus_def = DB.AMLAS.xavier.values.ALLIES_DEFENSE_RATIO * lvl
    for i, u in pairs(adj_xavier) do
        u:add_modification(
            "trait",
            {
                id = trait_id,
                name = _ "Xavier's defense",
                description = fmt(_ "Xavier is so strong! He grants us <b>%d%%</b> bonus defense", bonus_def),
                add_defenses(bonus_def)
            }
        )
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
    local pourrait = LS.of_pairs(wesnoth.find_reach(unit, {ignore_units = true}))
    local peut = LS.of_pairs(wesnoth.find_reach(unit))
    local bloque =
        pourrait:filter(
        function(x, y, v)
            return (is_empty(x, y) and next_to(unit, x, y) and (peut:get(x, y) == nil))
        end
    )
    return bloque:to_pairs()
end

local function pourrait(unit)
    local pourrait = LS.of_pairs(wesnoth.find_reach(unit, {ignore_units = true}))
    local peut = LS.of_pairs(wesnoth.find_reach(unit))
    pourrait =
        pourrait:filter(
        function(x, y, v)
            return (is_empty(x, y) and (peut:get(x, y) == nil))
        end
    )
    return pourrait:to_pairs()
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
            {"command", {{"lua", {code = 'UI.war_jump("' .. unit.id .. '",' .. unit.x .. "," .. unit.y .. ")"}}}}
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
            {"command", {{"lua", {code = 'UI.elusive("' .. unit.id .. '",' .. unit.x .. "," .. unit.y .. ")"}}}}
        }
    )

    ANIM.hover_tiles(pou, "Right-click here")
end

-- ------------------------------------ Formations (Xavier) ------------------------------------
-- A formation is defined by a function taking the center tile, ie xaviers'tile, and returning
-- a table of table of tiles, (an inner table being a possible formation)

local function Y_formation(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_tiles(center)
    local formations = {}
    for __, c in ipairs({c1, c2, c3, c4, c5, c6}) do
        local front = wesnoth.map.rotate_right_around_center(center, c, 3) -- in front of xavier
        local Y_1 = wesnoth.map.rotate_right_around_center(front, c, 1)
        local Y_2 = wesnoth.map.rotate_right_around_center(front, c, -1)
        table.insert(formations, {target = c, center, Y_1, Y_2})
    end
    return formations
end

local function A_formation(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_tiles(center)
    local formations = {}
    for __, c in ipairs({c1, c2, c3, c4, c5, c6}) do
        local adj = wesnoth.map.rotate_right_around_center(c, center, 2)
        table.insert(formations, {center, c, adj})
    end
    return formations
end

local function I_formation(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_tiles(center)
    local formations = {}
    for __, c in ipairs({c1, c2, c3, c4, c5, c6}) do
        local behind = wesnoth.map.rotate_right_around_center(center, c, 3)
        local target = wesnoth.map.rotate_right_around_center(c, center, 3)
        table.insert(formations, {target = target, center, c, behind})
    end
    return formations
end

local function O_formation(center)
    local xavier = wesnoth.get_unit(center[1], center[2])
    if xavier == nil or not (xavier.id == "xavier") then
        wesnoth.message("O_formation should be called on Xavier's tile only !")
        return {}
    end
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_tiles(center)
    local formations = {}
    for __, c in ipairs({c1, c2, c3, c4, c5, c6}) do
        local is_encerclement = true
        local u = wesnoth.get_unit(c[1], c[2])
        if not (u == nil) and wesnoth.is_enemy(u.side, xavier.side) then
            local d1, d2, d3, d4, d5, d6 = wesnoth.map.get_adjacent_tiles(c)
            for __, d in ipairs({d1, d2, d3, d4, d5, d6}) do
                local ud = wesnoth.get_unit(d[1], d[2])
                if ud == nil or wesnoth.is_enemy(ud.side, xavier.side) then -- no encerclement
                    is_encerclement = false
                    break
                end
            end
            if is_encerclement then
                table.insert(formations, {target = c, d1, d2, d3, d4, d5, d6})
            end
        end
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

-- Returns the active formations (xavier need to have the ability corresponding)
function AB.get_active_formations(xavier)
    local tiles_ally = LS.create()
    local tiles_target = LS.create()
    local active_formations = {}
    if get_ability(xavier, "Y_formation") then
        for __, pos in ipairs(Y_formation {xavier.x, xavier.y}) do
            if _check_formation(xavier, pos) then
                tiles_ally:of_pairs(pos)
                active_formations.Y = pos.target
                tiles_target:insert(pos.target[1], pos.target[2])
            end
        end
    end
    if get_ability(xavier, "I_formation") then
        for __, pos in ipairs(I_formation {xavier.x, xavier.y}) do
            if _check_formation(xavier, pos) then
                tiles_ally:of_pairs(pos)
                active_formations.I = pos.target
                tiles_target:insert(pos.target[1], pos.target[2])
            end
        end
    end
    if get_ability(xavier, "A_formation") then
        for __, pos in ipairs(A_formation {xavier.x, xavier.y}) do
            if _check_formation(xavier, pos) then
                tiles_ally:of_pairs(pos)
                active_formations.A = true
            end
        end
    end
    if get_ability(xavier, "O_formation") then
        for __, pos in ipairs(O_formation {xavier.x, xavier.y}) do
            if _check_formation(xavier, pos) then
                tiles_ally:of_pairs(pos)
                active_formations.O = pos.target
                tiles_target:insert(pos.target[1], pos.target[2])
            end
        end
    end
    return active_formations, tiles_ally, tiles_target
end

-- Application of ablities when a formation is active
local formations_abilities = {}
function formations_abilities.Y(xavier, target)
    local lvl = get_ability(xavier, "Y_formation")
    if lvl then
        local value = DB.SPECIAL_SKILLS.xavier.Y_formation(lvl)
        local x, y = target[1], target[2]
        xavier:add_modification(
            "trait",
            {
                id = "_formation_Y",
                T.effect {
                    apply_to = "attack",
                    T.set_specials {
                        mode = "append",
                        T.attacks {
                            add = value,
                            name = _ "Back formation",
                            active_on = "offense",
                            T.filter_opponent {
                                x = x,
                                y = y
                            }
                        }
                    }
                }
            }
        )
    end
end

function formations_abilities.A(xavier)
    local lvl = get_ability(xavier, "A_formation")
    if lvl then
        local value = DB.SPECIAL_SKILLS.xavier.A_formation(lvl)
        xavier:add_modification(
            "trait",
            {
                id = "_formation_A",
                add_defenses(value)
            }
        )
    end
end

function formations_abilities.I(xavier, target)
    local lvl = get_ability(xavier, "I_formation")
    if lvl then
        local value = DB.SPECIAL_SKILLS.xavier.I_formation(lvl)
        local x, y = target[1], target[2]
        xavier:add_modification(
            "trait",
            {
                id = "_formation_I",
                T.effect {
                    apply_to = "attack",
                    T.set_specials {
                        mode = "append",
                        T.damage {
                            add = value,
                            name = _ "Spear formation",
                            active_on = "offense",
                            T.filter_opponent {
                                x = x,
                                y = y
                            }
                        }
                    }
                }
            }
        )
    end
end

function formations_abilities.O(xavier, target)
    wesnoth.fire("clear_menu_item", {id = "union_debuf"}) -- removing then rebuilding
    local lvl = get_ability(xavier, "O_formation")
    local cd = xavier.variables.special_skill_cd or 0
    if lvl and target and (cd == 0) then
        local x, y = target[1], target[2]
        local lua_code = string.format("AB.union_debuf(%d, %d)", x, y)
        UI.setup_menu_debuf(x, y, lua_code)
    end
end

function AB.union_debuf(x, y)
    local target = wesnoth.get_unit(x, y)
    local xavier = wesnoth.get_unit("xavier")
    local lvl = get_ability(xavier,"O_formation")
    local cd = DB.SPECIAL_SKILLS.xavier.O_formation(lvl)
    wesnoth.message(cd)
    if target == nil or xavier == nil then
        wesnoth.message(_ "Union debuf not possible here ! ")
    else
        ANIM.quake()
        local list_abilities = H.get_child(target.__cfg, "abilities") or {}
        target:add_modification(
            "trait",
            {
                T.effect {
                    apply_to = "remove_ability",
                    T.abilities(list_abilities)
                },
                T.effect {
                    apply_to = "attack",
                    T.set_specials {} -- remove all specials
                }
            }
        )
        wesnoth.float_label(x, y, _ "Disabled !")
        xavier.variables.special_skill_cd = cd
    end
end

-- Update abilities related to Formations,
-- and display active ones
local function update_xavier_formation()
    local xavier = wesnoth.get_unit("xavier")
    if xavier == nil then
        return
    end
    for _, name in pairs({"A", "I", "Y"}) do -- remove potential old ability
        xavier:remove_modifications({id = "_formation_" .. name}, "trait")
    end
    local active_formations, tiles, targets = AB.get_active_formations(xavier)
    ANIM.hover_tiles(tiles:to_pairs(), FORMATION_LABEL, nil, targets:to_pairs(), TARGET_LABEL, 50)
    for name, target in pairs(active_formations) do
        if not (name == "O") then
            formations_abilities[name](xavier, target)
        end
    end
    formations_abilities.O(xavier, active_formations.O) -- always called, to remove menu item if needed
end

-- -------------------------- Event handler --------------------------
function AB.on_moveto()
    allies_defense()
    update_xavier_formation()
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
        local __, tiles, targets = AB.get_active_formations(u)
        ANIM.hover_tiles(tiles:to_pairs(), FORMATION_LABEL, 15, targets:to_pairs(), TARGET_LABEL, 50)
    end
end

-- Should decrease special skill CDs
function AB.turn_start()
	local lhero = wesnoth.get_units {role = "hero"}
	for __, v in pairs(lhero) do
        local current_cd = v.variables.special_skill_cd or 0
        if current_cd > 0 then
            v.variables.special_skill_cd = current_cd - 1
        end
	end
end
