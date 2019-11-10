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
    }
}
DB.AMLAS.morgane = morgane
