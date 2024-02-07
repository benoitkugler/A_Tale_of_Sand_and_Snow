ES = {}

local Scenario_event = {
    { id = "prestart", name = "prestart", T.lua { code = "ES.prestart()" } },
    { id = "turn1",    name = "turn_1",   T.lua { code = "ES.turn1()" } }, {
    id = "click_xavier",
    name = "select",
    T.filter { id = "xavier" },
    T.lua { code = "ES.presente_xavier()" }
}, { id = "turn2", name = "turn_2", T.lua { code = "ES.turn2()" } }
}

for _, v in pairs(Scenario_event) do wesnoth.add_event_handler(v) end

-- Ces 2 fonctions sont toujours appelés par la macro STANDARD_EVENT
function ES.atk() end

function ES.kill()
    local dying = PrimaryUnit()
    if dying.id == "leader" then
        Message("xavier",
            _ "Haha ! We defeated them ! You dont need to be scared anymore, Morgane !")
        Message("morgane",
            _ "Was I ? ... <i>(Turning back to Bunsop)</i> So, who are you ?")
        Message("xavier",
            _ "You're talking to a dog ? Humpf... Well, goodbye then, I need to hurry not to miss the departure of the Vranken Xaintrailles company !")
        MoveTo("xavier", 14, 2)
        wesnoth.get_unit("xavier"):to_recall()
        local mr = wesnoth.get_unit("morgane")
        MoveTo("bunshop", wesnoth.find_vacant_tile(mr.x, mr.y))
        Message("morgane",
            _ "<i>(Stroking the dog)</i> Argh, to think I'm assigned to the same squad as that braggart...")
        Victory()
    end
end

function ES.prestart()
    wesnoth.put_unit({ type = "Ruffian", side = 2 }, 2, 15)
    wesnoth.put_unit({ type = "Ruffian", side = 2 }, 6, 15)
    wesnoth.put_unit({ type = "Ruffian", side = 2 }, 3, 7)
    wesnoth.put_unit({ type = "Thug", side = 2 }, 4, 7)

    -- Recuperation de vranken et changement
    local vr = wesnoth.get_units { id = "vranken" }[1]
    wesnoth.extract_unit(vr)
    wesnoth.put_unit({
        id = "xavier",
        type = "xavier1",
        name = "Xavier Augentyr",
        canrecruit = true,
        role = "hero"
    }, vr.x, vr.y)
    local newu = vr.__cfg
    newu["canrecruit"] = nil
    wesnoth.put_recall_unit(newu)

    -- Mise à jour de la liste des heros
    wesnoth.set_variable("heros_joueur", "morgane, xavier")

    local xav = wesnoth.get_unit("xavier")
    local x, y = wesnoth.find_vacant_tile(xav.x, xav.y)
    wesnoth.put_unit({
        id = "morgane",
        type = "morgane1",
        side = 1,
        name = "Morgane"
    }, x, y)

    -- heroes variables init
    Conf.heroes.init("xavier")
    Conf.heroes.init("morgane")
end

function ES.presente_xavier()
    Popup(_ "New hero",
        _ "\tLet me introduce you to <span color='" ..
        Conf.heroes.get_color("xavier") .. "' weight='bold'>Xavier</span>, " ..
        "a young and talented military student. His intuition on military tactics " ..
        " have to be battle-tested, but may become very useful to you..." ..
        '\n\tYou will find more information in the <span style=\'italic\'>"Skills"</span> menu, ' ..
        "by right-clicking on Xavier. ")
end

function ES.turn1()
    local id = wesnoth.get_units({ side = 2, canrecruit = true })[1].id
    Message(id, _ "Haha, we are back ! Tought we would give up that easily ?")
    Message("xavier",
        "Huhu, they have surrounded us.. and they have called big brother...")
    Message("xavier",
        "(To Morgane) Stay behind me, I'll get rid of these garnments !")

    wml.fire("objectives", {
        {
            "objective",
            { description = _ "Defeat ennemy leader.", condition = "win" }
        },
        { "objective", { description = _ "Death of Xavier.", condition = "lose" } },
        { "objective", { description = _ "Death of Morgane.", condition = "lose" } },
        { "objective", { description = _ "Turns run out.", condition = "lose" } },
        { "note",      { description = _ "No gold carry over next scenario." } }, {
        "note", {
        description = _ "<span style='italic'>Hint: Xavier is showing off. " ..
            "Take your time, as it might be more difficult than he will admit.</span>"
    }
    }
    })
end

function ES.turn2()
    local bu = GetRecallUnit("bunshop")
    bu:to_map(14, 2)
    bu = wesnoth.get_unit("bunshop")
    bu.side = 3
    MoveTo("bunshop", 12, 12)
    wesnoth.message(bu.valid)
    Message("morgane",
        _ "Hum... This dog is intriging... I <i>feel</i> something...")
    Message("xavier",
        _ "Hu ? Would you be kind enough to let me focus on the fight ?!")
    Message("morgane", _ "... <i>(Focusing)</i>")
    Message("bunshop", _ "<i>(Barks)</i>")
    local x, y = 8, 13
    local tbx, tby = wesnoth.find_vacant_tile(x, y)
    MoveTo("bunshop", tbx, tby)
    tbx, tby = wesnoth.find_vacant_tile(x, y)
    MoveTo("morgane", tbx, tby)
    Message("morgane", _ "<i>(Starring at Bunshop)</i> ... ")
    Message("bunshop", _ "<i>(Barks loudly)</i>")
    bu.side = 1
    Message("morgane", _ "See ? I can help too...")
end
