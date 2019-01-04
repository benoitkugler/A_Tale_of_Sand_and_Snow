DB_AMLAS.xavier = {
	_default_border = "#a99508", 
	_default_background = "181 167 71", -- rgb
	{
		id = "leadership1",
		_short_desc = "Leadership I",
		image = "misc/laurel.png",
		max_times = 1,
		always_display = 1,
		description = _ "Grants 15% bonus damage for higher level allies.",
		T.effect {
			apply_to = "new_ability",
			T.abilities {
				T.leadership {
					cumulative = false,
					value = "(15 * 1)",
					affect_self = false,
					description = _ "Even more experienced units are impressed by its skills ! Adjacent own units of equal or higher level will do $(15*RATIO) more damage.",
					id = "leadership1",
					female_name = "inspiration1",
					name = "inspiration1",
					T.affect_adjacent {
						T.filter {
							formula = "level >= other.level"
						}
					}
				}
			}
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "leadership2",
		_short_desc = "Leadership II",
		require_amla = "leadership1",
		image = "misc/laurel.png",
		max_times = 1,
		always_display = 1,
		description = _ "Grants 30% bonus damage for higher level allies.",
		T.effect {
			apply_to = "remove_ability",
			T.abilities {
				id = "leadership1"
			}
		},
		T.effect {
			apply_to = "new_ability",
			T.abilities {
				T.leadership {
					cumulative = false,
					value = "(15 * 2)",
					affect_self = false,
					description = _ "Even more experienced units are impressed by its skills ! Adjacent own units of equal or higher level will do $(15*RATIO) more damage.",
					id = "leadership2",
					female_name = "inspiration2",
					name = "inspiration2",
					T.affect_adjacent {
						T.filter {
							formula = "level >= other.level"
						}
					}
				}
			}
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "leadership3",
		_short_desc = "Leadership III",
		require_amla = "leadership2",
		image = "misc/laurel.png",
		max_times = 1,
		always_display = 1,
		description = _ "Grants 45% bonus damage for higher level allies.",
		T.effect {
			apply_to = "remove_ability",
			T.abilities {
				id = "leadership2"
			}
		},
		T.effect {
			name = "",
			apply_to = ""
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "defense_reduc",
		_short_desc = "<B> Defense shred </B>",
		_color = {54, 255, 5},
		require_amla = "sword_precis,crossbow_marksman",
		image = "icons/broken_tunic.png",
		max_times = 3,
		always_display = 1,
		description = _ "Reduces ennemies defense on hit. A implémenter !",
		T.effect {
			name = "",
			apply_to = ""
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "sword2",
		_short_desc = "Sword <BR /> <B> +2</B> dmg",
		require_amla = "sword_marksman",
		image = "attacks/sword-elven.png",
		max_times = 2,
		always_display = 1,
		description = _ "Even better with sword",
		T.effect {
			apply_to = "attack",
			increase_damage = 2,
			name = "sword"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "defense",
		_short_desc = "Bonus defense",
		require_amla = "leadership3",
		image = "icons/dress_silk_green.png",
		max_times = 3,
		always_display = 1,
		description = _ "Enhance allies defenses. A implémenter !",
		T.effect {
			name = "",
			apply_to = ""
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "crossbow",
		_short_desc = "Crossbow <BR /> <B> +2</B> dmg",
		image = "attacks/crossbow-human.png",
		max_times = 2,
		always_display = 1,
		description = _ "Better with crossbows",
		T.effect {
			apply_to = "attack",
			increase_damage = 2,
			name = "crossbow"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "armor_shred",
		_short_desc = "<B> Armor shred </B>",
		_color = {54, 255, 5},
		_level_bonus = true,
		require_amla = "sword_precis,crossbow_marksman",
		image = "icons/broken_shield.png",
		max_times = 3,
		always_display = 1,
		description = _ "Reduces ennemies armor on hit. A implémenter !",
		T.effect {
			name = "",
			apply_to = ""
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "crossbow_marksman",
		_short_desc = "Crossbow <BR /> <B> Marksman</B> ",
		_level_bonus = true,
		require_amla = "crossbow_atk",
		image = "attacks/crossbow-human.png",
		max_times = 1,
		always_display = 1,
		description = _ "More precise with crossbows : 60% chance to hit",
		T.effect {
			set_icon = "attacks/crossbow-human.png",
			apply_to = "attack",
			name = "crossbow",
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
		id = "sword_marksman",
		_short_desc = "Sword <BR /> <B> Marksman</B>",
		_color = {69, 117, 174},
		_level_bonus = true,
		require_amla = "sword,sword",
		image = "attacks/sword_marksman.png",
		max_times = 1,
		always_display = 1,
		description = _ "More precise with sword : 60% chance to hit",
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
		id = "crossbow_atk",
		_short_desc = "Crossbow <BR /> <B> +1</B> str.",
		require_amla = "crossbow,crossbow",
		image = "attacks/crossbow-human.png",
		max_times = 1,
		always_display = 1,
		description = _ "Faster with crossbows",
		T.effect {
			apply_to = "attack",
			name = "crossbow",
			increase_attacks = 1
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "sword",
		_short_desc = "Sword <BR /> <B> +2</B> dmg",
		image = "attacks/sword-elven.png",
		max_times = 2,
		always_display = 1,
		description = _ "Better with sword",
		T.effect {
			apply_to = "attack",
			increase_damage = 2,
			name = "sword"
		},
		unpack(standard_amla_heal(5))
	},
	{
		id = "sword_atk2",
		_short_desc = "Sword <BR /> <B> +1</B> str",
		require_amla = "sword2,sword2",
		image = "attacks/sword-elven.png",
		max_times = 1,
		always_display = 1,
		description = _ "Faster with sword",
		T.effect {
			apply_to = "attack",
			name = "sword",
			increase_attacks = 1
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "defense2",
		_short_desc = "Defense range <BR /> + 1",
		_level_bonus = true,
		require_amla = "defense,defense,defense",
		image = "icons/dress_silk_green.png",
		max_times = 1,
		always_display = 1,
		description = _ "Even better defense for allies ! A implémenter",
		T.effect {
			name = "",
			apply_to = ""
		},
		unpack(standard_amla_heal(10))
	},
	{
		id = "sword_precis",
		_short_desc = "Sword <BR /> <B> Precis </B>",
		_color = {69, 117, 174},
		_level_bonus = true,
		require_amla = "sword_atk2,leadership3",
		image = "attacks/sword_precis.png",
		max_times = 1,
		always_display = 1,
		description = _ "So precise with swords : 70% chance to hit",
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
		id = "default",
		require_amla = "defense_reduc,defense_reduc,defense_reduc,armor_shred,armor_shred,armor_shred",
		max_times = -1,
		description = _ "Basic +3Hp AMLA.",
		T.effect {
			increase_total = 3,
			apply_to = "hitpoints"
		},
		unpack(standard_amla_heal(5))
	}
}
