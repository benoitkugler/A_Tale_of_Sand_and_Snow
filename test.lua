ES={}
local _ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

 
VAR.objets_joueur={ceinture_geant="brinx",bottes_celerite=0,ring_haste="vranken",shield_myrom="drumar"}
wesnoth.set_variable("heros_joueur","brinx,vranken,drumar")
wesnoth.set_variable("table_shields",{er="ee"})
VAR.table_status ={}
VAR.table_status.chilled = {}
VAR.table_status.chilled[0] = {id="eee",cd=4}
VAR.table_status.chilled[1] = {id="eefge",cd=5}



function ES.kill()
end
function ES.atk()
   
end

function test()
    local u = get_pri()

   
    
end

local s = wesnoth.theme_items.edit_left_button_function
function wesnoth.theme_items.edit_left_button_function()
    local r=  s()
    wesnoth.message(wesnoth.debug(r))
    return r
end
--     wesnoth.add_modification(u,"object",{{"effect",{apply_to="attack",{"set_specials", { {"isHere",{id="slow_zone",name="test"} }  }}  }}},false)
