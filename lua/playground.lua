--- Script file for the Playground scenario

---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function() end,
}

InitVariables()

UI.setup_menus()

local function setup_units()
    for _, cfg in ipairs({
        { id = "brinx",  type = "brinx4",  name = "Brinx" },
        { id = "drumar", type = "drumar4", name = "Drumar" },
        { id = "rymor",  type = "rymor4",  name = "Rymor" },
        { id = "bunshop", type = "bunshop3", name = "Bunshop",
            T.abilities { T.customName { id = "elusive", name = "Elusive", _level = 1 } },
        },
        { id = "sword_spirit", type = "sword_spirit4", name = "Gondhul",
            T.abilities { T.customName { id = "war_jump", name = "War jump", _level = 1 } } },
        { id = "morgane", type = "morgane3", name = "Morgane" },
        { id = "xavier",  type = "xavier4",  name = "Xavier" }
    }) do
        local hero = wesnoth.units.create(cfg)
        hero:to_map(wesnoth.paths.find_vacant_hex(14, 16, hero))
    end

    -- init variables and activate advancements
    for _, id in ipairs({ "vranken", "brinx", "drumar",
        "rymor", "bunshop", "sword_spirit", "morgane", "xavier",
    }) do
        local hero = wesnoth.units.get(id)
        hero:init_hero()
        hero.level = 10 -- unlock all skills
        hero:custom_variables().xp = 1000
        -- unlock all special skills
        local skills = Conf.special_skills[hero.id] --[[@as hero_skills]]
        local hero_skills = {}
        for _, skill in ipairs(skills) do
            hero_skills[skill.name] = skill.max_lvl
            wesnoth.interface.add_chat_message(skill.name)
            SPECIAL_SKILLS[skill.name](skill.max_lvl, hero)
        end
        hero:custom_variables().special_skills = hero_skills
    end

    for _, loc in ipairs({ { x = 9, y = 17 }, { x = 10, y = 18 }, { x = 9, y = 18 } }) do
        wesnoth.units.to_map({ type = "Dune Blademaster_muspell", side = 2 }, loc)
    end
end

wesnoth.game_events.add({
    id = "unit_setup", name = "prestart", action = setup_units
})

-- wml.fire("set_menu_item", { id = "setup_units", description = "Create heroes" })
-- wesnoth.game_events.add({ name = "menu item setup_units", action = setup_units })

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
