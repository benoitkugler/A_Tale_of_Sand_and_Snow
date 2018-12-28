-- In descriptions string the pattern | | will be replace by the color of the skill.

local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

local apply={} 

local info = {}

info["bunshop"]={}
info["rymor"]={}

-- DRUMAR

info["drumar"]={
	help_des=_"Several years of battles in Vranken company have made Frä Drümar more warlike than any other Frä. " .. 
	"She excels at slowing enemies and taking advantage of their delayed reactions. " .. 
	"\nShe will earn experience (scaling with enemies level) when applying " .. 
	"<span  font_weight ='bold' >slows</span>, <span  font_weight ='bold' >snares</span> or " .. 
	" <span  font_weight ='bold' >chilling</span> states to her targets, " .. 
	"as well as using <span  font_weight ='bold' >cold</span> attacks.",
	help_ratios=_"(<span weight ='bold' >x 1</span> per cold attack, <span weight ='bold' >x 1.5</span> " ..
	"per slow, <span weight ='bold' >x 2</span> per snare, <span weight ='bold' >x 2.5</span> per chilling state)",
	{
		img="comp_spe/iceball_red.png",max_lvl=3,name="wave_dmg",color='#D02300', 
		name_aff=_"|Cold Strengh :|",require_lvl=4,
		{cout_suivant=50,des=_"<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant=50,des=_"Grants |10%| bonus damage on the chilling wave. "},
		{cout_suivant=60,des=_"Grants |20%| bonus damage on the chilling wave. "},
		{cout_suivant=0,des=_"Grants |one bonus attack| on the chilling wave. "}
	},
	{
		img="comp_spe/forecast.png",max_lvl=3,name="defense",color='#265690',
		name_aff=_"|Forecast :|",require_lvl=4,
		{cout_suivant=70,des=_"<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant=70,des=_"Ennemies struggle to hit : |7%| bonus defense. "},
		{cout_suivant=70,des=_"Ennemies struggle to hit : |14%| bonus defense. "},
		{cout_suivant=0,des="Ennemies struggle to hit : |21%| bonus defense. "}
	},
	{
		img="comp_spe/slow_zone.png",max_lvl=1,name="slow_zone",color='#00A8A2',
		name_aff=_"|Slowing field :|",
		require_avancement={id="toile_atk",des=_"Requires <span weight='bold' color='#919191'>faster entangle</span> "},
		require_lvl=4,
		{cout_suivant=110,des=_"<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant=35,des=_"Entangle now |slows all enemies| near the target. "}
	},
	{
		img="attacks/chilling_touch_master.png",max_lvl=3,name="bonus_cold_mistress",color='#1ED9D0',
		name_aff=_"|Cold Expert :|",
		require_avancement={id="attack_chilled",des=_"Requires <span weight='bold' color='#1ED9D0'>Chilling touch</span> advancement"},
		require_lvl=6,
		{cout_suivant=40,des=_"<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant=35,des=_"Increases Chilling bonus damage to |90%|. "},
		{cout_suivant=40,des=_"Increases Chilling bonus damage to |110%|. "},
		{cout_suivant=0,des=_"Chilling state now lasts |3 turns|. "}
	}
}



-- VRANKEN

info["vranken"]={
	help_des=_ "Vranken has a familly link with his sword. ".. 
	"Every time <span  font_weight ='bold' >Göndhul fights</span>, Vranken earn points " .. 
	"(scaling with opponents level).",
	help_ratios= _ "(<span weight ='bold'>x 1</span> per defense, <span weight ='bold'>x 2 </span>per attack, ".. 
	"<span weight ='bold' >x 3</span> per kill, <span weight ='bold' >10</span> per level up)",
	{
		img="comp_spe/leeches_cac.png",max_lvl=3,name="leeches_cac",color='#24BE13',
		name_aff=_"|Leeches :|",require_lvl=4,
		{cout_suivant=40,des=_"<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant=35,des=_"Leeches |10%| of damage dealt with swords "},
		{cout_suivant=40,des=_"Leeches |15%| of damage dealt with swords "},
		{cout_suivant=0,des=_"Leeches |20%| of damage dealt with swords "}
	},
	{
		img="comp_spe/drain.png",max_lvl=3,name="drain_cac",color='#24BE13',
		name_aff=_"|Drain :|",require_lvl=4,
		{cout_suivant=50,des=_"<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant=35,des=_"Drains |30%| of damage dealt with swords, " .. 
		"if Göndhul is at most <span weight ='bold'>4</span> hexes away from Vranken "},
		{cout_suivant=35,des=_"Drains |40%| of damage dealt with swords, " .. 
		"if Göndhul is at most <span weight ='bold'>8</span> hexes away from Vranken "},
		{cout_suivant=0,des=_"Drains |50%| of damage dealt with swords, ".. 
		"if Göndhul is at most <span weight ='bold'>16</span> hexes away from Vranken "}
	},
	{
		img="attacks/atk_brut.png",max_lvl=3,name="atk_brut",color='#e7cfa9',
		name_aff=_"|Lightning sword :|",require_lvl=5,
		{cout_suivant=100,des=_"<span style='italic'>Skill not learned yet.</span> "},
		{cout_suivant=50,des=_"Grants a sword which deals |true damage|, but deals |70%| of your usual sword damage "},
		{cout_suivant=50,des=_"Now deals |85%| of your usual sword damage "},
		{cout_suivant=0,des=_"Now deals |100%| of your usual sword damage "}
	},
	{
		img="comp_spe/transposition.png",max_lvl=2,name="transposition",color='#9E25C7',
		name_aff=_"<span style='italic'>|War link|</span>",require_lvl=6,
		{cout_suivant=150,des=_"<span style='italic'>Skill not learned yet.</span>"},
		{cout_suivant=100,des=_"Enables Vranken and Göndhul to |switch position|. " .. 
		"Cooldown : <span weight='bold'>2</span> turns"},
		{cout_suivant=0,des=_"Cooldown decreases to <span weight='bold'>1</span>  turn "}
	}
}


function apply.leeches_cac (lvl,unit)
	local torem = "leeches1"
	for i =2,lvl-1,1 do
		torem = torem..", leeches"..i
	end
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , range = "melee" , remove_specials=torem}}})
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , range = "melee" , {"set_specials", {mode="append", {"isHere", {id="leeches"..tostring(lvl), name=_"leeches",
        description=_"Regenerates "..tostring(lvl*5 + 5).." % of the damage dealt in offense and defense. Also works against undead" --des
    }}} }}}})
	wesnoth.extract_unit(unit)
	local newu = purge_objet(unit.__cfg)
	wesnoth.put_unit(newu)
