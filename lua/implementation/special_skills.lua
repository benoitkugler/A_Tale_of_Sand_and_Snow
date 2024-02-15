-- Implementation of special skills (trigered when choosing to a skill in menu item.)
-- Each special skill is coded in WML object with id skill_idoftheskill
-- An attribut _level maybe added to abilities and specials when needed
-- Upgrading a skill should remove the old level and create a new one.
-- Some peculiar skills may also be implemented in Event combat or Abilities

---@type table<string, fun(lvl:integer, unit:unit)>
SPECIAL_SKILLS = {}

local function _get_ids(lvl, skill_name)
    local id, old_id = "skill_" .. skill_name .. lvl, "skill_" .. skill_name .. tostring(lvl - 1)
    return id, old_id
end

-- ---------------------------------- Vranken ----------------------------------
function SPECIAL_SKILLS.leeches_cac(lvl, unit)
    local id, old_id = _get_ids(lvl, "leeches_cac")
    unit:remove_modifications({ id = old_id }, "object")

    local value = Conf.special_skills.vranken.leeches_cac(lvl)
    local desc =
        string.format(
            tostring(_ "Regenerates %d%% of the damage dealt in offense and defense. Also works against undead"),
            value
        )
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "attack",
                range = "melee",
                T.set_specials {
                    mode = "append",
                    T.customName {
                        id = "leeches",
                        _level = lvl,
                        name = _ "leeches",
                        description = desc
                    }
                }
            }
        }
    )
end

function SPECIAL_SKILLS.drain_cac(lvl, unit)
    local id, old_id = _get_ids(lvl, "drain_cac")
    unit:remove_modifications({ id = old_id }, "object")

    local values = Conf.special_skills.vranken.drain_cac(lvl)
    local dmg, radius = values[1], values[2]
    local desc =
        string.format(tostring(_ "Regenerates %d%% of the damage dealt in offense and defense. Doesn't apply to undead"),
            dmg)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "attack",
                range = "melee",
                T.set_specials {
                    mode = "append",
                    T.drains {
                        id = "drain_cac",
                        _level = lvl,
                        name = _ "drains",
                        value = dmg,
                        description = desc,
                        description_inactive = _ "Göndhul is too far away from Vranken.",
                        T.filter_self {
                            T.filter_location {
                                radius = radius,
                                T.filter { id = "sword_spirit" }
                            }
                        }
                    }
                }
            }
        }
    )
end

function SPECIAL_SKILLS.atk_brut(lvl, unit)
    local id, old_id = _get_ids(lvl, "atk_brut")
    unit:remove_modifications({ id = old_id }, "object")

    local ratio = Conf.special_skills.vranken.atk_brut(lvl)

    local atk = unit:weapon("sword")
    local new_attack = {
        apply_to = "new_attack",
        name = "sword",
        range = "melee",
        type = "brut",
        damage = atk.damage * ratio / 100,
        number = atk.number,
        description = _ "ether sword",
        icon = "attacks/atk_brut.png"
    }

    unit:add_modification(
        "object",
        {
            id = id,
            { "effect", new_attack }
        }
    )
end

function SPECIAL_SKILLS.transposition(lvl, unit)
    local id, old_id = _get_ids(lvl, "transposition")
    unit:remove_modifications({ id = old_id }, "object")

    local cd = Conf.special_skills.vranken.transposition(lvl)
    unit:custom_variables().special_skill_cd = 0
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "transposition",
                        _level = lvl,
                        name = _ "War link",
                        description = Fmt(_ "Vranken senses its sword spirit and may switch position with Göndhul, " ..
                            "no matter the distance between them. \n<b>%d</b> turn%s cooldown.", cd, cd > 1 and "s" or "")
                    }
                }
            }
        }
    )
end

-- ----------------------------------- Brinx -----------------------------------
function SPECIAL_SKILLS.def_muspell(lvl, unit)
    local id, old_id = _get_ids(lvl, "def_muspell")
    unit:remove_modifications({ id = old_id }, "object")

    local value = Conf.special_skills.brinx.def_muspell(lvl)
    local desc =
        string.format(tostring(_ "Brinx learned how to better dodge muspellian attacks : %d%% bonus defense."), value)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = id,
                        name = _ "Muspell Equilibrium",
                        description = desc
                    }
                }
            },
            T.effect {
                apply_to = "attack",
                T.set_specials {
                    mode = "append",
                    T.chance_to_hit {
                        id = "def_muspell",
                        _level = lvl,
                        name = "",
                        description = "",
                        sub = value,
                        apply_to = "opponent",
                        T.filter_opponent { race = "muspell" }
                    }
                }
            }
        }
    )
end

