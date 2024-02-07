AB = {}
---@type location_set
local LocSet = wesnoth.require "location_set"

local FORMATION_LABEL = _ "Formation"
local TARGET_LABEL = _ "Target"


---@param set loc_set
local function to_zip_pairs(set)
    ---@type integer[], integer[]
    local listx, listy = {}, {}
    for __, v in ipairs(set:to_pairs()) do
        table.insert(listx, v[1])
        table.insert(listy, v[2])
    end
    return listx, listy
end

-- Return true if x,y is adjacent to one ennemy of unit
---@param unit unit
---@param x integer
---@param y integer
local function next_to_ennemy(unit, x, y)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_hexes({ x = x, y = y })
    for _, loc in ipairs({ c1, c2, c3, c4, c5, c6 }) do
        local u = wesnoth.units.get(loc.x, loc.y)
        if u and wesnoth.sides.is_enemy(u.side, unit.side) then return true end
    end
    return false
end

---@param x integer
---@param y integer
local function is_empty(x, y) return wesnoth.units.get(x, y) == nil end

-- Return a set of tiles behind ennemy lines
---@param unit unit
local function tiles_behind(unit)
    local available_tiles = LocSet.of_pairs(wesnoth.paths.find_reach(unit, {
        ignore_units = true,
    }))
    local true_reachable = LocSet.of_pairs(wesnoth.paths.find_reach(unit))
    local tiles = available_tiles:filter(
        function(x, y, v)
            return (is_empty(x, y) and next_to_ennemy(unit, x, y) and
                (true_reachable:get(x, y) == nil))
        end)
    return tiles
end

-- Return a set of location where the unit may go if
-- ennemy units weren't blocking the path.
---@param unit unit
local function available_tiles(unit)
    local reachable = LocSet.of_pairs(
        wesnoth.paths.find_reach(unit, { ignore_units = true }))
    local true_reachable = LocSet.of_pairs(wesnoth.paths.find_reach(unit))
    local tiles = reachable:filter(function(x, y, v)
        return (is_empty(x, y) and (true_reachable:get(x, y) == nil))
    end)
    return tiles
end

---@param unit unit
local function show_war_jump(unit)
    local blocked = tiles_behind(unit)
    local listx, listy = to_zip_pairs(blocked)
    local lua_code = Fmt("AB.war_jump(%q,%d,%d)", unit.id, unit.x, unit.y)
    UI.setup_menu_warjump(listx, listy, lua_code)
    ANIM.hover_tiles(blocked:to_pairs(), "Right-click here")
end

function AB.war_jump(unit_id, x, y)
    local u = wesnoth.units.get(unit_id)
    local tox, toy = GetLocation()
    if u == nil then
        Popup(_ "Error",
            _ "Can't <span color='red'>War Jump </span> now. Please <span weight='bold'>select</span> me again.")
    else
        local locs = LocSet.of_pairs(wesnoth.paths.find_reach(u, { ignore_units = true }))
        local moves_left = locs:get(tox, toy)
        if u.x ~= x or u.y ~= y or not GetAbilityLevel(u, "war_jump") or
            not moves_left or not is_empty(tox, toy) then
            Popup(_ "Error",
                _ "Can't <span color='red'>War Jump </span> right now. Please <span weight='bold'>select</span> me again.")
        else
            wml.fire("teleport", {
                T.filter { id = unit_id },
                x = tox,
                y = toy,
                animate = true
            })
            u.moves = 0
        end
    end
    UI.clear_menu_item("warjump")
end

local function show_elusive(unit)
    local blocked = available_tiles(unit)
    local listx, listy = to_zip_pairs(blocked)
    local lua_code = Fmt("AB.elusive(%q,%d,%d)", unit.id, unit.x, unit.y)
    UI.setup_menu_elusive(listx, listy, lua_code)
    ANIM.hover_tiles(blocked:to_pairs(), "Right-click here")
end

---@param unit_id string
---@param x integer
---@param y integer
function AB.elusive(unit_id, x, y)
    local u = wesnoth.units.get(unit_id)
    local tox, toy = GetLocation()
    if u == nil then
        Popup(_ "Error",
            _ "Can't be <span color='green'>Elusive</span> right now. Please <span weight='bold'>select</span> me again.")
    else
        local locs = LocSet.of_pairs(wesnoth.paths.find_reach(u, { ignore_units = true }))
        local moves_left = locs:get(tox, toy)
        if u.x ~= x or u.y ~= y or not GetAbilityLevel(u, "elusive") or
            not moves_left or not is_empty(tox, toy) then
            Popup(_ "Error",
                _ "Can't be <span color='green'>Elusive</span> right now. Please <span weight='bold'>select</span> me again.")
        else
            wml.fire("move_unit", {
                id = unit_id,
                to_x = tox,
                to_y = toy,
                fire_event = true
            })
            u.moves = moves_left[3]
        end
    end
    UI.clear_menu_item("elusive")
