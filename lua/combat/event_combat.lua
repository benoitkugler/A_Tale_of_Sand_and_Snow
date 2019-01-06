-- Implementation of special effect during figth.
EC = {}

local COLOR_MAGIC_RES_SHRED = "#B95C43"
local COLOR_DEFENSE_SHRED = "#994d00"


--Fonctions d'applications des effets
local endturn = {}
local apply = {}
local noms = {}
setmetatable(
    apply,
    {__newindex = function(t, k, v)
            table.insert(noms, k)
            rawset(t, k, v)
        end}
)

local label_pri, label_snd = "", "" -- Labels personnalisés
local delay = 0

function EC.combat(dmg_dealt)
    delay = 0
    local type_event = wesnoth.current.event_context.name
    local u1, u2 = get_pri(), get_snd()
    label_pri, label_snd = "", ""
    local x1, y1, x2, y2 = u1 and u1.x, u1 and u1.y, u2 and u2.x, u2 and u2.y

    for nb, i in ipairs(noms) do
        if u1 and u1.valid and u2 and u2.valid then
            apply[i](type_event, u1, u2, dmg_dealt)
        end
    end

    if x1 and y1 then
        if delay > 0 then
            wesnoth.delay(delay)
        end
        wesnoth.float_label(x1, y1, label_pri)
    end
    if x2 and y2 then
        if delay > 0 then
            wesnoth.delay(delay)
        end
        wesnoth.float_label(x2, y2, label_snd)
    end
    if delay > 0 then
        wesnoth.delay(delay)
    end
    if not (u1 == nil) and u1.valid then
        u1:advance(true, true)
    end 
    if not (u2 == nil) and u2.valid then
        u2:advance(true, true)
    end
end

function EC.fin_tour()
    lhero = wesnoth.get_units {role = "hero"}
    for i, v in pairs(lhero) do
        v.variables.bloodlust = false
    end
    for i, v in pairs(endturn) do
        v()
    end
end

-- ABILITIES GENERIQUES

-- Shield flat
function apply.shield_flat(event, pri, snd, dmg)
    local s1, s2 = pri.level * 2, snd.level * 2 --shields
    if event == "attack" then
        if get_ability(pri, "shield_flat") then
            pri.hitpoints = pri.hitpoints + s1
        end
        if get_ability(snd, "shield_flat") then
            snd.hitpoints = snd.hitpoints + s2
        end
    elseif event == "attacker_hits" then
        if get_ability(snd, "shield_flat") then
            if dmg < s2 then
                snd.hitpoints = snd.hitpoints + dmg
            elseif snd.hitpoints > 0 then
                snd.hitpoints = snd.hitpoints + s2
            end
            label_snd = label_snd .. "<span color='#4A4257'>" .. _ " shield : " .. s2 .. " hitpoints" .. "</span>\n"
        end
    elseif event == "defender_hits" then
        if get_ability(pri, "shield_flat") then
            if dmg < s1 then
                pri.hitpoints = pri.hitpoints + dmg
            elseif pri.hitpoints > 0 then
                pri.hitpoints = pri.hitpoints + s1
            end
            label_pri = label_pri .. "<span color='#4A4257'>" .. _ " shield : " .. s1 .. " hitpoints" .. "</span>\n"
        end
    elseif event == "attack_end" then
        if get_ability(pri, "shield_flat") then
            pri.hitpoints = pri.hitpoints - s1
        end
        if get_ability(snd, "shield_flat") then
            snd.hitpoints = snd.hitpoints - s2
        end
    end
end

--  War leeches

