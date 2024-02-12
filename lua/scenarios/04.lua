local function on_prestart()
    wesnoth.units.to_map({ type = "Ruffian", side = 2 }, 2, 15)
    wesnoth.units.to_map({ type = "Ruffian", side = 2 }, 6, 15)
    wesnoth.units.to_map({ type = "Ruffian", side = 2 }, 3, 7)
    wesnoth.units.to_map({ type = "Thug", side = 2 }, 4, 7)

    -- hide vranken
    local vr = wesnoth.units.get("vranken")
    vr:extract()

    local xavier = wesnoth.units.create({
        id = "xavier",
        type = "xavier1",
        name = "Xavier Augentyr",
        canrecruit = true,
    })
    xavier:init_hero()
    xavier:to_map(vr.x, vr.y)

    vr.canrecruit = false

    CustomVariables().player_heroes = "morgane, xavier"

    local morgane = wesnoth.units.create({
        id = "morgane",
        type = "morgane1",
        side = 1,
        name = "Morgane"
    })
    morgane:init_hero()
    local x, y = wesnoth.paths.find_vacant_hex(xavier.x, xavier.y, morgane)
    morgane:to_map(x, y)
end

local function on_presente_xavier()
    local xavier = wesnoth.units.get("xavier")
    if xavier.status._was_presented then return end

    Popup(_ "New hero",
        _ "\tLet me introduce you to <span color='" ..
        Conf.heroes.get_color("xavier") .. "' weight='bold'>Xavier</span>, " ..
        "a young and talented military student. His intuition on military tactics " ..
        " have to be battle-tested, but may become very useful to you..." ..
        '\n\tYou will find more information in the <span style=\'italic\'>"Skills"</span> menu, ' ..
        "by right-clicking on Xavier. ")
    xavier.status._was_presented = true
end

local function on_turn1()
    local ennemy_leader = wesnoth.units.find_on_map({ side = 2, canrecruit = true })[1].id or ""
    Message(ennemy_leader, _ "Haha, we are back ! Tought we would give up that easily ?")
    Message("xavier",
        "Huhu, they have surrounded us.. and they have called big brother...")
    Message("xavier",
        "(To Morgane) Stay behind me, I'll get rid of these garnments !")

    wml.fire("objectives", {
        { "objective", { description = _ "Defeat ennemy leader.", condition = "win" } },
        { "objective", { description = _ "Death of Xavier.", condition = "lose" } },
        { "objective", { description = _ "Death of Morgane.", condition = "lose" } },
        { "objective", { description = _ "Turns run out.", condition = "lose" } },
        { "note",      { description = _ "No gold carry over next scenario." } },
        { "note", {
            description = _ "<span style='italic'>Hint: Xavier is showing off. " ..
                "Take your time, as it might be more difficult than he will admit.</span>"
        }
        }
    })
end

local function on_turn2()
    local bu = wesnoth.units.get_recall("bunshop")
    bu:to_map(14, 2)
    bu.side = 3
    MoveTo("bunshop", 12, 12)
    Message("morgane",
        _ "Hum... This dog is intriging... I <i>feel</i> something...")
    Message("xavier",
        _ "Hu ? Would you be kind enough to let me focus on the fight ?!")
    Message("morgane", _ "... <i>(Focusing)</i>")
    Message("bunshop", _ "<i>(Barks)</i>")
    local x, y = 8, 13
    local tbx, tby = wesnoth.paths.find_vacant_hex(x, y)
    MoveTo("bunshop", tbx, tby)
    tbx, tby = wesnoth.paths.find_vacant_hex(x, y)
    MoveTo("morgane", tbx, tby)
    Message("morgane", _ "<i>(Starring at Bunshop)</i> ... ")
    Message("bunshop", _ "<i>(Barks loudly)</i>")
    bu.side = 1
    Message("morgane", _ "See ? I can help too...")
end



---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function()
        local dying = PrimaryUnit()
        if dying.id == "leader" then
            Message("xavier",
                _ "Haha ! We defeated them ! You dont need to be scared anymore, Morgane !")
            Message("morgane",
                _ "Was I ? ... <i>(Turning back to Bunsop)</i> So, who are you ?")
            Message("xavier",
                _ "You're talking to a dog ? Humpf... Well, goodbye then, I need to hurry not to miss the departure of the Vranken Xaintrailles company !")
            MoveTo("xavier", 14, 2)
            wesnoth.units.get("xavier"):to_recall()
            local mr = wesnoth.units.get("morgane")
            MoveTo("bunshop", wesnoth.paths.find_vacant_hex(mr.x, mr.y))
            Message("morgane",
                _ "<i>(Stroking the dog)</i> Argh, to think I'm assigned to the same squad as that braggart...")
            Victory()
        end
    end
}

---@type game_event_options[]
local scenario_events = {
    { id = "s4_prestart",     name = "prestart", action = on_prestart },
    { id = "s4_turn1",        name = "turn_1",   action = on_turn1 },
    { id = "s4_click_xavier", name = "select",   action = on_presente_xavier, filter = { T.filter { id = "xavier" } } },
    { id = "s4_turn2",        name = "turn_2",   action = on_turn2 }
}

for __, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
