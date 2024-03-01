-- Misc. helpers
-- Format a translatable string
---@param translatable_str tstring
---@return tstring
function Fmt(translatable_str, ...)
    return _(string.format(tostring(translatable_str), ...))
end

ROMANS = { "I", "II", "III", "IV", "V", "VI" }

-- Return an array ofsorted string keys
---@param t table<string, any>
function SortedKeys(t)
    ---@type string[]
    local keys = {}
    for i, __ in pairs(t) do keys[#keys + 1] = i end
    table.sort(keys)
    return keys
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
---@field name tstring
---@field description tstring
---@field _level integer?
---@field value integer?

---Returns the special with `id_special` on the weapon.
---If id_special is nil, the any id is matched
---@param id_special string?
---@param special_name? string # default to customName
---@return special?
function weapon_mt:special(id_special, special_name)
    special_name = special_name or "customName"
    local specials = wml.get_child(self, "specials") or {}
    for spe in wml.child_range(specials, special_name) do
        if id_special == nil or spe["id"] == id_special then return spe --[[@as special]] end
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

function weapon_mt:specials()
    return wml.get_child(self, "specials")
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

---@class ability
---@field name tstring
---@field description tstring
---@field _level integer?
---@field value integer?

---Return the ability with id 'id_ability'.
---'ability_name' defaut to "customName"
---@param u unit
---@param id_ability string
---@param ability_name string?
---@return ability?
function wesnoth.units.get_ability(u, id_ability, ability_name)
    ability_name = ability_name or "customName"
    local list_abilities = wml.get_child(u.__cfg, "abilities") or {}
    for ab in wml.child_range(list_abilities, ability_name) do
        if ab.id == id_ability then return ab --[[@as ability]] end
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
    return ab and ab._level or nil
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

---Return a T.abilities resitance affecting allies (not the unit itself)
---@param id string
---@param value integer
---@param lvl integer
---@return WMLTag
function ResistanceAura(id, value, lvl)
    return T.abilities {
        T.resistance {
            id = id,
            _level = lvl,
            add = value,
            affect_self = false,
            affect_allies = true,
            T.affect_adjacent {},
            description = Fmt(_ "Adjacent allies resistances increased by %d%%", value),
            name = "Resistance aura " .. ROMANS[lvl],
            halo_image_self = "halo/resistance-aura.png~O(0.7)",
        }
    }
end

---Return a custom T.abilities with id 'def_aura' affecting allies (not the unit itself)
---@param value integer
---@param lvl integer
---@return WMLTag
function DefenseAura(value, lvl)
    return T.abilities {
        T.customName {
            id = "def_aura",
            _level = lvl,
            value = value,
            description = Fmt(_ "Adjacent allies gain %d%% defense", value),
            name = _ "Defense aura " .. ROMANS[lvl],
            halo_image_self = "halo/defense-aura.png~O(0.7)"
        }
    }
end

function GetLocation()
    return wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
end

-- Returns the amlas table { id_skill -> lvl }
---@param u unit
function wesnoth.units.skills_level(u)
    ---@type table<string,integer>
    local skills = {}
    for adv in wml.child_range(wml.get_child(u.__cfg, "modifications") or {},
        "advancement") do
        skills[ adv.id --[[@as string]] ] = (skills[adv.id] or 0) + 1
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

---Replace the modification with given 'id' by then given 'effect'.
---'type' defaults to 'object'.
---@param u unit
---@param id string
---@param effect WMLTag
---@param type modification_type?
function wesnoth.units.set_modification(u, id, effect, type)
    type = type or 'object'
    u:remove_modifications({ id = id }, type)
    u:add_modification(type, { id = id, effect })
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

---Returns the list of all the unit types with
---race 'muspell' and level included in [min_level, max_level]
---Special units like otchigin are not returned
---@param min_level integer
---@param max_level integer
function MuspellUnits(min_level, max_level)
    local ids = {} ---@type string[]
    for id, ut in pairs(wesnoth.unit_types) do
        local level = ut.__cfg.level -- workaround bug https://github.com/wesnoth/wesnoth/issues/8456
        if (not id:find("otchigin")) and ut.race == 'muspell' and
            min_level <= level and level <= max_level then
            table.insert(ids, id)
        end
    end
    return ids
end
