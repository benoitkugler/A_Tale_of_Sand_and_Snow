defaultbordure = "#a99508"
defaultfond = "181 167 71"

arbre = {
	{id = "sword", img = "attacks/sword-elven.png", txt = "Sword <BR /> <B> +2</B> dmg", max_level = 2},
	{
		id = "sword_marksman",
		levelbonus = true,
		img = "attacks/sword_marksman.png",
		txt = "Sword <BR /> <B> Marksman</B>",
		max_level = 1,
		parents = {"sword"},
		couleur = {69, 117, 174}
	},
	{
		id = "sword2",
		img = "attacks/sword-elven.png",
		txt = "Sword <BR /> <B> +2</B> dmg",
		max_level = 2,
		parents = {"sword_marksman"}
	},
	{
		id = "sword_atk2",
		img = "attacks/sword-elven.png",
		txt = "Sword <BR /> <B> +1</B> str",
		max_level = 1,
		parents = {"sword2"}
	},
	{
		id = "sword_precis",
		levelbonus = true,
		img = "attacks/sword_precis.png",
		txt = "Sword <BR /> <B> Precis </B>",
		max_level = 1,
		parents = {"sword_atk2", "leadership3"},
		couleur = {69, 117, 174}
	},
	{id = "leadership1", img = "misc/laurel.png", txt = "Leadership I", max_level = 1},
	{id = "leadership2", img = "misc/laurel.png", txt = "Leadership II", max_level = 1, parents = {"leadership1"}},
	{id = "leadership3", img = "misc/laurel.png", txt = "Leadership III", max_level = 1, parents = {"leadership2"}},
	{id = "defense", img = "icons/dress_silk_green.png", txt = "Bonus defense", max_level = 3, parents = {"leadership3"}},
	{
		id = "defense2",
		levelbonus = true,
		img = "icons/dress_silk_green.png",
		txt = "Defense range <BR /> + 1",
		max_level = 1,
		parents = {"defense"}
	},
	{id = "crossbow", img = "attacks/crossbow-human.png", txt = "Crossbow <BR /> <B> +2</B> dmg", max_level = 2},
	{
		id = "crossbow_atk",
		img = "attacks/crossbow-human.png",
		txt = "Crossbow <BR /> <B> +1</B> str.",
		max_level = 1,
		parents = {"crossbow"}
	},
	{
		id = "crossbow_marksman",
		levelbonus = true,
		img = "attacks/crossbow-human.png",
		txt = "Crossbow <BR /> <B> Marksman</B> ",
		max_level = 1,
		parents = {"crossbow_atk"}
	},
	{
		id = "armor_shred",
		levelbonus = true,
		img = "icons/broken_shield.png",
		txt = "<B> Armor shred </B>",
		max_level = 3,
		parents = {"sword_precis", "crossbow_marksman"},
		couleur = {54, 255, 5}
	},
	{
		id = "defense_reduc",
		img = "icons/broken_tunic.png",
		txt = "<B> Defense shred </B>",
		max_level = 3,
		parents = {"sword_precis", "crossbow_marksman"},
		couleur = {54, 255, 5}
	}
}
