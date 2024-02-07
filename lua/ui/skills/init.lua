local amla_tree = wesnoth.require("~add-ons/A_Tale_of_Sand_and_Snow/lua/ui/skills/amlas")
local special_skills = wesnoth.require("~add-ons/A_Tale_of_Sand_and_Snow/lua/ui/skills/special_skills")

-- SKILLS dialog (wrapper around special skills and amla tree)
local dialog = {
    T.tooltip { id = "tooltip_large" },
    T.helptip { id = "tooltip_large" },
    T.grid {
        T.row { T.column { T.label { id = "titre" } } },
        T.row { T.column { T.spacer { height = 10 } } },
        T.row {
            T.column {
                T.horizontal_listbox {
                    id = "tabs",
                    T.list_definition {
                        T.row {
                            T.column {
                                horizontal_grow = true,
                                T.toggle_panel {
                                    T.grid {
                                        T.row {
                                            T.column {
                                                border = "all",
                                                border_size = 15,
                                                T.label { id = "onglet" }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        },
        T.row { T.column { T.spacer { height = 10 } } },
        T.row {
            T.column {
                T.stacked_widget {
                    id = "pages",
                    { "layer", amla_tree.dialog },
                    { "layer", special_skills.dialog },
                    T.layer {
                        T.row {
                            T.column {
                                T.label { id = "cache" }
                            }
                        }
                    }
                }
            }
        },
        T.row { T.column { T.button { id = "ok", label = _ "Return" } } }
    }
}

local function preshow(unit)
    UI.skills_help = true
    wesnoth.set_dialog_markup(true, "titre")
    wesnoth.set_dialog_value(
        _ "<span font_size = 'large' font_weight ='bold' ><span  color ='#BFA63F' >Skills of your unit </span>" ..
        unit.name .. "</span>",
        "titre"
    )

    wesnoth.set_dialog_value(_ "Advancements", "tabs", 1, "onglet")
    wesnoth.set_dialog_value(_ "Special skills", "tabs", 2, "onglet")

    wesnoth.set_dialog_value(2, "pages")
    special_skills.preshow(unit)

    local function onTab()
        local i = wesnoth.get_dialog_value("tabs")
        wesnoth.set_dialog_value(i, "pages")
        if i == 1 then
            special_skills.postshow()
            if unit.__cfg.advances_to == "" then
                amla_tree.preshow(unit)
            else
                wesnoth.set_dialog_value(3, "pages")
                wesnoth.set_dialog_value(unit.name .. _ " has yet to reach its maximum level...", "cache")
                wesnoth.set_dialog_visible(false, "cache")
                wesnoth.set_dialog_visible(true, "cache")
            end
        else
            if Conf.special_skills[unit.id] then
                if unit.__cfg.advances_to == "" then
                    special_skills.init()
                else
                    wesnoth.set_dialog_value(3, "pages")
                    wesnoth.set_dialog_value(
                        _ "It's a bit early to show you the amazing skills " .. unit.name .. " will get...",
                        "cache"
                    )
                    wesnoth.set_dialog_visible(false, "cache")
                    wesnoth.set_dialog_visible(true, "cache")
                end
            else
                wesnoth.set_dialog_value(3, "pages")
                wesnoth.set_dialog_value(
                    _ "Sadly, " .. unit.name .. " won't get specials skills in this campaign...",
                    "cache"
                )
                wesnoth.set_dialog_visible(false, "cache")
                wesnoth.set_dialog_visible(true, "cache")
            end
        end
    end
    wesnoth.set_dialog_callback(onTab, "tabs")

    onTab()
end


local function show_skills()
    local u = PrimaryUnit()
    wesnoth.show_dialog(
        dialog,
        function() preshow(u) end
    )
end
return show_skills
