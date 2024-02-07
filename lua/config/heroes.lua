-- default is black
local colors = {
    brinx = "#357815",
    rymor = "#BCB4D6",
    drumar = "#00FFF5",
    bunshop = "#FFFA80",
    xavier = "#a99508",
    sword_spirit = "#A00E27",
    morgane = "#ddebe0"
}

local HE = {}

-- name, label, action for skills with cooldown
HE.actif_skills = {
    vranken = { "transposition", _ "Transposition", "AB.transposition()" },
    xavier = { "O_formation", _ "Union debuf", "AB.union_debuf()" }
}

-- Should be called once, at first use of the hero
---@param unit_id string
function HE.init(unit_id)
    local u = wesnoth.units.get(unit_id)
    u.variables.special_skills = {}
    u.variables.xp = 0
    u.role = "hero"
end

function HE.get_color(unit_id) return colors[unit_id] or "#000000" end

DB.HEROES = HE
