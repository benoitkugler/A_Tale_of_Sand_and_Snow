-- Numerical values
local V = {
    BONUS_DEF = 10,
}

Conf.amlas.bunshop = {
    _default_border = "#b3230c",
    _default_background = "166 154 149", -- rgb
    values = V,
    -- Nimble tree
    {
        id = "skirmisher",
        _short_desc = "Skirmisher",
        image = "icons/sandals.png",
        max_times = 1,
        always_display = 1,
        description = _ "Extremly nimble, now able to dodge ennemies.",
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.skirmisher {
                    id = "skirmisher",
                    affect_self = true,
                    description = _ "This unit is skilled in moving past enemies quickly, and ignores all enemy Zones of Control.",
                    female_name = "skirmisher",
                    name = "skirmisher"
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "pm",
        _short_desc = "Moves <BR/>  <B> +1 </B>",
        image = "icons/boots_elven.png",
        require_amla = "skirmisher",
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
        require_amla = "skirmisher",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "More nimble, +%d%% defense", V.BONUS_DEF),
        AddDefenses(V.BONUS_DEF),
        table.unpack(StandardAmlaHeal(5))
    },
    -- offense tree
    {
        id = "fangs_dmg",
        _short_desc = "Fangs <BR /> <B> +1</B> dmg",
        image = "attacks/fangs.png",
        max_times = 3,
        always_display = 1,
        description = _ "Stronger with fangs",
        T.effect { apply_to = "attack", increase_damage = 1, name = "fangs" },
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "bersek",
        _short_desc = "Berseker",
        _level_bonus = true,
        _color = { 200, 50, 50 },
        require_amla = "fangs_dmg,fangs_dmg,fangs_dmg",
        image = "attacks/fangs.png",
        max_times = 1,
        always_display = 1,
        description = _ "Bunshop gets mad when attacking vilains. Add weapon special : bersek",
        T.effect {
            apply_to = "attack",
            name = "fangs",
            T.set_specials {
                mode = "append",
                T.berserk {
                    active_on = "offense",
                    id = "berserk",
                    name = _ "berserk",
                    description = _ "When used offensively, this attack presses the engagement until one of the combatants is slain, or 30 rounds of attacks have occurred.",
                    value = 30,
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "fangs_atk",
        _short_desc = "Fangs <BR /> <B> +1</B> str",
        require_amla = "bersek",
        image = "attacks/fangs.png",
        max_times = 3,
        always_display = 1,
        description = _ "Faster with fangs",
        T.effect { apply_to = "attack", name = "mace", increase_attacks = 1 },
        table.unpack(StandardAmlaHeal(8))
    },

    -- Lymbe tree : TODO

    {
        id = "default",
        require_amla = "fangs_atk,fangs_atk,fangs_atk,defense,defense,defense",
        max_times = -1,
        description = _ " Whow, you've completed all the tree. Bravo !",
        table.unpack(StandardAmlaHeal(5, 10))
    }
}
