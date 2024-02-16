local ADAPTATIVE_RESILIENCE_BASE = 40 -- max bonus def (for 0 hp)
local ADAPTATIVE_RESILIENCE_STEP = 10 -- ADAPTATIVE_RESILIENCE_BASE + lvl * this

local V = {                           -- numerical values
    adaptative_resilience = function(lvl)
        return ADAPTATIVE_RESILIENCE_BASE + lvl * ADAPTATIVE_RESILIENCE_STEP
    end,
    REGEN = 20,   -- * lvl
    MAX_HP = 30,  -- * lvl
    RES_AURA = 7, -- * lvl
    DEF_AURA = 7, -- * lvl

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
    {
        id = "adaptative_def_res",
        _short_desc = "<B> Adaptative defenses </B>",
        image = "icons/shield_tower.png",
        max_times = 3,
        always_display = 1,
        description = "Porthos defense and resistance increase when he is weak",
        T.effect {
            apply_to = "remove_ability",
            T.abilities { T.customName { id = "adaptative_def_res" } }
        },
        ---@param unit unit
        function(unit)
            local current_lvl = unit:ability_level("adaptative_def_res") or 0
            local next_lvl = current_lvl + 1
            local value = V.DEF_AURA * next_lvl
            return T.effect {
                apply_to = "new_ability",
                T.abilities { T.customName {
                    id = "adaptative_def_res",
                    name = _ "Adaptative resilience " .. ROMANS[next_lvl],
                    description = Fmt(_ "Porthos gains up to %d%% defense and resistance when he is low health",
                        V.adaptative_resilience(next_lvl)),
                } }
            }
        end,
        table.unpack(StandardAmlaHeal(10))
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
    --- attack tree
    {
        id = "cleaver",
        _short_desc = "Cleaver <BR /> <B> +1 </B> dmg",
        image = "attacks/cleaver.png",
        max_times = 2,
        always_display = 1,
        description = _ "Better with cleaver",
        T.effect { apply_to = "attack", increase_damage = 1, name = "cleaver" },
        table.unpack(StandardAmlaHeal(5))
    },
    {
        id = "cleaver_drain",
        _short_desc = "Drain <BR/>Cleaver",
        _color = { 79, 253, 235 },
        require_amla = "cleaver,cleaver",
        image = "attacks/cleaver_drain.png",
        max_times = 1,
        always_display = 1,
        description = _ "Cleaver absorbs life. Add weapon special : drain.",
        T.effect {
            apply_to = "attack",
            name = "cleaver",
            T.set_specials {
                mode = "append",
                T.drains {
                    id = "drains",
                    name = _ "drains",
                    description = _ "This unit drains health from living units, healing itself for half the amount of damage it deals (rounded down).",
                }
            }
        },
        table.unpack(StandardAmlaHeal(10))
    },
    {
        id = "cleaver_atk",
        _short_desc = "Cleaver <BR /> <B> +1</B> str",
        require_amla = "cleaver_drain",
        image = "attacks/cleaver.png",
        max_times = 2,
        always_display = 1,
        description = _ "Faster with cleaver",
        T.effect { apply_to = "attack", name = "cleaver", increase_attacks = 1 },
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
