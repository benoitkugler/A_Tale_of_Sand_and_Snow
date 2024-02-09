UI = {}

UI.show_skills_dialog = wesnoth.require("skills")

--- Remove the item with the given id
---@param id string
function UI.clear_menu_item(id)
    local menus = CustomVariables().showed_menus
    if menus[id] then
        wml.fire("clear_menu_item", { id = id })
        menus[id] = nil
    end
end

---@class menu_config
---@field id string
---@field description tstring
---@field image string?
---@field [integer] WMLTag

---@param config menu_config
---@param action fun()
local function set_menu_item(config, action)
    wml.fire("set_menu_item", config)
    wesnoth.game_events.add({ name = "menu item " .. config.id, action = action })
    -- keep in memory which menu are shown to avoid warnings
    CustomVariables().showed_menus[config.id] = true
end

local function set_menu_item_at(id, desc, image, x, y, action)
    set_menu_item({
        id = id,
        description = desc,
        image = image,
        T.show_if {
            T.have_location { x = "$x1", y = "$y1", { "and", { x = x, y = y } } }
        },
    }, action)
end

-- TODO: Better icon
---@param x integer
---@param y integer
---@param action fun()
function UI.setup_menu_debuf(x, y, action)
    set_menu_item_at("union_debuf", _ "Xavier's union debuf !",
        "menu/union_debuf.png", x, y, action)
end

---@param x integer
---@param y integer
---@param action fun()
function UI.setup_menu_war_jump(x, y, action)
    set_menu_item_at("war_jump", _ "War jump here with Gondhül !",
        "menu/war_jump.png", x, y, action)
end

---@param x integer
---@param y integer
---@param action fun()
function UI.setup_menu_elusive(x, y, action)
    set_menu_item_at("elusive", _ "Sneak here with Bunshop !", "menu/ellusive.png", x,
        y, action)
end

-- Setup menu needed by abilities with cooldown
local MENUS_SPECIAL_SKILLS = {
    vranken = { _ "Transposition", AB.transposition }
}
function UI.turn_start()
    for unit_id, datas in pairs(MENUS_SPECIAL_SKILLS) do
        local label, action = datas[1], datas[2]
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
                }, action)
            end
        end
    end
end

function UI.set_menu_skills()
    set_menu_item({
        id = "show_skills",
        description = _ "Skills",
        T.show_if { T.have_unit { x = "$x1", y = "$y1", role = "hero" } },
        T.default_hotkey { key = "s", shift = true }
    }, UI.show_skills_dialog)
end

function UI.setup_menus()
    UI.set_menu_skills()

    set_menu_item({
        id = "objets",
        description = _ "Objects",
    }, O.showObjectsDialog)
end