end

function apply.drain_cac (lvl,unit)
	local torem = "drain_cac1"
	for i =2,lvl-1,1 do
		torem = torem..", drain_cac"..i
	end
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , range = "melee" , remove_specials=torem}}})
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , range = "melee" , {"set_specials", {mode="append", {"drains", {id="drain_cac"..tostring(lvl), name=_"drains",
    value=lvl*10 + 20 , description=_"Regenerates "..tostring(lvl*10 + 20).." % of the damage dealt in offense and defense. Doesn't apply to undead", --ratio du drain
    description_inactive =_"Göndhul is too far away from Vranken.", {"filter_self", { {"filter_location" ,
        { radius=2^(lvl+1) , --portee de la comp 
            {"filter", {id = "sword_spirit"}}}}}}}}  }}}}})
	wesnoth.extract_unit(unit)
	local newu = purge_objet(unit.__cfg)
	wesnoth.put_unit(newu)
end

function apply.atk_brut (lvl,unit)
	local torem = "atk_brut1"
	for i =2,lvl-1,1 do
		torem = torem..", atk_brut"..i
	end
	local atk= 0
	for at in H.child_range(unit.__cfg,"attack") do
		if at.name=="sword" and at.type=="blade" then
			atk = at
		end
	end

	atk.type = "brut"
	atk.damage = atk.damage *(70 + (lvl-1)*15)/100 --ratio degat
	atk.description = _"ether sword"
	atk.icon = "attacks/ak_brut.png" 
	atk["apply_to"] = "new_attack"
	
	if lvl == 1 then
		wesnoth.add_modification(unit,"object",{no_write=true,{"effect", atk}} )
	else
		wesnoth.add_modification(unit,"object",{no_write=true,{"effect", {apply_to="attack" , type="brut" , name="sword", increase_damage = "-100%"}}} )
		wesnoth.add_modification(unit,"object",{no_write=true,{"effect", {apply_to="attack" , type="brut" , name="sword", increase_damage = atk.damage}}} )
	end
	wesnoth.extract_unit(unit)
	local newu = purge_objet(unit.__cfg)
	wesnoth.put_unit(newu)