end

-- ----------------------- ALLIED DEFENSE (Xavier) -----------------------
-- Called on move event
-- We first remove passed defense bonus
-- Then we find the unit who should benefit from Xavier ability
-- Then we apply a trait modification with id _tmp_allies_defense_bonus
local function update_xavier_defense()
    local xavier = wesnoth.units.get("xavier")
    local lvl = GetAbilityLevel(xavier, "allies_defense")
    if not lvl then return end

    local trait_id = "_tmp_allies_defense_bonus"
    local us = wesnoth.units.find_on_map { trait = trait_id }
    for i, u in pairs(us) do u:remove_modifications({ id = trait_id }, "trait") end
    local adj_xavier = wesnoth.units.find_on_map {
        T.filter_adjacent { id = "xavier" },
        T.filter_side { T.allied_with { side = xavier.side } }
    }
    local bonus_def = Conf.amlas.xavier.values.ALLIES_DEFENSE_RATIO * lvl
    for i, u in pairs(adj_xavier) do
        u:add_modification("trait", {
            id = trait_id,
            name = _ "Xavier's defense",
            description = Fmt(
                _ "Xavier is so strong! He grants us <b>%d%%</b> bonus defense",
                bonus_def),
            AddDefenses(bonus_def)
        })
    end
end

-- ------------------------------------ Formations (Xavier) ------------------------------------
local fms = wesnoth.require("xavier_formations")
local formations_def, formations_abilities = fms.def, fms.abs

-- Returns true if all tiles of the formation are allied (and occupied)
---@param xavier unit
local function _check_formation(xavier, formation)
    local side = xavier.side
    for __, tile in ipairs(formation) do
        local u = wesnoth.units.get(tile[1], tile[2])
        if u == nil or wesnoth.sides.is_enemy(side, u.side) then return false end
    end
    return true
end

-- Returns the active formations (xavier need to have the ability corresponding)
---@param xavier unit
function AB.get_active_formations(xavier)
    local tiles_ally = LocSet.create()
    local tiles_target = LocSet.create()
    local active_formations = {}
    if GetAbilityLevel(xavier, "Y_formation") then
        for __, pos in ipairs(formations_def.Y { x = xavier.x, y = xavier.y }) do
            if _check_formation(xavier, pos) then
                tiles_ally:of_pairs(pos)
                active_formations.Y = pos.target
                tiles_target:insert(pos.target[1], pos.target[2])
            end
        end
    end
    if GetAbilityLevel(xavier, "I_formation") then
        for __, pos in ipairs(formations_def.I { x = xavier.x, y = xavier.y }) do
            if _check_formation(xavier, pos) then
                tiles_ally:of_pairs(pos)
                active_formations.I = pos.target
                tiles_target:insert(pos.target[1], pos.target[2])
            end
        end
    end
    if GetAbilityLevel(xavier, "A_formation") then
        for __, pos in ipairs(formations_def.A { x = xavier.x, y = xavier.y }) do
            if _check_formation(xavier, pos) then
                tiles_ally:of_pairs(pos)
                active_formations.A = true
            end
        end
    end
    if GetAbilityLevel(xavier, "O_formation") then
        for __, pos in ipairs(formations_def.O { x = xavier.x, y = xavier.y }) do
            if _check_formation(xavier, pos) then
                tiles_ally:of_pairs(pos)
                active_formations.O = pos.target
                tiles_target:insert(pos.target[1], pos.target[2])
            end
        end
    end
    return active_formations, tiles_ally, tiles_target
end

-- Update abilities related to Formations,
-- and display active ones
local function update_xavier_formation()
    local xavier = wesnoth.units.get("xavier")
    if xavier == nil then return end
    for _, name in pairs({ "A", "I", "Y" }) do -- remove potential old ability
        xavier:remove_modifications({ id = "_formation_" .. name }, "trait")
    end
    local active_formations, tiles, targets = AB.get_active_formations(xavier)
    ANIM.hover_tiles(tiles:to_pairs(), FORMATION_LABEL, nil, targets:to_pairs(),
        TARGET_LABEL, 50)
    for name, target in pairs(active_formations) do
        if not (name == "O") then
            formations_abilities[name](xavier, target)
        end
    end
    formations_abilities.O(xavier, active_formations.O) -- always called, to remove menu item if needed
