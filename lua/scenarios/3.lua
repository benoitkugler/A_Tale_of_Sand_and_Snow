ES = {}

local Scenario_event = {
    { id = "prestart", name = "prestart", T.lua { code = "ES.prestart()" } },
    { id = "turn1",    name = "turn_1",   T.lua { code = "ES.turn1()" } }
}

for _, v in pairs(Scenario_event) do wesnoth.add_event_handler(v) end

-- Ces 2 fonctions sont toujours appelés par la macro STANDARD_EVENT
function ES.atk() end

function ES.kill() end

function ES.prestart()
    wesnoth.put_unit({
        id = "egil",
        type = "Grand Marshal_nifhell",
        side = 2,
        name = "Egil Skinir"
    }, 10, 4)
    wesnoth.put_unit({
        id = "ran",
        type = "Iron Mauler_nifhell",
        side = 2,
        name = "Ran Gragass"
    }, 7, 6)
    wesnoth.put_unit({
        id = "harbar",
        type = "General_nifhell",
        side = 2,
        name = "Harbar Augentyr"
    }, 8, 5)
    wesnoth.put_unit({
        id = "urvi",
        type = "Red Mage_nifhell",
        side = 2,
        name = "Urvi Herjar"
    }, 9, 5)
    wesnoth.put_unit({
        id = "bragi",
        type = "Master at ArmsN",
        side = 2,
        name = "Bragi Daldr"
    }, 11, 5)
    wesnoth.put_unit({
        id = "dummy1",
        type = "Master Bowman_nifhell",
        side = 2,
        name = "Zac Tod"
    }, 12, 5)
    wesnoth.put_unit({
        id = "dummy3",
        type = "Royal Guard_nifhell_nifhell",
        side = 2,
        name = "Ulk Zappsnhcip"
    }, 13, 6)

    wesnoth.put_unit({ type = "Swordsman_nifhell", side = 2 }, 8, 21)
    wesnoth.put_unit({ type = "Swordsman_nifhell", side = 2 }, 12, 21)
    local vr = GetRecallUnit("vranken")
    vr:to_map(10, 21)
end

function ES.turn1()
    wml.fire("move_unit", { id = "vranken", to_x = 10, to_y = 7 })

    Message("egil", _ "Captain Xaintrailles, please have a sit !")

    Message("ran",
        _ "You're here because of worrying news from Dead Island. Its garrison seems under attack. Our magi received this message yesterday, send through the White Arks by Jödumur, commanding Dead Island company.")

    Message("narrator",
        _ "<i>(projection)</i> Communication Mage for Dead Island here ! We are under attack from Muspell. They outnumber us by far ! We request immediate help ! They have already broke our first line and ... ")

    Message("harbar",
        _ "The message stops here, so we fear muspellians have already taken the White Arks facility..")

    Message("urvi",
        _ "<i>(thumping the table)</i> What an arrogance from Muspell ! " ..
        "They openly dare to attack the Federation ! They will pay for this insult !")

    Message("bragi",
        _ "The Council share Herjar's opinion. Your mission, Vranken, is to lead Nifhell forces and take back Dead Island !")

    Message("vranken",
        _ "<i>(Thinking for a while)</i> It's rather strange to me that Muspell attacks Dead Island. We have always let them use the White Arks. What's would be the point ?")

    Message("egil", _ "That doesn't matter. We have to stop Muspell invasion !")

    Message("harbar",
        _ "We omitted a detail : the muspellian troops are displaying Octopus flag !")

    Message("narrator",
        _ "Vranken thrilled. Octopus was the best general of Muspell. " ..
        "He quickly earned his reputation by defeating Nifhell in small skirmishes during the last two years. " ..
        "His name came from he ability to move his troops like tentacles, thus winning already lost battles.")

    Message("vranken",
        _ "That's not a detail ! When should we head towards the White Arks ?")

    Victory()
end
