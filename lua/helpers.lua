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
    return wesnoth.units.get(
        wesnoth.current.event_context.x1,
        wesnoth.current.event_context.y1)
end

function SecondaryUnit()
    return wesnoth.units.get(
        wesnoth.current.event_context.x2,
        wesnoth.current.event_context.y2)
end

---@class weapon : helper.weapon, unit_weapon


---@class helper.weapon
local weapon_mt = {}

---@param table WMLTable
---@return weapon
local function new_weapon(table)
    weapon_mt.__index = weapon_mt
    return setmetatable(table, weapon_mt) --[[@as weapon]]
end


---@class special
---@field _level integer?

-- Returns the special with `id_special` on the weapon.
---@param id_special string
---@param special_name? string # default to customName
---@return special?
function weapon_mt:special(id_special, special_name)
    special_name = special_name or "customName"
    local specials = wml.get_child(self, "specials") or {}
    for spe in wml.child_range(specials, special_name) do
        if spe["id"] == id_special then return spe --[[@as special]] end
    end
    return nil
end

---@param id_special string
---@param special_name? string # default to customName
---@return integer?
function weapon_mt:special_level(id_special, special_name)
    local spe = self:special(id_special, special_name)
    return (spe or {})._level
end

---Returns the weapon used by the primary unit
---@return weapon
function PWeapon()
    local t = wml.get_child(wesnoth.current.event_context, "weapon") or {}
    return new_weapon(t)
end

---Returns the weapon used by the secondary unit
---@return weapon
function SWeapon()
    local t = wml.get_child(wesnoth.current.event_context, "second_weapon") or {}
    return new_weapon(t)
end

---Return the ability with id 'id_ability'.
---'ability_name' defaut to "customName"
---@param u unit
---@param id_ability string
---@param ability_name string?
---@return WMLTable?
function wesnoth.units.get_ability(u, id_ability, ability_name)
    ability_name = ability_name or "customName"
    local list_abilities = wml.get_child(u.__cfg, "abilities") or {}
    for ab in wml.child_range(list_abilities, ability_name) do
        if ab.id == id_ability then return ab end
    end
    return nil
end

---Return the field '_level' of the abilities with id 'id_ability'.
---'ability_name' defaut to "customName"
---@param u unit
---@param id_ability string
---@param ability_name string?
---@return integer|nil
function wesnoth.units.ability_level(u, id_ability, ability_name)
    local ab = u:get_ability(id_ability, ability_name)
    return ab and ab._level --[[@as integer|nil]] or nil
end

-- Return an T.effect wml tag augmenting all resitances by the given number (positive is better)
---@param res integer
---@return WMLTag
function AddResistances(res)
    return T.effect {
        apply_to = "resistance",
        T.resistance {
            impact = -res,
            blade = -res,
            arcane = -res,
            cold = -res,
            pierce = -res,
            fire = -res
        }
    }
end

-- Return an T.effect wml tag augmenting all defenses by given number (positive is better)
---@param def integer
---@return WMLTag
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

-- Returns the amlas table { id_skill -> lvl }
---@param u unit
---@return table<string,integer>
function wesnoth.units.skills_level(u)
    local skills = {}
    for adv in wml.child_range(wml.get_child(u.__cfg, "modifications") or {},
        "advancement") do
        skills[adv.id] = (skills[adv.id] or 0) + 1
    end
    -- clear sentinel values
    skills.amla_dummy = nil
    skills.default = nil
    return skills
end

---Returns the weapon with the given name
---@param u unit
---@param name string
---@return weapon
function wesnoth.units.weapon(u, name)
    return new_weapon(u.attacks[name].__cfg)
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
        ti.marked_up_text = _ "<span size='large' color ='#BFA63F' font_weight ='bold'>" .. title ..
            "</span>"
        local me = window:find("the_message") --[[@as simple_widget]]
        me.marked_up_text = message
    end
    gui.show_dialog(dialog, preshow)
end

---Same as wesnoth.units.get, but works for unit on
---the recall list.
---@param id string
---@return unit
function wesnoth.units.get_recall(id)
    return wesnoth.units.find_on_recall({ id = id })[1]
end
