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
    local vr = wesnoth.units.get("vranken")
    vr:init_hero()
    vr:custom_variables().xp = 1000

    local brinx = wesnoth.units.create {
        type = "brinx4",
        id = "brinx",
        name = "Brinx",
        moves = 10,
        { "abilities", { { "isHere", { id = "elusive", name = "Elusive" } } } }
    }
    brinx:init_hero()
    brinx:to_map(15, 16)
    brinx:custom_variables().xp = 1000

    local sw = wesnoth.units.create {
        type = "sword_spirit2",
        id = "sword_spirit",
        name = "Göndhul",
    }
    sw:init_hero()
    sw:to_map(15, 18)

    local dru = wesnoth.units.create {
        id = "drumar",
        type = "drumar4",
        side = 1,
        name = "Dru",
    }
    dru:init_hero()
    dru:to_map(20, 20)
    dru:custom_variables().xp = 1000

    local bun = wesnoth.units.create {
        type = "bunshop3",
        id = "bunshop",
        name = "Bunshop",
        moves = 10
    }
    bun:init_hero()
    bun:to_map(18, 18)

    local xavier = wesnoth.units.create { type = "xavier4", id = "xavier", name = "Xavier" }
    xavier:init_hero()
    xavier:to_map(19, 18)
    xavier:custom_variables().xp = 1000
    xavier.level = 7

    local rymor = wesnoth.units.create {
        type = "rymor4",
        id = "rymor",
        name = "Rymor",
        moves = 10
    }
    rymor:init_hero()
    rymor:to_map(18, 19)

    wesnoth.units.to_map({ type = "Sergeant", side = 2 }, 15, 15)

    local morgane = wesnoth.units.create {
        type = "morgane1",
        id = "morgane",
        side = 1
    }
    morgane:init_hero()
    morgane:to_map(6, 5)

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
