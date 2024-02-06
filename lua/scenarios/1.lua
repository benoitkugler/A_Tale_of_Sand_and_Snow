-- Scenario events of 1 - Prologue
ES = {}

local mess = {
    _ "With me soldiers of Nifhell !",
    _ "Stand still ! Protect the facility at all costs !"
}

local brinx_color = DB.HEROES.get_color("brinx")

wesnoth.add_event_handler({
    id = "event_scenario_include",
    name = "prestart",
    T.lua { code = "ES.first_time()" }
})

local Scenario_event = {
    { id = "prestart",   name = "prestart",      T.lua { code = "ES.prestart()" } },
    { id = "start",      name = "start",         T.lua { code = "ES.start()" } },
    { id = "turn1",      name = "turn_1",        T.lua { code = "ES.turn1()" } },
    { id = "turn2",      name = "turn_2",        T.lua { code = "ES.turn2()" } },
    { id = "side3turn6", name = "side_3_turn_6", T.lua { code = "ES.explo_mur()" } },
    { id = "turn12",     name = "turn_12",       T.lua { code = "ES.turn12()" } }
}

local First_time = {}

function ES.first_time()
    for i, v in pairs(First_time) do
        --    wesnoth.remove_event_handler(v.id)
        wesnoth.add_event_handler(v)
    end

    -- Global variables for the whole campaign
    VAR.table_status = {}
    VAR.table_status_shielded = {}
    VAR.objets_joueur = {}
    VAR.heros_joueur = "brinx"
end

for i, v in pairs(Scenario_event) do
    --  wesnoth.remove_event_handler(v.id)
    wesnoth.add_event_handler(v)
end

local items = wesnoth.require "lua/wml/items.lua"

-- Ces 2 fonctions sont toujours appelés par la macro STANDARD_EVENT
function ES.atk()
    local u = wesnoth.get_units {
        x = wesnoth.current.event_context.x1,
        y = wesnoth.current.event_context.y1
    }[1]
    if u.id == "jod" then
        wml.fire("message",
            { speaker = "jod", message = mess[math.random(2)] })
    end
end

local function presente_brinx(is_jod_dead)
    local s
    if is_jod_dead then
        s =
            _ "As he has lost his revered Lieutenant, Brinx is feeling hatred towards muspellians, " ..
            "and this hatred will make him stronger."
    else
        s =
            _ "As he was struck by the savage muspellian raid on Dead Island, Brinx is feeling" ..
            "hatred towards muspellians, and this hatred will make him stronger."
    end
    Popup(_ "Welcome", _ "\tHello friend, and welcome to this campaign. " ..
        "Let me introduce you to your first hero : <span color='" ..
        brinx_color .. "' weight='bold'> Brinx</span>. " .. s ..
        _ " <span weight='bold'>Fighting muspellians</span> will eventually unlock unique " ..
        "skills for Brinx." ..
        '\n\tYou can access more information in the <span style=\'italic\'>"Skills"</span> menu, ' ..
        "by right-clicking on Brinx.")
    UI.set_menu_skills()
end

function ES.kill()
    local u = PrimaryUnit()
    if u.id == "jod" then
        wml.fire("message", {
            speaker = "jod",
            message = _ "Argh... I fell... The council must now about this att..."
        })
        wml.fire("message", {
            speaker = "brinx",
            message = _ "Nooo ! Bloody muspellians !"
        })
        presente_brinx(true)
    elseif u.id == "brinx" then
        wml.fire("message", {
            speaker = "brinx",
            message = _ "No... I have to avenge Nifhell..."
        })
        wml.fire("endlevel", { result = "defeat", side = 1 })
    end
end

function ES.prestart()
    -- Initialisation des variables

    DB.HEROES.init("brinx")

    -- Suppression temporaire du menu skill
    UI.clear_menu_item("menu_special_skills")

    -- Ecriture sur la map des labels

    wml.fire("label", { x = 13, y = 1, text = _ "Towards North White Ark" })
    wml.fire("label", { x = 55, y = 6, text = _ "East White Ark" })
    wml.fire("label", { x = 16, y = 23, text = _ "White Arks Facility" })
end

