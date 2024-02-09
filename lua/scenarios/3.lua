local function prestart()
    wesnoth.units.to_map({
        id = "egil",
        type = "Grand Marshal_nifhell",
        side = 2,
        name = "Egil Skinir"
    }, 10, 4)
    wesnoth.units.to_map({
        id = "ran",
        type = "Iron Mauler_nifhell",
        side = 2,
        name = "Ran Gragass"
    }, 7, 6)
    wesnoth.units.to_map({
        id = "harbar",
        type = "General_nifhell",
        side = 2,
        name = "Harbar Augentyr"
    }, 8, 5)
    wesnoth.units.to_map({
        id = "urvi",
        type = "Red Mage_nifhell",
        side = 2,
        name = "Urvi Herjar"
    }, 9, 5)
    wesnoth.units.to_map({
        id = "bragi",
        type = "Master at Arms_nifhell",
        side = 2,
        name = "Bragi Daldr"
    }, 11, 5)
    wesnoth.units.to_map({
        id = "dummy1",
        type = "Master Bowman_nifhell",
        side = 2,
        name = "Zac Tod"
    }, 12, 5)
    wesnoth.units.to_map({
        id = "dummy3",
        type = "Royal Guard_nifhell",
        side = 2,
        name = "Ulk Zappsnhcip"
    }, 13, 6)

    wesnoth.units.to_map({ type = "Swordsman_nifhell", side = 2 }, 8, 21)
    wesnoth.units.to_map({ type = "Swordsman_nifhell", side = 2 }, 12, 21)

    local vr = wesnoth.units.get_recall("vranken")
    vr:to_map(10, 21)
end

local function turn1()
    MoveTo("vranken", 10, 7)

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

---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function() end,
}

---@type game_event_options[]
local scenario_events = {
    { id = "s3_prestart", name = "prestart", action = prestart },
    { id = "s3_turn1",    name = "turn_1",   action = turn1 }
}

for _, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
