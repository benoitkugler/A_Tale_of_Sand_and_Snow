--- DEV file, included in debug scenarios

ES = {}

InitVariables()

UI.setup_menus()

UI.set_menu_item({
    id = "debug",
    description = _ "Hp to 1",
    T.command { T.lua { code = "Set_hp()" } }
})


VAR.player_objects = {
    ceinture_geant = "brinx",
    bottes_celerite = "",
    ring_haste = "vranken",
    shield_myrom = "drumar"
}
wesnoth.set_variable("heros_joueur", "brinx,vranken,drumar,rymor")

-- local br = wesnoth.get_unit("brinx")
-- br.variables.status_shielded_hp = 15
-- br.status.shielded = true

function ES.kill() end

function ES.atk() end

function start()
    local u = {
        type = "brinx4",
        id = "brinx",
        name = "Brinx",
        role = "hero",
        moves = 10,
        { "abilities", { { "isHere", { id = "elusive", name = "Elusive" } } } }
    }
    wesnoth.put_unit(u, 15, 16)
    Conf.HEROES.init("brinx")
    local br = wesnoth.get_unit("brinx")
    br.variables.xp = 1000
    local u = {
        type = "sword_spirit2",
        id = "sword_spirit",
        name = "Göndhul",
        role = "hero"
    }
    wesnoth.put_unit(u, 15, 18)
    Conf.HEROES.init("sword_spirit")
    wesnoth.put_unit({
        id = "drumar",
        type = "drumar4",
        side = 1,
        name = "Dru",
        role = "hero"
    }, 20, 20)
    Conf.HEROES.init("drumar")
    local dru = wesnoth.get_unit("drumar")
    dru.variables.xp = 1000

    local u = {
        type = "bunshop3",
        id = "bunshop",
        name = "Bunshop",
        role = "hero",
        moves = 10
    }
    wesnoth.put_unit(u, 18, 18)
    Conf.HEROES.init("bunshop")

    local u = { type = "xavier4", id = "xavier", name = "Xavier", role = "hero" }
    wesnoth.put_unit(u, 19, 18)
    Conf.HEROES.init("xavier")
    local u = wesnoth.get_unit("xavier")
    u.variables.xp = 1000
    u.level = 7

    local u = {
        type = "rymor4",
        id = "rymor",
        name = "Rymor",
        role = "hero",
        moves = 10
    }
    wesnoth.put_unit(u, 18, 19)
    Conf.HEROES.init("rymor")
    local u = wesnoth.get_unit("vranken")
    local u = wesnoth.get_unit("brinx")

    wesnoth.put_unit({ type = "Sergeant", side = 2 }, 15, 15)

    wesnoth.put_unit({
        type = "morgane1",
        id = "morgane",
        role = "hero",
        side = 1
    }, 6, 5)
    Conf.HEROES.init("morgane")
    wesnoth.put_unit({ type = "otchigin1", side = 2 }, 5, 6)
    wesnoth.put_unit({ type = "otchigin2", side = 2 }, 5, 7)
    wesnoth.put_unit({ type = "otchigin3", side = 2 }, 6, 6)
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
function test(x, y)
    -- local location = wesnoth.map.rotate_right_around_center({ 2, 2 }, { 2, 3 }, 2)
    -- wesnoth.interface.add_chat_message(tostring(location))
    -- Popup("test", "test")
    UI.set_menu_item({ id = "menu_test", description = 'Test Menu' })
    -- switch_limbes()
end

local function _table_to_string(tab)
    local s, v_s = "", ""
    for i, v in pairs(tab) do
        if not (type(i) == "number") then
            if type(v) == "number" or type(v) == "boolean" then
                v_s = tostring(v)
            else
                v_s = '"' .. v .. '"'
            end
            if i == "description" then v_s = "_ " .. v_s end
            s = s .. i .. " = " .. v_s .. ",\n"
        end
    end
    for i, v in ipairs(tab) do
        tag = v[1]
        s = s .. "T." .. tag .. " { \n"
        s = s .. _table_to_string(v[2])
        s = s .. "}, \n"
    end
    return s
end

function ES.dump_amla()
    local types = { "amla_vranken", "amla_brinx", "amla_drumar", "amla_xavier" }
    local s = ""
    for i, t in pairs(types) do
        local u = wesnoth.create_unit { type = t }
        s = s .. "\n \n" .. t .. " = { \n"
        for adv in H.child_range(u.__cfg, "advancement") do
            s = s .. "\n { \n " .. _table_to_string(adv) .. "\n },"
        end
        s = s .. "\n } \n"
    end
    wesnoth.message(s)
end

local s = wesnoth.theme_items.edit_left_button_function
function wesnoth.theme_items.edit_left_button_function()
    local r = s()
    wesnoth.message(wesnoth.debug(r))
    return r
end

--     wesnoth.units.add_modification(u,"object",{{"effect",{apply_to="attack",{"set_specials", { {"isHere",{id="slow_zone",name="test"} }  }}  }}},false)