function SPECIAL_SKILLS.dmg_muspell(lvl, unit)
    local id, old_id = _get_ids(lvl, "dmg_muspell")
    unit:remove_modifications({ id = old_id }, "object")

    local value = Conf.special_skills.brinx.dmg_muspell(lvl)
    local desc = string.format(tostring(_ "Brinx deals %d%% bonus damage when facing a muspellian opponent."), value)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "dmg_muspell",
                        _level = lvl,
                        name = _ "Muspell Terror",
                        description = desc
                    }
                }
            },
            T.effect {
                apply_to = "attack",
                T.set_specials {
                    mode = "append",
                    T.damage {
                        id = "def_muspell",
                        _level = lvl,
                        name = "",
                        description = "",
                        multiply = 1 + value / 100,
                        T.filter_opponent { race = "muspell" }
                    }
                }
            }
        }
    )
end

function SPECIAL_SKILLS.fresh_blood_musp(lvl, unit)
    local id, old_id = _get_ids(lvl, "fresh_blood_musp")
    unit:remove_modifications({ id = old_id }, "object")

    local value = Conf.special_skills.brinx.fresh_blood_musp(lvl)
    local desc = string.format(tostring(_ "Brinx heals himself for %d HP when killing a muspellian"), value)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "fresh_blood_musp",
                        _level = lvl,
                        name = _ "Muspell strength",
                        description = desc
                    }
                }
            }
        }
    )
end

function SPECIAL_SKILLS.muspell_rage(lvl, unit)
    local id, old_id = _get_ids(lvl, "muspell_rage")
    unit:remove_modifications({ id = old_id }, "object")

    local value = Conf.special_skills.brinx.muspell_rage(lvl)
    local desc = string.format(tostring(_ "Brinx deals and takes %d%% bonus damage."), value)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "muspell_rage",
                        _level = lvl,
                        name = _ "Revenge",
                        description = desc,
                        description_inactive = _ "There is no muspellian friend to anger Brinx.",
                        T.filter { T.filter_side { T.has_unit { race = "muspell" } } }
                    }
                }
            },
            T.effect {
                apply_to = "attack",
                T.set_specials {
                    mode = "append",
                    T.damage {
                        id = "muspell_rage",
                        _level = lvl,
                        name = "",
                        apply_to = "both",
                        description = "",
                        multiply = 1 + value / 100,
                        T.filter { T.filter_side { T.has_unit { race = "muspell" } } }
                    }
                }
            }
        }
    )
end

-- ----------------------------------- Drumar ----------------------------------- --
function SPECIAL_SKILLS.wave_dmg(lvl, unit)
    local id, old_id = _get_ids(lvl, "wave_dmg")
    unit:remove_modifications({ id = old_id }, "object")

    local values = Conf.special_skills.drumar.wave_dmg(lvl)
    local dmg, nb_atk = values[1], values[2]

    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "attack",
                name = "chill wave",
                increase_damage = tostring(dmg) .. "%",
                increase_attacks = nb_atk
            }
        }
    )
end

function SPECIAL_SKILLS.forecast_defense(lvl, unit)
    local id, old_id = _get_ids(lvl, "forecast_defense")
    unit:remove_modifications({ id = old_id }, "object")

    local def = Conf.special_skills.drumar.forecast_defense(lvl)
    unit:add_modification(
        "object",
        {
            id = id,
            AddDefenses(def)
        }
    )
end

function SPECIAL_SKILLS.slow_zone(lvl, unit)
    local id, old_id = _get_ids(lvl, "slow_zone")
    unit:remove_modifications({ id = old_id }, "object")

    local intensity = Conf.special_skills.drumar.slow_zone(lvl)
    local desc = string.format(tostring(_ "Decrease adjacent ennemies damages and movements by %d%%"), intensity)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "attack",
                name = "entangle",
                T.set_specials {
                    mode = "append",
                    T.customName {
                        id = "slow_zone",
                        _level = lvl,
                        name = _ "slowing field",
                        description = desc
                    }
                }
            }
        }
    )
end

-- enhance chilling special
function SPECIAL_SKILLS.bonus_cold_mistress(lvl, unit)
    local id, old_id = _get_ids(lvl, "bonus_cold_mistress")
    unit:remove_modifications({ id = old_id }, "object")

    local values = Conf.special_skills.drumar.bonus_cold_mistress(lvl)
    local dmg, nb_turn = values[1], values[2]
    local desc = string.format(
        tostring(_ "Target takes <span weight='bold'>%d%%</span> bonus damage, when hit by cold attacks. Last <span weight='bold'>%d</span> turns."),
        dmg, nb_turn)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "attack",
                name = "chilling touch",
                remove_specials = "status_chilled",
                T.set_specials {
                    mode = "append",
                    T.customName {
                        id = "status_chilled",
                        _level = lvl + 1,
                        name = _ "chilling",
                        description = desc
                    }
                }
            }
        }
    )
end

