-- ------------------------------------ Formations (Xavier) ------------------------------------
-- A formation is defined by a function taking the center tile, ie xaviers'tile, and returning
-- a table of table of tiles, (an inner table being a possible formation)
local formations_def = {}

---@param center location
---@return table[]
function formations_def.Y(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_hexes(center)
    local formations = {}
    for __, c in ipairs({ c1, c2, c3, c4, c5, c6 }) do
        local front = wesnoth.map.rotate_right_around_center(center, c, 3) -- in front of xavier
        local Y_1 = wesnoth.map.rotate_right_around_center(front, c, 1)
        local Y_2 = wesnoth.map.rotate_right_around_center(front, c, -1)
        table.insert(formations, { target = c, center, Y_1, Y_2 })
    end
    return formations
end

---@param center location
---@return table[]
function formations_def.A(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_hexes(center)
    local formations = {}
    for __, c in ipairs({ c1, c2, c3, c4, c5, c6 }) do
        local adj = wesnoth.map.rotate_right_around_center(c, center, 2)
        table.insert(formations, { center, c, adj })
    end
    return formations
end

---@param center location
---@return table[]
function formations_def.I(center)
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_hexes(center)
    local formations = {}
    for __, c in ipairs({ c1, c2, c3, c4, c5, c6 }) do
        local behind = wesnoth.map.rotate_right_around_center(center, c, 3)
        local target = wesnoth.map.rotate_right_around_center(c, center, 3)
        table.insert(formations, { target = target, center, c, behind })
    end
    return formations
end

---@param center location
---@return table[]
function formations_def.O(center)
    local xavier = wesnoth.units.get(center[1], center[2])
    if xavier == nil or not (xavier.id == "xavier") then
        wesnoth.interface.add_chat_message("O_formation should be called on Xavier's tile only !")
        return {}
    end
    local c1, c2, c3, c4, c5, c6 = wesnoth.map.get_adjacent_hexes(center)
    local formations = {}
    for __, c in ipairs({ c1, c2, c3, c4, c5, c6 }) do
        local is_encerclement = true
        local u = wesnoth.units.get(c[1], c[2])
        if not (u == nil) and wesnoth.sides.is_enemy(u.side, xavier.side) then
            local d1, d2, d3, d4, d5, d6 = wesnoth.map.get_adjacent_hexes(c)
            for __, d in ipairs({ d1, d2, d3, d4, d5, d6 }) do
                local ud = wesnoth.units.get(d[1], d[2])
                if ud == nil or wesnoth.sides.is_enemy(ud.side, xavier.side) then -- no encerclement
                    is_encerclement = false
                    break
                end
            end
            if is_encerclement then
                table.insert(formations, { target = c, d1, d2, d3, d4, d5, d6 })
            end
        end
    end
    return formations
end

-- Application of ablities when a formation is active
local formations_abilities = {}
function formations_abilities.Y(xavier, target)
    local lvl = GetAbilityLevel(xavier, "Y_formation")
    if lvl then
        local value = Conf.special_skills.xavier.Y_formation(lvl)
        local x, y = target[1], target[2]
        xavier:add_modification("trait", {
            id = "_formation_Y",
            T.effect {
                apply_to = "attack",
                T.set_specials {
                    mode = "append",
                    T.attacks {
                        add = value,
                        name = _ "Back formation",
                        active_on = "offense",
                        T.filter_opponent { x = x, y = y }
                    }
                }
            }
        })
    end
end

function formations_abilities.A(xavier)
    local lvl = GetAbilityLevel(xavier, "A_formation")
    if lvl then
        local value = Conf.special_skills.xavier.A_formation(lvl)
        xavier:add_modification("trait",
            { id = "_formation_A", AddDefenses(value) })
    end
end

function formations_abilities.I(xavier, target)
    local lvl = GetAbilityLevel(xavier, "I_formation")
    if lvl then
        local value = Conf.special_skills.xavier.I_formation(lvl)
        local x, y = target[1], target[2]
        xavier:add_modification("trait", {
            id = "_formation_I",
            T.effect {
                apply_to = "attack",
                T.set_specials {
                    mode = "append",
                    T.damage {
                        add = value,
                        name = _ "Spear formation",
                        active_on = "offense",
                        T.filter_opponent { x = x, y = y }
                    }
                }
            }
        })
    end
end

---@param xavier unit
---@param target unit
function formations_abilities.O(xavier, target)
    UI.clear_menu_item("union_debuf") -- removing then rebuilding
    local lvl = GetAbilityLevel(xavier, "O_formation")
    local cd = xavier:custom_variables().special_skill_cd or 0
    if lvl and target and (cd == 0) then
        local x, y = target[1], target[2]
        local lua_code = string.format("AB.union_debuf(%d, %d)", x, y)
        UI.setup_menu_debuf(x, y, lua_code)
    end
end

return { def = formations_def, abs = formations_abilities }
