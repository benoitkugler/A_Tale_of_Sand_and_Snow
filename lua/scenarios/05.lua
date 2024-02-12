local function on_prestart()
    -- TODO: properly set up vranken

    -- init mark and recall all heroes
    -- local vr = wesnoth.units.get("vranken")

    -- local mark = wesnoth.units.create({
    --     id = "mark",
    --     type = "mark1",
    --     name = "Mârk",
    -- })
    -- mark:init_hero()
    -- mark:to_map(wesnoth.paths.find_vacant_hex(vr.x, vr.y))


    CustomVariables().player_heroes = "vranken,bunshop,drumar,rymor,morgane,xavier,sword_spirit"
end

local function on_presente_mark()
    local mark = wesnoth.units.get("mark")
    if mark.status._was_presented then return end

    Popup(_ "New hero",
        _ "\tLet me introduce you to <span color='" ..
        Conf.heroes.get_color("mark") .. "' weight='bold'>Mârk</span>, " ..
        "a bold and brave kid. His strengh and power will grow over the battles," ..
        " making it a fierce melee fighter !" ..
        '\n\tYou will find more information in the <span style=\'italic\'>"Skills"</span> menu, ' ..
        "by right-clicking on Mârk. ")
    mark.status._was_presented = true
end

local function on_turn1()
    -- init mark and recall all heroes
    local vr = wesnoth.units.get("vranken")

    local mark = wesnoth.units.create({
        id = "mark",
        type = "mark1",
        name = "Mârk",
    })
    mark:init_hero()
    mark:to_map(wesnoth.paths.find_vacant_hex(vr.x, vr.y))

    for __, u in ipairs(wesnoth.units.find_on_recall({ role = "hero" })) do
        u:to_map(wesnoth.paths.find_vacant_hex(vr.x, vr.y))
    end

    -- local ennemy_leader = wesnoth.units.find_on_map({ side = 2, canrecruit = true })[1].id or ""
    -- Message(ennemy_leader, _ "Haha, we are back ! Tought we would give up that easily ?")
    -- Message("xavier",
    --     "Huhu, they have surrounded us.. and they have called big brother...")
    -- Message("xavier",
    --     "(To Morgane) Stay behind me, I'll get rid of these garnments !")

    -- wml.fire("objectives", {
    --     { "objective", { description = _ "Defeat ennemy leader.", condition = "win" } },
    --     { "objective", { description = _ "Death of Xavier.", condition = "lose" } },
    --     { "objective", { description = _ "Death of Morgane.", condition = "lose" } },
    --     { "objective", { description = _ "Turns run out.", condition = "lose" } },
    --     { "note",      { description = _ "No gold carry over next scenario." } },
    --     { "note", {
    --         description = _ "<span style='italic'>Hint: Xavier is showing off. " ..
    --             "Take your time, as it might be more difficult than he will admit.</span>"
    --     }
    --     }
    -- })
end

---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function()
        local dying = PrimaryUnit()
        if dying.id == "ennemy_leader" then
            -- Message("xavier",
            --     _ "Haha ! We defeated them ! You dont need to be scared anymore, Morgane !")
            -- Message("morgane",
            --     _ "Was I ? ... <i>(Turning back to Bunsop)</i> So, who are you ?")
            -- Message("xavier",
            --     _ "You're talking to a dog ? Humpf... Well, goodbye then, I need to hurry not to miss the departure of the Vranken Xaintrailles company !")
            -- MoveTo("xavier", 14, 2)
            -- wesnoth.units.get("xavier"):to_recall()
            -- local mr = wesnoth.units.get("morgane")
            -- MoveTo("bunshop", wesnoth.paths.find_vacant_hex(mr.x, mr.y))
            -- Message("morgane",
            --     _ "<i>(Stroking the dog)</i> Argh, to think I'm assigned to the same squad as that braggart...")
            -- Victory()
        end
    end
}

---@type game_event_options[]
local scenario_events = {
    { id = "s5_prestart",     name = "prestart", action = on_prestart },
    { id = "s5_turn1",        name = "turn_1",   action = on_turn1 },
    { id = "s5_click_xavier", name = "select",   action = on_presente_mark, filter = { T.filter { id = "mark" } } },
    -- { id = "s5_turn2",        name = "turn_2",   action = on_turn2 }
}

for __, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
