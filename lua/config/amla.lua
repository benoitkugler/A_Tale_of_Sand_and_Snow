-- Load amlas tree defined in trees/
-- Each amla may have function as effect, which will be called with current unit as argument
-- Each amla may have _level_bonus boolean raising by 1 the lvl of the unit
-- Each amla should define a _short_desc string field (where dot formatting is allowed).
-- This string will be the title of the matching node in the graph displayed in game.


---shortcut to avoid boilerplate code in trees
---@param exp integer
---@param hp integer?
---@return WMLTag[]
function StandardAmlaHeal(exp, hp)
    hp = hp or 2
    return {
        T.effect { increase = tostring(exp) .. "%", apply_to = "max_experience" },
        T.effect { remove = "poisoned", apply_to = "status" },
        T.effect { remove = "slowed", apply_to = "status" },
        T.effect { apply_to = "hitpoints", increase_total = hp, heal_full = true }
    }
end

---@class custom_amla
---@field [string] any
---@field [integer] WMLTag|fun(u:unit):WMLTag -- effects

---@class hero_amla_tree
---@field _default_border string
---@field _default_background string
---@field [integer] custom_amla

---@type table<Hero, hero_amla_tree>
Conf.amlas = {}

wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/brinx.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/drumar.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/vranken.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/xavier.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/morgane.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/sword_spirit.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/mark.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/porthos.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/bunshop.lua"
