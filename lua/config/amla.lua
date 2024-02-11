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

Conf.amlas = {}
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/brinx.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/drumar.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/vranken.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/xavier.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/morgane.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/sword_spirit.lua"
wesnoth.dofile "~add-ons/A_Tale_of_Sand_and_Snow/lua/config/trees/mark.lua"