end

-- --- Special skills (actual action, menu setup is done beforehand) ---
-- Vranken
function AB.transposition()
    local vranken = wesnoth.units.get("vranken")
    if vranken:custom_variables().special_skill_cd > 0 then
        return wesnoth.interface.add_chat_message(_ "Can't jump now !") -- shouln't happen
    end

    local sword_spirit = wesnoth.units.get("sword_spirit")
    ANIM.transposition("vranken", "sword_spirit", true)
    local x, y = vranken.x, vranken.y
    wesnoth.units.extract(vranken)
    wesnoth.units.extract(sword_spirit)
    vranken:to_map(sword_spirit.x, sword_spirit.y)
    sword_spirit:to_map(x, y)
    ANIM.transposition("vranken", "sword_spirit", false)

    local lvl = vranken:custom_variables().special_skills.transposition or 0
    local cd = Conf.special_skills.vranken.transposition(lvl)
    vranken:custom_variables().special_skill_cd = cd
    UI.clear_menu_item("vranken_special_skill")
end

-- Xavier
function AB.union_debuf(x, y)
    local target = wesnoth.units.get(x, y)
    local xavier = wesnoth.units.get("xavier")
    local lvl = xavier:custom_variables().special_skills.O_formation or 0
    local cd = Conf.special_skills.xavier.O_formation(lvl)
    if target == nil or xavier == nil then
        return wesnoth.interface.add_chat_message(_ "Union debuf not possible here ! ") -- shouln't happen
    end

    ANIM.quake()
    local list_abilities = wml.get_child(target.__cfg, "abilities") or {}
    target:add_modification("trait", {
        T.effect { apply_to = "remove_ability", T.abilities(list_abilities) },
        T.effect {
            apply_to = "attack",
            T.set_specials {} -- remove all specials
        }
    })
    wesnoth.interface.float_label(x, y, _ "Disabled !")
    xavier:custom_variables().special_skill_cd = cd
end

-- -------------------------- Event handler --------------------------
function AB.on_moveto()
    local u = PrimaryUnit()
    local xavier = wesnoth.units.get("xavier")
    if not xavier then return end
    if not wesnoth.sides.is_enemy(u.side, xavier.side) then
        update_xavier_defense()
        update_xavier_formation() -- only when necessary, to avoid slows
    end
end

-- Appelée sur sélection d'une unité
function AB.select()
    UI.clear_menu_item("elusive")
    UI.clear_menu_item("war_jump")
    local u = PrimaryUnit()

    if GetAbilityLevel(u, "war_jump") and u.moves > 0 then show_war_jump(u) end

    if GetAbilityLevel(u, "elusive") and u.moves > 0 then show_elusive(u) end

    if u.id == "xavier" then
        local _, tiles, targets = AB.get_active_formations(u)
        ANIM.hover_tiles(tiles:to_pairs(), FORMATION_LABEL, 15,
            targets:to_pairs(), TARGET_LABEL, 50)
    end
end

---Implements the long heal ability (called on each turn)
---@param healer unit
local function long_heal(healer)
    local level_long_heal = GetAbility(healer, "long_heal")._level
    if not level_long_heal then return end
    local value_heal = GetAbility(healer, "better_heal", "heals").value
    local candidates = wesnoth.units.find_on_map {
        T.filter_location { x = healer.x, y = healer.y, radius = 3 }
    }
    local ratio = Conf.amlas.morgane.values.LONG_HEAL_RATIO
    for _, u in pairs(candidates) do
        local d = wesnoth.map.distance_between({ x = u.x, y = u.y }, { x = healer.x, y = healer.y })
        if not wesnoth.sides.is_enemy(healer.side, u.side) and (d == 2 or d == 3) then -- other units will be healed by the standard heal
            local amount = Round(ratio * level_long_heal * value_heal / d)
            wml.fire("heal_unit", {
                T.filter { x = u.x, y = u.y },
                T.filter_second { id = "morgane" },
                amount = amount,
                animate = true
            })
        end
    end
end

-- Should decrease special skill CDs
function AB.turn_start()
    local lhero = wesnoth.units.find_on_map { role = "hero" }
    for _, v in pairs(lhero) do
        local current_cd = v:custom_variables().special_skill_cd or 0
        if current_cd > 0 then
            v:custom_variables().special_skill_cd = current_cd - 1
        end
    end

    local morg = wesnoth.units.get("morgane")
    if morg then long_heal(morg) end
end
