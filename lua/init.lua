-- Load all the lua modules (excepted Scenario)
-- H = wesnoth.require "lua/helper.lua"
T = wml.tag
VAR = wml.variables
_ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

---CustomGlobalVariables is a WML table storing
---variables used by this campaing
---This is a shallow proxy : writing the direct fields
---will update the underlying state (but nested objects must be updated and stored back)
---@class CustomGlobalVariables
---@field showed_menus table<string, boolean>
---@field table_status any
---@field table_status_shielded any
---@field player_objects table<string,string> # object -> owner
---@field player_heroes string # comma separated
---@field s6_gates_activated_turn integer? # turn starting the activation

---InitVariables creates global variables.
---It should be called once at campaign startup
---or in test scenario, but not when loading lua code,
---since it would overwrite existing ones.
function InitVariables()
    ---@type CustomGlobalVariables
    local vars = wml.variables
    vars.showed_menus = {}
    vars.table_status = {}
    vars.table_status_shielded = {}
    vars.player_objects = {}
    vars.player_heroes = "brinx"
end

---Variables is are typed wrapper for wml.variables
---@return CustomGlobalVariables
function CustomVariables() return wml.variables end

---ScenarioEvents defines the event handler a scenario must implement
---@class ScenarioEvents
---@field atk fun()
---@field kill fun()

wesnoth.require "helpers"
wesnoth.require "helpers_events"
wesnoth.require "animations"
wesnoth.require "config/config"

wesnoth.require "limbes"

wesnoth.require "implementation/ability"
EXP = wesnoth.require "implementation/special_exp_gain"
wesnoth.require "implementation/event_combat"
wesnoth.require "implementation/amla"
wesnoth.require "implementation/special_skills"

wesnoth.require "ui/custom_game_display"
wesnoth.require "ui/objects"
wesnoth.require "ui/menus"
wesnoth.require "standard_event" -- event setup

--- always build menus
UI.setup_menus()

function Set_hp()
    for __, u in pairs(wesnoth.units.find_on_map({ side = 2 })) do u.hitpoints = 1 end
end

---CustomUnitVariables is the WML table on units used
---by this campaign
---@class CustomUnitVariables
---@field x integer
---@field y integer
---@field special_skills table<string, integer> # skill_id -> level
---@field special_skill_cd integer
---@field xp integer
---@field bloodlust boolean
---@field status_chilled_lvl integer?
---@field status_chilled_cd integer?
---@field status_shielded_hp integer?

---Typed wrapper around u.variables
---@param u unit
---@return CustomUnitVariables
function wesnoth.units.custom_variables(u) return u.variables end
