-- default is black
local colors = {
    brinx = "#357815",
    rymor = "#BCB4D6",
    drumar = "#00FFF5",
    bunshop = "#FFFA80",
    xavier = "#a99508",
    sword_spirit = "#A00E27",
    morgane = "#ddebe0",
    mark = "#f5dd42"
}

Conf.heroes = {}

-- name, label, action for skills with cooldown
---@alias actif_skill {[1]:string, [2]:string, [3]:string}
---@type table<string, actif_skill>
Conf.heroes.actif_skills = {
    vranken = { "transposition", _ "Transposition", "AB.transposition()" },
    xavier = { "O_formation", _ "Union debuf", "AB.union_debuf()" }
}

-- Should be called once, at first use of the hero
---@param unit unit
function wesnoth.units.init_hero(unit)
    unit:custom_variables().special_skills = {}
    unit:custom_variables().xp = 0
    unit.role = "hero"
end

function Conf.heroes.get_color(unit_id) return colors[unit_id] or "#000000" end
