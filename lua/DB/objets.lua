local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"


--Base de données des objets

obj_DB = {}

obj_DB["ring_haste"] = {name=_"Ring of haste",presentation=_"<span color='#C2B000'>Ring of <span weight='bold'>haste</span></span>",description=_"You're wearing the Flow of the Swallow ! \n <span color='#C2B000'>+2 bonus attacks</span> on every weapon",image="objets/ring_haste",eff={apply_to="attack",increase_attacks=2},contreff={apply_to="attack",increase_attacks=-2}}

obj_DB["shield_myrom"] = {name=_"Shield of Myröm",description=_"Forged in Myröm enemies' blood, this shield <span color='#265690'>blocks damage</span> - twice as the wearer level - on every hit, in defense and offense. ",presentation=_"<span color='#BC1C2F'>Shield of <span weight='bold'>Myröm</span></span>",image="objets/shield_myrom",code=function (unit) return "Blocks <span color='#265690'>"..2*unit.level.."</span> damage on every hit, in defense and offense. " end,eff =  {apply_to="new_ability",T.abilities{T.isHere{id="shield_flat"}}} , contreff = {apply_to="remove_ability",T.abilities{T.isHere{id="shield_flat"}}} }


obj_DB["anneau_vie"] ={name=_"Ring of life",description=_"Augmente de <span color='red'>20</span> les <span color='red'>PV</span> de son porteur.",image="objets/1" , 
	presentation=_"<span  color='red'>Anneau de <span font_weight = 'bold'>robustesse </span></span>", eff = {apply_to="hitpoints" , increase_total=20 , increase = 20} , contreff = {apply_to="hitpoints",increase_total=-20,increase=-20}}

obj_DB["ceinture_geant"]  ={name=_"Giant's belt", description=_"Augmente de <span color='blue'> 10% </span> les <span color='blue'>résistances</span> de son porteur." ,image="objets/2",presentation=_"<span  color='blue'> Ceinture du <span font_weight = 'bold'>géant</span></span>" ,  eff = {"effect" , {apply_to="resistance" , {"resistance" , {blade=-10 , pierce=-10 , impact=-10, fire=-10, cold=-10 ,arcane=-10}}} } , contreff = {"effect" , {apply_to="resistance" , {"resistance" , {blade=10 , pierce=10 , impact=10, fire=10, cold=10 ,arcane=10}}} }}



obj_DB["bottes_celerite"]  = {name=_"Boots of celerity" , description=_"Augmente les <span color='yellow'>déplacements</span> de <span color='yellow'>2</span>." ,image="objets/3", presentation=_"<span color='yellow'>Bottes de <span font_weight = 'bold'>célérité </span></span>" , eff = {apply_to="movement" , increase=2}, contreff =  {apply_to="movement" , increase=-2 }}

obj_DB["cloak_speed"]  = {name=_"Cloak of speed" , description=_"Grants its wearer <span color='yellow'>2</span> bonus <span color='yellow'>attacks</span>." ,image="objets/cloak_speed", presentation=_"<span color='yellow'>Cloak of <span font_weight = 'bold'>celerity </span></span>" , eff = {apply_to="attack" , increase_attacks=2}, contreff =  {apply_to="attack" , increase_attacks=-2} }


