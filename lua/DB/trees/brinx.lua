local brinx = {
    _default_border = "#1EF113",
    _default_background = "68 154 42",
    {
        id = "sword",
        _short_desc = "Sword <BR /> <B> +1 </B> dmg",
        image = "attacks/sword-elven.png",
        max_times = 3,
        always_display = 1,
        description = _ "Better with swords",
        T.effect{apply_to = "attack", increase_damage = 1, name = "sword"},
        table.unpack(standard_amla_heal(5))
    },
    {
        id = "though",
        _short_desc = "Resistances <BR/>  <B> +5 </B> %",
        require_amla = "hp,hp",
        image = "icons/cuirass_leather_studded.png",
        max_times = 2,
        always_display = 1,
        description = _ "Tougher, + 5% resistances",
        T.effect{
            apply_to = "resistance",
            T.resistance{
                impact = -5,
                blade = -5,
                arcane = -5,
                cold = -5,
                pierce = -5,
                fire = -5
            }
        },
        table.unpack(standard_amla_heal(7))
    },
    {
        id = "bow_fire",
        _short_desc = "<B> Fire </B> <BR />  Bow",
        _color = {214, 68, 17},
        require_amla = "bow_precis",
        image = "attacks/bow-elven-fire.png",
        max_times = 1,
        always_display = 1,
        description = _ "Grants a bow enchanted by elven magic, which sets arrows ablaze.",
        function(unit)
            local atk_bow = unit.attacks.bow
            local effect = T.effect{
                apply_to = "new_attack",
                name = "bow",
                icon = "attacks/bow-elven-fire.png",
                range = "ranged",
                number = atk_bow.number,
                type = "fire",
                description = _ "burning bow",
                damage = atk_bow.damage,
                T.specials(atk_bow.specials)
            }
            return effect
        end,
        table.unpack(standard_amla_heal(15))
    },
    {
        id = "pm",
        _short_desc = "Moves <BR/>  <B> +1 </B>",
        image = "icons/boots_elven.png",
        max_times = 2,
        always_display = 1,
        description = _ "Faster, +1 move",
        T.effect{increase = 1, apply_to = "movement"},
        table.unpack(standard_amla_heal(5))
    },
    {
        id = "bow_focus",
        _short_desc = "Bow <BR /> <B> Focus </B>",
        _color = {69, 117, 174},
        _level_bonus = true,
        require_amla = "bow_fire,bow_pierce",
        image = "attacks/bow_focus.png",
        max_times = 1,
        always_display = 1,
        description = _ "Deadly accurate with bows : 80% chance to hit.",
        T.effect{
            set_icon = "attacks/bow_focus.png",
            apply_to = "attack",
            name = "bow",
            T.set_specials{
                mode = "append",
                T.chance_to_hit{
                    id = "focus",
                    value = 80,
                    description = _ "This attack always has a 80% chance to hit regardless of the defensive ability of the unit being attacked.",
                    cumulative = false,
                    name = "focus"
                }
            }
        },
        T.effect{
            apply_to = "attack",
            remove_specials = "marksman,precis",
            name = "bow"
        },
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "bow2",
        _short_desc = "Bow <BR /> <B> +2</B> dmg",
        require_amla = "bow_precis",
        image = "attacks/bow-elven.png",
        max_times = 2,
        always_display = 1,
        description = _ "Even better with bows",
        T.effect{apply_to = "attack", increase_damage = 2, name = "bow"},
        table.unpack(standard_amla_heal(5))
    },
    {
        id = "bow_pierce",
        _short_desc = "<B> Piercing </B> <BR />  Arrows",
        _color = {214, 220, 220},
        require_amla = "bow_precis",
        image = "icons/arrow_strong.png",
        max_times = 1,
        always_display = 1,
        description = _ "Massive arrows dealing damgage to 2 ennemies at once.",
        T.effect{
            name = "bow",
            apply_to = "attack",
            T.set_specials{
                mode = "append",
                T.isHere{
                    id = "weapon_pierce",
                    description = _ "Deals 75% damage to the enemy behind the target.",
                    name = "pierce"
                }
            }
        },
        table.unpack(standard_amla_heal(15))
    },
    {
        id = "movement",
        _short_desc = "Faster on <BR /> sand &amp; snow",
        _level_bonus = true,
        require_amla = "skirmisher",
        image = "icons/sandals.png",
        max_times = 1,
        always_display = 1,
        description = _ "Even faster on sands or snow",
        T.effect{
            replace = true,
            apply_to = "movement_costs",
            T.movement_costs{frozen = 1, sand = 1}
        },
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "bow_precis",
        _short_desc = "Bow <BR /> <B> Precision</B>",
        _color = {69, 117, 174},
        _level_bonus = true,
        require_amla = "bow_atk",
        image = "attacks/bow_precis.png",
        max_times = 1,
        always_display = 1,
        description = _ "More precise with bows : 70% chance to hit.",
        T.effect{
            set_icon = "attacks/bow_precis.png",
            apply_to = "attack",
            name = "bow",
            T.set_specials{
                mode = "append",
                T.chance_to_hit{
                    id = "precis",
                    value = 70,
                    description = _ "This attack always has a 70% chance to hit regardless of the defensive ability of the unit being attacked.",
                    cumulative = false,
                    name = "precision"
                }
            }
        },
        T.effect{
            apply_to = "attack",
            remove_specials = "marksman",
            name = "bow"
        },
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "skirmisher",
        _short_desc = "Skirmisher",
        require_amla = "pm,pm",
        image = "icons/sandals.png",
        max_times = 1,
        always_display = 1,
        description = _ "Extremly nimble, now able to dodge ennemies",
        T.effect{
            apply_to = "new_ability",
            T.abilities{
                T.skirmisher{
                    id = "skirmisher",
                    affect_self = true,
                    description = _ "This unit is skilled in moving past enemies quickly, and ignores all enemy Zones of Control.",
                    female_name = "skirmisher",
                    name = "skirmisher"
                }
            }
        },
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "bow_atk",
        _short_desc = "Bow <BR /> <B> +1</B> str",
        require_amla = "bow,bow",
        image = "attacks/bow-elven.png",
        max_times = 1,
        always_display = 1,
        description = _ "Faster with bows",
        T.effect{apply_to = "attack", name = "bow", increase_attacks = 1},
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "sword_atk",
        _short_desc = "Sword <BR /> <B> +1</B> str",
        require_amla = "sword,sword,sword",
        image = "attacks/sword-elven.png",
        max_times = 1,
        always_display = 1,
        description = _ "Faster with swords",
        T.effect{apply_to = "attack", name = "sword", increase_attacks = 1},
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "bloodlust",
        _short_desc = "<B> Bloodlust </B>",
        _color = {54, 255, 5},
        _level_bonus = true,
        require_amla = "bow_focus,bow_atk2",
        image = "icons/blood-frenzy.png",
        max_times = 1,
        always_display = 1,
        description = _ "Upon killing a unit, this unit will gain another attack and some moves.",
        T.effect{
            apply_to = "new_ability",
            T.abilities{
                T.isHere{
                    id = "bloodlust",
                    description = _ "Killing a unit refreshes this unit's strength, and gives it a new attack. Happens at most once a turn.",
                    name = "Bloodlust"
                }
            }
        },
        table.unpack(standard_amla_heal(15))
    },
    {
        id = "hp",
        _short_desc = "Health <BR/> <B> +5 </B> hp",
        image = "icons/hp.png",
        max_times = 2,
        always_display = 1,
        description = _ "Healthier, + 5HP",
        T.effect{increase_total = 5, apply_to = "hitpoints"},
        table.unpack(standard_amla_heal(5))
    },
    {
        id = "bow_atk2",
        _short_desc = "Bow <BR /> <B> +1</B> str",
        require_amla = "bow2,bow2",
        image = "attacks/bow-elven.png",
        max_times = 1,
        always_display = 1,
        description = _ "Even faster with bows",
        T.effect{apply_to = "attack", name = "bow", increase_attacks = 1},
        table.unpack(standard_amla_heal(10))
    },
    {
        id = "bow",
        _short_desc = "Bow <BR /> <B> +2</B> dmg",
        image = "attacks/bow-elven.png",
        max_times = 2,
        always_display = 1,
        description = _ "Better with bows",
        T.effect{apply_to = "attack", increase_damage = 2, name = "bow"},
        table.unpack(standard_amla_heal(5))
    },
    {
        max_times = -1,
        description = _ " Whow, you've completed all the tree. Bravo !",
        require_amla = "bloodlust,movement,though,though",
        id = "default",
        image = "",
        T.effect{increase_total = 1, apply_to = "hitpoints"},
        table.unpack(standard_amla_heal(5))
    }
}
DB.AMLAS.brinx = brinx
