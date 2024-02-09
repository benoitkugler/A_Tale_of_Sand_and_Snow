-- Numerical values
local V = {
    BONUS_RES = 7, -- per amla
    REGEN = 10,    -- per level
}

local sword_spirit = {
    _default_border = "#b3230c",
    _default_background = "166 154 149", -- rgb
    values = V,
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
        always_display = 1,
        description = Fmt(_ "Regenerates +%d HP per turn.", V.REGEN),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.regenerate { id = "regen" } }
        },
        ---@param unit unit
        function(unit)
            local current_lvl =
                unit:ability_level("regen", "regenerate") or 0
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
        id = "default",
        require_amla = "",
        max_times = -1,
        description = _ "Basic +10Hp AMLA.",
        T.effect { increase_total = 10, apply_to = "hitpoints" },
        table.unpack(StandardAmlaHeal(5))
    }
}
Conf.amlas.sword_spirit = sword_spirit
