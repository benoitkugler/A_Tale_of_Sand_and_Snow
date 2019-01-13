local colors = {
	vranken = "",
	brinx = "#357815",
	rymor = "#BCB4D6",
	drumar = "#00FFF5",
	bunshop = "#FFFA80",
	xavier = "#a99508",
	sword_spirit = "#A00E27"
}

-- Special variables for heroes
local HE = {}

-- Should be called once, at first use of the hero
function HE.init(unit_id)
	local u = wesnoth.get_unit(unit_id)
	u.variables.special_skills = {}
	u.variables.xp = 0
	u.role = "hero"
end

function HE.get_color(unit_id)
	return colors[unit_id] or "#000000"
end

return HE