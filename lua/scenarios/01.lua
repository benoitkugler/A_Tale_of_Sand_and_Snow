-- Scenario events of 1 - Prologue



local mess = {
    _ "With me soldiers of Nifhell !",
    _ "Stand still ! Protect the facility at all costs !",
    _ "Bloody muspellians !"
}

local brinx_color = Conf.heroes.colors.brinx

-- setup global variables for the whole campaign
local function setup_campaign()
    InitVariables()
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

local function prestart()
    -- init brinx variables
    wesnoth.units.get("brinx"):init_hero()

    -- hide this menu for now
    UI.clear_menu_item("menu_special_skills")

    -- add some labels
    wml.fire("label", { x = 13, y = 1, text = _ "Towards North White Ark" })
    wml.fire("label", { x = 55, y = 6, text = _ "East White Ark" })
    wml.fire("label", { x = 16, y = 23, text = _ "White Arks Facility" })
end

local function start()
    wesnoth.units.to_map({ type = "Swordsman_nifhell", side = 2 }, 25, 28)
    wesnoth.units.to_map({ type = "Swordsman_nifhell", side = 2 }, 26, 25)
end

local function turn1()
    local u1 = wesnoth.units.get(26, 25)
    local u2 = wesnoth.units.get(25, 28)

    local ra = wesnoth.units.get("rand")
    ra:to_recall(1)

    Message(u1.id, _ "Hey, what's going on ?")

    ANIM.anim_zaap(55, 5, "d")

    Message(u2.id, _ "Damned, the East White Ark is being activated !")
    ANIM.anim_zaap(55, 5, "d")
    Message(u1.id, _ "Could Muspell dare attacking us ?")
    ANIM.anim_zaap(55, 5, "d")
    wml.fire("recall", { id = "rand", x = 54, y = 6 })
    wesnoth.units.get("rand").side = 3
    wesnoth.interface.delay(500)

    MoveTo("rand", 41, 25)

    Message(u1.id, _ "They actually did ! Sound the alarm !")

    Message("jod",
        _ "What the hell ! Is Muspell really breaking the tacit piece ? Whatever, to arms men ! We have to protect the White Arks facilities at all costs !")

    Message("jod", _ "And I need two volunteers to escort the young Brinx !")
    wesnoth.units.to_map({ type = "Bowman_nifhell", side = 1 }, 12, 27)
    wesnoth.units.to_map({ type = "Heavy Infantryman_nifhell", side = 1 }, 10, 26)
    Message("brinx", _ "Thanks sir !")
end

local function turn2()
    Message("rand", _ "I let you a chance to live. Just surrender.")
    Message("jod", _ "...")
    Message("rand", _ "So death will be. Soldiers, cut the escape path !")
    wesnoth.interface.scroll_to_hex(14, 18)
    wesnoth.units.to_map(
        { type = "Dune Spearguard_muspell", side = 3, max_moves = 0 }, 13, 18)
    wesnoth.units.to_map(
        { type = "Dune Spearguard_muspell", side = 3, max_moves = 0 }, 14, 17)
    wesnoth.interface.delay(500)
end

local function explo_mur()
    ANIM.thunder()

    Message("brinx", _ "What just happened ?! ")
    wesnoth.interface.scroll_to_hex(26, 26)
    wesnoth.current.map[{ 24, 27 }] = "Re"
    wesnoth.current.map[{ 25, 25 }] = "Re"
    wesnoth.interface.add_item_image(24, 27, "scenery/rubble.png")
    wesnoth.interface.add_item_image(25, 25, "scenery/rubble.png")
    wml.fire("redraw")
    wesnoth.interface.delay(200)
    Message("jod", _ "In the name of Powers ! Their naphtha just destroyed our walls...")

    Message("rand", _ "Nice job soldiers, the gate is ours ! Go ahead, for Muspell !")
end

local function turn12()
    local ennemy_chief = wesnoth.units.get("rand")
    for _ = 1, 10 do
        local x, y = wesnoth.paths.find_vacant_hex(ennemy_chief.x, ennemy_chief.y)
        wesnoth.units.to_map({ type = "Dune Blademaster_muspell", side = 3 }, x, y)
    end
    Message("rand",
        _ "Halt soldiers, enough blood for today. We are in control of the White Arks facility, that's the point. Put in jail the remaining Nifhellians, and alert the Khan about the success of our mission !")
    if wesnoth.units.get("jod") ~= nil then presente_brinx(false) end
    Victory()
end


---@type ScenarioEvents
ES = {
    atk = function()
        local u = PrimaryUnit()
        if u.id == "jod" then
            Message("jod", mess[math.random(3)])
        end
    end,
    kill = function()
        local u = PrimaryUnit()
        if u.id == "jod" then
            Message("jod", _ "Argh... I fell... The council must now about this att...")
            Message("brinx", _ "Nooo ! Bloody muspellians !")
            presente_brinx(true)
        elseif u.id == "brinx" then
            Message("brinx", _ "No... I have to avenge Nifhell...")
            wml.fire("endlevel", { result = "defeat", side = 1 })
        end
    end
}

---@type game_event_options[]
local scenario_events = {
    { id = "s1_event_scenario_include", name = "prestart",      action = setup_campaign },
    { id = "s1_prestart",               name = "prestart",      action = prestart },
    { id = "s1_start",                  name = "start",         action = start },
    { id = "s1_turn1",                  name = "turn_1",        action = turn1 },
    { id = "s1_turn2",                  name = "turn_2",        action = turn2 },
    { id = "s1_side3turn6",             name = "side_3_turn_6", action = explo_mur },
    { id = "s1_turn12",                 name = "turn_12",       action = turn12 }
}

for __, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
