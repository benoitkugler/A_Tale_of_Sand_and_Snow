DB_AMLAS.drumar = {
	{
		id = "though",
		require_amla = "hp,hp",
		image = "icons/helmet_chain-coif.png",
		max_times = 3,
		always_display = 1,
		description = _ "More resilient to magical damage.",
		T.effect {
			apply_to = "resistance",
			T.resistance {
				cold = -7,
				fire = -7,
				arcane = -7
			}
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "wave",
		image = "attacks/iceball.png",
		max_times = 3,
		always_display = 1,
		description = _ "Better with chill wave.",
		T.effect {
			apply_to = "attack",
			increase_damage = 2,
			name = "chill wave"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "toile_snare",
		_level_bonus = true,
		require_amla = "toile_atk,toile_atk,toile_atk",
		image = "attacks/entangle_snare.png",
		max_times = 1,
		always_display = 1,
		description = _ "Entangle now snares the target for one turn.",
		T.effect {
			set_icon = "attacks/entangle_snare.png",
			apply_to = "attack",
			name = "entangle",
			T.set_specials {
				mode = "append",
				T.isHere {
					description = _ "Lock down the target for 1 turn.",
					id = "snare",
					active_on = "offense",
					name = "snare"
				}
			}
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "toile",
		image = "attacks/entangle.png",
		max_times = 2,
		always_display = 1,
		description = _ "Better with entangle.",
		T.effect {
			apply_to = "attack",
			increase_damage = 2,
			name = "entangle"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "wave_weaker_slow2",
		require_amla = "wave_weaker_slow1",
		image = "icons/iceball_slow.png",
		max_times = 1,
		always_display = 1,
		description = _ "Chill wave decreases target's damages even harder.",
		T.effect {
			name = "chill wave",
			apply_to = "attack",
			T.set_specials {
				mode = "append",
				T.isHere {
					description = _ "Reduces target's damage by <span color='red'> 15%</span> per hit. <span style='italic'>Last 1 turn.</span>",
					id = "weaker_slow*2",
					active_on = "offense",
					name = "weaker slow"
				}
			}
		},
		T.effect {
			apply_to = "attack",
			remove_specials = "weaker_slow*1",
			name = "chill wave"
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "attack_chilled",
		_level_bonus = true,
		require_amla = "wave_arch_magical,wave_res2,wave_weaker_slow2",
		image = "attacks/touch-undead.png",
		max_times = 1,
		always_display = 1,
		description = _ "Chilling touch : a powerful cold damage boost.",
		T.effect {
			icon = "attacks/touch-undead.png",
			range = "melee",
			number = 2,
			type = "cold",
			description = _ "Chilling touch",
			damage = 25,
			apply_to = "new_attack",
			name = "chilling touch",
			T.specials {
				T.isHere {
					id = "status_chilled*1",
					description = _ "Tags the target for 2 turns. Chilled unit will take bonus damage when hit by cold attacks.",
					name = "chilling"
				}
			}
		},
		unpack(standard_amla_heal(15))
	},
	{
		id = "hp",
		image = "icons/amla-default.png",
		max_times = 2,
		always_display = 1,
		description = _ "Healthier.",
		T.effect {
			increase_total = 7,
			apply_to = "hitpoints"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "toile_atk",
		require_amla = "toile,toile",
		image = "attacks/entangle.png",
		max_times = 3,
		always_display = 1,
		description = _ "Faster with entangle.",
		T.effect {
			apply_to = "attack",
			name = "entangle",
			increase_attacks = 1
		},
		unpack(standard_amla_heal(7))
	},
	{
		id = "wave_atk",
		require_amla = "wave,wave,wave",
		image = "attacks/iceball.png",
		max_times = 2,
		always_display = 1,
		description = _ "Faster with chill wave.",
		T.effect {
			apply_to = "attack",
			name = "chill wave",
			increase_attacks = 1
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "wave_res2",
		require_amla = "wave_res1",
		image = "icons/iceball_res.png",
		max_times = 1,
		always_display = 1,
		description = _ "Chill wave reduces target's resistances even harder.",
		T.effect {
			name = "chill wave",
			apply_to = "attack",
			T.set_specials {
				mode = "append",
				T.isHere {
					description = _ "Reduces target's magic resistances by <span color='red'>7%</span> per hit.",
					id = "res_magic*2",
					active_on = "offense",
					name = "magic weakness"
				}
			}
		},
		T.effect {
			apply_to = "attack",
			remove_specials = "res_magic*1",
			name = "chill wave"
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "wave_weaker_slow1",
		require_amla = "wave_atk,wave_atk",
		image = "icons/iceball_slow.png",
		max_times = 1,
		always_display = 1,
		description = _ "Chill wave decreases target's damage per hit.",
		T.effect {
			name = "chill wave",
			apply_to = "attack",
			T.set_specials {
				mode = "append",
				T.isHere {
					description = _ "Reduces target's damage by <span color='red'> 10%</span> per hit. <span style='italic'>Last 1 turn.</span>",
					id = "weaker_slow*1",
					active_on = "offense",
					name = "weaker slow"
				}
			}
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "wave_arch_magical",
		_level_bonus = true,
		require_amla = "wave_atk,wave_atk",
		image = "attacks/iceball_arch_magical.png",
		max_times = 1,
		always_display = 1,
		description = _ "Amazingly accurate with chill wave.",
		T.effect {
			set_icon = "attacks/iceball_arch_magical.png",
			apply_to = "attack",
			name = "chill wave",
			T.set_specials {
				mode = "append",
				T.chance_to_hit {
					id = "arch_magical",
					value = 80,
					description = _ "This attack always has an 80% chance to hit regardless of the defensive ability of the unit being attacked.",
					cumulative = false,
					name = "arch magical"
				}
			}
		},
		T.effect {
			apply_to = "attack",
			remove_specials = "magical",
			name = "chill wave"
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "wave_res1",
		require_amla = "wave_atk,wave_atk",
		image = "icons/iceball_res.png",
		max_times = 1,
		always_display = 1,
		description = _ "Chill wave reduces target's resistances per hit.",
		T.effect {
			name = "chill wave",
			apply_to = "attack",
			T.set_specials {
				mode = "append",
				T.isHere {
					description = _ "Reduces target's magic resistances by <span color='red'>5%</span> per hit.",
					id = "res_magic*1",
					active_on = "offense",
					name = "magic weakness"
				}
			}
		},
		unpack(standard_amla_heal(10))
	},
	{
		max_times = -1,
		require_amla = "though,though,attack_chilled,toile_snare",
		id = "default",
		T.effect {
			increase_total = 1,
			apply_to = "hitpoints"
		},
		unpack(standard_amla_heal(5))
	}
}