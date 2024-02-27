local V = {        -- numerical values
    BONUS_RES = 8, -- * lvl
    BONUS_DEF = 5, -- * lvl
    MAX_HP = 25,   -- * lvl
}

Conf.amlas.rymor = {
    _default_border = "#BCB4D6",
    _default_background = "240 151 234",
    values = V,
    -- Defense tree
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
        id = "defense",
        _short_desc = "Better defense",
        image = "icons/dress_silk_green.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "More nimble, +%d%% defense", V.BONUS_DEF),
        AddDefenses(V.BONUS_DEF),
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "juggernaut",
        require_amla = "though,defense",
        _short_desc = ("HP <BR/>  <B> +%d </B>"):format(V.MAX_HP),
        image = "icons/amla-default.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Healthier, + %d hitpoints", V.MAX_HP),
        table.unpack(StandardAmlaHeal(7, V.MAX_HP))
    },
    -- Offense tree
    {
        id = "hammer_dmg",
        _short_desc = "Hammer <BR /> <B> +3</B> dmg",
        image = "attacks/hammer.png",
        max_times = 3,
        always_display = 1,
        description = _ "Stronger with hammers",
        T.effect { apply_to = "attack", increase_damage = 3, name = "hammer" },
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "hammer_atk",
        _short_desc = "Hammer <BR /> <B> +1</B> str",
        require_amla = "hammer_dmg,hammer_dmg,hammer_dmg",
        image = "attacks/hammer.png",
        max_times = 1,
        always_display = 1,
        description = _ "Faster with hammers",
        T.effect { apply_to = "attack", name = "hammer", increase_attacks = 1 },
        table.unpack(StandardAmlaHeal(8))
    },
    {
        id = "hammer_marksman",
        _short_desc = "Hammer <BR/>Marksman",
        _level_bonus = true,
        _color = { 44, 230, 214 },
        require_amla = "hammer_atk",
        image = "attacks/hammer-blue.png",
        max_times = 1,
        always_display = 1,
        description = _ "More precise with hammers : 60% chance to hit.",
        T.effect {
            apply_to = "attack",
            name = "hammer",
            T.set_specials {
                mode = "append",
                T.chance_to_hit {
                    id = "marksman",
                    name = "marksman",
                    value = 60,
                    active_on = "offense",
                    description = _ "When used offensively, this attack always has at least a 60% chance to hit.",
                    cumulative = true,
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "hammer_cleave",
        _short_desc = "Hammer <BR /> <B> Cleave </B>",
        _color = { 132, 94, 114 },
        require_amla = "hammer_dmg",
        image = "attacks/hammer.png",
        max_times = 1,
        always_display = 1,
        description = _ "Attacking with hammers deals 75% damage to nearby ennemies.",
        T.effect {
            apply_to = "attack",
            name = "hammer",
            T.set_specials {
                mode = "append",
                T.customName {
                    id = "cleave",
                    description = _ "Deals 75% damage to enemies between attacker and defender.",
                    name = "cleave"
                }
            }
        },
        table.unpack(StandardAmlaHeal(15))
    },
}
