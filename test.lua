--- DEV file, included in debug scenarios

--- scenario handler
ES = {}
function ES.atk() end

function ES.kill() end

InitVariables()


UI.set_menu_item({
    id = "debug",
    description = _ "Hp to 1",
    T.command { T.lua { code = "Set_hp()" } }
})

UI.set_menu_item({
    id = "advance_unit",
    description = "Advance unit",
    T.show_if { T.have_unit { x = "$x1", y = "$y1" } },
    T.command { T.lua { code = "local args = ... ;  AdvanceUnit(args.x, args.y)", T.args { x = "$x1", y = "$y1" } } },
})

function AdvanceUnit(x, y)
    local unit = wesnoth.units.get(x, y)
    unit.experience = unit.max_experience
    unit:advance(true, true)
end

VAR.player_objects = {
    ceinture_geant = "brinx",
    bottes_celerite = "",
    ring_haste = "vranken",
    shield_myrom = "drumar"
}

CustomVariables().player_heroes = "brinx,vranken,drumar,rymor"


function Start()
    Conf.heroes.init("vranken")
    local vr = wesnoth.units.get("vranken")
    vr:custom_variables().xp = 1000

    local u = {
        type = "brinx4",
        id = "brinx",
        name = "Brinx",
        role = "hero",
        moves = 10,
        { "abilities", { { "isHere", { id = "elusive", name = "Elusive" } } } }
    }
    wesnoth.units.to_map(u, 15, 16)
    Conf.heroes.init("brinx")
    local br = wesnoth.units.get("brinx")
    br:custom_variables().xp = 1000
    local u = {
        type = "sword_spirit2",
        id = "sword_spirit",
        name = "Göndhul",
        role = "hero"
    }
    wesnoth.units.to_map(u, 15, 18)
    Conf.heroes.init("sword_spirit")
    wesnoth.units.to_map({
        id = "drumar",
        type = "drumar4",
        side = 1,
        name = "Dru",
        role = "hero"
    }, 20, 20)
    Conf.heroes.init("drumar")
    local dru = wesnoth.units.get("drumar")
    dru:custom_variables().xp = 1000

    local u = {
        type = "bunshop3",
        id = "bunshop",
        name = "Bunshop",
        role = "hero",
        moves = 10
    }
    wesnoth.units.to_map(u, 18, 18)
    Conf.heroes.init("bunshop")

    local u = { type = "xavier4", id = "xavier", name = "Xavier", role = "hero" }
    wesnoth.units.to_map(u, 19, 18)
    Conf.heroes.init("xavier")
    local u = wesnoth.units.get("xavier")
    u:custom_variables().xp = 1000
    u.level = 7

    local u = {
        type = "rymor4",
        id = "rymor",
        name = "Rymor",
        role = "hero",
        moves = 10
    }
    wesnoth.units.to_map(u, 18, 19)
    Conf.heroes.init("rymor")

    wesnoth.units.to_map({ type = "Sergeant", side = 2 }, 15, 15)

    wesnoth.units.to_map({
        type = "morgane1",
        id = "morgane",
        role = "hero",
        side = 1
    }, 6, 5)
    Conf.heroes.init("morgane")
    wesnoth.units.to_map({ type = "otchigin1", side = 2 }, 5, 6)
    wesnoth.units.to_map({ type = "otchigin2", side = 2 }, 5, 7)
    wesnoth.units.to_map({ type = "otchigin3", side = 2 }, 6, 6)
end

local in_limbe = false
local function switch_limbes()
    if in_limbe then
        Limbes.close()
    else
        Limbes.enter()
    end
    in_limbe = not in_limbe
end

-- entry point on the right click menu
function Test(x, y)
    -- local location = wesnoth.map.rotate_right_around_center({ 2, 2 }, { 2, 3 }, 2)
    -- wesnoth.interface.add_chat_message(tostring(location))
    -- Popup("test", "test")
    UI.set_menu_item({ id = "menu_test", description = 'Test Menu' })
    -- switch_limbes()
end

function ES.dump_amla()
    local types = { "amla_vranken", "amla_brinx", "amla_drumar", "amla_xavier" }
    local s = ""
    for i, t in pairs(types) do
        local u = wesnoth.units.create { type = t }
        s = s .. "\n \n" .. t .. " = { \n"
        for adv in wml.child_range(u.__cfg, "advancement") do
            s = s .. "\n { \n " .. wml.tostring(adv) .. "\n },"
        end
        s = s .. "\n } \n"
    end
    wesnoth.interface.add_chat_message(s)
end

local s = wesnoth.interface.game_display.edit_left_button_function
function wesnoth.interface.game_display.edit_left_button_function()
    local r = s()
    wesnoth.interface.add_chat_message(wml.tostring(r))
    return r
end
