-- Load all the lua modules (excepted Scenario)
H = wesnoth.require "lua/helper.lua"
T = wml.tag
VAR = wml.variables
_ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"


wesnoth.require "helpers"
wesnoth.require "animations"
wesnoth.require "DB/init"
wesnoth.require "custom_themes"

wesnoth.require "combat/competences_spe"

wesnoth.require "implementation/ability"
wesnoth.require "implementation/special_exp_gain"
wesnoth.require "implementation/event_combat"
wesnoth.require "implementation/amla"
wesnoth.require "implementation/special_skills"

wesnoth.require "menus/objets"
wesnoth.require "menus/items"
wesnoth.require "standard_event" --event setup
