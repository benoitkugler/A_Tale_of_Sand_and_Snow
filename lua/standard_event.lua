-- Called once at lua require. Setup common events.

ST = {}

local Standard_event = {
    {id = "prestart_menus", first_time_only = false, name = "prestart", T.lua {code = "UI.setup_menus()"}},
    {id = "new_turn", first_time_only = false, name = "new turn", T.lua {code = "AB.turn_start()"}},
    {id = "attack", first_time_only = false, name = "attack", T.lua {code = "EXP.atk (); ES.atk (); EC.combat (0)"}},
    {
        id = "attacker_hits",
        first_time_only = false,
        name = "attacker hits",
        T.lua {T.args {dmg_dealt = "$damage_inflicted"}, code = "local arg = ... ; EC.combat (arg.dmg_dealt)"}
    },
    {
        id = "defender_hits",
        first_time_only = false,
        name = "defender hits",
        T.lua {T.args {dmg_dealt = "$damage_inflicted"}, code = "local arg = ... ; EC.combat (arg.dmg_dealt)"}
    },
    {id = "attack_end", first_time_only = false, name = "attack_end", T.lua {code = " EC.combat ()"}},
    {
        id = "die",
        first_time_only = false,
        name = "die",
        T.lua {code = "EC.combat () ;EXP.kill();ES.kill();ST.kill()"}
    },
    {id = "turn_end", first_time_only = false, name = "turn end", T.lua {code = " EC.fin_tour () "}},
    {id = "select", first_time_only = false, name = "select", T.lua {code = "AB.select()"}},
    {id = "moveto", first_time_only = false, name = "moveto", T.lua {code = "AB.on_moveto()"}},
    {id = "post_advance", first_time_only = false, name = "post advance", T.lua {code = "AMLA.adv() ; EXP.adv()"}},
    {
        id = "pre_advance",
        first_time_only = false,
        name = "pre advance",
        T.filter {role = "hero", advances_to = ""},
        T.lua {code = "AMLA.pre_advance()"}
    }
}

-- Commons events for all scenarios
for __, v in pairs(Standard_event) do
    wesnoth.remove_event_handler(v.id)
    wesnoth.add_event_handler(v)
end

-- Heroes last breath
function ST.kill()
    local killer = get_snd()
    local dying = get_pri()
    if dying.id == "rymor" then
        wesnoth.fire("message", {speaker = "rymor", message = _ "I fall ? Is this even possible ..."})
        wesnoth.fire("message", {speaker = "vranken", message = _ "No ! Rymor ! "})
        wesnoth.fire("endlevel", {result = "defeat", side = 1})
    elseif dying.id == "drumar" then
        wesnoth.fire(
            "message",
            {speaker = "drumar", message = _ "I protected you, Vranken, I can rest in peace now..."}
        )
        wesnoth.fire("message", {speaker = "rymor", message = _ "Frä Drumar..."})
        wesnoth.fire("endlevel", {result = "defeat", side = 1})
    elseif dying.id == "bunshop" then
        wesnoth.fire("message", {speaker = "rymor", message = _ "Noo... How could I let him die ?!"})
        wesnoth.fire("endlevel", {result = "defeat", side = 1})
    elseif dying.id == "sword_spirit" then
        wesnoth.fire("message", {speaker = "sword_spirit", message = _ "..."})
        wesnoth.fire("message", {speaker = "vranken", message = _ "He's grabbing me in the Death Lands ! Nooo..."})
        wesnoth.extract_unit(wesnoth.get_units {id = "vranken"}[1])
        wesnoth.fire("endlevel", {result = "defeat", side = 1})
    elseif dying.id == "vranken" then
        wesnoth.fire("message", {speaker = "vranken", message = _ "Noo... I still have so much to do..."})
        wesnoth.fire("message", {speaker = "rymor", message = _ "No ! Vranken ! Don't let me alone, old friend !"})
        wesnoth.fire("endlevel", {result = "defeat", side = 1})
    end
end
