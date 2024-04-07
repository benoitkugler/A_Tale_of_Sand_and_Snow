local function on_prestart()
    -- add some labels
    wml.fire("label", { x = 13, y = 1, text = _ "Towards North White Ark" })
    wml.fire("label", { x = 55, y = 6, text = _ "East White Ark" })
    wml.fire("label", { x = 16, y = 23, text = _ "White Arks Facility" })

    -- setup allies and ennemy units
    wesnoth.sides.get(2).recruit = NifhellUnits(1, 2)
    wesnoth.sides.get(3).recruit = MuspellUnits(1, 2) -- the octopus
    wesnoth.sides.get(4).recruit = MuspellUnits(1, 1)
    wesnoth.sides.get(5).recruit = MuspellUnits(1, 1)

    -- setup otchigins
    local o1 = Limbes.create_otchigin(1, 3)
    local o2 = Limbes.create_otchigin(1, 5)
    o1:to_map(wesnoth.paths.find_vacant_hex(49, 27, o1))
    o2:to_map(wesnoth.paths.find_vacant_hex(33, 33, o2))
end


local function on_turn1()
    local vr = wesnoth.units.get("vranken")

    -- recall all heroes
    for __, u in ipairs(wesnoth.units.find_on_recall({ role = "hero" })) do
        u:to_map(wesnoth.paths.find_vacant_hex(vr.x, vr.y, u))
    end

    local otchigins = wesnoth.units.find_on_map { role = "otchigin" }

    Message("vranken", _ "And here is the White Arks Facility. Hum, nothing seems damaged, that is good news !")
    Message("rymor", _ "But Muspell units have taken a strong position. It won't be easy to defeat them.")
    Message("vranken", _ "Especially since the Octopus is actually fighting !")
    wesnoth.interface.scroll_to_hex(otchigins[1])
    wesnoth.interface.delay(300)
    wesnoth.interface.scroll_to_hex(otchigins[2])
    wesnoth.interface.delay(300)
    Message("drumar", _ "Be careful Vranken, two <i>Otchigins</i> are present on Muspell side. \z
    These strong sorcerers are very efficient on the battefield.")
    Message("allied_leader", _ "Pfeu, I'm not impressed by these frail mens. Nifhell will prevail !")
    Message("allied_leader", _ "To arms, men ! For our fallen brothers and for Nifhell !")

    Popup(_ "About recall", _ "You may now recall regular units. In this campaign, <i>Bowmen</i> and <i>Spearman</i> \z
    may gain decent power through AMLA, but won't have the same potential than your heroes. Albeit, you should recruit and train some of them, to assist \z
    your squad in large battles.")

    wml.fire("objectives", {
        { "objective", { description = _ "Defeat the ennemy leaders.", condition = "win" } },
        { "objective", { description = _ "Death of any of your heroes.", condition = "lose" } },
        { "note",      { description = _ "No gold carry over next scenario." } },
    })
end


local function on_turn2()
    Message("drumar", _ "See ? The Muspell warriors are helped by the Tengi.. These damned Otchigins..")
    Message("vranken", _ "Hum, this is a problem indeed.. We will have to be very careful..")
    Message("morgane",
        _ "<i>(thinking)</i> I'm feeling something.. I'm kind of attracted to these sorcerers.. How strange !")
end

local function on_turn3()
    Message("morgane",
        _ "<i>(To Drümar)</i> This is so weird, I'm hearing like a calling.. It seems somehow related to the Otchigins.")
    Message("drumar",
        "<i>(surprised)</i> Hum ? Could you have a connection with the Limbes ? This is so unusual for novices. \z
    Elder Fräs sometimes accomplish this after a long life of study and pratice...")
    Message("morgane", _ "What should I do ? Perhaps joining the Limbes could help ?")
    Message("drumar", "It is you call, child...")
    Popup(_ "Fighting in the Limbes", _ "The great power hidden in Morgäne allows her to freely enter the Limbes. \z
    Whenever <b>Otchigins</b> are present in a battle, and when an ally is near one of them, Morgäne may start a fight in the Limbes (right-click on her).\n\z
    <i>Be careful: once you have entered the Limbes, the only way out is defeating your opponents. Also, dying in the Limbes amounts to dying in the material plan...</i>")
end

---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function()
        local dying = PrimaryUnit()
        if dying.id == "ennemy_leader" then
            -- TODO
        end
    end
}

---@type game_event_options[]
local scenario_events = {
    { id = "s7_prestart", name = "prestart", action = on_prestart },
    { id = "s7_turn1",    name = "turn_1",   action = on_turn1 },
    { id = "s7_turn2",    name = "turn_2",   action = on_turn2 },
    { id = "s7_turn3",    name = "turn_3",   action = on_turn3 },
    -- { id = "s6_click_porthos", name = "select",    action = on_presente_porthos, filter = { T.filter { id = "porthos" } } },
    -- { id = "s6_see",           name = "sighted",   action = on_see_ennemy,       filter = { T.filter { side = 2 } } },
    -- { id = "s6_enter_hex",     name = "enter_hex", action = on_enter_hex,        first_time_only = false,                 filter = { T.filter { side = 1 } } },
    -- { id = "s6_new_turn",      name = "new turn",  action = on_new_turn,         first_time_only = false, },
}

for __, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
