-- Numerical values
local V = {
    BETTER_LEADERSHIP_RATIO = 15, -- % per level
    ALLIES_DEFENSE_RATIO = 5,     -- % per level
    REDUCE_DEFENSE = 2,           -- % per hit per level
    REDUCE_ARMOR = 3,             -- % per hit per level
    SWORD_BONUS_DAMAGE = 2,       -- per amla
    SWORD_BONUS_ATK = 1,          -- per amla
    SWORD2_BONUS_ATK = 1,         -- per amla
    CROSSBOW_BONUS_DAMAGE = 2,    -- per amla
    CROSSBOW_BONUS_ATK = 1        -- per amla
}

local xavier = {
    _default_border = "#a99508",
    _default_background = "181 167 71", -- rgb
    values = V,
    {
        id = "better_leadership",
        _short_desc = "Better Leadership",
        image = "misc/laurel.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(
            _ "Grants additionnal %d%% bonus damage for higher level allies.",
            V.BETTER_LEADERSHIP_RATIO),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.leadership { id = "better_leadership" } }
        },
        function(unit)
            local current_lvl = GetAbilityLevel(unit, "better_leadership",
                "leadership") or 0
            local value = V.BETTER_LEADERSHIP_RATIO * (current_lvl + 1)
            return T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.leadership {
                        cumulative = true,
                        id = "better_leadership",
                        _level = current_lvl + 1,
                        value = value,
                        affect_self = false,
                        description = Fmt(
                            _ [[
Even more experienced units are impressed by Xavier's skills !
Adjacent own units of equal or higher level will do %d%% more damage. ]], value),
                        name = "Inspiration-" .. ROMANS[current_lvl + 1],
                        T.affect_adjacent {
                            T.filter { formula = "level >= other.level" }
                        }
                    }
                }
            }
        end,
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "defense_shred",
        _short_desc = "<B> Defense shred </B>",
        _color = { 54, 255, 5 },
        require_amla = "defense",
        image = "icons/broken_tunic.png",
        max_times = 3,
        always_display = 1,
        description = _ "In offense, reduces ennemies defense on hit, both with sword and crossbow.",
        ---@param unit unit
        function(unit)
            local current_lvl = unit:weapon("sword"):get_special("defense_shred")._level or 0
            local shred_on_hit = V.REDUCE_DEFENSE * (current_lvl + 1)
            return T.effect {
                apply_to = "attack",
                remove_specials = "defense_shred",
                T.set_specials {
                    mode = "append",
                    T.isHere {
                        id = "defense_shred",
                        _level = current_lvl + 1,
                        active_on = "offense",
                        name = _ "destabilize",
                        description = Fmt(_ "Decreses defense by %d%% per hit",
                            shred_on_hit)
                    }
                }
            }
        end,
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "defense",
        _short_desc = "Bonus defense",
        require_amla = "better_leadership,better_leadership,better_leadership,sword_precis,crossbow_marksman",
        image = "icons/dress_silk_green.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Adjacent allies gain additionnal %d%% defense",
            V.ALLIES_DEFENSE_RATIO),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.isHere { id = "allies_defense" } }
        },
        function(unit) -- need the current ability level.adjacent
            local current_lvl = GetAbilityLevel(unit, "allies_defense") or 0
            local value = (current_lvl + 1) * V.ALLIES_DEFENSE_RATIO
            return T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.isHere {
                        id = "allies_defense",
                        _level = current_lvl + 1,
                        name = _ "Defense-" .. ROMANS[current_lvl + 1],
                        description = Fmt(_ "Adjacent allies gain %d%% defense",
                            value)
                    }
                }
            }
        end,
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "crossbow",
        _short_desc = Fmt("Crossbow <BR /> <B> +%d </B> dmg",
            V.CROSSBOW_BONUS_DAMAGE),
        image = "attacks/crossbow-human.png",
        max_times = 2,
        always_display = 1,
        description = _ "Better with crossbows",
        T.effect {
            apply_to = "attack",
            increase_damage = V.CROSSBOW_BONUS_DAMAGE,
            name = "crossbow"
        },
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "armor_shred",
        _short_desc = "<B> Armor shred </B>",
        _color = { 54, 255, 5 },
        _level_bonus = true,
        require_amla = "defense",
        image = "icons/broken_shield.png",
        max_times = 3,
        always_display = 1,
        description = _ "Reduces ennemies armor on hit, with sword or crossbow.",
        ---@param unit unit
        function(unit)
            local current_lvl = unit:weapon("sword"):get_special("armor_shred")._level or 0
            local shred_on_hit = V.REDUCE_ARMOR * (current_lvl + 1)
            return T.effect {
                apply_to = "attack",
                remove_specials = "armor_shred",
                T.set_specials {
                    mode = "append",
                    T.isHere {
                        id = "armor_shred",
                        _level = current_lvl + 1,
                        active_on = "offense",
                        name = _ "shreds",
                        description = Fmt(
                            _ "Decreses physical resistances by %d%% per hit",
                            shred_on_hit)
                    }
                }
            }
        end,
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "crossbow_marksman",
        _short_desc = "Crossbow <BR /> <B> Marksman</B> ",
        _level_bonus = true,
        require_amla = "crossbow_atk",
        image = "attacks/crossbow-human.png",
        max_times = 1,
        always_display = 1,
        description = _ "More precise with crossbows : 60% chance to hit",
        T.effect {
            set_icon = "attacks/crossbow-human.png",
            apply_to = "attack",
            name = "crossbow",
            T.set_specials {
                mode = "append",
                T.chance_to_hit {
                    id = "marksman",
                    value = 60,
                    active_on = "offense",
                    description = _ "When used offensively, this attack always has at least a 60% chance to hit.",
                    cumulative = true,
                    name = "marksman"
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "sword_marksman",
        _short_desc = "Sword <BR /> <B> Marksman</B>",
        _color = { 69, 117, 174 },
        _level_bonus = true,
        require_amla = "sword,sword",
        image = "attacks/sword_marksman.png",
        max_times = 1,
        always_display = 1,
        description = _ "More precise with sword : 60% chance to hit",
        T.effect {
            set_icon = "attacks/sword_marksman.png",
            apply_to = "attack",
            name = "sword",
            T.set_specials {
                mode = "append",
                T.chance_to_hit {
                    id = "marksman",
                    value = 60,
                    active_on = "offense",
                    description = _ "When used offensively, this attack always has at least a 60% chance to hit.",
                    cumulative = true,
                    name = "marksman"
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "crossbow_atk",
        _short_desc = Fmt("Crossbow <BR /> <B>+%d</B> str.",
            V.CROSSBOW_BONUS_ATK),
        require_amla = "crossbow,crossbow",
        image = "attacks/crossbow-human.png",
        max_times = 2,
        always_display = 1,
        description = _ "Faster with crossbows",
        T.effect {
            apply_to = "attack",
            name = "crossbow",
            increase_attacks = V.CROSSBOW_BONUS_ATK
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "sword",
        _short_desc = Fmt("Sword <BR /> <B>+%d</B> dmg", V.SWORD_BONUS_DAMAGE),
        image = "attacks/sword-elven.png",
        max_times = 2,
        always_display = 1,
        description = _ "Better with sword",
        T.effect {
            apply_to = "attack",
            increase_damage = V.SWORD_BONUS_DAMAGE,
            name = "sword"
        },
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "sword_atk2",
        _short_desc = Fmt("Sword <BR /> <B>+%d</B> str", V.SWORD2_BONUS_ATK),
        require_amla = "sword_marksman",
        image = "attacks/sword-elven.png",
        max_times = 2,
        always_display = 1,
        description = _ "Faster with sword",
        T.effect {
            apply_to = "attack",
            name = "sword",
            increase_attacks = V.SWORD2_BONUS_ATK
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "sword_precis",
        _short_desc = "Sword <BR /> <B> Precis </B>",
        _color = { 69, 117, 174 },
        _level_bonus = true,
        require_amla = "sword_atk2",
        image = "attacks/sword_precis.png",
        max_times = 1,
        always_display = 1,
        description = _ "So precise with swords : 70% chance to hit",
        T.effect {
            set_icon = "attacks/sword_precis.png",
            apply_to = "attack",
            name = "sword",
            T.set_specials {
                mode = "append",
                T.chance_to_hit {
                    id = "precis",
                    value = 70,
                    description = _ [[ This attack always has a 70% chance to hit,
					regardless of the defensive ability of the unit being attacked. ]],
                    cumulative = false,
                    name = "precision"
                }
            }
        },
        T.effect {
            apply_to = "attack",
            remove_specials = "marksman",
            name = "sword"
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "default",
        require_amla = "defense_reduc,defense_reduc,defense_reduc,armor_shred,armor_shred,armor_shred",
        max_times = -1,
        description = _ "Basic +3Hp AMLA.",
        T.effect { increase_total = 3, apply_to = "hitpoints" },
        table.unpack(StandardAmlaHeal(5))
    }
}
Conf.amlas.xavier = xavier
