-- Special variables for heroes
HE={}


local heros = {}

--Heros  vranken 
heros["vranken"] ={variables = {}}
heros.vranken.variables.xp =  0
heros.vranken.variables.bloodlust = false
heros.vranken.variables.table_comp_spe = {leeches_cac=0, drain_cac=0, atk_brut=0, transposition=0}
heros.vranken.variables.comp_spe = false
heros.vranken.variables.comp_spe_lvl = 1
heros.vranken.variables.comp_spe_cd = 0

--Heros  rymor 
heros["rymor"] ={variables = {}} 
heros.rymor.variables.xp = 0
heros.rymor.variables.bloodlust = false
heros.rymor.variables.table_comp_spe = {}
heros.rymor.variables.comp_spe = false
heros.rymor.variables.comp_spe_lvl = 1
heros.rymor.variables.comp_spe_cd = 0
heros.rymor.color = '#BCB4D6'

--Heros  drumar 
heros["drumar"] ={variables = {}}
heros.drumar.variables.xp =  0
heros.drumar.variables.bloodlust = false
heros.drumar.variables.table_comp_spe ={ wave_dmg = 0 , defense =0 , slow_zone=0 , bonus_cold_mistress=0}
heros.drumar.variables.comp_spe = false
heros.drumar.color = "#00FFF5"

--Heros  bunshop 
heros["bunshop"] ={variables = {}}  
heros.bunshop.variables.xp =  0
heros.bunshop.variables.bloodlust = false
heros.bunshop.variables.table_comp_spe = {}
heros.bunshop.variables.comp_spe = false
heros.bunshop.variables.comp_spe_lvl = 1
heros.bunshop.variables.comp_spe_cd = 0
heros.bunshop.color = '#FFFA80'

--Heros  morgane 
heros["morgane"] = {variables ={}} 
heros.morgane.variables.xp =  0
heros.morgane.variables.bloodlust = false
heros.morgane.variables.table_comp_spe = {}
heros.morgane.variables.comp_spe = false
heros.morgane.variables.comp_spe_lvl = 1
heros.morgane.variables.comp_spe_cd = 0

--Heros  brinx 
heros["brinx"] = {variables ={}} 
heros.brinx.variables.xp =  0
heros.brinx.variables.bloodlust = false
heros.brinx.variables.table_comp_spe = {def_muspell = 0 , dmg_muspell =0 , fresh_blood_musp=0 , muspell_rage=0}
heros.brinx.variables.comp_spe = false
heros.brinx.color = '#357815'


--Heros  sword_spirit 
heros["sword_spirit"] = {variables ={}}  
heros.sword_spirit.variables.bloodlust = false
heros.sword_spirit.variables.table_comp_spe = {}
heros.sword_spirit.variables.comp_spe = false
heros.sword_spirit.color = "#A00E27"

-- Should be called once, at first use of the hero
function HE.init(myId)
	local u = wesnoth.get_unit( myId)
	local r = heros[myId].variables
	for i,v in pairs(r)  do
		if u.variables[i] ~= nil then
			u.variables[i] = r[i]
		end
	end
end  


function HE.get_color(myId)
	return heros[myId].color
end