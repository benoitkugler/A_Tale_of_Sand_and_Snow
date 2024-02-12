local x_messenger, y_messenger = 19, 1



local function create_sword_spirit()
    Message("vranken", _ "Hum... I feel like this fight will be harder than expected... Any help will be welcome... ")
    Message("vranken", _ "<span style='italic'>(rubbing the pommel of his sword)</span>")
    Message("vranken", _ "Göndhul ! Fight for us !")

    local sword_spirit = wesnoth.units.create({
        type = "sword_spirit2",
        id = "sword_spirit",
        name = "Göndhul",
        side = 1
    })
    sword_spirit:init_hero()
    sword_spirit:to_recall()

    local vr = wesnoth.units.get("vranken")
    local x, y = wesnoth.paths.find_vacant_hex(vr.x, vr.y, sword_spirit)
    wml.fire("recall", { id = "sword_spirit", x = x, y = y })
    Message("sword_spirit", _ "<span style='italic'>(Deep, guttural voice)</span> Master... At your service...")
    Message("vranken",
        _ "<span style='italic'>(Feeling uncomfortable)</span> Bruuh, he's always scary, even after all these years...")

    Popup(_ "New hero",
        _ "\tThis is <span color='" .. Conf.heroes.get_color("sword_spirit") ..
        "' weight='bold'> Göndhul</span>, " ..
        "the Xaintrailles family warden. He is linked to Vranken by oath, " ..
        "advising Vranken and finally enhancing Vranken's skills. " ..
        '\n\tYou will find more information in the <span style=\'italic\'>"Skills"</span> menu, ' ..
        "by right-clicking on Vranken. " ..
        "\n\t<span style='italic'>Special note : Göndhul struggle with living beings.. " ..
        'Pay attention to his <span color=\'red\'>"Fear of love"</span> ability.</span>')

    wml.fire("objectives", {
        {
            "objective",
            { description = _ "Defeat ennemy leader.", condition = "win" }
        },
        { "objective", { description = _ "Death of Vranken.", condition = "lose" } },
        { "objective", { description = _ "Death of Rymôr.", condition = "lose" } },
        {
            "objective",
            { description = _ "Death of Frä Drumar.", condition = "lose" }
        },
        { "objective", { description = _ "Death of Bunshop.", condition = "lose" } },
        {
            "objective",
            { description = _ "Death of Göndhul.", condition = "lose" }
        },
        { "objective", { description = _ "Turns run out.", condition = "lose" } },
        { "note",      { description = _ "No gold carry over next scenario." } }
    })

    -- add the new hero
    local lheros = CustomVariables().player_heroes
    lheros = lheros .. ",sword_spirit"
    CustomVariables().player_heroes = lheros
end

local function on_see_ennemy()
    -- check if we already have seen one
    if wesnoth.units.get("sword_spirit") then return end
    create_sword_spirit()
end


local function on_prestart()
    -- hide brinx and introduce vranken
    local brinx = wesnoth.units.get("brinx")
    brinx:extract()

    local vranken = wesnoth.units.create({
        id = "vranken",
        type = "vranken2",
        name = _ "Vranken",
        canrecruit = true,
    })
    vranken:init_hero()
    vranken:to_map(brinx.x, brinx.y)

    brinx.canrecruit = false
    brinx:to_recall()

    -- local newu = brinx.__cfg
    -- newu["canrecruit"] = nil
    -- wesnoth.put_recall_unit(newu)

    -- set the proper heroes for this scenario
    CustomVariables().player_heroes = "vranken,bunshop,drumar,rymor"
end

local function presentation()
    Popup(_ "New heroes",
        _ "\tYou now have three new heroes : " .. "<span color='" ..
        Conf.heroes.get_color("drumar") ..
        "' weight='bold'>Frä Drumar</span>, a powerful spell caster, " ..
        "<span color='" .. Conf.heroes.get_color("rymor") ..
        "' weight='bold'>Rymôr</span>, solid as a rock, and " ..
        "<span color='" .. Conf.heroes.get_color("bunshop") ..
        "' weight='bold'>Bunshop</span>, as nimble and fast as a storm. " ..
        "\nEach of them has unique skills and ways of enhancing them." ..
        '\nYou will find more information in the <span style=\'italic\'>"Skills"</span> menu, ' ..
        "by right-clicking on heroes.")
end

local function on_turn1()
    Message("vranken", _ "Come on soldiers ! Let's end this !")

    local vr = wesnoth.units.get("vranken")
    local rymor = wesnoth.units.create({
        id = "rymor",
        type = "rymor1",
        side = 1,
        name = _ "Rymôr",
    })
    rymor:init_hero()
    local x, y = wesnoth.paths.find_vacant_hex(vr.x, vr.y, rymor)
    rymor:to_map(x, y)
    Message("rymor", _ "Ah some action, at last !")

    local drumar = wesnoth.units.create({
        id = "drumar",
        type = "drumar1",
        side = 1,
        name = _ "Frä Drumar",
    })
    drumar:init_hero()
    x, y = wesnoth.paths.find_vacant_hex(vr.x, vr.y, drumar)
    drumar:to_map(x, y)
    Message("drumar", _ "The Source is formal, Vranken, this should be an easy win !")

    Message("rymor", _ "Ready Bunshop ?")

    local bunshop = wesnoth.units.create({
        id = "bunshop",
        type = "bunshop0",
        side = 1,
        name = _ "Bunshop",
    })
    bunshop:init_hero()
    x, y = wesnoth.paths.find_vacant_hex(vr.x, vr.y, bunshop)
    bunshop:to_map(x, y)
    Message("bunshop", _ "<span style='italic'>(enthusiastic barking)</span>")

    presentation()
    Popup(_ "Note",
        _ "As you might have guessed, this campaign is not about war strategy, " ..
        "manipulating a lot of units, but rather about training and mastering your heroes." ..
        "\nAs such, you should not focus too much on recruiting troops : they should only protect you heroes. " ..
        "Besides, gold should never be an issue, as you heroes will always be recalled at your side.")
end



---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function()
        local dying = PrimaryUnit()
        if dying.id == "ennemy_leader" then
            Message("vranken",
                _ "At last ! Their leader has fallen, and the remaining bandits should flee. They won't be a threat anymore !")
            Message("rymor", _ "Good job soldiers, time to take some rest !")
            local x, y = wesnoth.paths.find_vacant_hex(x_messenger, y_messenger)

            wesnoth.units.to_map({ id = "jod", type = "Woodsman", side = 1 }, x, y)
            wml.fire("lift_fog", { T.filter_side { side = 1 }, x = x, y = y })
            Message("jod",
                _ "<span style='italic'>(Shouting)</span> Sir ! Urgent message from the capital ! Seems like the Council needs you !")
            Message("rymor", _ "I guess the rest will wait...")
            Victory()
        end
    end
}


---@type game_event_options[]
local scenario_events = {
    { id = "s2_see",      name = "sighted",  action = on_see_ennemy, filter = { T.filter { side = 2 } } },
    { id = "s2_prestart", name = "prestart", action = on_prestart },
    { id = "s2_turn1",    name = "turn_1",   action = on_turn1 }
}

for __, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
