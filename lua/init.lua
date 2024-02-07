-- Load all the lua modules (excepted Scenario)
-- H = wesnoth.require "lua/helper.lua"
T = wml.tag
VAR = wml.variables
_ = wesnoth.textdomain "wesnoth-A_Tale_of_Sand_and_Snow"

---CustomGlobalVariables is a WML table storing
---variables used by this campaing
---@class CustomGlobalVariables
---@field showed_menus table<string, boolean>
---@field table_status any
---@field table_status_shielded any
---@field player_objects table<string,string> # object -> owner
---@field heros_joueur string # comma separated

---InitVariables creates global variables.
---It should be called once at campaign startup
---or in test scenario, but not when loading lua code,
---since it would overwrite existing ones.
function InitVariables()
    ---@type CustomGlobalVariables
    local vars = wml.variables_proxy
    vars.showed_menus = {}
    vars.table_status = {}
    vars.table_status_shielded = {}
    vars.player_objects = {}
    vars.heros_joueur = "brinx"
end

---Variables is are typed wrapper for wml.variables
---@return CustomGlobalVariables
function Variables() return wml.variables end

wesnoth.require "helpers"
wesnoth.require "helpers_events"
wesnoth.require "animations"
wesnoth.require "config/config"

wesnoth.require "limbes"

wesnoth.require "implementation/ability"
wesnoth.require "implementation/special_exp_gain"
wesnoth.require "implementation/event_combat"
wesnoth.require "implementation/amla"
wesnoth.require "implementation/special_skills"

wesnoth.require "ui/custom_themes"
wesnoth.require "ui/objects"
wesnoth.require "ui/menus"
wesnoth.require "standard_event" -- event setup

function Set_hp()
    for _, u in pairs(wesnoth.units.find_on_map({ side = 2 })) do u.hitpoints = 1 end
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
