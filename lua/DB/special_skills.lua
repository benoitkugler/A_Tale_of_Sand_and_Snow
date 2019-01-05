local info = wesnoth.require("~add-ons/A_Tale_of_Sand_and_Snow/lua/DB/special_skills_meta.lua")

-- Implementation of special skills (trigered when choosing to a skill in menu item.)
-- Each special skill is coded in WML has an object with id skill_idoftheskill
-- An attribut _level maybe added to abilities and specials when needed
-- Upgrading a skill should remove the old level and create a new one.

local apply = {}

local function _get_ids(lvl, skill_name)
	local id, old_id = "skill_" .. skill_name .. lvl, "skill_" .. skill_name .. tostring(lvl - 1)
	return id, old_id
end

-- ---------------------------------- Vranken ----------------------------------
function apply.leeches_cac(lvl, unit)
	local id, old_id = _get_ids(lvl, "leeches_cac")
	unit:remove_modifications({id = old_id}, "object")

	local value = info[unit.id].leeches_cac(lvl)
	local desc = string.format(tostring(_ "Regenerates %d%% of the damage dealt in offense and defense. Also works against undead"),value)
	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "attack",
				range = "melee",
				T.set_specials {
					mode = "append",
					T.isHere {
						id = "leeches",
						_level = lvl,
						name = _ "leeches",
						description = desc
					}
				}
			}
		}
	)
end

function apply.drain_cac(lvl, unit)
	local id, old_id = _get_ids(lvl, "drain_cac")
	unit:remove_modifications({id = old_id}, "object")

	local values = info[unit.id].drain_cac(lvl)
	local dmg, radius = values[1], values[2]
	local desc = string.format(tostring(_ "Regenerates %d%% of the damage dealt in offense and defense. Doesn't apply to undead"), dmg)
	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "attack",
				range = "melee",
				T.set_specials {
					mode = "append",
					T.drains {
						id = "drain_cac",
						_level = lvl,
						name = _ "drains",
						value = dmg,
						description = desc,
						description_inactive = _ "Göndhul is too far away from Vranken.",
						T.filter_self {
							T.filter_location {
								radius = radius, 
								T.filter {id = "sword_spirit"}
							}
						}
					}
				}
			}
		}
	)
end

function apply.atk_brut(lvl, unit)
	local id, old_id = _get_ids(lvl, "atk_brut")
	unit:remove_modifications({id = old_id}, "object")

	local ratio = info[unit.id].atk_brut(lvl)

	local atk = unit.attacks.sword
	local new_attack = {
		apply_to = "new_attack",
		name = "sword",
		range = "melee",
		type = "brut",
		damage = atk.damage * ratio / 100, 
		number = atk.number,
		description = _ "ether sword",
		icon = "attacks/atk_brut.png"
	}

	unit:add_modification(
		"object",
		{
			id = id,
			{"effect", new_attack}
		}
	)
end

function apply.transposition(lvl, unit)
	local id, old_id = _get_ids(lvl, "transposition")
	unit:remove_modifications({id = old_id}, "object")


	unit.variables.comp_spe = true
	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "new_ability",
				T.abilities {
					T.isHere {
						id = "transposition",
						_level = lvl,
						name = _ "War link",
						description = _ "Vranken senses its sword spirit and may switch position with Göndhul, no matter the distance between them. \n<span color='green'>Available now </span>"
					}
				}
			}
		}
	)
end

-- ----------------------------------- Brinx -----------------------------------
function apply.def_muspell(lvl, unit)
	local id, old_id = _get_ids(lvl, "def_muspell")
	unit:remove_modifications({id = old_id}, "object")

	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "new_ability",
				T.abilities {
					T.isHere {
						id = id,
						name = _ "Muspell Equilibrium",
						description = _ "Brinx learned how to better dodge muspellian attacks : +" ..
							tostring(5 + lvl * 5) .. " % bonus defense." --des
					}
				}
			},
			T.effect {
				apply_to = "attack",
				T.set_specials {
					mode = "append",
					T.chance_to_hit {
						id = "def_muspell",
						_level = lvl,
						name = "",
						description = "",
						sub = (5 + 5 * lvl),
						--chance to hit
						apply_to = "opponent",
						T.filter_opponent {race = "muspell"}
					}
				}
			}
		}
	)
end

function apply.dmg_muspell(lvl, unit)
	local id, old_id = _get_ids(lvl, "dmg_muspell")
	unit:remove_modifications({id = old_id}, "object")

	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "new_ability",
				T.abilities {
					T.isHere {
						id = "dmg_muspell",
						_level = lvl,
						name = _ "Muspell Terror",
						description = _ "Brinx deals " .. tostring(lvl * 10) .. " % bonus damage when facing a muspellian opponent." --des
					}
				}
			},
			T.effect {
				apply_to = "attack",
				T.set_specials {
					mode = "append",
					T.damage {
						id = "def_muspell",
						_level = lvl,
						name = "",
						description = "",
						multiply = (1 + lvl * 0.1), --special damage
						T.filter_opponent {race = "muspell"}
					}
				}
			}
		}
	)
end

function apply.fresh_blood_musp(lvl, unit)
	local id, old_id = _get_ids(lvl, "fresh_bloo_musp")
	unit:remove_modifications({id = old_id}, "object")

	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "new_ability",
				T.abilities {
					T.isHere {
						id = "fresh_blood_musp",
						_level = lvl,
						name = _ "Muspell strength",
						description = _ "Brinx heals himself for " .. (2 + 6 * lvl) .. "HP when killing a muspellian" --des
					}
				}
			}
		}
	)
end

function apply.muspell_rage(lvl, unit)
	local id, old_id = _get_ids(lvl, "fresh_bloo_musp")
	unit:remove_modifications({id = old_id}, "object")

	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "new_ability",
				T.abilities {
					T.isHere {
						id = "muspell_rage",
						_level = lvl,
						name = _ "Revenge",
						description = _ "Brinx deals and takes " .. (lvl * 10) .. " % bonus damage.",
						--des
						description_inactive = _ "There is no muspellian friend to anger Brinx.",
						T.filter {T.filter_side {T.has_unit {race = "muspell"}}}
					}
				}
			},
			T.effect {
				apply_to = "attack",
				T.set_specials {
					mode = "append",
					T.damage {
						id = "muspell_rage",
						_level = lvl,
						name = "",
						apply_to = "both",
						description = "",
						multiply = (1 + lvl * 0.1), --rage bonus
						T.filter {T.filter_side {T.has_unit {race = "muspell"}}}
					}
				}
			}
		}
	)
end

-- ----------------------------------- Drumar ----------------------------------- --
function apply.wave_dmg(lvl, unit)
	wesnoth.message("A implémenter !")
end

function apply.forecast_defense(lvl, unit)
	wesnoth.message("A implémenter !")
end

function apply.slow_zone(lvl, unit)
	wesnoth.message("A implémenter !")
end

function apply.bonus_cold_mistress(lvl, unit)
	wesnoth.message("A implémenter !")
end

local DB = {apply = apply, info = info}
return DB
