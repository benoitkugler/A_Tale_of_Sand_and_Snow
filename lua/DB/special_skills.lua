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
	local desc =
		string.format(
		tostring(_ "Regenerates %d%% of the damage dealt in offense and defense. Also works against undead"),
		value
	)
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
	local desc =
		string.format(tostring(_ "Regenerates %d%% of the damage dealt in offense and defense. Doesn't apply to undead"), dmg)
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

	local value = info[unit.id].def_muspell(lvl)
	local desc =
		string.format(tostring(_ "Brinx learned how to better dodge muspellian attacks : %d%% bonus defense."), value)
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
						description = desc
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
						sub = value,
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

	local value = info[unit.id].dmg_muspell(lvl)
	local desc = string.format(tostring(_ "Brinx deals %d%% bonus damage when facing a muspellian opponent."), value)
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
						description = desc
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
						multiply = 1 + value / 100,
						T.filter_opponent {race = "muspell"}
					}
				}
			}
		}
	)
end

function apply.fresh_blood_musp(lvl, unit)
	local id, old_id = _get_ids(lvl, "fresh_blood_musp")
	unit:remove_modifications({id = old_id}, "object")

	local value = info[unit.id].fresh_blood_musp(lvl)
	local desc = string.format(tostring(_ "Brinx heals himself for %d HP when killing a muspellian"), value)
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
						description = desc
					}
				}
			}
		}
	)
end

function apply.muspell_rage(lvl, unit)
	local id, old_id = _get_ids(lvl, "muspell_rage")
	unit:remove_modifications({id = old_id}, "object")

	local value = info[unit.id].muspell_rage(lvl)
	local desc = string.format(tostring(_ "Brinx deals and takes %d%% bonus damage."), value)
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
						description = desc,
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
						multiply = 1 + value / 100,
						T.filter {T.filter_side {T.has_unit {race = "muspell"}}}
					}
				}
			}
		}
	)
end

-- ----------------------------------- Drumar ----------------------------------- --
function apply.wave_dmg(lvl, unit)
	local id, old_id = _get_ids(lvl, "wave_dmg")
	unit:remove_modifications({id = old_id}, "object")

	local values = info[unit.id].wave_dmg(lvl)
	local dmg, nb_atk = values[1], values[2]

	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "attack",
				name = "chill wave",
				increase_damage = tostring(dmg) .. "%",
				increase_attacks = nb_atk
			}
		}
	)
end

function apply.forecast_defense(lvl, unit)
	local id, old_id = _get_ids(lvl, "forecast_defense")
	unit:remove_modifications({id = old_id}, "object")

	local def = info[unit.id].forecast_defense(lvl)
	unit:add_modification(
		"object",
		{
			id = id,
			add_defenses(def)
		}
	)
end

function apply.slow_zone(lvl, unit)
	local id, old_id = _get_ids(lvl, "slow_zone")
	unit:remove_modifications({id = old_id}, "object")

	local intensity = info[unit.id].slow_zone(lvl)
	local desc = string.format(tostring(_ "Decrease adjacent ennemies damages and movements by %d%%"), intensity)
	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "attack",
				name = "entangle",
				T.set_specials {
					mode = "append",
					T.isHere {
						id = "slow_zone",
						_level = lvl,
						name = _ "slowing field",
						description = desc
					}
				}
			}
		}
	)
end

function apply.bonus_cold_mistress(lvl, unit)
	local id, old_id = _get_ids(lvl, "bonus_cold_mistress")
	unit:remove_modifications({id = old_id}, "object")

	local values = info[unit.id].bonus_cold_mistress(lvl)
	local dmg, nb_turn = values[1], values[2]
	local desc = string.format(tostring(_ "Target takes <span weight='bold'>%d%%</span> bonus damage, when hit by cold attacks. Last <span weight='bold'>%d</span> turns."), dmg, nb_turn)
	unit:add_modification(
		"object",
		{
			id = id,
			T.effect {
				apply_to = "attack",
				name = "chilling touch",
				remove_specials = "status_chilled",
				T.set_specials {
					mode = "append",
					T.isHere {
						id = "status_chilled",
						_level = lvl + 1,
						name = _ "chilling",
						description = desc
					}
				}
			}
		}
	)
end

local DB = {apply = apply, info = info}
return DB
