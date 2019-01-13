UI = {}

UI.show_skills = wesnoth.require("skills/init")

function UI.setup_menu_debuf(x, y, lua_code)
    wesnoth.fire(
        "set_menu_item",
        {
            id = "union_debuf",
            description = _ "Xavier's union debuf !",
            image = "menu/ellusive.png",
            T.show_if {
                T.have_location {
                    x = "$x1",
                    y = "$y1",
                    {"and", {x = x, y = y}}
                }
            },
            T.command {T.lua {code = lua_code}}
        }
    )
end



function UI.setup_menus()
    -- Setup of menus items
    wesnoth.fire(
        "set_menu_item",
        {
            id = "special_skills",
            description = _ "Special Ability",
            T.show_if {T.have_unit {x = "$x1", y = "$y1", T.filter_wml {T.variables {special_skills = true}}}},
            T.command {T.lua {code = "CS.special_skills()"}}
        }
    )

    wesnoth.fire(
        "set_menu_item",
        {
            id = "show_skills",
            description = _ "Skills",
            T.show_if {T.have_unit {x = "$x1", y = "$y1", role = "hero"}},
            T.command {T.lua {code = "UI.show_skills()"}},
            T.default_hotkey { key = "s", shift = true}

        }
    )

    wesnoth.fire(
        "set_menu_item",
        {
            id = "objets",
            description = _ "Objects",
            T.command {T.lua {code = "O.menuObj()"}}
        }
    )
end



--MENU MOUVEMENT INVOQUÉ PAR LES ABILITIES ELUSIVE ET WAR JUMP
local function isIn(l, x, y)
    local bo = false
    local mv = 0
    for i, v in pairs(l) do
        if (v[1] == x and v[2] == y) then
            bo = true
            mv = v[3]
        end
    end
    return bo, mv
end

function UI.war_jump(id, x, y)
    local u = wesnoth.get_units {id = id}[1]
    local tox, toy = get_loc()
    if u == nil then
        popup(
            _ "Error",
            _ "This unit can't <span color='red'>War Jump </span> now. Please <span weight='bold'>select</span> it again."
        )
    else
        local loc = wesnoth.find_reach(u, {ignore_units = true})
        local b, moves_left = isIn(loc, tox, toy)
        if u.x ~= x or u.y ~= y or not has_ab(u, "war_jump") or not b or not is_empty(tox, toy) then
            popup(
                _ "Error",
                _ "" ..
                    tostring(u.name) ..
                        " can't <span color='red'>War Jump </span> right now. Please <span weight='bold'>select</span> it again."
            )
        else
            wesnoth.fire("teleport", {{"filter", {id = id}}, x = tox, y = toy, animate = true})
            u.moves = 0
        end
    end
    wesnoth.fire("clear_menu_item", {id = "movement"})
end

function UI.elusive(id, x, y)
    local u = wesnoth.get_units {id = id}[1]
    local tox, toy = get_loc()

    if u == nil then
        popup(
            _ "Error",
            _ "This unit can't be <span color='green'>Elusive</span> right now. Please <span weight='bold'>select</span> it again."
        )
    else
        local loc = wesnoth.find_reach(u, {ignore_units = true})
        local b, moves_left = isIn(loc, tox, toy)

        if u.x ~= x or u.y ~= y or not has_ab(u, "elusive") or not b or not is_empty(tox, toy) then
            popup(
                _ "Error",
                _ "" ..
                    tostring(u.name) ..
                        "  can't be <span color='green'>Elusive</span> right now. Please <span weight='bold'>select</span> it again."
            )
        else
            wesnoth.fire("move_unit", {id = id, to_x = tox, to_y = toy, fire_event = true})
            u.moves = moves_left
        end
    end
    wesnoth.fire("clear_menu_item", {id = "movement"})
end



