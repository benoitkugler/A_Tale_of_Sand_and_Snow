-- Track special experience gains
local V = Conf.special_xp_gain -- shortcut

local exp_functions = {
    sword_spirit = {},
    brinx = {},
    drumar = {},
    rymor = {},
    bunshop = {},
    global = {},
    xavier = {}
}

-- Funtion called on every unit fighting
function exp_functions.global.combat(atk, def)
    local rymor = wesnoth.units.get("rymor")
    if rymor and rymor:matches { side = def.side, T.filter_adjacent { id = def.id } } then -- defender is ally and next to rymor
        rymor:custom_variables().xp = rymor:custom_variables().xp + atk.level +
            V.rymor
            .ADJ_NEXT -- def next to rymor
    end
    local xavier = wesnoth.units.get("xavier")
    if xavier then
        if xavier:matches { side = atk.side, T.filter_adjacent { id = atk.id } } then -- atker is ally and next to xavier
            xavier:custom_variables().xp = xavier:custom_variables().xp + atk.level +
                V.xavier.LEADERSHIP
        elseif xavier:matches { side = def.side, T.filter_adjacent { id = def.id } } then
            xavier:custom_variables().xp = xavier:custom_variables().xp + def.level +
                V.xavier.LEADERSHIP
        end
    end
end

-- Functions called only when the given hero is fighting

-- ---------------------- Bunshop ----------------------
---@param atk unit
---@param def unit
function exp_functions.bunshop.combat(atk, def)
    if atk.id == "bunshop" then
        Bunshop_atk_unit_full = (def.hitpoints == def.max_hitpoints) -- Storing for event kill

        local c = wesnoth.map.rotate_right_around_center({ x = atk.x, y = atk.y },
            { x = def.x, y = def.y }, 3) -- behind defender
        local u = wesnoth.units.get(c)
        if u and not wesnoth.sides.is_enemy(u.side, atk.side) then
            atk:custom_variables().xp = atk:custom_variables().xp + def.level *
                V.bunshop.ATK_BACKSTAB -- backstab attack
        end
    end
end

function exp_functions.bunshop.kill(kil, dyi)
    if kil.id == "bunshop" then
        if Bunshop_atk_unit_full then
            kil:custom_variables().xp = kil:custom_variables().xp + dyi.level * V.bunshop.ONE_SHOT -- one shot
        end
    end
end

-- ----------------------- Rymor -----------------------
function exp_functions.rymor.combat(atk, def)
    if def.id == "rymor" then
        def:custom_variables().xp = def:custom_variables().xp + atk.level * V.rymor.DEF -- defense
    end
end

-- ------------------ Sword spirit ------------------
function exp_functions.sword_spirit.adv(__)
    local u = wesnoth.units.get("vranken")
    u:custom_variables().xp = u:custom_variables().xp + V.sword_spirit.LEVEL_UP -- sword_spirit lvl up
end

function exp_functions.sword_spirit.combat(atk, def)
    if atk.id == "sword_spirit" then
        local u = wesnoth.units.get("vranken")
        u:custom_variables().xp = u:custom_variables().xp + V.sword_spirit.ATK * def.level -- attaque
    elseif def.id == "sword_spirit" then
        local u = wesnoth.units.get("vranken")
        u:custom_variables().xp = u:custom_variables().xp + atk.level + V.sword_spirit.DEF -- defense
    end
end

---@param kil unit
---@param dyi unit
function exp_functions.sword_spirit.kill(kil, dyi)
    if kil.id == "sword_spirit" then
        local u = wesnoth.units.get("vranken")
        u:custom_variables().xp = u:custom_variables().xp + dyi.level * V.sword_spirit.KILL -- sword_spirit kills
    end
end

-- -------------------- Brinx --------------------
function exp_functions.brinx.combat(atk, def)
    if atk.race == "muspell" and def.id == "brinx" then
        def:custom_variables().xp = def:custom_variables().xp + atk.level + V.brinx
            .DEF_MUSPELL -- defense contre muspell
    elseif def.race == "muspell" and atk.id == "brinx" then
        atk:custom_variables().xp = atk:custom_variables().xp + def.level * V.brinx
            .ATK_MUSPELL -- attaque contre muspell
    end
