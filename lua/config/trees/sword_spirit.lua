-- Numerical values
local V = {
    BONUS_RES = 7, -- per amla
    REGEN = 10,    -- per level
    MAX_HP = 15,   -- per amla
    RES_SHRED = 7, -- per amla
    DEF_SHRED = 7, -- per amla
}

local sword_spirit = {
    _default_border = "#b3230c",
    _default_background = "166 154 149", -- rgb
    values = V,
    -- Defense tree
    {
        id = "though",
        _short_desc = ("Resistances <BR/>  <B> +%d </B> %%"):format(V.BONUS_RES),
        image = "icons/cuirass_leather_studded.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Tougher, + %d%% resistances", V.BONUS_RES),
        T.effect {
            apply_to = "resistance",
            T.resistance {
                impact = -V.BONUS_RES,
                blade = -V.BONUS_RES,
                arcane = -V.BONUS_RES,
                cold = -V.BONUS_RES,
                pierce = -V.BONUS_RES,
                fire = -V.BONUS_RES
            }
        },
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
        _short_desc = ("HP <BR/>  <B> +%d </B> %%"):format(V.MAX_HP),
        image = "icons/amla-default.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Healthier, + %d%% hitpoints", V.MAX_HP),
        table.unpack(StandardAmlaHeal(7, 15))
    },
    -- Moves tree
    {
        id = "pm",
        _short_desc = "Moves <BR/>  <B> +1 </B>",
        image = "icons/boots_elven.png",
        max_times = 3,
        always_display = 1,
        description = _ "Faster, +1 move",
        T.effect { increase = 1, apply_to = "movement" },
        table.unpack(StandardAmlaHeal(2))
    },
    {
        id = "war_jump",
        _short_desc = "<B> War jump </B>",
        _color = { 54, 255, 5 },
        _level_bonus = true,
        require_amla = "pm,pm,pm",
        image = "icons/war_jump-small.png",
        max_times = 1,
        always_display = 1,
        description = _ "Able to jump behind ennemies",
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.customName {
                    id = "war_jump",
                    description = _ "Jump behind ennemies (once per turn).",
                    name = "War jump"
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    -- Debuf auras tree
    {
        id = "shred_aura_res",
        _short_desc = "<B> Weakness aura </B>",
        image = "halo/reddens-aura-small.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Reduces adjacent ennemies resistances by %d%%", V.RES_SHRED),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.customName { id = "shred_aura_res" } }
        },
        ---@param unit unit
        function(unit)
            local current_lvl = unit:ability_level("shred_aura_res") or 0
            local next_lvl = current_lvl + 1
            local value = V.RES_SHRED * next_lvl
            return T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "shred_aura_res",
                        _level = next_lvl,
                        description = Fmt(_ "Adjacent ennemies resistances decreased by %d%%", value),
                        name = "Weakness aura " .. ROMANS[next_lvl]
                    }
                }
            }
        end,
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "shred_aura_def",
        _short_desc = "<B> Clumsiness aura </B>",
        image = "halo/reddens-aura-small.png",
        require_amla = "shred_aura_res,shred_aura_res,shred_aura_res",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Reduces adjacent ennemies defenses by %d%%", V.DEF_SHRED),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.customName { id = "shred_aura_def" } }
        },
        ---@param unit unit
        function(unit)
            local current_lvl = unit:ability_level("shred_aura_def") or 0
            local next_lvl = current_lvl + 1
            local value = V.DEF_SHRED * next_lvl
            return T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "shred_aura_def",
                        _level = next_lvl,
                        description = Fmt(_ "Adjacent ennemies defenses decreased by %d%%", value),
                        name = "Clumsiness aura " .. ROMANS[next_lvl]
                    }
                }
            }
        end,
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "distant_shred_auras",
        _short_desc = "<B> Wider auras </B>",
        _color = { 54, 255, 5 },
        _level_bonus = true,
        require_amla = "shred_aura_def,shred_aura_def,shred_aura_def",
        image = "halo/reddens-aura-small.png",
        max_times = 1,
        always_display = 1,
        description = _ "Clumsiness and weakness auras also affect distant ennemies.",
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.customName { id = "shred_aura_def" } }
        },
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.customName { id = "shred_aura_res" } }
        },
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.customName {
                    id = "distant_shred_auras",
                    description = _ "Clumsiness and weakness auras also affect distant ennemies.",
                    name = "Distant aura"
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    --- attack tree
    {
        id = "blade_requiem",
        _short_desc = "Blade and Requiem <BR /> <B> +1</B> dmg",
        image = "items/sword-holy.png",
        max_times = 3,
        always_display = 1,
        description = _ "Stronger with blade and requiem",
        T.effect { apply_to = "attack", increase_damage = 1, name = "ancient_blade" },
        T.effect { apply_to = "attack", increase_damage = 1, name = "requiem" },
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "blade_slow",
        _short_desc = "Slowing <BR/>Blade",
        _color = { 79, 253, 235 },
        require_amla = "blade_requiem,blade_requiem,blade_requiem",
        image = "items/sword-holy.png",
        max_times = 1,
        always_display = 1,
        description = _ "Freezes your blade. Add weapon special : slows.",
        T.effect {
            set_icon = "items/sword-holy.png",
            apply_to = "attack",
            name = "ancient_blade",
            T.set_specials {
                mode = "append",
                T.slow {
                    id = "slow",
                    description = _ "This attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
                    name = "slows"
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "requiem_slow",
        _short_desc = "Slowing <BR/>Requiem",
        _color = { 79, 253, 235 },
        require_amla = "blade_requiem,blade_requiem,blade_requiem",
        image = "attacks/wail.png",
        max_times = 1,
        always_display = 1,
        description = _ "Enhances your requiem. Add weapon special : slows.",
        T.effect {
            apply_to = "attack",
            name = "requiem",
            T.set_specials {
                mode = "append",
                T.slow {
                    id = "slow",
                    description = _ "This attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
                    name = "slows"
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "blade_requiem_atk",
        _short_desc = "Blade and requiem <BR /> <B> +1</B> str",
        require_amla = "blade_slow,requiem_slow",
        _level_bonus = true,
        image = "items/sword-holy.png",
        max_times = 1,
        always_display = 1,
        description = _ "Faster with with blade and requiem",
        T.effect { apply_to = "attack", name = "ancient_blade", increase_attacks = 1 },
        T.effect { apply_to = "attack", name = "requiem", increase_attacks = 1 },
        table.unpack(StandardAmlaHeal(10))
    },

    {
        id = "default",
        require_amla = "juggernaut,juggernaut,juggernaut,war_jump,distant_shred_auras,blade_requiem_atk",
        max_times = -1,
        description = _ " Whow, you've completed all the tree. Bravo !",
        table.unpack(StandardAmlaHeal(5, 10))
    }
}
Conf.amlas.sword_spirit = sword_spirit
