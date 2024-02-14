--- Script file for the Playground scenario

---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function() end,
}

InitVariables()

local function setup_units()
    for __, cfg in ipairs({
        { id = "brinx",  type = "brinx4",  name = "Brinx" },
        { id = "drumar", type = "drumar4", name = "Drumar" },
        { id = "rymor",  type = "rymor4",  name = "Rymor" },
        { id = "bunshop", type = "bunshop3", name = "Bunshop",
            T.abilities { T.customName { id = "elusive", name = "Elusive", _level = 1 } },
        },
        { id = "sword_spirit", type = "sword_spirit4", name = "Gondhul",
            T.abilities { T.customName { id = "war_jump", name = "War jump", _level = 1 } },
        },
        { id = "morgane", type = "morgane3", name = "Morgane" },
        { id = "xavier",  type = "xavier4",  name = "Xavier" },
        { id = "mark",    type = "mark1",    name = "Mark" },
        { id = "porthos", type = "porthos1", name = "Porthos",
            T.abilities { T.customName { id = "sacrifice", name = "Sacrifice", _level = 3 } }
        },
    }) do
        local hero = wesnoth.units.create(cfg)
        hero:to_map(wesnoth.paths.find_vacant_hex(14, 16, hero))
    end

    -- init variables and activate advancements
    for __, id in ipairs({ "vranken", "brinx", "drumar", "mark",
        "rymor", "bunshop", "sword_spirit", "morgane", "xavier", "porthos",
    }) do
        local hero = wesnoth.units.get(id)
        hero:init_hero()
        hero:custom_variables().xp = 1000
    end

    for __, loc in ipairs({ { x = 9, y = 17 }, { x = 10, y = 18 }, { x = 9, y = 18 } }) do
        wesnoth.units.to_map({ type = "Dune Blademaster_muspell", side = 2, moves = 0 }, loc)
    end
end

wesnoth.game_events.add({
    id = "unit_setup", name = "prestart", action = setup_units
})


wml.fire("set_menu_item", {
    id = "advance_unit",
    description = "Advance unit",
    T.default_hotkey { key = "a" },
    T.show_if { T.have_unit { x = "$x1", y = "$y1" } },
})
wesnoth.game_events.add({
    name = "menu item advance_unit",
    first_time_only = false,
    action = function()
        local unit = PrimaryUnit()
        unit.experience = unit.max_experience
        unit:advance(true, true)
    end
})
