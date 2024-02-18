-- Numerical values
local V = {
    BONUS_RES = 8, -- per amla
    REGEN = 15,    -- per amla
    MAX_HP = 20,   -- per amla
    BONUS_DEF = 8, -- per amla
    BOLD = 12,     -- per amla
}

Conf.amlas.mark = {
    _default_border = "#f5dd42",
    _default_background = "255 242 156",
    values = V,

    -- hp tree
    {
        id = "though",
        _short_desc = ("Resistances <BR/>  <B> +%d </B> %%"):format(V.BONUS_RES),
        image = "icons/cuirass_leather_studded.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Tougher, + %d%% resistances", V.BONUS_RES),
        AddResistances(V.BONUS_RES),
        table.unpack(StandardAmlaHeal(7))
    },
    {
        id = "regen",
        _short_desc = ("Regeneration <BR/> <B> +%d</B> hp"):format(V.REGEN),
        image = "icons/potion_red_small.png",
        max_times = 3,
        require_amla = "though,though,though",
        always_display = 1,
        description = Fmt(_ "Regenerates +%d HP per turn.", V.REGEN),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.regenerate { id = "regen" } }
        },
        ---@param unit unit
        function(unit)
            local current_lvl = unit:ability_level("regen", "regenerate") or 0
            local value = V.REGEN * (current_lvl + 1)
            return T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.regenerate {
                        id = "regen",
                        _level = current_lvl + 1,
                        value = value,
                        description = Fmt(_ "Heals himself for %d HP per turn.", value),
                        name = "Regeneration " .. ROMANS[current_lvl + 1]
                    }
                }
            }
        end,
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "juggernaut",
        require_amla = "regen,regen,regen",
        _short_desc = ("HP <BR/>  <B> +%d </B>"):format(V.MAX_HP),
        image = "icons/amla-default.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Healthier, + %d hitpoints", V.MAX_HP),
        table.unpack(StandardAmlaHeal(7, V.MAX_HP))
    },
    -- nimble tree
    {
        id = "pm",
        _short_desc = "Moves <BR/>  <B> +1 </B>",
        image = "icons/boots_elven.png",
        max_times = 2,
        always_display = 1,
        description = _ "Faster, +1 move",
        T.effect { increase = 1, apply_to = "movement" },
        table.unpack(StandardAmlaHeal(2))
    },
    {
        id = "defense",
        _short_desc = "Better defense",
        image = "icons/dress_silk_green.png",
        require_amla = "pm,pm",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "More nimble,  +%d%% defense", V.BONUS_DEF),
        AddDefenses(V.BONUS_DEF),
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "elusive",
        _level_bonus = true,
        _short_desc = "Elusive",
        image = "icons/boots_elven.png",
        require_amla = "defense,defense,defense",
        max_times = 1,
        always_display = 1,
        description = _ "Mark is so swift that he may now sneak behind ennemies.",
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.customName {
                    id = "elusive",
                    _level = 1,
                    description = _ "Mark may access hex behind ennemy lines.",
                    name = "Elusive"
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    -- offense tree
    {
        id = "mace_dmg",
        _short_desc = "Mace <BR /> <B> +2</B> dmg",
        image = "attacks/mace.png",
        max_times = 3,
        always_display = 1,
        description = _ "Stronger with maces",
        T.effect { apply_to = "attack", increase_damage = 2, name = "mace" },
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "mace_atk",
        _short_desc = "Mace <BR /> <B> +1</B> str",
        require_amla = "mace_dmg,mace_dmg,mace_dmg",
        image = "attacks/mace.png",
        max_times = 2,
        always_display = 1,
        description = _ "Faster with maces",
        T.effect { apply_to = "attack", name = "mace", increase_attacks = 1 },
        table.unpack(StandardAmlaHeal(8))
    },
    {
        id = "mace_marksman",
        _short_desc = "Mace <BR/>Marksman",
        _level_bonus = true,
        _color = { 44, 230, 214 },
        require_amla = "mace_atk,mace_atk",
        image = "attacks/mace_marksman.png",
        max_times = 1,
        always_display = 1,
        description = _ "More precise with maces : 60% chance to hit.",
        T.effect {
            set_icon = "attacks/mace_marksman.png",
            apply_to = "attack",
            name = "mace",
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
    --  vivacity tree
    {
        id = "mace_initiative",
        _short_desc = "Mace <BR/>First strike",
        image = "attacks/mace.png",
        require_amla = "mace_dmg",
        max_times = 1,
        always_display = 1,
        description = _ "Quicker with maces : always hits first.",
        T.effect {
            set_icon = "attacks/mace.png",
            apply_to = "attack",
            name = "mace",
            T.set_specials {
                mode = "append",
                T.firststrike {
                    id = "firststrike",
                    name = _ "first strike",
                    description = _ "This unit always strikes first with this attack, even if they are defending.",
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "bold",
        _short_desc = "Mace <BR/>Bold",
        image = "attacks/mace.png",
        _color = { 235, 117, 33 },
        require_amla = "mace_initiative",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Bold in battle : deals +%d%% damages against fresh ennemies", V.BOLD),
        ---@param unit unit
        function(unit)
            local current_lvl = unit:weapon("mace"):special_level("bold", "damage") or 0
            local next_lvl = current_lvl + 1
            local value = V.BOLD * next_lvl
            return T.effect {
                apply_to = "attack",
                name = "mace",
                remove_specials = "bold",
                T.set_specials {
                    mode = "append",
                    T.damage {
                        id = "bold",
                        _level = next_lvl,
                        multiply = 1 + (value / 100),
                        name = _ "bold " .. ROMANS[next_lvl],
                        description = Fmt(_ "Deals %d%% bonus damages against full health ennemies", value),
                        T.filter_opponent { formula = "$this_unit.hitpoints = $this_unit.max_hitpoints" }
                    }
                }
            }
        end,
        table.unpack(StandardAmlaHeal(8))
    },
    {
        id = "bloodlust",
        _short_desc = "<B> Bloodlust </B>",
        _color = { 54, 255, 5 },
        _level_bonus = true,
        require_amla = "bold,bold,bold",
        image = "icons/blood-frenzy.png",
        max_times = 1,
        always_display = 1,
        description = _ "Upon killing a unit, this unit will gain another attack and some moves.",
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.customName {
                    id = "bloodlust",
                    _level = 1,
                    description = _ "Killing a unit refreshes this unit's strength, and gives it a new attack. Happens at most once a turn.",
                    name = "Bloodlust"
                }
            }
        },
        table.unpack(StandardAmlaHeal(15))
    },

    {
        max_times = -1,
        require_amla = "mace_marksman,juggernaut,juggernaut,juggernaut,defense,defense,defense,bloodlust",
        id = "default",
        description = _ " Whow, you've completed all the tree. Bravo !",
        table.unpack(StandardAmlaHeal(5, 5))
    }
}
