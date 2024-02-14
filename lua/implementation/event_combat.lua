-- Implementation of special effect during figth.
EC = {}

-- TODO: Use values defined in Conf

local COLOR_MAGIC_RES_SHRED = "#B95C43"
local COLOR_ARMOR_SHRED = "#104d00"
local COLOR_DEFENSE_SHRED = "#994d00"
local COLOR_SHIELDED = "#4A4257"

-- Table of event handlers
local endturn = {}                  -- end of turn event
---@type table<string, fun(event:string, primary:unit, secondary:unit, dmg_dealt: integer)>
local apply = {}                    -- combat event

local label_pri, label_snd = "", "" -- custom labels
local delay = 0

local keys

---Called with events: attack, attacker_hits, defender_hits, attack_end, die
function EC.on_combat_event()
    local dmg_dealt = wesnoth.current.event_context.damage_inflicted
    delay = 0
    local type_event = wesnoth.current.event_context.name
    local u1, u2 = PrimaryUnit(), SecondaryUnit()
    label_pri, label_snd = "", ""
    local x1, y1, x2, y2 = u1 and u1.x, u1 and u1.y, u2 and u2.x, u2 and u2.y

    for __, i in ipairs(keys) do
        if u1 and u1.valid and u2 and u2.valid then
            apply[i](type_event, u1, u2, dmg_dealt)
        end
    end

    if x1 and y1 then
        if delay > 0 then wesnoth.interface.delay(delay, true) end
        wesnoth.interface.float_label(x1, y1, label_pri)
    end
    if x2 and y2 then
        if delay > 0 then wesnoth.interface.delay(delay, true) end
        wesnoth.interface.float_label(x2, y2, label_snd)
    end
    if delay > 0 then wesnoth.interface.delay(delay, true) end
    if not (u1 == nil) and u1.valid then u1:advance(true, true) end
    if not (u2 == nil) and u2.valid then u2:advance(true, true) end
end

function EC.fin_tour()
    local lhero = wesnoth.units.find_on_map { role = "hero" }
    for __, v in pairs(lhero) do v:custom_variables().bloodlust = false end
    for __, v in pairs(endturn) do v() end
end

-- COMMON ABILITIES

-- Shield flat : absorb a fix amount of dmg on every hit, defense and offense.
-- TODO:Object : to refactor.
function apply.shield_flat(event, pri, snd, dmg)
    local s1, s2 = pri.level * 2, snd.level * 2 -- shields
    if event == "attack" then                   -- adding shield value to avoid temporary death.
        if pri:ability_level("shield_flat") then
            pri.hitpoints = pri.hitpoints + s1
        end
        if snd:ability_level("shield_flat") then
            snd.hitpoints = snd.hitpoints + s2
        end
    elseif event == "attacker_hits" then
        if snd:ability_level("shield_flat") then
            if dmg < s2 then
                snd.hitpoints = snd.hitpoints + dmg
            elseif snd.hitpoints > 0 then
                snd.hitpoints = snd.hitpoints + s2
            end
            label_snd =
                label_snd .. "<span color='#4A4257'>" .. _ " shield : " .. s2 ..
                " hitpoints" .. "</span>\n"
        end
    elseif event == "defender_hits" then
        if pri:ability_level("shield_flat") then
            if dmg < s1 then
                pri.hitpoints = pri.hitpoints + dmg
            elseif pri.hitpoints > 0 then
                pri.hitpoints = pri.hitpoints + s1
            end
            label_pri =
                label_pri .. "<span color='#4A4257'>" .. _ " shield : " .. s1 ..
                " hitpoints" .. "</span>\n"
        end
    elseif event == "attack_end" then
        if pri:ability_level("shield_flat") then
            pri.hitpoints = pri.hitpoints - s1
        end
        if snd:ability_level("shield_flat") then
            snd.hitpoints = snd.hitpoints - s2
        end
    end
end

--  War leeches

