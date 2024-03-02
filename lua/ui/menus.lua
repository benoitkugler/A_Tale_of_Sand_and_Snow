UI = {}


--- Remove the item with the given id
---@param id string
function UI.clear_menu_item(id)
    local menus = CustomVariables().showed_menus
    if menus[id] then
        wml.fire("clear_menu_item", { id = id })
        menus[id] = nil
    end
    CustomVariables().showed_menus = menus
end

---@class menu_config
---@field id string
---@field description tstring
---@field image string?
---@field [integer] WMLTag

---@param config menu_config
local function set_menu_item(config)
    wml.fire("set_menu_item", config)
    -- keep in memory which menu are shown to avoid warnings when removing twice
    local menus = CustomVariables().showed_menus or {}
    menus[config.id] = true
    CustomVariables().showed_menus = menus
end

---@param id string
---@param desc tstring
---@param image string?
---@param x integer|integer[]
---@param y integer|integer[]
local function set_menu_item_at(id, desc, image, x, y)
    set_menu_item({
        id = id,
        description = desc,
        image = image,
        T.show_if {
            T.have_location { x = "$x1", y = "$y1", { "and", { x = x, y = y } } }
        },
    })
end

-- TODO: Better icon
---@param x integer
---@param y integer
function UI.setup_menu_debuf(x, y)
    set_menu_item_at("union_debuf", _ "Xavier's union debuf !", "menu/union_debuf.png", x, y)
end

---@param x integer[]
---@param y integer[]
function UI.setup_menu_war_jump(x, y)
    set_menu_item_at("war_jump", _ "War jump here with Gondhül !", "menu/war_jump.png", x, y)
end

---@param x integer[]
---@param y integer[]
function UI.setup_menu_elusive(x, y)
    set_menu_item_at("elusive", _ "Sneak here with Mark !", "menu/ellusive.png", x, y)
end

-- Setup menu needed by abilities with cooldown
local MENUS_SPECIAL_SKILLS = {
    vranken = { _ "Transposition", AB.transposition }
}

function UI.refresh_special_skills_menu()
    for unit_id, datas in pairs(MENUS_SPECIAL_SKILLS) do
        local label = datas[1]
        local id_menu = unit_id .. "_special_skill"
        UI.clear_menu_item(id_menu)

        local hero = wesnoth.units.get(unit_id)
        if hero then
            local cd = hero:custom_variables().special_skill_cd
            if cd and cd == 0 then
                set_menu_item({
                    id = id_menu,
                    description = label,
                    T.show_if { T.have_unit { x = "$x1", y = "$y1", id = unit_id } },
                })
            end
        end
    end
end

function UI.turn_start()
    UI.refresh_special_skills_menu()
end

function UI.set_menu_skills()
    set_menu_item({
        id = "show_skills",
        description = _ "Skills",
        T.show_if { T.have_unit { x = "$x1", y = "$y1", role = "hero" } },
        T.default_hotkey { key = "s", shift = true }
    })
end

local show_skills_dialog = wesnoth.require("skills")
local show_objects_dialog = wesnoth.require("inventory")

function UI.setup_menus()
    UI.set_menu_skills()

    set_menu_item({ id = "objects", description = _ "Objects" })

    -- display the limbes access on morgane
    set_menu_item({
        id = "enter_limbes",
        description = _ "Enter the Limbes",
        T.show_if {
            T.have_unit { x = "$x1", y = "$y1", id = "morgane", { "not", { status = "_limbe" } } },
            T.have_unit { role = "otchigin" },
        },
    })

    -- register all possible events triggered by menu items
    wesnoth.game_events.add({ name = "menu item objects", first_time_only = false, action = show_objects_dialog })
    wesnoth.game_events.add({ name = "menu item show_skills", first_time_only = false, action = show_skills_dialog })

    wesnoth.game_events.add({ name = "menu item enter_limbes", first_time_only = false, action = Limbes.enter })

    wesnoth.game_events.add({ name = "menu item elusive", first_time_only = false, action = AB.elusive })
    wesnoth.game_events.add({ name = "menu item war_jump", first_time_only = false, action = AB.war_jump })
    wesnoth.game_events.add({ name = "menu item union_debuf", first_time_only = false, action = AB.union_debuf })

    for unit_id, datas in pairs(MENUS_SPECIAL_SKILLS) do
        local action = datas[2]
        local id_menu = unit_id .. "_special_skill"
        wesnoth.game_events.add({ name = "menu item " .. id_menu, first_time_only = false, action = action })
    end
end
