-- Track special experience gains
local V = Conf.special_xp_gain -- shortcut

-- Functions called only when the given hero is fighting
---@type table<string, fun(attacker:unit, defender:unit)>
local on_attack_funcs = {
    -- sword_spirit = {},
    -- brinx = {},
    -- drumar = {},
    -- rymor = {},
    -- bunshop = {},
    -- xavier = {},
}

-- Funtion called on every unit fighting
---@param atk unit
---@param def unit
local function on_attack_common(atk, def)
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


-- tag set to true if target Bunshop attack has full hitpoints
local bunshop_atk_unit_full = false

-- ---------------------- Bunshop ----------------------
function on_attack_funcs.bunshop(atk, def)
    if atk.id == "bunshop" then
        bunshop_atk_unit_full = (def.hitpoints == def.max_hitpoints) -- Storing for event kill

        local c = wesnoth.map.rotate_right_around_center({ x = atk.x, y = atk.y },
            { x = def.x, y = def.y }, 3) -- behind defender
        local u = wesnoth.units.get(c)
        if u and not wesnoth.sides.is_enemy(u.side, atk.side) then
            atk:custom_variables().xp = atk:custom_variables().xp + def.level *
                V.bunshop.ATK_BACKSTAB -- backstab attack
        end
    end
end

---@param kil unit
---@param dyi unit
local function bunshop_on_kill(kil, dyi)
    if bunshop_atk_unit_full then
        kil:custom_variables().xp = kil:custom_variables().xp + dyi.level * V.bunshop.ONE_SHOT -- one shot
    end
end

-- ----------------------- Rymôr -----------------------
function on_attack_funcs.rymor(atk, def)
    if def.id == "rymor" then
        def:custom_variables().xp = def:custom_variables().xp + atk.level * V.rymor.DEF -- defense
    end
end

-- ------------------ Sword spirit ------------------
local function sword_spirit_on_adv()
    local u = wesnoth.units.get("vranken")
    u:custom_variables().xp = u:custom_variables().xp + V.sword_spirit.LEVEL_UP -- sword_spirit lvl up
end

function on_attack_funcs.sword_spirit(atk, def)
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
local function sword_spirit_on_kill(kil, dyi)
    local u = wesnoth.units.get("vranken")
    u:custom_variables().xp = u:custom_variables().xp + dyi.level * V.sword_spirit.KILL -- sword_spirit kills
end

-- -------------------- Brinx --------------------
function on_attack_funcs.brinx(atk, def)
    if atk.race == "muspell" and def.id == "brinx" then
        def:custom_variables().xp = def:custom_variables().xp + atk.level + V.brinx
            .DEF_MUSPELL -- defense contre muspell
    elseif def.race == "muspell" and atk.id == "brinx" then
        atk:custom_variables().xp = atk:custom_variables().xp + def.level * V.brinx
            .ATK_MUSPELL -- attaque contre muspell
    end
end

---@param kil unit
---@param dyi unit
local function brinx_on_kill(kil, dyi)
    if dyi.race == "muspell" then
        kil:custom_variables().xp = kil:custom_variables().xp + dyi.level * V.brinx.KILL_MUSPELL -- brinx kills muspell
    end
end

-- -------------------- Drumar --------------------
function on_attack_funcs.drumar(atk, def)
    if def.id == "drumar" then
        local weapon = SWeapon()
        if weapon.type == "cold" then
            def:custom_variables().xp = def:custom_variables().xp + atk.level + V.drumar.DEF_COLD -- defense cold
        end
        if weapon:special(nil, "slow") then
            def:custom_variables().xp = def:custom_variables().xp +
                Round(atk.level * V.drumar.DEF_SLOW) -- defense slow
        end
    elseif atk.id == "drumar" then
        local weapon = PWeapon()
        if weapon.type == "cold" then
            atk:custom_variables().xp = atk:custom_variables().xp + def.level + V.drumar.ATK_COLD
            -- attaque cold
        end
        if weapon:special(nil, "slow") then
            atk:custom_variables().xp = atk:custom_variables().xp +
                Round(def.level * V.drumar.ATK_SLOW) -- attaque slow
        end
        if weapon:special("snare") then
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
function on_attack_funcs.xavier(atk, def)
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

-- -------------------- Porthos --------------------


---@param porthos unit
local function porthos_on_hit(porthos)
    local dmg = wesnoth.current.event_context.damage_inflicted
    local xp_gain = Round(Conf.special_xp_gain.porthos.DMG_TAKEN_RATIO * dmg)
    porthos:custom_variables().xp = porthos:custom_variables().xp + xp_gain
end



-- Top level
local events = {}

function events.on_advance()
    local unit = PrimaryUnit()
    if unit.id == "sword_spirit" then
        sword_spirit_on_adv()
    end
end

function events.on_attack()
    local atker = PrimaryUnit()
    local defer = SecondaryUnit()
    if on_attack_funcs[atker.id] then
        on_attack_funcs[atker.id](atker, defer)
    elseif on_attack_funcs[defer.id] then
        on_attack_funcs[defer.id](atker, defer)
    end

    on_attack_common(atker, defer)
end

function events.on_kill()
    local dying = PrimaryUnit()
    local killer = SecondaryUnit()
    if killer.id == "sword_spirit" then
        sword_spirit_on_kill(killer, dying)
    elseif killer.id == "bunshop" then
        bunshop_on_kill(killer, dying)
    elseif killer.id == "brinx" then
        brinx_on_kill(killer, dying)
    end
end

function events.on_attacker_hits()
    local atker = PrimaryUnit()
    local defer = SecondaryUnit()
    if defer.id == "porthos" then
        porthos_on_hit(defer)
    end
end

function events.on_defender_hits()
    local atker = PrimaryUnit()
    local defer = SecondaryUnit()
    if atker.id == "porthos" then
        porthos_on_hit(atker)
    end
end

return events
