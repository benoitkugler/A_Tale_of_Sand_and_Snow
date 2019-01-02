local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

AM = {}

-- Create new weapons by coping specials, damage, strikes from a base attacK
-- Only weapons with name prefixed by copy_ are concerned
local function update_copyobj(unit)
    local u = unit
    for spe in H.child_range(u.__cfg, "attack") do
        if string.find(spe.name, "copy_") ~= nil then
            local name = string.gsub(spe.name, "copy_", "")
            local tocopy = 0
            for atk in H.child_range(u.__cfg, "attack") do
                if atk.name == name then
                    tocopy = atk
                end
            end
            wesnoth.add_modification(
                u,
                "object",
                {
                    no_write = "yes",
                    {
                        "effect",
                        {
                            apply_to = "attack",
                            name = spe.name,
                            set_name = name,
                            increase_damage = tocopy.damage,
                            increase_attacks = tocopy.number,
                            {"set_specials", H.get_child(tocopy, "specials")}
                        }
                    }
                }
            )
        end
    end
end

-- Update the unit level when reaching key amlas
db_lvl = {}
db_lvl["brinx"] = {base_lvl = 4, bow_precis = true, bow_focus = true, bloodlust = true, movement = true}
db_lvl["vranken"] = {base_lvl = 4, sword_marksman = true, sword_cleave = true, sand = true}
db_lvl["drumar"] = {base_lvl = 4, wave_arch_magical = true, attack_chilled = true, toile_snare = true}
setmetatable(
    db_lvl,
    {
        __index = function()
            return {}
        end
    }
)

function AM.update_lvl(unit)
    local skills = table_skills(unit)
    local llvl = db_lvl[unit.id]
    local base_lvl = llvl.base_lvl
    if base_lvl and unit.level >= base_lvl then
        for i, v in pairs(skills) do
            if llvl[i] then
                base_lvl = base_lvl + 1
            end
        end
        unit.level = base_lvl
    end
end

local function purge_advances(tab)
    local s = {}
    for i, v in pairs(tab) do
        if type(v) == "table" and #v >= 2 then
            if v[1] == "advancement" then
                table.insert(s, {v[1], {id = v[2]["id"]}})
            else
                table.insert(s, {v[1], purge_advances(v[2])})
            end
        else
            s[i] = v
        end
    end
    return s
end

-- Enlève les AMLA et rajoute l'alma default
local function purge_direct_advancement(t)
    local s = {}
    local has_amla = false
    for i, v in pairs(t) do
        if type(v) == "table" then
            if v[1] == "advancement" then
                has_amla = true
            else
                table.insert(s, v)
            end
        else
            s[i] = v
        end
    end
    if has_amla then
        table.insert(s, {"advancement", {id = "amla_dummy"}})
    end
    return s
end

-- function AM.adv()
--     local u = get_pri()
--     update_copyobj(u)

--     if u.__cfg.role == "hero" then
--         update_lvl(u)
--         local newu = purge_direct_advancement(u.__cfg)
--         wesnoth.extract_unit(u)
--         newu = purge_advances(newu)
--         wesnoth.put_unit(newu)
--     end
-- end

-- function AM.pre_advance()
--     local u = get_pri()
--     local t = u.__cfg
--     if t.advances_to == "" and t.role == "hero" then
--         t = supp_id(t, "advancement", "amla_dummy")
--         local dummy = wesnoth.create_unit({type = "amla_" .. u.id})
--         for i, v in pairs(dummy.advancements) do
--             table.insert(t, {"advancement", v})
--         end
--         wesnoth.extract_unit(u)
--         wesnoth.put_unit(t)
--     end
-- end

-- TODO: Encoder les amla en lua (dynamique)


function AM.adv()
    local u = get_pri()
    u:remove_modifications({ id = "current_amlas"}, "trait")
end

function AM.pre_advance()
    local u = get_pri()
    u:add_modification(
        "trait",
        {
            id = "current_amlas",
            T.effect {
                apply_to = "new_advancement",
                T.advancement {
                    id = "bow",
                    max_times = 2,
                    description = _ "Better with everything ! ",
                    image = "attacks/bow-elven.png",
                    always_display = 1,
                    T.effect {
                        apply_to = "attack",
                        increase_damage = 2
                    },
                    T.effect {
                        apply_to = "hitpoints",
                        increase_total=7,
                        heal_full=true,
                    }
                },
                T.advancement {
                    id = "bow2",
                    require_amla = {"bow", "bow"},
                    max_times = 1,
                    description = _ "Better with everything 22 ! ",
                    image = "attacks/bow-elven.png",
                    always_display = 1,
                    T.effect {
                        apply_to = "attack",
                        increase_damage = 2
                    },
                    T.effect {
                        apply_to = "hitpoints",
                        increase_total=7,
                        heal_full=true,
                    }
                }
            }
        }
    )
end
