local function on_prestart()
    -- add some labels
    wml.fire("label", { x = 10, y = 31, text = _ "North White Ark" })
    wml.fire("label", { x = 30, y = 31, text = _ "Towards White Arks Facility" })
    wml.fire("label", { x = 15, y = 23, text = _ "Towards disused quarters" })

    -- setup ennemy units
    wesnoth.sides.get(2).recruit = MuspellUnits(1, 2)
end

local function on_presente_porthos()
    local porthos = wesnoth.units.get("porthos")
    if porthos.status._was_presented then return end

    Popup(_ "New hero",
        _ "\tLet me introduce you to <span color='" ..
        Conf.heroes.colors.porthos .. "' weight='bold'>Porthos</span>, \z
        an ogre born on Dead Island. Growing up in such arsh conditions, Porthos has developped a solid constitution, \z
        making him your best defensive unit !\z
        \n\tYou will find more information in the <span style='italic'>Skills</span> menu, \z
        by right-clicking on Porthos.")
    porthos.status._was_presented = true
end

local function on_turn1()
    local vr = wesnoth.units.get("vranken")
    -- local rymor = wesnoth.units.get_recall("rymor")


    -- recall all heroes, expect brinx
    for __, u in ipairs(wesnoth.units.find_on_recall({ role = "hero" })) do
        if u.id ~= "brinx" then
            u:to_map(wesnoth.paths.find_vacant_hex(vr.x, vr.y))
        end
    end


    Message("vranken", _ "Here we are folks, welcome to Dead Island !")

    Message("xavier", _ "Hurgh.. my head..")
    Message("rymor",
        _ "(Grinning) Ah, it seems young Xavier has discovered the post effects of travelling through the Arks.. ")
    Message("rymor", _ "What about the other kids ?")
    Message("mark", _ "Hum.. not the best feeling either..")
    Message("morgane", _ "What are you guys talking about ? Wasn't it the most awesome feeling !?")
    Message("drumar",
        _ "My child, Frä may feel less pain travelling through the Arks.. Anyway, you all will get used to it !")

    Message("vranken",
        _ "Well, the facility we have to defend is somewhere South. We should get going and scout the environ. \z
        Do not engage with the Muspell forces until the army has joined us though !")
    Message("drumar",
        _ "<i>(To Vranken)</i> Hum... I can sense something around here. Oddly enough, it comes from the North.")
    Message("vranken",
        _ "North ? There is nothing worth I can remember !")
    Message("rymor", _ "Hum... I've heard rumors about old quarters, left by Nifhell some decades ago..")
    Message("vranken",
        _ "Alright, we should get to the bottom of it anyway. Let's explore before reaching the Facility !")
end

local function on_see_ennemy()
    -- this function is called several times
    if wesnoth.units.get("porthos") then return end

    local seeer = SecondaryUnit()
    Message(seeer.id, _ "Ah ! Some Muspellian units over here ! ")
    Message(seeer.id == "vranken" and "rymor" or "vranken", _ "We found a Muspellian outpost !")

    wml.fire("lift_fog", { multiturn = true, T.filter_side { side = 1 } })


    -- -- position brinx and porthos on the map, in the prison
    local brinx = wesnoth.units.get_recall("brinx")
    local porthos = wesnoth.units.create({
        id = "porthos",
        type = "porthos1",
        name = "Porthos",
    })
    porthos:init_hero()

    brinx:to_map(19, 5, true)
    porthos:to_map(18, 4, true)
    wesnoth.interface.scroll_to_hex(19, 5)

    Message("drumar", _ "An outpost perhaps, but certainly a prisonner camp !")
    Message("vranken",
        _ "By the powers, some Nifhell man have survived the Muspell raid ! Let's make them free !")

    wml.fire("objectives", {
        { "objective", { description = _ "Free Brinx.", condition = "win" } },
        { "objective", { description = _ "Defeat the ennemy leader.", condition = "win" } },
        { "objective", { description = _ "Death of any of your heroes.", condition = "lose" } },
        { "note",      { description = _ "No gold carry over next scenario." } },
        { "note", {
            description = _ "<span style='italic'>Hint: If the battle seems easy, there might be a catch ! Stay together..</span>"
        } }
    })
end

---@param loc location
local function is_adjacent_gates(loc)
    -- this could probably be achieved with a clever filter..
    local d1 = wesnoth.map.distance_between(loc, { x = 18, y = 12 })
    local d2 = wesnoth.map.distance_between(loc, { x = 19, y = 13 })
    local d3 = wesnoth.map.distance_between(loc, { x = 20, y = 13 })
    return d1 <= 1 or d2 <= 1 or d3 <= 1
end

---@param loc location
local function is_adjacent_jail(loc)
    local d = wesnoth.map.distance_between(loc, { x = 20, y = 5 })
    return d <= 1
end

local function is_jail_opened()
    return wesnoth.current.map[{ 20, 5 }] == "Rr^Pr/o"
end


---@param nb_units integer
---@param unit_types string[]
---@param near location
local function spawn_ennemies(nb_units, unit_types, near)
    for i = 1, nb_units, 1 do
        local new_unit = wesnoth.units.create({
            type = mathx.random_choice(unit_types),
            side = 2,
        })
        local x, y = wesnoth.paths.find_vacant_hex(near, new_unit)
        new_unit:to_map(x, y, true)
    end
end

local function on_enter_hex()
    local vars = CustomVariables()
    local u = PrimaryUnit()
    if not vars.s6_gates_activated_turn and is_adjacent_gates(u) then
        -- abort the move
        wml.fire("cancel_action")

        Message(u.id, _ "Hum ? These gates seem to work still. <i>(The gates activate)</i>\n\z
        Hu-oh.. There is a message now : \n<b>Gates closing at the end of the turn !</b>")
        Message("vranken", _ "Hurry guys, we need to get through the gates !")

        vars.s6_gates_activated_turn = wesnoth.current.turn
        return
    end

    if not is_jail_opened() and is_adjacent_jail(u) then
        -- open the jail
        wesnoth.current.map[{ 20, 5 }] = "Rr^Pr/o"
        Message("brinx", _ "Hurra, Nifhellians brothers. Thank you for the rescue !")
        Message("porthos", _ "Me.. fight..")
        Message("brinx", _ "This fellow was with me in jail. Not very talkative, but he seems resilient !")
        Message("vranken", _ "This is fine, we need all the help we can get against Muspell !")

        -- If the ennemy leader is already dead, fire victory
        if not (wesnoth.units.get("ennemy_leader")) then
            Message("vranken", _ "Now, let's get some rest before marching on the Facility.")
            Victory()
            return
        else
            Message("ennemy_leader", _ "Soldiers ! Kill the prisonners !")
            spawn_ennemies(5, MuspellUnits(3, 3), { x = 20, y = 5 })
            Message("vranken", _ "Alright, protect our comrades !")

            wml.fire("objectives", {
                { "objective", { description = _ "Defeat the ennemy leader.", condition = "win" } },
                { "objective", { description = _ "Death of any of your heroes.", condition = "lose" } },
                { "note",      { description = _ "No gold carry over next scenario." } },
            })
        end
    end
end

-- close the gates :
-- enemy units are moved inside the gates
-- friendly units are killed by the gates !
-- Also, summon the real ennemy units
local function close_gates()
    local units_on_gates = wesnoth.units.find_on_map {
        T.filter_location {
            x = 18, y = 12,
            T["or"] { x = 19, y = 13 },
            T["or"] { x = 20, y = 13 },
        }
    }
    -- update the gates first so that find_vacant_hex ignore it properly
    local closed_gate_terrain = "Rr^Pr\\"
    wesnoth.current.map[{ 18, 12 }] = closed_gate_terrain
    wesnoth.current.map[{ 19, 13 }] = closed_gate_terrain
    wesnoth.current.map[{ 20, 13 }] = closed_gate_terrain

    for __, unit in ipairs(units_on_gates) do
        if unit.side == 1 then
            Message(unit.id, _ "<i>(Panicking)</i> Hey !! I'm being crushed by the gates !")
            unit:extract()
            wml.fire("endlevel", { result = "defeat", side = 1 })
            return
        else
            local x, y = wesnoth.paths.find_vacant_hex(unit.x, unit.y, unit)
            MoveTo(unit.id, x, y)
        end
    end

    -- summon backup ennemies
    Message("ennemy_leader", _ "With me, soldiers of Muspell ! Do not let the prisonners escape !")
    local unit_types = MuspellUnits(2, 2)
    local nb_units = wesnoth.scenario.difficulty == "NORMAL" and 8 or 10
    spawn_ennemies(nb_units, unit_types, { x = 21, y = 6 })
    spawn_ennemies(nb_units / 2, unit_types, { x = 26, y = 6 })
end



local function on_new_turn()
    local activation_turn = CustomVariables().s6_gates_activated_turn
    if activation_turn and wesnoth.current.turn == activation_turn + 1 then
        close_gates()
    end
end

---@type ScenarioEvents
ES = {
    atk = function() end,
    kill = function()
        local dying = PrimaryUnit()
        if dying.id == "ennemy_leader" then
            -- check the jail has been opened
            if is_jail_opened() then
                Message("vranken", _ "Nice job ! Let's get some rest before marching on the Facility.")
                Victory()
            else
                Message("vranken", _ "And now, let's free our soldiers !.")
            end
        end
    end
}

---@type game_event_options[]
local scenario_events = {
    { id = "s6_prestart",      name = "prestart",  action = on_prestart },
    { id = "s6_turn1",         name = "turn_1",    action = on_turn1 },
    { id = "s6_click_porthos", name = "select",    action = on_presente_porthos, filter = { T.filter { id = "porthos" } } },
    { id = "s6_see",           name = "sighted",   action = on_see_ennemy,       filter = { T.filter { side = 2 } } },
    { id = "s6_enter_hex",     name = "enter_hex", action = on_enter_hex,        first_time_only = false,                 filter = { T.filter { side = 1 } } },
    { id = "s6_new_turn",      name = "new turn",  action = on_new_turn,         first_time_only = false, },
}

for __, v in pairs(scenario_events) do
    wesnoth.game_events.add(v)
end