end


function apply.transposition (lvl,unit)
	local torem = "transposition"..tostring(lvl-1)
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="remove_ability" ,{"abilities" , { {"isHere" , {id=torem}}} } }}})
	
	unit.variables.comp_spe= true
	
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="new_ability" ,  {"abilities" , { {"isHere" , {id="transposition"..lvl , name=_"War link" , description=_"Vranken senses its sword spirit and may switch position with Göndhul, no matter the distance between them. \n<span color='green'>Available now </span>"}} }}}}})
	wesnoth.extract_unit(unit)
	local newu = purge_objet(unit.__cfg)
	wesnoth.put_unit(newu)
end

-- BRINX

info["brinx"]={
	help_des=_"Brinx seeks to avenge Jödumur's death. Every time he " .. 
	"<span  font_weight ='bold' >fights against muspellians</span>, " .. 
	"Brinx earn points (scaling with opponents level).",
	help_ratios=_"(<span   font_weight ='bold' >x 1</span> per defense, " .. 
	"<span  font_weight ='bold'>x 3 </span>per attack, <span  font_weight ='bold' >x 5</span> per kill)",
	{
		img="icons/armor_leather.png",max_lvl=3,name="def_muspell",color='#4575AE',
		name_aff=_"|Muspell Equilibrium : |",require_lvl=4,
		{cout_suivant=50,des=_"<span style='italic'>Skill not learned yet </span>"},
		{cout_suivant=20,des=_"Gives Brinx |10%| defense bonus against muspellians "},
		{cout_suivant=30,des=_"Gives Brinx |15%| defense bonus against muspellians "},
		{cout_suivant=0,des=_"Gives Brinx |20%| defense bonus against muspellians "}
	},
	{
		img="icons/crossed_sword_and_hammer.png",max_lvl=3,name="dmg_muspell",color='#D02300',
		name_aff=_"|Muspell Terror : |",require_lvl=4,
		{cout_suivant=40,des=_"<span style='italic'>Skill not learned yet </span>"},
		{cout_suivant=35,des=_"Gives Brinx |10%| bonus damage against Muspell troops "},
		{cout_suivant=45,des=_"Gives Brinx |20%| bonus damage against Muspell troops "},
		{cout_suivant=0,des=_"Gives Brinx |30%| bonus damage against Muspell troops "}
	},
	{
		img="icons/potion_red_medium.png",max_lvl=3,name="fresh_blood_musp",color='#24BE13',
		name_aff=_"|Muspell Strength : |",require_lvl=5,
		{cout_suivant=70,des=_"<span style='italic'>Skill not learned yet</span> "},
		{cout_suivant=50,des=_"Regenerates |10 HP| when killing a muspellian unit "},
		{cout_suivant=65,des=_"Regenerates |20 HP| when killing a muspellian unit "},
		{cout_suivant=0,des=_"Regenerates |30 HP| when killing a muspellian unit "}
	},
	{
		img="comp_spe/bloody_sword.png",max_lvl=2,name="muspell_rage",color='#D02300',
		name_aff=_"<span style='italic' >|Revenge |</span>",require_lvl=6,
		{cout_suivant=200,des=_"<span style='italic'>Skill not learned yet </span>"},
		{cout_suivant=100,des=_"If a muspellian is at his sides, Brinx will take and deal |10%| bonus damage against all enemies "},
		{cout_suivant=0,des=_"If a muspellian is at his sides, Brinx will take and deal |20%| bonus damage against all enemies "}
	}
}


