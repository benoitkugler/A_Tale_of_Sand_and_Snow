-- Called once at lua require. Setup common events.
ST = {}

-- Heroes last breath
local function on_kill()
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


local Standard_event = {
    {
        id = "prestart_menus",
        first_time_only = false,
        name = "preload",
        action = UI.setup_menus,
    },
    {
        id = "new_turn",
        first_time_only = false,
        name = "side_1_turn",
        action = function()
            AB.turn_start(); UI.turn_start()
        end
    },
    {
        id              = "attack",
        first_time_only = false,
        name            = "attack",
        action          = function()
            EXP.on_attack(); ES.atk(); EC.on_combat_event()
        end
    },
    {
        id = "attacker_hits",
        first_time_only = false,
        name = "attacker hits",
        action = EC.on_combat_event
    },
    {
        id = "defender_hits",
        first_time_only = false,
        name = "defender hits",
        action = EC.on_combat_event
    },
    {
        id = "attack_end",
        first_time_only = false,
        name = "attack_end",
        action = EC.on_combat_event,
    },
    {
        id = "die",
        first_time_only = false,
        name = "die",
        action = function()
            EC.on_combat_event(); EXP.on_kill(); ES.kill(); on_kill()
        end
    },
    {
        id = "turn_end",
        first_time_only = false,
        name = "turn end",
        action = EC.fin_tour,
    },
    {
        id = "select",
        first_time_only = false,
        name = "select",
        action = AB.select
    },
    {
        id = "moveto",
        first_time_only = false,
        name = "moveto",
        action = AB.on_moveto
    },
    {
        id = "post_advance",
        first_time_only = false,
        name = "post advance",
        action = function()
            AMLA.adv(); EXP.on_advance()
        end
    },
    {
        id = "pre_advance",
        first_time_only = false,
        name = "pre advance",
        T.filter { role = "hero", advances_to = "" },
        action = AMLA.pre_advance
    }
}

-- Commons events for all scenarios
for __, v in ipairs(Standard_event) do
    wesnoth.game_events.remove(v.id)
    wesnoth.game_events.add(v)
end
