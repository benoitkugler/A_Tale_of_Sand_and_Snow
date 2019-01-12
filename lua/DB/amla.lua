-- Load amlas tree defined in trees/
-- Each amla may have function as effect, which will be called with current unit as argument
-- Each amla may have _level_bonus boolean raising by 1 the lvl of the unit
-- Each amla should define a _short_desc string field (where dot formatting is allowed). 
-- This string will be the title of the matching node in the graph displayed in game.


-- shortcut to avoid boilerplate code in trees
function standard_amla_heal(exp)
	return {T.effect {
		increase = tostring(exp) .. "%",
		apply_to = "max_experience"
	},
	T.effect {
		remove = "poisoned",
		apply_to = "status"
	},
	T.effect {
		remove = "slowed",
		apply_to = "status"
	},
	T.effect {
		apply_to = "hitpoints",
		increase_total = 2,
		heal_full = true
	}}
end

local amlas = {}
amlas.brinx =  wesnoth.require "trees/brinx"
amlas.drumar = wesnoth.require "trees/drumar"
amlas.vranken = wesnoth.require "trees/vranken"
amlas.xavier = wesnoth.require "trees/xavier"
return amlas

