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
		name_aff = _ "Cold Strengh :",
		require_lvl = 4,
		desc = _ "Grants %s%% additionnal bonus damage and %s bonus attack on the chilling wave.",
		costs = {50,50,60}
	},
	wave_dmg = function(lvl) return lvl == 3 and {15, 1} or {10 , 0} end,
	{
		img = "comp_spe/forecast.png",
		max_lvl = 3,
		name = "forecast_defense",
		color = "#265690",
		name_aff = _ "Forecast :",
		require_lvl = 4,
		desc = _ "Ennemies struggle to hit : %s%% additional bonus defense.",
		costs = {70,70,70}
	},
	forecast_defense = function(lvl) return 7 end,
	{
		img = "comp_spe/slow_zone.png",
		max_lvl = 1,
		name = "slow_zone",
		color = "#00A8A2",
		name_aff = _ "Slowing field :",
		require_avancement = {
			id = "toile_atk",
			des = _ "Requires <span weight='bold' color='#919191'>faster entangle</span> "
		},
		require_lvl = 4,
		desc = _ "Entangle now <span color='#00A8A2'>permanetly slows all enemies</span> near the target. Intensity : %s%%",
		costs = {150, 100}
	},
	slow_zone = function(lvl) return 10 + (10	 * lvl) end,
	{
		img = "attacks/chilling_touch_master.png",
		max_lvl = 3,
		name = "bonus_cold_mistress",
		color = "#1ED9D0",
		name_aff = _ "Cold Expert :",
		require_avancement = {
			id = "attack_chilled",
			des = _ "Requires <span weight='bold' color='#1ED9D0'>Chilling touch</span> object"
		},
		require_lvl = 6,
		desc = _ "Increases Chilling bonus damage to %s%% and %s turns duration.",
		costs = {40, 40, 60}
	},
	bonus_cold_mistress = function(lvl) return lvl == 3 and {60, 3} or {30 + 10 * lvl, 2} end
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