-- ------------------------------------ Xavier ------------------------------------
---@param lvl integer
---@param unit unit
function SPECIAL_SKILLS.Y_formation(lvl, unit)
    local id, old_id = _get_ids(lvl, "Y_formation")
    unit:remove_modifications({ id = old_id }, "object")
    local value = Conf.special_skills.xavier.Y_formation(lvl)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "Y_formation",
                        _level = lvl,
                        name = _ "Back formation",
                        description = Fmt(_ "Xavier sends its friends to distract the ennemy. When attacking in Y, " ..
                            "he has the time to perform <b>%d</b> additionnal attacks", value)
                    }
                }
            }
        }
    )
end

---@param lvl integer
---@param unit unit
function SPECIAL_SKILLS.A_formation(lvl, unit)
    local id, old_id = _get_ids(lvl, "A_formation")
    unit:remove_modifications({ id = old_id }, "object")
    local value = Conf.special_skills.xavier.A_formation(lvl)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "A_formation",
                        _level = lvl,
                        name = _ "Wedge formation",
                        description = Fmt(_ "Xavier is transcendanted by his friends. When fighting in A, " ..
                            "he will gain <b>%d%% defense</b>.", value)
                    }
                }
            }
        }
    )
end

---@param lvl integer
---@param unit unit
function SPECIAL_SKILLS.I_formation(lvl, unit)
    local id, old_id = _get_ids(lvl, "I_formation")
    unit:remove_modifications({ id = old_id }, "object")
    local value = Conf.special_skills.xavier.I_formation(lvl)
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "I_formation",
                        _level = lvl,
                        name = _ "Spear formation",
                        description = Fmt(_ "Xavier is transcendanted by his friends. When attacking in I, " ..
                            "he will gain <b>%d damages</b>.", value)
                    }
                }
            }
        }
    )
end

---@param lvl integer
---@param unit unit
function SPECIAL_SKILLS.O_formation(lvl, unit)
    local id, old_id = _get_ids(lvl, "O_formation")
    unit:remove_modifications({ id = old_id }, "object")

    local value = Conf.special_skills.xavier.O_formation(lvl)
    unit:custom_variables().special_skill_cd = 0
    unit:add_modification(
        "object",
        {
            id = id,
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "O_formation",
                        _level = lvl,
                        name = _ "Union formation",
                        description = Fmt(_ "When grouping as 6, Xavier may disarm its opponent, removing its abilities " ..
                            "and weapon specials (<b>%d</b> turn(s) cooldown).", value)
                    }
                }
            }
        }
    )
end

-------------------------------------- Morgane --------------------------------------
function SPECIAL_SKILLS.moves(lvl, unit)
    local id, old_id = _get_ids(lvl, "moves")
    unit:remove_modifications({ id = old_id }, "object")

    local new_costs = lvl == 1 and T.movement_costs {
        forest = 1,
        hills = 1,
        cave = 1,
        shallow_water = 2,
        swamp_water = 2,
        mountains = 2,
        frozen = 2,
    } or T.movement_costs {
        forest = 1,
        hills = 1,
        cave = 1,
        shallow_water = 1,
        swamp_water = 1,
        mountains = 1,
        frozen = 1,
    }

    unit:add_modification('object', {
        id = id,
        T.effect {
            apply_to = "movement_costs",
            replace = true,
            new_costs
        }
    })
end

function SPECIAL_SKILLS.limbes_defense(lvl, unit)
    local id, old_id = _get_ids(lvl, "limbes_defense")
    unit:remove_modifications({ id = old_id }, "object")

    local def = Conf.special_skills.morgane.limbes_defense(lvl)
    unit:add_modification(
        "object",
        {
            id = id,
            AddDefenses(def)
        }
    )
end

------------------------- Porthos -------------------------

function SPECIAL_SKILLS.pain_adept(lvl, unit)
    local id, old_id = _get_ids(lvl, "pain_adept")
    unit:remove_modifications({ id = old_id }, "object")

    local percent = Conf.special_skills.porthos.pain_adept(lvl)
    unit:add_modification('object', {
        id = id,
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.customName {
                    id = "pain_adept",
                    _level = lvl,
                    name = _ "Pain adept " .. ROMANS[lvl],
                    description = Fmt(_ "Porthos gains %d%% of his missing health as bonus damage (refreshed at each turn start).", percent)
                }
            }
        }
    })
end

function SPECIAL_SKILLS.sacrifice(lvl, unit)
    local id, old_id = _get_ids(lvl, "sacrifice")
    unit:remove_modifications({ id = old_id }, "object")

    local percents = Conf.special_skills.porthos.sacrifice(lvl)
    local adj, dist = percents[1], percents[2]
    local desc = dist == 0
        and Fmt(_ "Porthos shares %d%% of the damage inflicted to adjacent allies", adj)
        or Fmt(
            _ "Porthos shares %d%% of the damage inflicted to adjacent allies (%d%% for allies distant by 2 hexes).",
            adj, dist)
    unit:add_modification('object', {
        id = id,
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.customName {
                    id = "sacrifice",
                    _level = lvl,
                    name = _ "Sacrifice " .. ROMANS[lvl],
                    description = desc
                }
            }
        }
    })
end
