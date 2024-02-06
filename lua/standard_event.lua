-- Called once at lua require. Setup common events.
ST = {}

local Standard_event = {
    {
        id = "prestart_menus",
        first_time_only = false,
        name = "preload",
        T.lua { code = "UI.setup_menus()" }
    },
    {
        id = "new_turn",
        first_time_only = false,
        name = "side_1_turn",
        T.lua { code = "AB.turn_start(); UI.turn_start()" }
    },
    {
        id = "attack",
        first_time_only = false,
        name = "attack",
        T.lua { code = "EXP.atk (); ES.atk (); EC.combat(0)" }
    },
    {
        id = "attacker_hits",
        first_time_only = false,
        name = "attacker hits",
        T.lua {
            T.args { dmg_dealt = "$damage_inflicted" },
            code = "local arg = ... ; EC.combat (arg.dmg_dealt)"
        }
    },
    {
        id = "defender_hits",
        first_time_only = false,
        name = "defender hits",
        T.lua {
            T.args { dmg_dealt = "$damage_inflicted" },
            code = "local arg = ... ; EC.combat (arg.dmg_dealt)"
        }
    },
    {
        id = "attack_end",
        first_time_only = false,
        name = "attack_end",
        T.lua { code = " EC.combat ()" }
    },
    {
        id = "die",
        first_time_only = false,
        name = "die",
        T.lua { code = "EC.combat(); EXP.kill(); ES.kill(); ST.kill()" }
    },
    {
        id = "turn_end",
        first_time_only = false,
        name = "turn end",
        T.lua { code = " EC.fin_tour () " }
    },
    {
        id = "select",
        first_time_only = false,
        name = "select",
        T.lua { code = "AB.select()" }
    },
    {
        id = "moveto",
        first_time_only = false,
        name = "moveto",
        T.lua { code = "AB.on_moveto()" }
    },
    {
        id = "post_advance",
        first_time_only = false,
        name = "post advance",
        T.lua { code = "AMLA.adv() ; EXP.adv()" }
    },
    {
        id = "pre_advance",
        first_time_only = false,
        name = "pre advance",
        T.filter { role = "hero", advances_to = "" },
        T.lua { code = "AMLA.pre_advance()" }
    }
}

-- Commons events for all scenarios
for __, v in ipairs(Standard_event) do
    wesnoth.game_events.remove(v.id)
    wesnoth.game_events.add(v)
end

-- Heroes last breath
function ST.kill()
    local dying = PrimaryUnit()
    if dying.id == "rymor" then
        Message("rymor", _ "I fall ? Is this even possible ...")
        Message("vranken", _ "No ! Rymor ! ")
    elseif dying.id == "drumar" then
        Message("drumar",
            _ "I protected you, Vranken, I can rest in peace now...")
        Message("rymor", _ "Frä Drumar...")
    elseif dying.id == "bunshop" then
        Message("rymor", _ "Noo... How could I let him die ?!")
    elseif dying.id == "sword_spirit" then
        Message("sword_spirit", _ "...")
        Message("vranken", _ "He's grabbing me in the Death Lands ! Nooo...")
        wesnoth.units.extract(wesnoth.units.find_on_map { id = "vranken" }[1])
    elseif dying.id == "vranken" then
        Message("vranken", _ "Noo... I still have so much to do...")
        Message("rymor", _ "No ! Vranken ! Don't let me alone, old friend !")
    elseif dying.id == "morgane" then
        Message("morgane",
            _ "My body dies ? ... Nooo ... My spirit vanishes as well !!")
    else
        return
    end
    wml.fire("endlevel", { result = "defeat", side = 1 })
end
