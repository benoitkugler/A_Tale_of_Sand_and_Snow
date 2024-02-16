local V = {                          -- numerical values
    ADAPTATIVE_RESILIENCE_BASE = 40, -- max bonus def (for 0 hp)
    ADAPTATIVE_RESILIENCE_STEP = 10, -- ADAPTATIVE_RESILIENCE_BASE + lvl * this
    REGEN = 20,                      -- * lvl
    MAX_HP = 30,                     -- * lvl
    RES_AURA = 7,                    -- * lvl
    DEF_AURA = 7,                    -- * lvl
}

Conf.amlas.porthos = {
    _default_border = "#f542e9",
    _default_background = "240 151 234",
    values = V,
    -- Defense tree
    {
        id = "regen",
        _short_desc = ("Combat regeneration <BR/> <B> +%d</B> hp"):format(V.REGEN),
        image = "icons/potion_red_small.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Regenerates +%d HP after attacking.", V.REGEN),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.customName { id = "end_attack_regen" } }
        },
        ---@param unit unit
        function(unit)
            local current_lvl = unit:ability_level("end_attack_regen") or 0
            local value = V.REGEN * (current_lvl + 1)
            return T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.customName {
                        id = "end_attack_regen",
                        _level = current_lvl + 1,
                        value = value,
                        description = Fmt(_ "Heals himself for %d HP after attacking.", value),
                        name = "Combat regeneration " .. ROMANS[current_lvl + 1]
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
    -- Defense auras tree
    {
        id = "res_aura_porthos",
        _short_desc = "<B> Resistance aura </B>",
        image = "halo/resistance-aura-small.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Increases adjacent allies resistances by %d%%", V.RES_AURA),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.resistance { id = "res_aura_porthos" } }
        },
        ---@param unit unit
        function(unit)
            local current_lvl = unit:ability_level("res_aura_porthos") or 0
            local next_lvl = current_lvl + 1
            local value = V.RES_AURA * next_lvl
            return T.effect {
                apply_to = "new_ability",
                ResistanceAura("res_aura_porthos", value, next_lvl),
            }
        end,
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "def_aura",
        _short_desc = "<B> Defense aura </B>",
        image = "halo/defense-aura-small.png",
        max_times = 3,
        always_display = 1,
        description = Fmt(_ "Increases adjacent allies defenses by %d%%", V.DEF_AURA),
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.defense { id = "def_aura" } }
        },
        ---@param unit unit
        function(unit)
            local current_lvl = unit:ability_level("def_aura") or 0
            local next_lvl = current_lvl + 1
            local value = V.DEF_AURA * next_lvl
            return T.effect {
                apply_to = "new_ability",
                DefenseAura(value, next_lvl),
            }
        end,
        table.unpack(StandardAmlaHeal(10))
    },
    -- {
    --     id = "shred_aura_def",
    --     _short_desc = "<B> Clumsiness aura </B>",
    --     image = "halo/reddens-aura-small.png",
    --     require_amla = "shred_aura_res,shred_aura_res,shred_aura_res",
    --     max_times = 3,
    --     always_display = 1,
    --     description = Fmt(_ "Reduces adjacent ennemies defenses by %d%%", V.DEF_SHRED),
    --     T.effect {
    --         apply_to = "remove_ability",
    --         T.abilities { T.customName { id = "shred_aura_def" } }
    --     },
    --     ---@param unit unit
    --     function(unit)
    --         local current_lvl = unit:ability_level("shred_aura_def") or 0
    --         local next_lvl = current_lvl + 1
    --         local value = V.DEF_SHRED * next_lvl
    --         return T.effect {
    --             apply_to = "new_ability",
    --             T.abilities {
    --                 T.customName {
    --                     id = "shred_aura_def",
    --                     _level = next_lvl,
    --                     description = Fmt(_ "Adjacent ennemies defenses decreased by %d%%", value),
    --                     name = "Clumsiness aura " .. ROMANS[next_lvl],
    --                     halo_image_self = "halo/reddens-aura.png"
    --                 }
    --             }
    --         }
    --     end,
    --     table.unpack(StandardAmlaHeal(10))
    -- },
    -- {
    --     id = "distant_shred_auras",
    --     _short_desc = "<B> Wider auras </B>",
    --     _color = { 54, 255, 5 },
    --     _level_bonus = true,
    --     require_amla = "shred_aura_def,shred_aura_def,shred_aura_def",
    --     image = "halo/reddens-aura-small.png",
    --     max_times = 1,
    --     always_display = 1,
    --     description = _ "Clumsiness and weakness auras also affect distant ennemies.",
    --     T.effect {
    --         apply_to = "remove_ability",
    --         T.abilities { T.customName { id = "shred_aura_def" } }
    --     },
    --     T.effect {
    --         apply_to = "remove_ability",
    --         T.abilities { T.customName { id = "shred_aura_res" } }
    --     },
    --     T.effect {
    --         apply_to = "new_ability",
    --         T.abilities {
    --             T.customName {
    --                 id = "distant_shred_auras",
    --                 _level = 1,
    --                 description = _ "Göndhul is so powerfull that it Clumsiness aura III and Weakness aura III abilities also affect distant ennemies.",
    --                 name = "Distant aura",
    --                 halo_image_self = "halo/reddens-aura-distant.png"
    --             }
    --         }
    --     },
    --     table.unpack(StandardAmlaHeal(10))
    -- },
    -- --- attack tree
    -- {
    --     id = "blade_requiem",
    --     _short_desc = "Blade and Requiem <BR /> <B> +1</B> dmg",
    --     image = "items/sword-holy.png",
    --     max_times = 3,
    --     always_display = 1,
    --     description = _ "Stronger with blade and requiem",
    --     T.effect { apply_to = "attack", increase_damage = 1, name = "ancient_blade" },
    --     T.effect { apply_to = "attack", increase_damage = 1, name = "requiem" },
    --     table.unpack(StandardAmlaHeal(5))
    -- },
    -- {
    --     id = "blade_slow",
    --     _short_desc = "Slowing <BR/>Blade",
    --     _color = { 79, 253, 235 },
    --     require_amla = "blade_requiem,blade_requiem,blade_requiem",
    --     image = "items/sword-holy.png",
    --     max_times = 1,
    --     always_display = 1,
    --     description = _ "Freezes your blade. Add weapon special : slows.",
    --     T.effect {
    --         set_icon = "items/sword-holy.png",
    --         apply_to = "attack",
    --         name = "ancient_blade",
    --         T.set_specials {
    --             mode = "append",
    --             T.slow {
    --                 id = "slow",
    --                 description = _ "This attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
    --                 name = "slows"
    --             }
    --         }
    --     },
    --     table.unpack(StandardAmlaHeal(10))
    -- },
    -- {
    --     id = "requiem_slow",
    --     _short_desc = "Slowing <BR/>Requiem",
    --     _color = { 79, 253, 235 },
    --     require_amla = "blade_requiem,blade_requiem,blade_requiem",
    --     image = "attacks/wail.png",
    --     max_times = 1,
    --     always_display = 1,
    --     description = _ "Enhances your requiem. Add weapon special : slows.",
    --     T.effect {
    --         apply_to = "attack",
    --         name = "requiem",
    --         T.set_specials {
    --             mode = "append",
    --             T.slow {
    --                 id = "slow",
    --                 description = _ "This attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
    --                 name = "slows"
    --             }
    --         }
    --     },
    --     table.unpack(StandardAmlaHeal(10))
    -- },
    -- {
    --     id = "blade_requiem_atk",
    --     _short_desc = "Blade and requiem <BR /> <B> +1</B> str",
    --     require_amla = "blade_slow,requiem_slow",
    --     _level_bonus = true,
    --     image = "items/sword-holy.png",
    --     max_times = 1,
    --     always_display = 1,
    --     description = _ "Faster with with blade and requiem",
    --     T.effect { apply_to = "attack", name = "ancient_blade", increase_attacks = 1 },
    --     T.effect { apply_to = "attack", name = "requiem", increase_attacks = 1 },
    --     table.unpack(StandardAmlaHeal(10))
    -- },

    {
        id = "default",
        require_amla = "juggernaut,juggernaut,juggernaut,war_jump,distant_shred_auras,blade_requiem_atk",
        max_times = -1,
        description = _ " Whow, you've completed all the tree. Bravo !",
        table.unpack(StandardAmlaHeal(5, 10))
    }
}
