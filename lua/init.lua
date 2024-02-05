-- Load all the lua modules (excepted Scenario)
H = wesnoth.require "lua/helper.lua"
T = wml.tag
VAR = wml.variables
_ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

wesnoth.require "helpers"
wesnoth.require "helpers_events"
wesnoth.require "animations"
wesnoth.require "DB/init"

wesnoth.require "limbes"

wesnoth.require "implementation/ability"
wesnoth.require "implementation/special_exp_gain"
wesnoth.require "implementation/event_combat"
wesnoth.require "implementation/amla"
wesnoth.require "implementation/special_skills"

wesnoth.require "ui/custom_themes"
wesnoth.require "ui/objets"
wesnoth.require "ui/menus"
wesnoth.require "standard_event" -- event setup

function Set_hp()
    for _, u in pairs(wesnoth.units.find_on_map({ side = 2 })) do u.hitpoints = 1 end
end

UI.set_menu_item({
    id = "debug",
    description = _ "Hp to 1",
    T.command { T.lua { code = "Set_hp()" } }
})
