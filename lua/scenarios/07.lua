local function on_prestart()
    -- add some labels
    wml.fire("label", { x = 13, y = 1, text = _ "Towards North White Ark" })
    wml.fire("label", { x = 55, y = 6, text = _ "East White Ark" })
    wml.fire("label", { x = 16, y = 23, text = _ "White Arks Facility" })

    -- setup ennemy units
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


    Message("vranken", _ "And here is the White Arks Facility. Hum, nothing seems damaged, that is good news !")
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
    -- { id = "s6_click_porthos", name = "select",    action = on_presente_porthos, filter = { T.filter { id = "porthos" } } },
    -- { id = "s6_see",           name = "sighted",   action = on_see_ennemy,       filter = { T.filter { side = 2 } } },
    -- { id = "s6_enter_hex",     name = "enter_hex", action = on_enter_hex,        first_time_only = false,                 filter = { T.filter { side = 1 } } },
    -- { id = "s6_new_turn",      name = "new turn",  action = on_new_turn,         first_time_only = false, },
}

for __, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
