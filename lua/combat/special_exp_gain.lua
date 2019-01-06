-- Track special experience gains
local V = {
    rymor = {
        ADJ_NEXT = 2, -- + atk.level
        DEF = 2, -- * atk.level
    },
    brinx = {
        DEF_MUSPELL = 1, -- + ath.level
        ATK_MUSPELL = 3, -- * def.level
        KILL_MUSPELL = 5, -- * dying.level
    },
    sword_spirit = { -- xp goes to vranken
        LEVEL_UP = 60, -- on level up
        ATK = 2, -- * def.level
        DEF = 1, -- + def.level
        KILL = 3, -- * dying.level
    },
    drumar = {
        DEF_COLD = 1, -- + atk.level
        DEF_SLOW = 1.45, -- * atk.level
        ATK_COLD = 2, -- + def.level
        ATK_SLOW = 1.5, -- * def.level
        ATK_SNARE = 2, -- * def.level
        ATK_CHILLING_TOUCH = 2.4, -- * def.level
    },
    bunshop = {
        ATK_BACKSTAB = 2, -- * def.level
        ONE_SHOT = 4, -- * dying.level
    }
}

local exp_functions = {
    sword_spirit = {},
    brinx = {},
    drumar = {},
    rymor = {},
    bunshop = {},
    global = {}
}

function exp_functions.global.combat(atk, def)
    local rymor = wesnoth.get_unit("rymor")
    if #(wesnoth.get_units {
        id = "rymor",
        side = def.side,
        T.filter_adjacent {
            id = def.id,
        }
    }) then -- defender is ally and next to rymor
        rymor.variables.xp = rymor.variables.xp + atk.level + V.rymor.ADJ_NEXT -- def next to rymor
    end
end

-- ---------------------- Bunshop ----------------------
function exp_functions.bunshop.combat(atk, def)
    if atk.id == "bunshop" then
        bunshop_atk_unit_full = (def.hitpoints == def.max_hitpoints) -- Storing for event kill

        local c = wesnoth.map.rotate_right_around_center({atk.x, atk.y}, {def.x, def.y}, 3) -- behind defender
        local u = wesnoth.get_unit(c[1], c[2])
        if u and not wesnoth.is_ennemy(u.side, atk.side) then
            atk.variables.xp = atk.variables.xp + def.__cfg.level * V.bunshop.ATK_BACKSTAB --backstab attack
        end
    end
end

function exp_functions.bunshop.kill(kil, dyi)
    if kil.id == "bunshop" then
        if bunshop_atk_unit_full then
            kil.variables.xp = kil.variables.xp + dyi.__cfg.level * V.bunshop.ONE_SHOT -- one shot
        end
    end
end

-- ----------------------- Rymor -----------------------
function exp_functions.rymor.combat(atk, def)
    if def.id == "rymor" then
        def.variables.xp = def.variables.xp + atk.__cfg.level * V.rymor.DEF --defense
    end
end

-- ------------------ Sword spirit ------------------
function exp_functions.sword_spirit.adv(__)
    local u = wesnoth.get_units {id = "vranken"}[1]
    u.variables.xp = u.variables.xp + V.sword_spirit.LEVEL_UP -- sword_spirit lvl up
end

function exp_functions.sword_spirit.combat(atk, def)
    if atk.id == "sword_spirit" then
        local u = wesnoth.get_units {id = "vranken"}[1]
        u.variables.xp = u.variables.xp +  V.sword_spirit.ATK * def.__cfg.level --attaque
    elseif def.id == "sword_spirit" then
        local u = wesnoth.get_units {id = "vranken"}[1]
        u.variables.xp = u.variables.xp + atk.__cfg.level + V.sword_spirit.DEF --defense
    end
end

function exp_functions.sword_spirit.kill(kil, dyi)
    if kil.id == "sword_spirit" then
        local u = wesnoth.get_units {id = "vranken"}[1]
        u.variables.xp = u.variables.xp + dyi.__cfg.level * V.sword_spirit.KILL --sword_spirit kills
    end
end

-- -------------------- Brinx --------------------
function exp_functions.brinx.combat(atk, def)
    if atk.race == "muspell" and def.id == "brinx" then
        def.variables.xp = def.variables.xp + atk.__cfg.level + V.brinx.DEF_MUSPELL --defense contre muspell
    elseif def.race == "muspell" and atk.id == "brinx" then
        atk.variables.xp = atk.variables.xp + def.__cfg.level * V.brinx.ATK_MUSPELL --attaque contre muspell
    end
end

function exp_functions.brinx.kill(kil, dyi)
    if kil.id == "brinx" and dyi.race == "muspell" then
        kil.variables.xp = kil.variables.xp  + dyi.__cfg.level * V.brinx.KILL_MUSPELL --brinx kills muspell
    end
end

-- -------------------- Drumar --------------------
function exp_functions.drumar.combat(atk, def)
    if def.id == "drumar" then
        local weapon = H.get_child(wesnoth.current.event_context, "second_weapon")
        if weapon.type == "cold" then
            def.variables.xp = def.variables.xp + atk.__cfg.level + V.drumar.DEF_COLD --defense cold
        end
        if H.get_child(weapon, "specials") ~= nil and H.get_child(H.get_child(weapon, "specials"), "slow") ~= nil then
            def.variables.xp = def.variables.xp + arrondi(atk.__cfg.level * V.drumar.DEF_SLOW) --defense slow
        end
    elseif atk.id == "drumar" then
        local weapon = H.get_child(wesnoth.current.event_context, "weapon")
        if weapon.type == "cold" then
            atk.variables.xp = atk.variables.xp + def.__cfg.level + V.drumar.ATK_COLD
        --attaque cold
        end
        if H.get_child(weapon, "specials") ~= nil and H.get_child(H.get_child(weapon, "specials"), "slow") ~= nil then
            atk.variables.xp = atk.variables.xp + arrondi(def.__cfg.level * V.drumar.ATK_SLOW) --attaque slow
        end
        if
            H.get_child(weapon, "specials") ~= nil and
                H.get_child(H.get_child(weapon, "specials"), "isHere", "snare") ~= nil
         then
            atk.variables.xp = atk.variables.xp + arrondi(def.__cfg.level * V.drumar.ATK_SNARE) --attaque snare
        end
        if weapon.name == "chilling touch" then 
            atk.variables.xp = atk.variables.xp + arrondi(def.__cfg.level * V.drumar.ATK_CHILLING_TOUCH) --attaque chilling touch
        end
    end
end

-- Top level
EXP = {}
function EXP.adv()
    local unit = get_pri()
    if exp_functions[unit.id] and exp_functions[unit.id].adv then
        exp_functions[unit.id].adv(unit)
    end
end

function EXP.atk()
    local atker = get_pri()
    local defer = get_snd()
    if exp_functions[atker.id] and exp_functions[atker.id].combat then
        exp_functions[atker.id].combat(atker, defer)
    end
    if exp_functions[defer.id] and exp_functions[defer.id].combat then
        exp_functions[defer.id].combat(atker, defer)
    end
    exp_functions.global.combat(atker, defer)
end

function EXP.kill()
    local dying = get_pri()
    local killer = get_snd()
    if exp_functions[dying.id] and exp_functions[dying.id].kill then
        exp_functions[dying.id].kill(killer, dying)
    end
    if exp_functions[killer.id] and exp_functions[killer.id].kill then
        exp_functions[killer.id].kill(killer, dying)
    end
end
