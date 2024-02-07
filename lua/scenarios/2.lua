ES = {}

local x_messenger, y_messenger = 19, 1

wesnoth.add_event_handler({
    id = "event_scenario_include",
    name = "prestart",
    T.lua { code = "ES.first_time()" }
})

local Scenario_event = {
    { id = "prestart", name = "prestart", T.lua { code = "ES.prestart()" } },
    { id = "turn1",    name = "turn_1",   T.lua { code = "ES.turn1()" } }
}

local First_time = {
    {
        id = "see",
        name = "sighted",
        T.filter { side = 2 },
        T.lua { code = "ES.see_ennemy()" }
    }
}

for i, v in pairs(Scenario_event) do
    --    wesnoth.remove_event_handler(v.id)
    wesnoth.add_event_handler(v)
end

function ES.first_time()
    for i, v in pairs(First_time) do
        --    wesnoth.remove_event_handler(v.id)
        wesnoth.add_event_handler(v)
    end
end

-- Ces 2 fonctions sont toujours appelés par la macro STANDARD_EVENT
function ES.atk() end

function ES.kill()
    local dying = PrimaryUnit()
    if dying.id == "leader" then
        Message("vranken",
            _ "At last ! Their leader has fallen, and the remaining bandits should flee. They won't be a threat anymore !")
        Message("rymor", _ "Good job soldiers, time to take some rest !")
        local x, y = wesnoth.find_vacant_tile(x_messenger, y_messenger)

        wesnoth.put_unit({ id = "jod", type = "Woodsman", side = 1 }, x, y)
        wml.fire("lift_fog", { T.filter_side { side = 1 }, x = x, y = y })
        Message("jod",
            _ "<span style='italic'>(Shouting)</span> Sir ! Urgent message from the capital ! Seems like the Council needs you !")
        Message("rymor", _ "I guess the rest will wait...")
        Victory()
    end
end

function ES.prestart()
    -- Recuperation de brinx et changement
    local br = wesnoth.get_units { id = "brinx" }[1]
    wesnoth.extract_unit(br)
    wesnoth.put_unit({
        id = "vranken",
        type = "vranken2",
        name = _ "Vranken",
        canrecruit = true,
        role = "hero",
        {
            "variables", {
            xp = "",
            bloodlust = "",
            special_skills = "",
            special_skills_lvl = "",
            special_skills_cd = "",
            T.special_skills {}
        }
        }
    }, br.x, br.y)
    local newu = br.__cfg
    newu["canrecruit"] = nil
    wesnoth.put_recall_unit(newu)

    -- Mise à jour de la liste des heros
    wesnoth.set_variable("heros_joueur", "vranken,bunshop,drumar,rymor")
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

    local u = wesnoth.get_unit("rymor")
    u.variables["special_skills"] = { skill1 = 0 }
    u = wesnoth.get_unit("bunshop")
    u.variables["special_skills"] = { skill1 = 0 }
    u = wesnoth.get_unit("drumar")
    u.variables["special_skills"] = { skill1 = 0 }
end

function ES.turn1()
    local vr = wesnoth.get_units { id = "vranken" }[1]
    local x, y

    wml.fire("message", {
        speaker = "vranken",
        message = _ "Come on soldiers ! Let's end this !"
    })

    x, y = wesnoth.find_vacant_tile(vr.x, vr.y)
    wesnoth.put_unit({
        id = "rymor",
        type = "rymor1",
        side = 1,
        name = _ "Rymôr",
        role = "hero",
        {
            "variables", {
            xp = "",
            bloodlust = "",
            special_skills = "",
            special_skills_lvl = "",
            special_skills_cd = "",
            T.special_skills {}
        }
        }
    }, x, y)

    wml.fire("message",
        { speaker = "rymor", message = _ "Ah some action, at last !" })

    x, y = wesnoth.find_vacant_tile(vr.x, vr.y)
    wesnoth.put_unit({
        id = "drumar",
        type = "drumar1",
        side = 1,
        name = _ "Frä Drumar",
        role = "hero",
        {
            "variables", {
            xp = "",
            bloodlust = "",
            special_skills = "",
            special_skills_lvl = "",
            special_skills_cd = "",
            T.special_skills {}
        }
        }
    }, x, y)
    wml.fire("message", {
        speaker = "drumar",
        message = _ "The Source is formal, Vranken, this should be an easy win !"
    })

    wml.fire("message", { speaker = "rymor", message = _ "Ready Bunshop ?" })

    x, y = wesnoth.find_vacant_tile(vr.x, vr.y)
    wesnoth.put_unit({
        id = "bunshop",
        type = "bunshop0",
        side = 1,
        name = _ "Bunshop",
        role = "hero",
        {
            "variables", {
            xp = "",
            bloodlust = "",
            special_skills = "",
            special_skills_lvl = "",
            special_skills_cd = "",
            T.special_skills {}
        }
        }
    }, x, y)
    wml.fire("message", {
        speaker = "bunshop",
        message = _ "<span style='italic'>(enthusiastic barking)</span>"
    })

    -- initialisation des variables

    Conf.heroes.init("vranken")
    Conf.heroes.init("rymor")
    Conf.heroes.init("drumar")
    Conf.heroes.init("bunshop")

    -- Présentation

    presentation()
    Popup(_ "Note",
        _ "As you might have guessed, this campaign is not about war strategy, " ..
        "manipulating a lot of units, but rather about training and mastering your heroes." ..
        "\nConsequently, you should not focus too much on recruiting troops : they should only protect you heroes. " ..
        "By the way, gold should never be an issue : you heroes will always be at your side.")
end

local function note_gondhul()
    Popup(_ "New hero",
        _ "\tThis is <span color='" .. Conf.heroes.get_color("sword_spirit") ..
        "' weight='bold'> Göndhul</span>, " ..
        "the Xaintrailles family warden. He's link to Vranken by oath, " ..
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
end

function ES.see_ennemy()
    wml.fire("message", {
        speaker = "vranken",
        message = _ "Hum... I feel like this fight will be harder than expected... Any help will be welcome... "
    })
    wml.fire("message", {
        speaker = "vranken",
        message = _ "<span style='italic'>(rubbing the pommel of his sword)</span>"
    })
    wml.fire("message",
        { speaker = "vranken", message = _ "Göndhul ! Fight for us !" })

    wesnoth.put_recall_unit({
        type = "sword_spirit2",
        id = "sword_spirit",
        name = "Göndhul",
        role = "hero",
        { "variables", { bloodlust = "", T.special_skills {}, special_skills = "" } }
    }, 1)
    local vr = wesnoth.get_unit("vranken")
    local sp = wesnoth.get_units { id = "sword_spirit" }[1]
    local x, y = wesnoth.find_vacant_tile(vr.x, vr.y, sp)
    wml.fire("recall", { id = "sword_spirit", x = x, y = y })
    Conf.heroes.init("sword_spirit")
    wml.fire("message", {
        speaker = "sword_spirit",
        message = _ "<span style='italic'>(Deep, guttural voice)</span> Master... At your service..."
    })
    wml.fire("message", {
        speaker = "vranken",
        message = _ "<span style='italic'>(Feeling uncomfortable)</span> Bruuh, he's always scary, even after all these years..."
    })
    note_gondhul()

    local lheros = wesnoth.get_variable("heros_joueur")
    lheros = lheros .. ",sword_spirit"
    wesnoth.set_variable("heros_joueur", lheros)
end