function ES.start()
    wesnoth.put_unit({ type = "SwordsmanN", side = 2 }, 25, 28)
    wesnoth.put_unit({ type = "SwordsmanN", side = 2 }, 26, 25)
    local br = wesnoth.get_unit("brinx").__cfg
    br.ellipse = "misc/ellipse"
    wesnoth.put_unit(br)
end

function ES.turn1()
    local u1 = wesnoth.get_units { x = 26, y = 25 }[1]
    local u2 = wesnoth.get_units { x = 25, y = 28 }[1]

    local ra = wesnoth.get_units { id = "rand" }[1]
    wesnoth.put_recall_unit(ra, 1)

    wml.fire("message",
        { speaker = u1.id, message = _ "Hey, what's going on ?" })

    ANIM.anim_zaap(55, 5, "d")

    wml.fire("message", {
        speaker = u2.id,
        message = _ "Damned, the East White Ark is being activated !"
    })
    ANIM.anim_zaap(55, 5, "d")
    wml.fire("message", {
        speaker = u1.id,
        message = _ "Could Muspell dare attacking us ?"
    })
    ANIM.anim_zaap(55, 5, "d")
    wml.fire("recall", { id = "rand", x = 54, y = 6 })
    wesnoth.get_units { id = "rand" }[1].side = 3
    wesnoth.delay(500)

    wml.fire("move_unit", { id = "rand", to_x = 41, to_y = 25 })

    wml.fire("message", {
        speaker = u1.id,
        message = _ "They actually did ! Sound the alarm !"
    })

    wml.fire("message", {
        speaker = "jod",
        message = _ "What the hell ! Is Muspell really breaking the tacit piece ? Whatever, to arms men ! We have to protect the White Arks facilities at all costs !"
    })

    wml.fire("message", {
        speaker = "jod",
        message = _ "And I need two volunteers to escort the young Brinx !"
    })
    wesnoth.put_unit({ type = "BowmanN", side = 1 }, 12, 27)
    wesnoth.put_unit({ type = "Heavy InfantrymanN", side = 1 }, 10, 26)
    wml.fire("message", { speaker = "brinx", message = _ "Thanks sir !" })
end

function ES.turn2()
    wml.fire("message", {
        speaker = "rand",
        message = _ "I let you a chance to live. Just surrender."
    })
    wml.fire("message", { speaker = "jod", message = _ "..." })
    wml.fire("message", {
        speaker = "rand",
        message = _ "So death will be. Soldiers, cut the escape path !"
    })
    wesnoth.scroll_to_tile(14, 18)
    wesnoth.put_unit(
        { type = "Dune Spearguard_muspell", side = 3, max_moves = 0 }, 13, 18)
    wesnoth.put_unit(
        { type = "Dune Spearguard_muspell", side = 3, max_moves = 0 }, 14, 17)
    wesnoth.delay(500)
end

function ES.explo_mur()
    ANIM.thunder()

    wml.fire("message",
        { speaker = "brinx", message = _ "What just happened ?! " })
    wesnoth.scroll_to_tile(26, 26)
    wesnoth.set_terrain(24, 27, "Re")
    wesnoth.set_terrain(25, 25, "Re")
    items.place_image(24, 27, "scenery/rubble.png")
    items.place_image(25, 25, "scenery/rubble.png")
    wml.fire("redraw")
    wesnoth.delay(200)
    wml.fire("message", {
        speaker = "jod",
        message = _ "In the name of Powers ! Their naphtha just destroyed our walls..."
    })

    wml.fire("message", {
        speaker = "rand",
        message = _ "Nice job soldiers, the gate is ours ! Go ahead, for Muspell !"
    })
end

function ES.turn12()
    local ennemy_chief = wesnoth.get_units { id = "rand" }[1]
    for _ = 1, 10 do
        local x, y = wesnoth.find_vacant_tile(ennemy_chief.x, ennemy_chief.y)
        wesnoth.put_unit({ type = "Dune Blademaster_muspell", side = 3 }, x, y)
    end
    wml.fire("message", {
        speaker = "rand",
        message = _ "Halt soldiers, enough blood for today. We are in control of the White Arks facility, that's the point. Put in jail the remaining Nifhellians, and alert the Khan about the success of our mission !"
    })
    if wesnoth.get_units { id = "jod" }[1] ~= nil then presente_brinx(false) end
    Victory()
end