function apply.war_leeches(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = get_ability(snd, "war_leeches")
        if lvl then
            wesnoth.fire("heal_unit", {T.filter {id = snd.id}, animate = true, amount = 2 * lvl}) --def is hit
        end
    end
end

--ABILITY SPECIAL de BRINX
function apply.bloodlust(event, pri, snd, dmg)
    if event == "die" then
        if get_ability(snd, "bloodlust") then
            if snd.variables and not snd.variables.bloodlust then
                snd.variables.bloodlust = true
                snd.moves = 4 --on kill
                snd.attacks_left = 1
            end
        end
    end
end

function apply.fresh_blood_musp(event, pri, snd, dmg)
    if event == "die" then
        local lvl = get_ability(snd, "fresh_blood_musp")
        if not lvl then
            return
        end
        if pri.__cfg.race == "muspell" then
            wesnoth.fire(
                "heal_unit",
                {animate = (snd.hitpoints ~= snd.max_hitpoints), T.filter {id = snd.id}, amount = 2 + 6 * lvl}
            ) --on kill
        end
    end
end

--WEAPON SPECIAL

-- Leeches
function apply.leeches(event, pri, snd, dmg)
    local lvl, u
    if event == "attacker_hits" then
        lvl = get_special(H.get_child(wesnoth.current.event_context, "weapon"), "leeches")
        u = pri
    elseif event == "defender_hits" then
        lvl = get_special(H.get_child(wesnoth.current.event_context, "second_weapon"), "leeches")
        u = snd
    end
    if lvl then
        if u.hitpoints < u.max_hitpoints then
            wesnoth.fire(
                "heal_unit",
                {T.filter {id = u.id}, animate = true, amount = arrondi(dmg * (0.05 + 0.05 * lvl))}
            ) --toujours
        end
    end
end

-- Pierce
function apply.weapon_pierce(event, pri, snd, dmg)
    if event == "attacker_hits" and get_special(H.get_child(wesnoth.current.event_context, "weapon"), "weapon_pierce") then
        local loc = case_derriere(pri.x, pri.y, snd.x, snd.y)
        local weapon = H.get_child(wesnoth.current.event_context, "weapon")
        wesnoth.fire(
            "harm_unit",
            {
                T.filter {x = loc[1], y = loc[2], {"not", {side = pri.side}}},
                annimate = true,
                fire_event = true,
                damage_type = weapon.type,
                amount = arrondi(dmg * 0.5)
            }
        ) --atker hit
    end
end

-- Mayhem
function apply.mayhem(event, pri, snd, dmg)
    if event == "attacker_hits" and get_special(H.get_child(wesnoth.current.event_context, "weapon"), "mayhem") then
        wesnoth.add_modification(snd, "object", {T.effect {apply_to = "attack", increase_damage = -1}}, false) --atker hit
    end
end

-- Cleave
function apply.cleave(event, pri, snd, dmg)
    if event == "attacker_hits" and get_special(H.get_child(wesnoth.current.event_context, "weapon"), "cleave") then
        local l =
            wesnoth.get_locations {
            T.filter_adjacent_location {x = pri.x, y = pri.y},
            T.filter_adjacent_location {x = snd.x, y = snd.y}
        }
        local att = H.get_child(wesnoth.current.event_context, "weapon")
        for i, v in pairs(l) do
            wesnoth.fire(
                "harm_unit",
                {
                    T.filter_second {id = pri.id},
                    experience = true,
                    T.filter {x = v[1], y = v[2], {"not", {side = pri.side}}},
                    fire_event = true,
                    annimate = true,
                    damage_type = att.type,
                    amount = arrondi(dmg * 0.75)
                }
            ) --atker hit
        end
    end
end

function apply.res_magic(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = get_special(H.get_child(wesnoth.current.event_context, "weapon"), "res_magic")
        if lvl then
            local value = 3 + 2 * lvl --atker hit
            wesnoth.add_modification(
                snd,
                "object",
                {T.effect {apply_to = "resistance", {"resistance", {fire = value, cold = value, arcane = value}}}},
                false
            )
            label_snd = label_snd .. fmt(_"<span color='%s'>-%d%% magic resistances</span>\n", COLOR_MAGIC_RES_SHRED, value)
        end
    end
end

function apply.defense_shred(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = get_special(H.get_child(wesnoth.current.event_context, "weapon"), "defense_shred")
        if lvl then
            local shred_per_hit = DB_AMLAS[pri.id].values.REDUCE_DEFENSE * lvl
            snd:add_modification(
                "trait",
                {
                    add_defenses(- shred_per_hit)
                },
                false
            )
            label_snd = label_snd .. fmt(_"<span color='%s'>-%d%% magic resistances</span>\n", COLOR_DEFENSE_SHRED, shred_per_hit)
        end
    end
end

function apply.weaker_slow(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = get_special(H.get_child(wesnoth.current.event_context, "weapon"), "weaker_slow")
        if lvl then
            local value = 5 + 5 * lvl --atker hit
            wesnoth.add_modification(
                snd,
                "object",
                {duration = "turn_end", T.effect {apply_to = "attack", increase_damage = "-" .. value .. "%"}},
                true
            )
            label_snd = label_snd .. _ "<span color='#919191'>-" .. value .. "% damage</span>\n"
        end
    end
end

function apply.snare(event, pri, snd, dmg)
    if event == "attacker_hits" and get_special(H.get_child(wesnoth.current.event_context, "weapon"), "snare") then
        wesnoth.add_modification(
            snd,
            "object",
            {duration = "turn_end", T.effect {apply_to = "movement", set = 0}},
            true
        )
        label_snd = label_snd .. _ "<span color='#1CDC3F'>Snared</span>\n"
    end
end

function apply.slow_zone(event, pri, snd, dmg)
    local lvl = get_special(H.get_child(wesnoth.current.event_context, "weapon"), "slow_zone")
    if event == "attacker_hits" and lvl then
        local intensity = SPECIAL_SKILLS.info[pri.id].slow_zone(lvl)
        local targets = wesnoth.get_units {T.filter_adjacent {id = snd.id, is_enemy = false}}
        for i, v in pairs(targets) do
            if not v.status._zone_slowed then
                v.status._zone_slowed = true
                v:add_modification(
                    "trait",
                    {
                        T.effect {
                            apply_to = "attack",
                            increase_damage = tostring(-intensity) .. "%"
                        },
                        T.effect {
                            apply_to = "movement",
                            increase = tostring(-intensity) .. "%"
                        }
                    }
                )
                wesnoth.float_label(v.x, v.y, _ "<span color='#00A8A2'>Slowed !</span>")
            end
        end
    end
end

-- Consume chilled status
function apply.chilled_dmg(event, pri, snd, dmg)
    if event == "attacker_hits" and snd.status.chilled then
        local special_lvl = snd.variables.status_chilled_lvl
        local att = H.get_child(wesnoth.current.event_context, "weapon")
        local values = SPECIAL_SKILLS.info.drumar.bonus_cold_mistress(special_lvl - 1)
        local percent_bonus = values[1]
        local bonus_dmg = arrondi(dmg * percent_bonus / 100)
        if att.type == "cold" then
            local dmg_display 
            if snd.hitpoints - bonus_dmg > 0 then
                snd.hitpoints = snd.hitpoints - bonus_dmg
                dmg_display = bonus_dmg
            else
                dmg_display = snd.hitpoints
                if snd.level == 0 then
                    pri.experience = pri.experience + 4
                else
                    pri.experience = pri.experience + 8 * snd.level
                end
                wesnoth.fire("kill", {id = snd.id, {"second_unit", {id = pri.id}}, animate = true, fire_event = true})
            end
            label_snd = label_snd .. "<span color='#1ED9D0'>" .. dmg_display .. "</span>\n"
        end
    end
end

-- Apply chilled status on target
-- table_status_chilled has id with _ instead of - as keys, and a 2 char string lvl cd 
function apply.put_status_chilled(event, pri, snd, dmg)
    if event == "attacker_hits" and snd then
        local lvl = get_special(H.get_child(wesnoth.current.event_context, "weapon"), "status_chilled")
        if lvl and not snd.status.chilled then
            local values = SPECIAL_SKILLS.info.drumar.bonus_cold_mistress(lvl - 1)
            local cd = values[2]
            snd.variables.status_chilled_lvl = lvl
            snd.variables.status_chilled_cd =  cd 
            -- if VAR.table_status_chilled == nil then
            --     H.set_variable_array("table_status_chilled", {{id = snd.id, lvl = lvl, cd = cd}})
            -- else 
            --     table.insert(VAR.table_status_chilled, {id = snd.id, lvl = lvl, cd = cd})
            -- end
            snd.status.chilled = true
            label_snd = label_snd .. _ "<span color='#1ED9D0'>Chilled !</span>\n"
        end
    end
end

-- Mise à jour des status chilled
function endturn.status_chilled()
    local us = wesnoth.get_units { status = "chilled" }
    for id, u in ipairs(us) do
        local lvl, cd = u.variables.status_chilled_lvl, u.variables.status_chilled_cd
        wesnoth.message(id .. lvl .. cd)
        if cd == 1 then
            u.status.chilled = nil
            u.variables.status_chilled_lvl = nil
            u.variables.status_chilled_cd = nil
        elseif cd then
            u.variables.status_chilled_cd =  u.variables.status_chilled_cd - 1
        end 
    end
end 

function apply.shield(event, pri, snd, dmg)
    if event == "attack" then
        if pri.status.shielded then
            local s = case_array(H.get_variable_array("table_status.shielded"), pri.id).value
            pri.hitpoints = pri.hitpoints + s
            label_pri = label_pri .. "<span color='#4A4257'> +" .. s .. _ " shield points</span>\n"
        end
        if snd.status.shielded then
            local s = case_array(H.get_variable_array("table_status.shielded"), snd.id).value
            snd.hitpoints = snd.hitpoints + s
            label_snd = label_snd .. "<span color='#4A4257'> +" .. s .. _ " shield points</span>\n"
        end
        delay = 50
    end
    if event == "attacker_hits" and snd.status.shielded then
        local c, i = case_array(H.get_variable_array("table_status.shielded"), snd.id)
        local sh = c.value
        if dmg >= sh then
            VAR.table_status.shielded[i - 1] = nil
            snd.status.shielded = nil
        else
            VAR.table_status.shielded[i - 1].value = sh - dmg
        end
    end
    if event == "defender_hits" and pri.status.shielded then
        local c, i = case_array(H.get_variable_array("table_status.shielded"), pri.id)
        local sh = c.value
        if dmg >= sh then
            VAR.table_status.shielded[i - 1] = nil
            pri.status.shielded = nil
        else
            VAR.table_status.shielded[i - 1].value = sh - dmg
        end
    end
    if event == "attack_end" then
        if pri.status.shielded then
            local s = case_array(H.get_variable_array("table_status.shielded"), pri.id).value
            pri.hitpoints = pri.hitpoints - s
        end
        if snd.status.shielded then
            local s = case_array(H.get_variable_array("table_status.shielded"), snd.id).value
            snd.hitpoints = snd.hitpoints - s
        end
    end
end

function endturn.status_shielded()
    local l_status = wesnoth.get_units {status = "shielded"}
    for i, v in ipairs(l_status) do
        v.status.shielded = nil
    end
    VAR.table_status_shielded = nil
    VAR.table_status_shielded = {}
end

--Tri pour executer les skills dans l'ordre souhaité
table.sort(noms)
