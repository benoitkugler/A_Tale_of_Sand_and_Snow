local V = { -- numerical values
    LONG_HEAL_RATIO = 0.8, -- * lvl / distance
    BETTER_HEAL = 10 -- bonus per level
}
local morgane = {
    _default_border = "#ddebe0",
    _default_background = "66 65 193",
    values = V,
    {
        id = "better_heal1",
        _short_desc = "Better <BR/>Heal",
        image = "icons/potion_red_small.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Better at healing : +%d additional heal",
                          V.BETTER_HEAL),
        T.effect{
            apply_to = "remove_ability",
            T.abilities{T.heals{id = "curing"}}
        },
        T.effect{
            apply_to = "remove_ability",
            T.abilities{T.heals{id = "healing"}}
        },
        T.effect{
            apply_to = "remove_ability",
            T.abilities{T.heals{id = "better_heal"}}
        },
        function(unit)
            local current_lvl =
                GetAbility(unit, "better_heal", "heals")._level or 0
            local value = 8 + V.BETTER_HEAL * (current_lvl + 1)
            return T.effect{
                apply_to = "new_ability",
                T.abilities{
                    T.heals{
                        cumulative = true,
                        id = "better_heal",
                        _level = current_lvl + 1,
                        value = value,
                        poison = "cured",
                        affect_self = false,
                        affect_allies = true,
                        T.affect_adjacent{},
                        description = Fmt(
                            _ [[
    Morgane talents for healing are ever growing !
    Adjacent own units will be healed by %d at each turn.]], value),
                        name = "Gifted healer " .. ROMANS[current_lvl + 1]
                    }
                }
            }
        end,
        table.unpack(standard_amla_heal(5))
    },
    {
        id = "long_heal1",
        _short_desc = "Distant <BR/>Heal",
        _level_bonus = true,
        image = "icons/potion_red_medium.png",
        require_amla = "better_heal1,better_heal1,better_heal1",
        max_times = 1,
        always_display = 1,
        description = _ "Able to heal non adjacent units",
        T.effect{
            apply_to = "new_ability",
            T.abilities{
                T.isHere{
                    id = "long_heal",
                    _level = 1,
                    description = Fmt(_ [[
    Harnessing the Limbes power, Morgane is able to heal distant allies.
    (<b>%d%%</b> and <b>%d%%</b> for distance 2 and 3) ]],
                                      Round(V.LONG_HEAL_RATIO * 100 / 2),
                                      Round(V.LONG_HEAL_RATIO * 100 / 3)),
                    name = "Distant healer " .. ROMANS[1]
                }
            }
        },
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "better_heal2",
        _short_desc = "Even better <BR/>Heal",
        image = "icons/potion_red_small.png",
        max_times = 2,
        always_display = 1,
        require_amla = "long_heal1",
        description = Fmt(_ "Even better at healing : +%d additional heal",
                          V.BETTER_HEAL),
        T.effect{
            apply_to = "remove_ability",
            T.abilities{T.heals{id = "better_heal"}}
        },
        function(unit)
            local current_lvl =
                GetAbility(unit, "better_heal", "heals")._level or 0
            local value = 8 + V.BETTER_HEAL * (current_lvl + 1)
            return T.effect{
                apply_to = "new_ability",
                T.abilities{
                    T.heals{
                        cumulative = true,
                        id = "better_heal",
                        _level = current_lvl + 1,
                        value = value,
                        poison = "cured",
                        affect_self = false,
                        affect_allies = true,
                        T.affect_adjacent{},
                        description = Fmt(
                            _ [[
    Morgane talents for healing are still growing !
    Adjacent own units will be healed by %d at each turn.]], value),
                        name = "Gifted healer " .. ROMANS[current_lvl + 1]
                    }
                }
            }
        end,
        table.unpack(standard_amla_heal(5))
    },
    {
        id = "long_heal2",
        _short_desc = "Better distant <BR/>Heal",
        image = "icons/potion_red_medium.png",
        require_amla = "better_heal2,better_heal2",
        max_times = 1,
        always_display = 1,
        description = _ "Able to better heal non adjacent units",
        T.effect{
            apply_to = "remove_ability",
            T.abilities{T.isHere{id = "long_heal"}}
        },
        T.effect{
            apply_to = "new_ability",
            T.abilities{
                T.isHere{
                    id = "long_heal",
                    _level = 2,
                    description = Fmt(_ [[
    Harnessing the Limbes power, Morgane is able to heal distant allies.
    (<b>%d%%</b> and <b>%d%%</b> for distance 2 and 3) ]],
                                      Round(V.LONG_HEAL_RATIO * 2 * 100 / 2),
                                      Round(V.LONG_HEAL_RATIO * 2 * 100 / 3)),
                    name = "Distant healer " .. ROMANS[2]
                }
            }
        },
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "lightbeam",
        _short_desc = "Lightbeam <BR /> <B> +2</B> dmg",
        image = "attacks/lightbeam.png",
        max_times = 3,
        always_display = 1,
        description = _ "Stronger with lightbeam",
        T.effect{apply_to = "attack", name = "lightbeam", increase_damage = 2},
        table.unpack(standard_amla_heal(5))
    },
    {
        id = "fast_lightbeam",
        _level_bonus = true,
        require_amla = "lightbeam,lightbeam,lightbeam",
        _short_desc = "Faster with lightbeam <BR /> <B> +1</B> str",
        image = "attacks/lightbeam.png",
        max_times = 1,
        always_display = 1,
        description = _ "Faster with lightbeam",
        T.effect{apply_to = "attack", name = "lightbeam", increase_attacks = 1},
        table.unpack(standard_amla_heal(7))
    },
    {
        id = "transfusion",
        _short_desc = "<B>Heal allies</B> <BR /> on hit",
        -- _color = {211, 224, 238},
        require_amla = "fast_lightbeam",
        image = "attacks/transfusion.png",
        max_times = 2,
        always_display = 1,
        description = _ "On hit, allies adjacents to the target are healed.",
        T.effect{
            apply_to = "attack",
            remove_specials = "transfusion",
            name = "lightbeam"
        },
        function(unit)
            local next_lvl =
                (get_special(unit.attacks.lightbeam, "transfusion")._level or 0) +
                    1
            return T.effect{
                set_icon = "attacks/transfusion.png",
                apply_to = "attack",
                name = "lightbeam",
                T.set_specials{
                    mode = "append",
                    T.isHere{
                        id = "transfusion",
                        _level = next_lvl,
                        description = Fmt(
                            _ "On each hit, allies adjacent to the target are healed by %d.",
                            next_lvl * 3),
                        active_on = "offense",
                        cumulative = false,
                        name = "transfusion " .. ROMANS[next_lvl]
                    }
                }
            }
        end,
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "fast_lightbeam2",
        require_amla = "transfusion",
        _short_desc = "Faster with lightbeam <BR /> <B> +1</B> str",
        image = "attacks/lightbeam.png",
        max_times = 2,
        always_display = 1,
        description = _ "Even faster with lightbeam",
        T.effect{apply_to = "attack", name = "lightbeam", increase_attacks = 1},
        table.unpack(standard_amla_heal(7))
    },
    {
        id = "though",
        _short_desc = "Resistances <BR/>  <B> +7 </B> %",
        require_amla = "better_heal1,fast_lightbeam",
        image = "icons/cuirass_leather_studded.png",
        max_times = 3,
        always_display = 1,
        description = _ "Limbes strengh makes Morgan tougher: + 7% resistances",
        T.effect{
            apply_to = "resistance",
            T.resistance{
                impact = -7,
                blade = -7,
                arcane = -7,
                cold = -7,
                pierce = -7,
                fire = -7
            }
        },
        table.unpack(standard_amla_heal(7))
    },
    {
        id = "deflect",
        _short_desc = "<B> Deflection </B>",
        _level_bonus = true,
        _color = {47, 74, 71},
        require_amla = "though,though,though,fast_lightbeam2",
        image = "icons/deflect.png",
        max_times = 1,
        always_display = 1,
        description = _ "Morgane is able to deflect 50% of the damage to nearby ennemy units.",
        T.effect{
            apply_to = "new_ability",
            T.abilities{
                T.isHere{
                    id = "deflect",
                    description = _ [[
    Travelling into the Limbes taught Morgane how to switch from a world to another.
    She is now able to deflect 50% of the damage received to ennemy units ]],
                    name = "Deflection"
                }
            }
        },
        table.unpack(standard_amla_heal(12))
    }
}
DB.AMLAS.morgane = morgane
