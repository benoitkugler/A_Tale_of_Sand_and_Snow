defaultbordure = "#1C71CD"
defaultfond = "66 65 193"

arbre = {
	{id = "pm", img = "icons/boots_elven.png", txt = "Moves <BR/> <B> +1 </B>", max_level = 2},
	{id = "snow", img = "icons/boots_ice.png", txt = "More nimble <BR/> on <B> snow </B>", max_level = 1, parents = {"pm"}},
	{
		id = "sand",
		img = "icons/boots_sand.png",
		txt = "More nimble <BR/> on <B> sand </B>",
		levelbonus = true,
		max_level = 1,
		parents = {"snow"}
	},
	{id = "sword_bow", img = "icons/bow_sword.png", txt = "Sword and Bow <BR /> <B> +1</B> dmg", max_level = 3},
	{
		id = "sword_bow_atk",
		img = "icons/bow_sword.png",
		txt = "Sword and Bow <BR /> <B> +1</B> str",
		max_level = 1,
		parents = {"sword_bow"}
	},
	{
		id = "sword_marksman",
		levelbonus = true,
		img = "attacks/sword_marksman.png",
		txt = "Sword <BR/>Marksman",
		max_level = 1,
		parents = {"sword_bow_atk"}
	},
	{
		id = "sword",
		img = "attacks/sword-human.png",
		txt = "Sword <BR /> <B> +2</B> dmg",
		max_level = 2,
		parents = {"sword_marksman"},
		couleur = {211, 224, 238}
	},
	{
		id = "sword_atk",
		img = "attacks/sword-human.png",
		txt = "Sword <BR /> <B> +1</B> str",
		max_level = 1,
		parents = {"sword"}
	},
	{
		id = "sword_precis",
		img = "attacks/sword_precis.png",
		txt = "Sword <BR /> <B> Precision</B>",
		max_level = 1,
		parents = {"sword_atk"},
		couleur = {211, 224, 238}
	},
	{
		id = "sword_cleave",
		levelbonus = true,
		img = "icons/sword_cleave.png",
		txt = "Sword <BR /> <B> Cleave </B>",
		max_level = 1,
		couleur = {132, 94, 114},
		parents = {"sword_atk"}
	},
	{
		id = "bow_slow",
		img = "attacks/bow_slow.png",
		txt = "Slowing <BR/>Bow",
		max_level = 1,
		parents = {"sword_bow_atk"},
		couleur = {79, 253, 235}
	},
	{id = "bow", img = "attacks/bow-elven.png", txt = "Bow <BR /> <B> +2</B> dmg", max_level = 1, parents = {"bow_slow"}},
	{id = "bow_atk", img = "attacks/bow-elven.png", txt = "Bow <BR /> <B> +1</B> str", max_level = 2, parents = {"bow"}},
	{
		id = "bow_firststrike",
		img = "icons/bow_firststrike.png",
		txt = "Bow <BR /> <B> First-strike</B>",
		max_level = 1,
		parents = {"bow_atk"}
	},
	{
		id = "bow_mayhem",
		img = "icons/bow_mayhem.png",
		txt = "Bow<BR /> <B> Mayhem </B>",
		max_level = 1,
		couleur = {123, 106, 184},
		parents = {"bow_atk"}
	},
	{id = "regen10", img = "icons/potion_red_small.png", txt = "Regeneration <BR/> <B> +10 </B> hp", max_level = 1},
	{
		id = "regen20",
		img = "icons/potion_red_medium.png",
		txt = "Regeneration <BR/> <B> +20 </B> hp",
		max_level = 1,
		parents = {"regen10"}
	},
	{
		id = "though",
		img = "icons/cuirass_leather_studded.png",
		txt = "Resistances <BR/>  <B> +7 </B> %",
		max_level = 2,
		parents = {"regen20"}
	}
}
