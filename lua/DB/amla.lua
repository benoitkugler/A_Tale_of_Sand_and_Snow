-- Load amlas tree defined in trees/
-- Each amla may have function as effect, which will be called with current unit as argument
-- Each amla may have _level_bonus boolean raising by 1 the lvl of the unit
-- Each amla should define a _short_desc string field (where dot formatting is allowed). 
-- This string will be the title of the matching node in the graph displayed in game.

AM = {}

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

DB_AMLAS = {}

wesnoth.require "trees/brinx"
wesnoth.require "trees/drumar"
wesnoth.require "trees/vranken"
wesnoth.require "trees/xavier"


-- Process an amla tree by computing effect given by a function
local function _process_amlas(amlas_table, unit)
	local computed_table = {}
	for i , amla in ipairs(amlas_table) do
		local computed_amla = {}
		for j, value in pairs(amla) do 
			if type(value) == "function" then -- executing function with unit as argument
				computed_amla[j] = value(unit)
			else --just copy
				computed_amla[j] = value 
			end
		end
		computed_table[i] = T.advancement(computed_amla)
	end
	return computed_table
end

-- Add bonus levels based on AMLAs the unit currently has
function AM.update_lvl(unit)
	local base_lvl = wesnoth.unit_types[unit.type].level
    for amla in H.child_range(H.get_child(unit.__cfg, "modifications") or {}, "advancement") do
		if amla._level_bonus then
			base_lvl = base_lvl + 1
		end
	end
	unit.level = base_lvl
end

function AM.adv()
    local u = get_pri()
	u:remove_modifications({ id = "current_amlas"}, "trait")
	AM.update_lvl(u)
end

function AM.pre_advance()
	local u = get_pri()
	local table_amlas = DB_AMLAS[u.id]  -- loading custom amlas
	if (table_amlas == nil) or #(u.advances_to) > 0 then
		return 
	end

	table_amlas =  _process_amlas(table_amlas, u)
    u:add_modification(
        "trait",
        {
            id = "current_amlas",
            T.effect {
				apply_to = "new_advancement",
				replace = true,
                unpack(table_amlas)
            }
        }
    )
end