DB_AMLAS.vranken = {
	{
		id = "sword_marksman",
		_level_bonus = true,
		require_amla = "sword_bow_atk",
		image = "attacks/sword_marksman.png",
		max_times = 1,
		always_display = 1,
		description = _ "More precise with swords : 60% chance to hit.",
		T.effect {
			set_icon = "attacks/sword_marksman.png",
			apply_to = "attack",
			name = "sword",
			T.set_specials {
				mode = "append",
				T.chance_to_hit {
					id = "marksman",
					value = 60,
					active_on = "offense",
					description = _ "When used offensively, this attack always has at least a 60% chance to hit.",
					cumulative = true,
					name = "marksman"
				}
			}
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "bow_slow",
		require_amla = "sword_bow_atk",
		image = "attacks/bow_slow.png",
		max_times = 1,
		always_display = 1,
		description = _ "Freezes your arc. Add weapon special : slows.",
		T.effect {
			set_icon = "attacks/bow_slow.png",
			apply_to = "attack",
			name = "bow",
			T.set_specials {
				mode = "append",
				T.slow {
					id = "slow",
					description = _ "This attack slows the target until it ends a turn. Slow halves the damage caused by attacks and the movement cost for a slowed unit is doubled. A unit that is slowed will feature a snail icon in its sidebar information when it is selected.",
					name = "slows"
				}
			}
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "sword_atk",
		require_amla = "sword,sword",
		image = "attacks/sword-human.png",
		max_times = 1,
		always_display = 1,
		description = _ "Faster with swords",
		T.effect {
			apply_to = "attack",
			name = "sword",
			increase_attacks = 1
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "sword_precis",
		require_amla = "sword_atk",
		image = "attacks/sword_precis.png",
		max_times = 1,
		always_display = 1,
		description = _ "More precise with swords : 70% chance to hit.",
		T.effect {
			set_icon = "attacks/sword_precis.png",
			apply_to = "attack",
			name = "sword",
			T.set_specials {
				mode = "append",
				T.chance_to_hit {
					id = "precis",
					value = 70,
					description = _ "This attack always has a 70% chance to hit regardless of the defensive ability of the unit being attacked.",
					cumulative = false,
					name = "precision"
				}
			}
		},
		T.effect {
			apply_to = "attack",
			remove_specials = "marksman",
			name = "sword"
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "sword_bow_atk",
		require_amla = "sword_bow,sword_bow,sword_bow",
		image = "icons/bow_sword.png",
		max_times = 1,
		always_display = 1,
		description = _ "Faster with swords and bows",
		T.effect {
			apply_to = "attack",
			name = "sword",
			increase_attacks = 1
		},
		T.effect {
			apply_to = "attack",
			name = "bow",
			increase_attacks = 1
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "sword_bow",
		image = "icons/bow_sword.png",
		max_times = 3,
		always_display = 1,
		description = _ "Stronger with swords and bows",
		T.effect {
			apply_to = "attack",
			increase_damage = 1,
			name = "sword"
		},
		T.effect {
			apply_to = "attack",
			increase_damage = 1,
			name = "bow"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "sand",
		_level_bonus = true,
		require_amla = "snow",
		image = "icons/boots_sand.png",
		max_times = 1,
		always_display = 1,
		description = _ "Fight and move better on sand.",
		T.effect {
			replace = true,
			apply_to = "movement_costs",
			T.movement_costs {
				sand = 1
			}
		},
		T.effect {
			replace = true,
			apply_to = "defense",
			T.defense {
				sand = 40
			}
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "snow",
		require_amla = "pm,pm",
		image = "icons/boots_ice.png",
		max_times = 1,
		always_display = 1,
		description = _ "Fight and move better on snow.",
		T.effect {
			replace = true,
			apply_to = "movement_costs",
			T.movement_costs {
				frozen = 1
			}
		},
		T.effect {
			replace = true,
			apply_to = "defense",
			T.defense {
				frozen = 40
			}
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "though",
		require_amla = "regen10,regen20",
		image = "icons/cuirass_leather_studded.png",
		max_times = 2,
		always_display = 1,
		description = _ "Tougher, + 5% resistances",
		T.effect {
			apply_to = "resistance",
			T.resistance {
				impact = -5,
				blade = -5,
				arcane = -5,
				cold = -5,
				pierce = -5,
				fire = -5
			}
		},
		unpack(standard_amla_heal(7))
	},
	{
		id = "bow",
		require_amla = "bow_slow",
		image = "attacks/bow-elven.png",
		max_times = 1,
		always_display = 1,
		description = _ "Better with bows",
		T.effect {
			apply_to = "attack",
			increase_damage = 2,
			name = "bow"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "regen20",
		require_amla = "regen10",
		image = "icons/potion_red_medium.png",
		max_times = 1,
		always_display = 1,
		description = _ "Regenerates +20 HP per turn.",
		T.effect {
			apply_to = "new_ability",
			T.abilities {
				T.regenerate {
					id = "regenerate_cure20",
					value = 20,
					description = _ "Heals himself for 20 HP per turn.",
					poison = "cured",
					name = "Regeneration"
				}
			}
		},
		T.effect {
			apply_to = "remove_ability",
			T.abilities {
				T.regenerate {
					id = "regenerate10"
				}
			}
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "regen10",
		image = "icons/potion_red_small.png",
		max_times = 1,
		always_display = 1,
		description = _ "Regenerates +10 HP per turn.",
		T.effect {
			apply_to = "new_ability",
			T.abilities {
				T.regenerate {
					id = "regenerate10",
					value = 10,
					description = _ "Heals himself for 10 HP per turn.",
					name = "Regeneration"
				}
			}
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "bow_mayhem",
		require_amla = "bow_atk,bow_atk",
		image = "icons/bow_mayhem.png",
		max_times = 1,
		always_display = 1,
		description = _ "Reduces opponent damages by 1 per strike.",
		T.effect {
			name = "bow",
			apply_to = "attack",
			T.set_specials {
				mode = "append",
				T.isHere {
					description = _ "Reduces damages of the target by 1per hit, until the end of the scenario.",
					id = "mayhem",
					active_on = "offense",
					name = "mayhem"
				}
			}
		},
		unpack(standard_amla_heal(15))
	},
	{
		id = "sword",
		require_amla = "sword_marksman",
		image = "attacks/sword-human.png",
		max_times = 2,
		always_display = 1,
		description = _ "Better with swords",
		T.effect {
			apply_to = "attack",
			increase_damage = 2,
			name = "sword"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "bow_atk",
		require_amla = "bow",
		image = "attacks/bow-elven.png",
		max_times = 2,
		always_display = 1,
		description = _ "Faster with bows",
		T.effect {
			apply_to = "attack",
			name = "bow",
			increase_attacks = 1
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "pm",
		image = "icons/boots_elven.png",
		max_times = 2,
		always_display = 1,
		description = _ "Very nimble, +1 move",
		T.effect {
			increase = 1,
			apply_to = "movement"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "bow_firststrike",
		require_amla = "bow_atk,bow_atk",
		image = "icons/bow_firststrike.png",
		max_times = 1,
		always_display = 1,
		description = _ "Always attacks first with bows, even in defense.",
		T.effect {
			name = "bow",
			apply_to = "attack",
			T.set_specials {
				mode = "append",
				T.firststrike {
					id = "firststrike",
					description = _ "This unit always strikes first with this attack, even if they are defending.",
					name = "first strike"
				}
			}
		},
		unpack(standard_amla_heal(15))
	},
	{
		id = "sword_cleave",
		_level_bonus = true,
		require_amla = "sword_atk",
		image = "icons/sword_cleave.png",
		max_times = 1,
		always_display = 1,
		description = _ "Attacking with swords deals 75% damage to nearby ennemies.",
		T.effect {
			name = "sword",
			apply_to = "attack",
			T.set_specials {
				mode = "append",
				T.isHere {
					id = "cleave",
					description = _ "Deals 75% damage to enemies between attacker and defender.",
					name = "cleave"
				}
			}
		},
		unpack(standard_amla_heal(15))
	},
	{
		max_times = -1,
		description = _ "",
		require_amla = "bow_mayhem,bow_firststrike,sword_cleave,sword_precis,sand,though,though",
		id = "default",
		image = "",
		T.effect {
			increase_total = 1,
			apply_to = "hitpoints"
		},
		unpack(standard_amla_heal(5))
	}
}