function apply.war_leeches(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = snd:ability_level("war_leeches")
        if lvl then
            wml.fire("heal_unit", {
                T.filter { id = snd.id },
                animate = true,
                amount = 2 * lvl
            }) -- def is hit
        end
    end
end

-- BRINX and MARK special skill
function apply.bloodlust(event, pri, snd, dmg)
    if event == "die" then
        if snd:ability_level("bloodlust") then
            if not snd:custom_variables().bloodlust then
                snd:custom_variables().bloodlust = true -- limit the effect
                snd.moves = 4
                snd.attacks_left = 1
                wesnoth.interface.float_label(snd.x, snd.y, "<span color='#eb7521'>Bloodlust !</span>")
            end
        end
    end
end

function apply.fresh_blood_musp(event, pri, snd, dmg)
    if event == "die" then
        local lvl = snd:ability_level("fresh_blood_musp")
        if not lvl then return end
        if pri.race == "muspell" then
            wml.fire("heal_unit", {
                animate = (snd.hitpoints ~= snd.max_hitpoints),
                T.filter { id = snd.id },
                amount = 2 + 6 * lvl
            }) -- on kill
        end
    end
end

-- Deflect
function apply.deflect(event, _, snd, dmg)
    if event == "attacker_hits" and snd:ability_level("deflect") then
        snd.hitpoints = snd.hitpoints + Round(dmg / 2)
        local enemies = wesnoth.units.find_on_map {
            T.filter_adjacent { id = snd.id }, { "not", { side = snd.side } }
        }
        local amount = Round(dmg / 2 / #(enemies))
        local att = PWeapon()
        wml.fire("harm_unit", {
            T.filter_second { id = snd.id },
            experience = true,
            T.filter { T.filter_adjacent { id = snd.id }, { "not", { side = snd.side } } },
            fire_event = true,
            annimate = true,
            damage_type = att.type,
            amount = amount
        })
    end
end

-- WEAPON SPECIAL

-- Leeches
function apply.leeches(event, pri, snd, dmg)
    local lvl, u
    if event == "attacker_hits" then
        lvl = PWeapon():special_level("leeches")
        u = pri
    elseif event == "defender_hits" then
        lvl = SWeapon():special_level("leeches")
        u = snd
    end
    if lvl then
        if u.hitpoints < u.max_hitpoints then
            wml.fire("heal_unit", {
                T.filter { id = u.id },
                animate = true,
                amount = Round(dmg * (0.05 + 0.05 * lvl))
            }) -- toujours
        end
    end
end

local function case_derriere(x1, y1, x2, y2)
    return wesnoth.map.rotate_right_around_center({ x = x1, y = y1 }, { x = x2, y = y2 }, 3)
end

-- Pierce
function apply.weapon_pierce(event, pri, snd, dmg)
    if event == "attacker_hits" and PWeapon():special_level("weapon_pierce") then
        local loc = case_derriere(pri.x, pri.y, snd.x, snd.y)
        local weapon = PWeapon()
        wml.fire("harm_unit", {
            T.filter { x = loc[1], y = loc[2], { "not", { side = pri.side } } },
            annimate = true,
            fire_event = true,
            damage_type = weapon.type,
            amount = Round(dmg * 0.5)
        }) -- atker hit
    end
end

-- Mayhem
function apply.mayhem(event, pri, snd, dmg)
    if event == "attacker_hits" and PWeapon():special_level("mayhem") then
        wesnoth.units.add_modification(snd, "object", {
            T.effect { apply_to = "attack", increase_damage = -1 }
        }, false) -- atker hit
    end
end

-- Cleave
function apply.cleave(event, pri, snd, dmg)
    if event == "attacker_hits" and PWeapon():special_level("cleave") then
        local l = wesnoth.current.map:find {
            T.filter_adjacent_location { x = pri.x, y = pri.y },
            T.filter_adjacent_location { x = snd.x, y = snd.y }
        }
        local att = PWeapon()
        for i, v in pairs(l) do
            wml.fire("harm_unit", {
                T.filter_second { id = pri.id },
                experience = true,
                T.filter { x = v[1], y = v[2], { "not", { side = pri.side } } },
                fire_event = true,
                annimate = true,
                damage_type = att.type,
                amount = Round(dmg * 0.75)
            }) -- atker hit
        end
    end
end

function apply.res_magic(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = PWeapon():special_level("res_magic")
        if lvl then
            local value = 3 + 2 * lvl -- atker hit
            wesnoth.units.add_modification(snd, "object", {
                T.effect {
                    apply_to = "resistance",
                    { "resistance", { fire = value, cold = value, arcane = value } }
                }
            }, false)
            label_snd = label_snd ..
                Fmt(
                    _ "<span color='%s'>-%d%% magic resistances</span>\n",
                    COLOR_MAGIC_RES_SHRED, value)
        end
    end
end

function apply.armor_shred(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = PWeapon():special_level("armor_shred")
        if lvl then
            local value = Conf.amlas.xavier.values.REDUCE_DEFENSE * lvl
            wesnoth.units.add_modification(snd, "object", {
                T.effect {
                    apply_to = "resistance",
                    {
                        "resistance",
                        { blade = value, pierce = value, impact = value }
                    }
                }
            }, false)
            label_snd = label_snd ..
                Fmt(_ "<span color='%s'>-%d%% armor</span>\n",
                    COLOR_ARMOR_SHRED, value)
        end
    end
end

function apply.defense_shred(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = PWeapon():special_level("defense_shred")
        if lvl then
            local shred_per_hit = Conf.amlas[pri.id].values.REDUCE_DEFENSE * lvl
            snd:add_modification("trait", { AddDefenses(-shred_per_hit) }, false)
            label_snd = label_snd ..
                Fmt(_ "<span color='%s'>-%d%% defense</span>\n",
                    COLOR_DEFENSE_SHRED, shred_per_hit)
        end
    end
end

function apply.weaker_slow(event, pri, snd, dmg)
    if event == "attacker_hits" then
        local lvl = PWeapon():special_level("weaker_slow")
        if lvl then
            local value = 5 * lvl -- atker hit
            wesnoth.units.add_modification(snd, "object", {
                duration = "turn_end",
                T.effect {
                    apply_to = "attack",
                    increase_damage = "-" .. value .. "%"
                }
            }, true)
            label_snd = label_snd .. _ "<span color='#919191'>-" .. value ..
                "% damage</span>\n"
        end
    end
end

function apply.snare(event, pri, snd, dmg)
    if event == "attacker_hits" and PWeapon():special_level("snare") then
        wesnoth.units.add_modification(snd, "object", {
            duration = "turn_end",
            T.effect { apply_to = "movement", set = 0 }
        }, true)
        label_snd = label_snd .. _ "<span color='#1CDC3F'>Snared</span>\n"
    end
end

function apply.transfusion(event, pri, snd, _)
    if event == "attacker_hits" then
        local spe = PWeapon():special("transfusion")
        if not spe then return end
        wml.fire("heal_unit", {
            T.filter { T.filter_adjacent { id = snd.id }, side = pri.side },
            T.filter_second { id = pri.id },
            amount = spe.value,
            animate = true
        })
    end
end

function apply.slow_zone(event, pri, snd, dmg)
    if pri.id ~= "drumar" then return end
    local lvl = PWeapon():special_level("slow_zone")
    if event == "attacker_hits" and lvl then
        local intensity = Conf.special_skills.drumar.slow_zone(lvl)
        local targets = wesnoth.units.find_on_map {
            T.filter_adjacent { id = snd.id, is_enemy = false }
        }
        for i, v in pairs(targets) do
            if not v.status._zone_slowed then
                v.status._zone_slowed = true
                v:add_modification("trait", {
                    T.effect {
                        apply_to = "attack",
                        increase_damage = tostring(-intensity) .. "%"
                    },
                    T.effect {
                        apply_to = "movement",
                        increase = tostring(-intensity) .. "%"
                    }
                })
                wesnoth.interface.float_label(v.x, v.y,
                    _ "<span color='#00A8A2'>Slowed !</span>")
            end
        end
    end
end

-- Consume chilled status
function apply.chilled_dmg(event, pri, snd, dmg)
    if event == "attacker_hits" and snd.status.chilled then
        local special_lvl = snd:custom_variables().status_chilled_lvl
        local att = PWeapon()
        local values = Conf.special_skills.drumar.bonus_cold_mistress(
            special_lvl - 1)
        local percent_bonus = values[1]
        local bonus_dmg = Round(dmg * percent_bonus / 100)
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
                wml.fire("kill", {
                    id = snd.id,
                    { "second_unit", { id = pri.id } },
                    animate = true,
                    fire_event = true
                })
            end
            label_snd = label_snd .. "<span color='#1ED9D0'>" .. dmg_display ..
                "<span size='small'> (chilled)</span></span>\n"
        end
    end
end

-- Apply chilled status on target
function apply.put_status_chilled(event, pri, snd, dmg)
    if pri.id ~= "drumar" then return end
    if event == "attacker_hits" and snd then
        local lvl = PWeapon():special_level("status_chilled")
        if lvl and not snd.status.chilled then
            local values = Conf.special_skills.drumar.bonus_cold_mistress(
                lvl - 1)
            local cd = values[2]
            snd:custom_variables().status_chilled_lvl = lvl
            snd:custom_variables().status_chilled_cd = cd
            snd.status.chilled = true
            label_snd = label_snd ..
                _ "<span color='#1ED9D0'>Chilled !</span>\n"
        end
    end
end

-- Mise à jour des status chilled
function endturn.status_chilled()
    local us = wesnoth.units.find_on_map { status = "chilled" }
    for id, u in ipairs(us) do
        local lvl, cd = u:custom_variables().status_chilled_lvl,
            u:custom_variables().status_chilled_cd
        if cd == 1 then
            u.status.chilled = nil
            u:custom_variables().status_chilled_lvl = nil
            u:custom_variables().status_chilled_cd = nil
        elseif cd then
            u:custom_variables().status_chilled_cd = u:custom_variables().status_chilled_cd - 1
        end
    end
end

function apply.shield(event, pri, snd, dmg)
    local function _init_shield(unit)
        local shield = unit:custom_variables().status_shielded_hp
        unit.hitpoints = unit.hitpoints + shield
        return Fmt(_ "<span color='%s'> +%d shield points</span>\n",
            COLOR_SHIELDED, shield)
    end

    if event == "attack" then -- applying inital shield
        if pri.status.shielded then
            local l = _init_shield(pri)
            label_pri = label_pri .. l
        end
        if snd.status.shielded then
            local l = _init_shield(snd)
            label_snd = label_snd .. l
        end
        delay = 50
    end

    local function _update_shield(unit)
        local sh = unit:custom_variables().status_shielded_hp
        if dmg >= sh then -- no more shield
            unit:custom_variables().status_shielded_hp = nil
            unit.status.shielded = nil
        else -- updating shield
            unit:custom_variables().status_shielded_hp = sh - dmg
        end
    end

    if event == "attacker_hits" and snd.status.shielded then
        _update_shield(snd)
    end
    if event == "defender_hits" and pri.status.shielded then
        _update_shield(pri)
    end

    local function _remove_over(unit)
        unit.hitpoints = unit.hitpoints - unit:custom_variables().status_shielded_hp
    end

    if event == "attack_end" then -- removing over shield left. If shield is remaining, hitpoints were untouched
        if pri.status.shielded then _remove_over(pri) end
        if snd.status.shielded then _remove_over(snd) end
    end
end

function endturn.status_shielded()
    local l_status = wesnoth.units.find_on_map { status = "shielded" }
    for __, v in ipairs(l_status) do
        v.status.shielded = nil
        v:custom_variables().status_shielded_hp = nil
    end
end

-- ------------------------------- Sacrifice (Porthos) -------------------------------

function apply.sacrifice(event, primary, secondary, dmg_dealt)
    if event ~= "attacker_hits" then return end  -- only active in defense
    if secondary.id == "porthos" then return end -- do not self apply the ability
    local porthos = wesnoth.units.get("porthos")
    if not porthos then return end
    if wesnoth.sides.is_enemy(porthos.side, secondary.side) then return end

    --- is porthos in range ?
    local level = porthos:ability_level("sacrifice")
    local d = wesnoth.map.distance_between(porthos, secondary)
    if (not level) or d >= 3 then return end

    local percent = Conf.special_skills.porthos.sacrifice(level)[d]
    local to_heal = Round(dmg_dealt * percent / 100)

    --- only trigger if the unit is still alive after being healed
    if secondary.hitpoints + to_heal <= 0 then return end

    -- mix the damages
    wml.fire("heal_unit", {
        T.filter { id = secondary.id },
        animate = true,
        amount = to_heal
    })
    wml.fire("harm_unit", {
        T.filter { id = porthos.id },
        amount = to_heal,
        animate = true,
        fire_event = true,
    })
end

keys = table.keys(apply)
table.sort(keys) -- deterministic