end

function exp_functions.brinx.kill(kil, dyi)
    if kil.id == "brinx" and dyi.race == "muspell" then
        kil:custom_variables().xp = kil:custom_variables().xp + dyi.level * V.brinx.KILL_MUSPELL -- brinx kills muspell
    end
end

-- -------------------- Drumar --------------------
function exp_functions.drumar.combat(atk, def)
    if def.id == "drumar" then
        local weapon = SWeapon()
        if weapon.type == "cold" then
            def:custom_variables().xp = def:custom_variables().xp + atk.level + V.drumar.DEF_COLD -- defense cold
        end
        if wml.get_child(weapon, "specials") ~= nil and
            wml.get_child(wml.get_child(weapon, "specials") or {}, "slow") ~= nil then
            def:custom_variables().xp = def:custom_variables().xp +
                Round(atk.level * V.drumar.DEF_SLOW) -- defense slow
        end
    elseif atk.id == "drumar" then
        local weapon = PWeapon()
        if weapon.type == "cold" then
            atk:custom_variables().xp = atk:custom_variables().xp + def.level + V.drumar.ATK_COLD
            -- attaque cold
        end
        if wml.get_child(wml.get_child(weapon, "specials") or {}, "slow") ~= nil then
            atk:custom_variables().xp = atk:custom_variables().xp +
                Round(def.level * V.drumar.ATK_SLOW) -- attaque slow
        end
        if wml.get_child(wml.get_child(weapon, "specials") or {}, "customName", "snare") ~=
            nil then
            atk:custom_variables().xp = atk:custom_variables().xp +
                Round(def.level * V.drumar.ATK_SNARE) -- attaque snare
        end
        if weapon.name == "chilling touch" then
            atk:custom_variables().xp = atk:custom_variables().xp +
                Round(def.level * V.drumar.ATK_CHILLING_TOUCH) -- attaque chilling touch
        end
    end
end

-- -------------------- Xavier --------------------
function exp_functions.xavier.combat(atk, def)
    if atk.id == "xavier" then
        local active_formations, __ = AB.active_xavier_formations(atk)
        local fY, fI = active_formations.Y, active_formations.I
        if not (fY == nil) and def.x == fY[1] and def.y == fY[2] then
            atk:custom_variables().xp = atk:custom_variables().xp +
                Round(def.level * V.xavier.Y_FORMATION)
        end
        if not (fI == nil) and def.x == fI[1] and def.y == fI[2] then
            atk:custom_variables().xp = atk:custom_variables().xp +
                Round(def.level * V.xavier.I_FORMATION)
        end
    elseif def.id == "xavier" then
        local active_formations, __ = AB.active_xavier_formations(atk)
        if active_formations.A then
            atk:custom_variables().xp = atk:custom_variables().xp + atk.level +
                V.xavier.A_FORMATION
        end
    end
end

-- Top level
local events = {}

function events.on_advance()
    local unit = PrimaryUnit()
    if exp_functions[unit.id] and exp_functions[unit.id].adv then
        exp_functions[unit.id].adv(unit)
    end
end

function events.on_attack()
    local atker = PrimaryUnit()
    local defer = SecondaryUnit()
    if exp_functions[atker.id] and exp_functions[atker.id].combat then
        exp_functions[atker.id].combat(atker, defer)
    end
    if exp_functions[defer.id] and exp_functions[defer.id].combat then
        exp_functions[defer.id].combat(atker, defer)
    end
    exp_functions.global.combat(atker, defer)
end

function events.on_kill()
    local dying = PrimaryUnit()
    local killer = SecondaryUnit()
    if exp_functions[dying.id] and exp_functions[dying.id].kill then
        exp_functions[dying.id].kill(killer, dying)
    end
    if exp_functions[killer.id] and exp_functions[killer.id].kill then
        exp_functions[killer.id].kill(killer, dying)
    end
end

return events
