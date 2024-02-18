local function on_prestart()
    -- switch back xavier for vranken as leader
    local xavier = wesnoth.units.get("xavier")
    xavier.canrecruit = false
    xavier:to_recall()

    local vranken = wesnoth.units.get_recall("vranken")
    vranken.canrecruit = true
    vranken:to_map(wesnoth.sides.get(1).starting_location)

    -- init mark
    local mark = wesnoth.units.create({
        id = "mark",
        type = "mark1",
        name = "Mârk",
    })
    mark:init_hero()
    mark:to_recall()

    CustomVariables().player_heroes = "vranken,bunshop,drumar,rymor,morgane,xavier,sword_spirit"

    wml.fire("label", { x = 38, y = 32, text = _ "White Ark" })
end

local function on_presente_mark()
    local mark = wesnoth.units.get("mark")
    if mark.status._was_presented then return end

    Popup(_ "New hero",
        _ "\tLet me introduce you to <span color='" ..
        Conf.heroes.colors.mark .. "' weight='bold'>Mârk</span>, " ..
        "a bold and brave kid. His strengh and power will grow over the battles," ..
        " making it a fierce melee fighter !" ..
        '\n\tYou will find more information in the <span style=\'italic\'>"Skills"</span> menu, ' ..
        "by right-clicking on Mârk. ")
    mark.status._was_presented = true
end

local function on_turn1()
    local vr = wesnoth.units.get("vranken")
    local rymor = wesnoth.units.get_recall("rymor")

    -- wesnoth.interface.add_chat_message(wesnoth.paths.find_vacant_hex(vr.x, vr.y))
    rymor:to_map(wesnoth.paths.find_vacant_hex(vr.x, vr.y))

    Message("rymor", _ "See ? Some bandits are in our way...")

    Message("ennemy_leader1", _ "Revenge for our fallen brothers !")
    Message("ennemy_leader2", _ "Hurgh !")

    Message("vranken",
        _ "(To Rymôr) Hum, I don't like being delayed during such an important expedition, but well .. We have to free the path to the White Ark for the whole army !")
    Message("rymor", _ "(Grinning) Some action is always good for our cadets. The sooner they fight, the better !")
    Message("vranken", _ "To arms, soldiers !")
    Message("ennemy_leader1", _ "Kill them all !")

    -- recall all heroes, expect brinx
    for __, u in ipairs(wesnoth.units.find_on_recall({ role = "hero" })) do
        if u.id ~= "brinx" then
            u:to_map(wesnoth.paths.find_vacant_hex(vr.x, vr.y))
        end
    end


    wml.fire("objectives", {
        { "objective", { description = _ "Defeat ennemy leaders.", condition = "win" } },
        { "objective", { description = _ "Death of any of your heroes.", condition = "lose" } },
        { "note",      { description = _ "No gold carry over next scenario." } },
        { "note", {
            description = _ "<span style='italic'>Hint:This is your first battle, and your are still quite weak. " ..
                "Recruit some expendable units and train your heroes as well as possible.</span>"
        }
        }
    })
end

---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function()
        local dying = PrimaryUnit()
        if dying.id == "ennemy_leader1" or dying.id == "ennemy_leader2" then
            -- check if one leader is already dead
            if not (wesnoth.units.get("ennemy_leader1") and wesnoth.units.get("ennemy_leader1")) then
                Message(dying.id, _ "Herk !")
                Message("vranken", _ "Nice jobs soldiers, the Ark is ours !")
                Message("rymor", _ "Congrats to the youngsters for your first fight under the Vranken company !")
                Victory()
            else
                Message(dying.id, _ "Hurgh, these youngsters are more useful then expected..")
            end
        end
    end
}

---@type game_event_options[]
local scenario_events = {
    { id = "s5_prestart",   name = "prestart", action = on_prestart },
    { id = "s5_turn1",      name = "turn_1",   action = on_turn1 },
    { id = "s5_click_mark", name = "select",   action = on_presente_mark, filter = { T.filter { id = "mark" } } },
}

for __, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
