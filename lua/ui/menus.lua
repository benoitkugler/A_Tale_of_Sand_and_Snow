UI = {}

UI.show_skills = wesnoth.require("skills/init")

-- data is the menu table.
-- keep in memory which menu are shown to avoid warnings
---@param data WMLTable
function UI.set_menu_item(data)
    wml.fire("set_menu_item", data)
    Variables().showed_menus[data.id] = true
end

--- Remove the item with the given id
---@param id string
function UI.clear_menu_item(id)
    local menus = Variables().showed_menus
    if menus[id] then
        wml.fire("clear_menu_item", { id = id })
        menus[id] = nil
    end
end

local function _set_menu_item(id, desc, image, x, y, lua_code)
    UI.set_menu_item({
        id = id,
        description = desc,
        image = image,
        T.show_if {
            T.have_location { x = "$x1", y = "$y1", { "and", { x = x, y = y } } }
        },
        T.command { T.lua { code = lua_code } }
    })
end

-- TODO: Better icon
function UI.setup_menu_debuf(x, y, lua_code)
    _set_menu_item("union_debuf", _ "Xavier's union debuf !",
        "menu/union_debuf.png", x, y, lua_code)
end

function UI.setup_menu_warjump(x, y, lua_code)
    _set_menu_item("warjump", _ "War jump here with Gondhül !",
        "menu/war_jump.png", x, y, lua_code)
end

function UI.setup_menu_elusive(x, y, lua_code)
    _set_menu_item("elusive", _ "Sneak here with Brinx", "menu/ellusive.png", x,
        y, lua_code)
end

-- Setup menu needed by abilities with cooldown
local MENUS_SPECIAL_SKILLS = {
    vranken = { _ "Transposition", "AB.transposition()" }
}
function UI.turn_start()
    for unit_id, datas in pairs(MENUS_SPECIAL_SKILLS) do
        local label, lua_code = datas[1], datas[2]
        local id_menu = unit_id .. "_special_skill"
        UI.clear_menu_item(id_menu)

        local hero = wesnoth.units.get(unit_id)
        if hero then
            local cd = hero.variables.special_skill_cd
            if cd and cd == 0 then
                UI.set_menu_item({
                    id = id_menu,
                    description = label,
                    T.show_if { T.have_unit { x = "$x1", y = "$y1", id = unit_id } },
                    T.command { T.lua { code = lua_code } }
                })
            end
        end
    end
end

function UI.set_menu_skills()
    UI.set_menu_item({
        id = "show_skills",
        description = _ "Skills",
        T.show_if { T.have_unit { x = "$x1", y = "$y1", role = "hero" } },
        T.command { T.lua { code = "UI.show_skills()" } },
        T.default_hotkey { key = "s", shift = true }
    })
end

function UI.setup_menus()
    wesnoth.log('info', "OGT IT", true)
    -- Setup of menus items
    UI.set_menu_item({
        id = "special_skills",
        description = _ "Special Ability",
        T.show_if {
            T.have_unit {
                x = "$x1",
                y = "$y1",
                T.filter_wml { T.variables { special_skills = true } }
            }
        },
        T.command { T.lua { code = "CS.special_skills()" } }
    })

    UI.set_menu_skills()

    UI.set_menu_item({
        id = "objets",
        description = _ "Objects",
        T.command { T.lua { code = "O.showObjectsDialog()" } }
    })
end
