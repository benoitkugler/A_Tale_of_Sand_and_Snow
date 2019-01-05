-- Special variables for heroes
HE={}


local heroes = {}

--Heroes  vranken 
heroes["vranken"] ={variables = {}}
heroes.vranken.variables.xp =  0
heroes.vranken.variables.bloodlust = false
heroes.vranken.variables.special_skills = {leeches_cac=0, drain_cac=0, atk_brut=0, transposition=0}
heroes.vranken.variables.comp_spe = false
heroes.vranken.variables.comp_spe_lvl = 1
heroes.vranken.variables.comp_spe_cd = 0

--Heroes  rymor 
heroes["rymor"] ={variables = {}} 
heroes.rymor.variables.xp = 0
heroes.rymor.variables.bloodlust = false
heroes.rymor.variables.special_skills = {}
heroes.rymor.variables.comp_spe = false
heroes.rymor.variables.comp_spe_lvl = 1
heroes.rymor.variables.comp_spe_cd = 0
heroes.rymor.color = '#BCB4D6'

--Heroes  drumar 
heroes["drumar"] ={variables = {}}
heroes.drumar.variables.xp =  0
heroes.drumar.variables.bloodlust = false
heroes.drumar.variables.special_skills ={ wave_dmg = 0 , forecast_defense =0 , slow_zone=0 , bonus_cold_mistress=0}
heroes.drumar.variables.comp_spe = false
heroes.drumar.color = "#00FFF5"

--Heroes  bunshop 
heroes["bunshop"] ={variables = {}}  
heroes.bunshop.variables.xp =  0
heroes.bunshop.variables.bloodlust = false
heroes.bunshop.variables.special_skills = {}
heroes.bunshop.variables.comp_spe = false
heroes.bunshop.variables.comp_spe_lvl = 1
heroes.bunshop.variables.comp_spe_cd = 0
heroes.bunshop.color = '#FFFA80'

--Heroes  morgane 
heroes["morgane"] = {variables ={}} 
heroes.morgane.variables.xp =  0
heroes.morgane.variables.bloodlust = false
heroes.morgane.variables.special_skills = {}
heroes.morgane.variables.comp_spe = false
heroes.morgane.variables.comp_spe_lvl = 1
heroes.morgane.variables.comp_spe_cd = 0

--Heroes  brinx 
heroes["brinx"] = {variables ={}} 
heroes.brinx.variables.xp =  0
heroes.brinx.variables.bloodlust = false
heroes.brinx.variables.special_skills = {def_muspell = 0 , dmg_muspell =0 , fresh_blood_musp=0 , muspell_rage=0}
heroes.brinx.variables.comp_spe = false
heroes.brinx.color = '#357815'


--Heroes  sword_spirit 
heroes["sword_spirit"] = {variables ={}}  
heroes.sword_spirit.variables.bloodlust = false
heroes.sword_spirit.variables.special_skills = {}
heroes.sword_spirit.variables.comp_spe = false
heroes.sword_spirit.color = "#A00E27"

-- Heroes Xavier
heroes["xavier"] = {variables = {}}
heroes.xavier.variables.bloodlust = false
heroes.xavier.variables.special_skills = {}
heroes.xavier.variables.comp_spe = false
heroes.xavier.color = "#a99508"

-- Should be called once, at first use of the hero
function HE.init(myId)
	local u = wesnoth.get_unit(myId)
	local r = heroes[myId].variables
	for i,v in pairs(r)  do
		if u.variables[i] ~= nil then
			u.variables[i] = r[i]
		end
	end
end  


function HE.get_color(myId)
	return heroes[myId].color
end