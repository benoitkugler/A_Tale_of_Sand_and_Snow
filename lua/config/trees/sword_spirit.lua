-- Numerical values
local V = {
    REGEN = 10,                -- per level
    ALLIES_DEFENSE_RATIO = 5,  -- % per level
    REDUCE_DEFENSE = 2,        -- % per hit per level
    REDUCE_ARMOR = 3,          -- % per hit per level
    SWORD_BONUS_DAMAGE = 2,    -- per amla
    SWORD_BONUS_ATK = 1,       -- per amla
    SWORD2_BONUS_ATK = 1,      -- per amla
    CROSSBOW_BONUS_DAMAGE = 2, -- per amla
    CROSSBOW_BONUS_ATK = 1     -- per amla
}

local sword_spirit = {
    _default_border = "#b3230c",
    _default_background = "166 154 149", -- rgb
    values = V,
    {
        id = "though",
        _short_desc = "Resistances <BR/>  <B> +7 </B> %",
        image = "icons/cuirass_leather_studded.png",
        max_times = 3,
        always_display = 1,
        description = _ "Tougher, + 7% resistances",
        T.effect {
            apply_to = "resistance",
            T.resistance {
                impact = -7,
                blade = -7,
                arcane = -7,
                cold = -7,
                pierce = -7,
                fire = -7
            }
        },
        table.unpack(StandardAmlaHeal(7))
    },
    {
        id = "regen",
        _short_desc = "Regeneration <BR/> <B> +10 </B> hpl",
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
