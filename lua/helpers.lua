-- Misc. helpers
-- Format a translatable string
---@param translatable_str tstring
---@return tstring
function Fmt(translatable_str, ...)
    return _(string.format(tostring(translatable_str), ...))
end

ROMANS = { "I", "II", "III", "IV", "V", "VI" }

-- Return string keys
---@param t table
---@return string[]
function table.keys(t)
    local s = {}
    for i, v in pairs(t) do if type(i) == "string" then s[#s + 1] = i end end
    return s
end

-- round
---@param f number
---@return integer
function Round(f) return math.floor(0.5 + f) end

-- Récupére l'unité primaire ou secondaire d'un event
function PrimaryUnit()
    return wesnoth.units.get(wesnoth.current.event_context.x1,
        wesnoth.current.event_context.y1)
end

function SecondaryUnit()
    return wesnoth.units.get(wesnoth.current.event_context.x2,
        wesnoth.current.event_context.y2)
end

---Return the ability with id 'id_ability'.
---'ability_name' defaut to "isHere"
---@param u unit
function GetAbility(u, id_ability, ability_name)
    ability_name = ability_name or "isHere"
    local list_abilities = H.get_child(u.__cfg, "abilities") or {}
    for ab in H.child_range(list_abilities, ability_name) do
        if ab.id == id_ability then return ab end
    end
    return {}
end

---Return the field '_level' of the abilities with id 'id_ability'.
---'ability_name' defaut to "isHere"
---@param u unit
---@return integer|nil
function GetAbilityLevel(u, id_ability, ability_name)
    local ab = GetAbility(u, id_ability, ability_name)
    return ab._level
end

---Returns the level of given special for current weapon
---@param id_special string
---@return integer|nil
function GetSpe(id_special)
    return GetSpecial(wesnoth.current.event_context.weapon,
        id_special)._level
end

-- Returns the special with `id_special` on the atk.
-- Atk is a unit.attack proxy or a weapon child
---@param atk unit_weapon|WMLTable
---@param id_special string
---@param special_name? string
---@return table
function GetSpecial(atk, id_special, special_name)
    special_name = special_name or "isHere"
    if atk == nil then return {} end
    local list_specials
    if type(atk) == "userdata" then
        ---@cast atk unit_weapon
        list_specials = atk.specials or {}
    else
        ---@cast atk WMLTable
        list_specials = wml.get_child(atk, "specials")
    end
    if not list_specials then return {} end
    for spe in wml.child_range(list_specials, special_name) do
        if spe["id"] == id_special then return spe end
    end
    return {}
end

-- Return an effect wml table augmenting all defenses by given number (positive is better)
---@param def integer
---@return table
function AddDefenses(def)
    return T.effect {
        apply_to = "defense",
        T.defense {
            deep_water = -def,
            shallow_water = -def,
            reef = -def,
            swamp_water = -def,
            flat = -def,
            sand = -def,
            forest = -def,
            hills = -def,
            mountains = -def,
            village = -def,
            castle = -def,
            cave = -def,
            frozen = -def,
            unwalkable = -def,
            fungus = -def,
            impassable = -def
        }
    }
end

function GetLocation()
    return wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
end

-- Returns the table id_skill = lvl
function TableSkills(u)
    local table_amlas = {}
    for adv in H.child_range(H.get_child(u.__cfg, "modifications"),
        "advancement") do
        table_amlas[adv.id] = (table_amlas[adv.id] or 0) + 1
    end
    table_amlas.amla_dummy = nil
    return table_amlas
end

---Popup window with translatable string
---@param title string
---@param message tstring
function Popup(title, message)
    local dialog = {
        T.tooltip { id = "tooltip_large" }, T.helptip { id = "tooltip_large" },
        T.grid {
            T.row { T.column { T.label { id = "the_title" } } },
            T.row { T.column { T.spacer { id = "space", height = 10 } } },
            T.row {
                T.column {
                    horizontal_alignement = "left",
                    T.label { id = "the_message", characters_per_line = 100 }
                }
            },
            T.row { T.column { T.spacer { id = "space2", height = 10 } } },
            T.row { T.column { T.button { id = "ok", label = _ "OK" } } }
        }
    }

    ---@param window window
    local function preshow(window)
        local ti = window:find("the_title") --[[@as simple_widget]]
        ti.use_markup = true
        ti.marked_up_text = _ "<span size='large' color ='#BFA63F' font_weight ='bold'>" .. title ..
            "</span>"
        local me = window:find("the_message") --[[@as simple_widget]]
        me.use_markup = true
        me.marked_up_text = message
    end
    gui.show_dialog(dialog, preshow)
end

---@param id string
---@return unit?
function GetRecallUnit(id)
    for _, u in pairs(wesnoth.units.find_on_recall({})) do
        if u.id == id then return u end
    end
end