function apply.def_muspell (lvl,unit)
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , remove_specials="def_muspell"..tostring(lvl-1)}}})
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="remove_ability" , {"abilities" , { {"isHere" , {id="def_muspell"..tostring(lvl-1)}}} }} }})

	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="new_ability" ,  {"abilities" , { {"isHere" , {id="def_muspell"..lvl , name=_"Nimble" , 
        description=_"Brinx learned how to better dodge muspellian attacks : +"..tostring(5+lvl*5).." % bonus defense." --des
    }} }}}}})
	
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , {"set_specials", {mode="append", {"chance_to_hit", {id="def_muspell"..tostring(lvl), name="",description="",
        sub=(5+5*lvl),--chance to hit
        apply_to="opponent",{"filter_opponent",{race="muspell"}}}}} }}}})
	wesnoth.extract_unit(unit)
	local newu = purge_objet(unit.__cfg)
	wesnoth.put_unit(newu)
end

function apply.dmg_muspell (lvl,unit)
	
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , remove_specials="dmg_muspell"..tostring(lvl-1)}}})
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="remove_ability" , {"abilities" , { {"isHere" , {id="dmg_muspell"..tostring(lvl-1)}}} }} }})

	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="new_ability" ,  {"abilities" , { {"isHere" , {id="dmg_muspell"..lvl , name=_"Muspell Terror" ,
        description=_"Brinx deals "..tostring(lvl*10).." % bonus damage when facing a muspellian opponent."--des
    }} }}}}})
	
	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , {"set_specials", {mode="append", {"damage", {id="def_muspell"..tostring(lvl), name="",description="",
        multiply=(1+lvl*0.1), --special damage
        {"filter_opponent",{race="muspell"}}}}} }}}})
	wesnoth.extract_unit(unit)
	local newu = purge_objet(unit.__cfg)
	wesnoth.put_unit(newu)
end

function apply.fresh_blood_musp (lvl,unit)
	

	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="remove_ability" , {"abilities" , { {"isHere" , {id="fresh_blood_musp"..tostring(lvl-1)}}} }} }})

	wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="new_ability" ,  {"abilities" , { {"isHere" , {id="fresh_blood_musp"..lvl , name=_"Muspell strength" , 
        description=_"Brinx heals himself for "..(lvl*10).. "HP when killing a muspellian" --des
    }} }}}}})

	wesnoth.extract_unit(unit)
	local newu = purge_objet(unit.__cfg)
	wesnoth.put_unit(newu)
end

function apply.muspell_rage (lvl,unit)
    
    wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , remove_specials="muspell_rage"..tostring(lvl-1)}}})
    wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="remove_ability" , {"abilities" , { {"isHere" , {id="muspell_rage"..tostring(lvl-1)}}} }} }})
    
    wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{ apply_to="new_ability" ,  {"abilities" , { {"isHere" , {id="muspell_rage"..lvl , name=_"Revenge" , 
        description=_"Brinx deals and takes "..(lvl*10).." % bonus damage.",--des
        description_inactive=_"There is no muspellian friend to anger Brinx.",{"filter",{{"filter_side",{{"has_unit",{race="muspell"}}}}}}}}}} }}})
        
        wesnoth.add_modification(unit,"object",{no_write=true,{"effect",{apply_to="attack" , {"set_specials", {mode="append", {"damage", {id="muspell_rage"..tostring(lvl), name="", apply_to="both" , description="",
            multiply=(1+lvl*0.1),--rage bonus
            {"filter_self",{{"filter_side",{{"has_unit",{race="muspell"}}}}}}}}} }}}})
            wesnoth.extract_unit(unit)
            local newu = purge_objet(unit.__cfg)
            wesnoth.put_unit(newu)
end

local DB = {apply= apply,info = info}
return DB