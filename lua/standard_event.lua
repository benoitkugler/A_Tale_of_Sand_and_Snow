-- Called once at lua require. Setup common events.

 

ST={}

local Standard_event={
{id="prestart_menus",name="prestart",{"lua",{code="ST.menus()"}}},
{id="new_turn",first_time_only=false,name="new turn",{"lua",{code="CS.debut_tour()"}}},
{id="attack",first_time_only=false,name="attack",{"lua",{code="EXP.atk (); ES.atk (); EC.combat (0)"}}},
{id="attacker_hits",first_time_only=false,name="attacker hits",{"lua",{{"args",{dmg_dealt ="$damage_inflicted"}} ,code="local arg = ... ; EC.combat (arg.dmg_dealt)"}}},
{id="defender_hits",first_time_only=false,name="defender hits",{"lua",{{"args",{dmg_dealt ="$damage_inflicted"}} ,code="local arg = ... ; EC.combat (arg.dmg_dealt)"}}},
{id="attack_end",first_time_only=false,name="attack_end",{"lua",{code=" EC.combat ()"}}},
{id="die",first_time_only=false,name="die",{"lua",{code="EC.combat () ;EXP.kill();ES.kill();ST.kill()"}}},
{id="turn_end",first_time_only=false,name="turn end",{"lua",{code=" EC.fin_tour () "}}},
{id="select",first_time_only=false,name="select",{"lua",{code="AB.select()"}}},
{id="moveto",first_time_only=false,name="moveto",{"lua",{code=""}}},
{id="post_advance",first_time_only=false,name="post advance",{"lua",{code="AM.adv() ; EXP.adv()"}}},
{id="pre_advance",first_time_only=false,name="pre advance",{"filter",{role="hero",advances_to=""}},{"lua",{code="AM.pre_advance()"}}}}

-- Commons events for all scenarios
for i,v in pairs(Standard_event) do
    wesnoth.remove_event_handler(v.id)
    wesnoth.add_event_handler(v)
end


function ST.menus ()
    -- Setup of menus items
    wesnoth.fire("set_menu_item",{
        id="comp_spe",
        description=_"Special Ability",
        T.show_if{ T.have_unit{x="$x1",y="$y1",T.filter_wml{T.variables{comp_spe=true}}}},
        T.command{T.lua{code="CS.comp_spe()"}} 
    })

    wesnoth.fire("set_menu_item",{
        id="skills_advances",
        description=_"Skills",
        T.show_if{T.have_unit{x="$x1",y="$y1",role="hero"}},
        T.command{T.lua{code="MI.skills_advances()"}} 
    })

    wesnoth.fire("set_menu_item", {
        id="objets",
        description=_"Objects",
        T.command{T.lua{code="O.menuObj()"}} 
    })

end

-- Heroes last breath 
function ST.kill()
    local killer = get_snd()
	local dying = get_pri()
    if dying.id == "rymor" then
        wesnoth.fire("message" , {speaker="rymor",message=_"I fall ? Is this even possible ..."})
        wesnoth.fire("message" , {speaker="vranken",message=_"No ! Rymor ! "})
        wesnoth.fire("endlevel",{result="defeat",side=1})
    elseif dying.id == "drumar" then
        wesnoth.fire("message" , {speaker="drumar",message=_"I protected you, Vranken, I can rest in peace now..."})
        wesnoth.fire("message" , {speaker="rymor",message=_"Frä Drumar..."})
        wesnoth.fire("endlevel",{result="defeat",side=1})
    elseif dying.id == "bunshop" then
        wesnoth.fire("message" , {speaker="rymor",message=_"Noo... How could I let him die ?!"})
        wesnoth.fire("endlevel",{result="defeat",side=1})
    elseif dying.id == "sword_spirit" then
        wesnoth.fire("message" , {speaker="sword_spirit",message=_"..."})
        wesnoth.fire("message" , {speaker="vranken",message=_"He's grabbing me in the Death Lands ! Nooo..."})
        wesnoth.extract_unit(wesnoth.get_units{id="vranken"}[1])
        wesnoth.fire("endlevel",{result="defeat",side=1})
    elseif dying.id== "vranken" then
        wesnoth.fire("message" , {speaker="vranken",message=_"Noo... I still have so much to do..."})
        wesnoth.fire("message" , {speaker="rymor",message=_"No ! Vranken ! Don't let me alone, old friend !"})
        wesnoth.fire("endlevel",{result="defeat",side=1})
    end
end
