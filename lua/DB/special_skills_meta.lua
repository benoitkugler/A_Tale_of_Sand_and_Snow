-- Metadata for specials skills (implementation is in special_skills)
-- In descriptions, %s will be replace by the computed value, in color.
-- Name of skills we be in color as well
-- Function which compute the values are directly accesible to be used in event_combat.

local info = {}

info["bunshop"] = {}
info["rymor"] = {}

-- DRUMAR
info["drumar"] = {
	help_des = _ "Several years of battles in Vranken company have made Frä Drümar more warlike than any other Frä. " ..
		"She excels at slowing enemies and taking advantage of their delayed reactions. " ..
			"\nShe will earn experience (scaling with enemies level) when applying " ..
				"<span  font_weight ='bold' >slows</span>, <span  font_weight ='bold' >snares</span> or " ..
					" <span  font_weight ='bold' >chilling</span> states to her targets, " ..
						"as well as using <span  font_weight ='bold' >cold</span> attacks.",
	help_ratios = _ "(<span weight ='bold' >x 1</span> per cold attack, <span weight ='bold' >x 1.5</span> " ..
		"per slow, <span weight ='bold' >x 2</span> per snare, <span weight ='bold' >x 2.5</span> per chilling state)",
	{
		img = "comp_spe/iceball_red.png",
		max_lvl = 3,
		name = "wave_dmg",
		color = "#D02300",
		name_aff = _ "|Cold Strengh :|",
		require_lvl = 4,
		{cout_suivant = 50, des = _ "<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant = 50, des = _ "Grants |10%| bonus damage on the chilling wave. "},
		{cout_suivant = 60, des = _ "Grants |20%| bonus damage on the chilling wave. "},
		{cout_suivant = 0, des = _ "Grants |one bonus attack| on the chilling wave. "}
	},
	{
		img = "comp_spe/forecast.png",
		max_lvl = 3,
		name = "defense",
		color = "#265690",
		name_aff = _ "|Forecast :|",
		require_lvl = 4,
		{cout_suivant = 70, des = _ "<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant = 70, des = _ "Ennemies struggle to hit : |7%| bonus defense. "},
		{cout_suivant = 70, des = _ "Ennemies struggle to hit : |14%| bonus defense. "},
		{cout_suivant = 0, des = "Ennemies struggle to hit : |21%| bonus defense. "}
	},
	{
		img = "comp_spe/slow_zone.png",
		max_lvl = 1,
		name = "slow_zone",
		color = "#00A8A2",
		name_aff = _ "|Slowing field :|",
		require_avancement = {
			id = "toile_atk",
			des = _ "Requires <span weight='bold' color='#919191'>faster entangle</span> "
		},
		require_lvl = 4,
		{cout_suivant = 110, des = _ "<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant = 35, des = _ "Entangle now |slows all enemies| near the target. "}
	},
	{
		img = "attacks/chilling_touch_master.png",
		max_lvl = 3,
		name = "bonus_cold_mistress",
		color = "#1ED9D0",
		name_aff = _ "|Cold Expert :|",
		require_avancement = {
			id = "attack_chilled",
			des = _ "Requires <span weight='bold' color='#1ED9D0'>Chilling touch</span> object"
		},
		require_lvl = 6,
		{cout_suivant = 40, des = _ "<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant = 35, des = _ "Increases Chilling bonus damage to |90%|. "},
		{cout_suivant = 40, des = _ "Increases Chilling bonus damage to |110%|. "},
		{cout_suivant = 0, des = _ "Chilling state now lasts |3 turns|. "}
	}
}

-- VRANKEN
info["vranken"] = {
	help_des = _ "Vranken has a familly link with his sword. " ..
		"Every time <span  font_weight ='bold' >Göndhul fights</span>, Vranken earn points " ..
			"(scaling with opponents level).",
	help_ratios = _ "(<span weight ='bold'>x 1</span> per defense, <span weight ='bold'>x 2 </span>per attack, " ..
		"<span weight ='bold' >x 3</span> per kill, <span weight ='bold' >10</span> per level up)",
	{
		img = "comp_spe/leeches_cac.png",
		max_lvl = 3,
		name = "leeches_cac",
		color = "#24BE13",
		name_aff = _ "Leeches :",
		require_lvl = 4,
		desc = _ "Leeches %s%% of damage dealt with swords ",
		costs = {40,35,40}
	},
	leeches_cac = function(lvl) return 5 + lvl * 5 end,
	{
		img = "comp_spe/drain.png",
		max_lvl = 3,
		name = "drain_cac",
		color = "#24BE13",
		name_aff = _ "Drain :",
		require_lvl = 4,
		desc = _ "Drains %s%% of damage dealt with swords, if Göndhul is at most <span weight ='bold'>%s</span> hexes away from Vranken",
		costs = {50,35,35},
		
		-- {cout_suivant = 50, des = _ "<span style='italic'>Skill not learned yet.</span>"},
		-- {
		-- 	cout_suivant = 35,
		-- 	des = _ "Drains |30%| of damage dealt with swords, " ..
		-- 		"if Göndhul is at most <span weight ='bold'>4</span> hexes away from Vranken "
		-- },
		-- {
		-- 	cout_suivant = 35,
		-- 	des = _ "Drains |40%| of damage dealt with swords, " ..
		-- 		"if Göndhul is at most <span weight ='bold'>8</span> hexes away from Vranken "
		-- },
		-- {
		-- 	cout_suivant = 0,
		-- 	des = _ "Drains |50%| of damage dealt with swords, " ..
		-- 		"if Göndhul is at most <span weight ='bold'>16</span> hexes away from Vranken "
		-- }
	},
	drain_cac = function(lvl) return {20 + lvl * 10, 2 ^ (lvl + 1) } end,
	{
		img = "attacks/atk_brut.png",
		max_lvl = 3,
		name = "atk_brut",
		color = "#e7cfa9",
		name_aff = _ "Lightning sword :",
		require_lvl = 5,
		desc = _ "Grants a sword which deals <span color='#e7cfa9'>true damage</span>, but deals %s%% of your usual sword damage ",
		costs = {100,50,50},
		-- {cout_suivant = 100, des = _ "<span style='italic'>Skill not learned yet.</span> "},
		
		-- {cout_suivant = 50, des = _ "Grants a sword which deals |true damage|, but deals |70%| of your usual sword damage "},
		-- {cout_suivant = 50, des = _ "Now deals |85%| of your usual sword damage "},
		-- {cout_suivant = 0, des = _ "Now deals |100%| of your usual sword damage "}
	},
	atk_brut = function(lvl) return 65 + (lvl * 15) end,
	{
		img = "comp_spe/transposition.png",
		max_lvl = 2,
		name = "transposition",
		color = "#9E25C7",
		name_aff = _ "<span style='italic'>War link</span>",
		require_lvl = 6,
		desc = _ "Enables Vranken and Göndhul to <span color='#9E25C7'>switch position</span>. Cooldown : <span weight='bold'>%s</span> turns.",
		costs = {150, 100},
		-- {cout_suivant = 150, des = _ "<span style='italic'>Skill not learned yet.</span>"},
		-- {
		-- 	cout_suivant = 100,
		-- 	des = _ "Enables Vranken and Göndhul to |switch position|. " .. "Cooldown : <span weight='bold'>2</span> turns"
		-- },
		-- {cout_suivant = 0, des = _ "Cooldown decreases to <span weight='bold'>1</span>  turn "}
	},
	transposition = function(lvl) return 3 - lvl  end 
}

-- BRINX
info["brinx"] = {
	help_des = _ "Brinx seeks to avenge Jödumur's death. Every time he " ..
		"<span  font_weight ='bold' >fights against muspellians</span>, " ..
			"Brinx earn points (scaling with opponents level).",
	help_ratios = _ "(<span   font_weight ='bold' >x 1</span> per defense, " ..
		"<span  font_weight ='bold'>x 3 </span>per attack, <span  font_weight ='bold' >x 5</span> per kill)",
	{
		img = "icons/armor_leather.png",
		max_lvl = 3,
		name = "def_muspell",
		color = "#4575AE",
		name_aff = _ "Muspell Equilibrium : ",
		require_lvl = 4,
		desc = _ "Gives Brinx %s%% defense bonus against muspellians ",
		costs = {50,20,30}
	},
	def_muspell = function(lvl) return 5 + lvl * 5 end,
	{
		img = "icons/crossed_sword_and_hammer.png",
		max_lvl = 3,
		name = "dmg_muspell",
		color = "#D02300",
		name_aff = _ "Muspell Terror : ",
		require_lvl = 4,
		desc = _ "Gives Brinx %s%% bonus damage against Muspell troops ",
		costs = {40,35,45}
	},
	dmg_muspell = function(lvl) return lvl * 10 end,
	{
		img = "icons/potion_red_medium.png",
		max_lvl = 3,
		name = "fresh_blood_musp",
		color = "#24BE13",
		name_aff = _ "Muspell Strength : ",
		require_lvl = 5,
		desc = _ "Regenerates %s when killing a muspellian unit",
		costs = {70,50,65}
	},
	fresh_blood_musp = function(lvl) return 2 + 6*lvl end,
	{
		img = "comp_spe/bloody_sword.png",
		max_lvl = 2,
		name = "muspell_rage",
		color = "#D02300",
		name_aff = _ "<span style='italic' >Revenge </span>",
		require_lvl = 6,
		desc = _ "If a muspellian is at his sides, Brinx will take and deal %s%% bonus damage against all enemies ",
		costs = {200,100}
	},
	muspell_rage = function(lvl) return 10 * lvl end
 }

return info