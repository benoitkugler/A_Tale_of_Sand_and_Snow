local MCS = {}

local LVL_0_DESC = _ "<span style='italic'>Skill not learned yet</span>"
local MAX_LVL_REACHED = _ "<span style='italic'>Max level reached </span>"

local function format_description(lvl, callable, description, str_color)
    if callable == nil then return description end
    local description = tostring(description) -- translation here
    local value = callable(lvl)
    if type(value) == "table" then
        local coloreds = {}
        for i, v in ipairs(value) do
            table.insert(coloreds, string.format("<span color='%s'>%d</span>",
                str_color, v))
        end
        return string.format(description, table.unpack(coloreds))
    else
        local colored = string.format("<span color='%s'>%d</span>", str_color,
            value)
        return string.format(description, colored)
    end
end

-- Gestion du menu
function MCS.postshow()
    MCS.u_lvl = nil
    MCS.skills_table = nil
    MCS.xp_total = nil
    MCS.xp_dispo = nil
    MCS.select_functions = nil
    MCS.to_valid = nil
end

MCS.dialog = {
    T.row {
        T.column {
            T.panel {
                definition = "story_viewer_panel",
                T.grid {
                    T.row { T.column { T.spacer { height = 10 } } }, T.row {
                    T.column {
                        border = "left,right",
                        border_size = 20,
                        T.grid {
                            T.row {
                                T.column {
                                    T.label {
                                        id = "text_xp_dispo",
                                        label = "test7789"
                                    }
                                }, T.column { T.spacer { width = 15 } },
                                T.column { T.label { id = "text_xp_total" } },
                                T.column { T.spacer { width = 15 } },
                                T.column {
                                    T.button {
                                        id = "help_button",
                                        label = _ "Show info"
                                    }
                                }
                            }
                        }
                    }
                }, T.row { T.column { T.spacer { height = 7 } } }, T.row {
                    T.column {
                        border = "left,right",
                        border_size = 10,
                        T.label { id = "help", characters_per_line = 80 }
                    }
                }, T.row { T.column { T.spacer { height = 7 } } }
                }
            }
        }
    }, T.row {
    T.column {
        border = "all",
        border_size = 10,
        T.grid {
            T.row {
                T.column {
                    T.panel {
                        definition = "box_display",
                        id = "cadre_next",
                        T.grid {
                            T.row { T.column { T.label { id = "titre_pres" } } },
                            T.row { T.column { T.spacer { height = 7 } } },
                            T.row {
                                T.column {
                                    T.label {
                                        id = "text_pres_suiv",
                                        characters_per_line = 35
                                    }
                                }
                            }, T.row { T.column { T.spacer { height = 7 } } },
                            T.row {
                                T.column {
                                    T.button {
                                        id = "lvl_up",
                                        label = _ "Level up skill"
                                    }
                                }
                            }
                        }
                    }
                }, T.column { T.spacer { width = 7 } }, T.column {
                T.listbox {
                    id = "lcomp",
                    T.list_definition {
                        T.row {
                            T.column {
                                horizontal_grow = true,
                                border = "all",
                                border_size = 5,
                                T.toggle_panel {
                                    T.grid {
                                        T.row {
                                            T.column {
                                                border = "all",
                                                border_size = 5,
                                                T.image { id = "img_comp" }
                                            },
                                            T.column {
                                                border = "right",
                                                border_size = 5,
                                                T.image { id = "img_lvl" }
                                            }, T.column {
                                            grow_factor = 1,
                                            horizontal_grow = true,
                                            T.label {
                                                id = "text_comp",
                                                characters_per_line = 50
                                            }
                                        }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            }
        }
    }
}
}

function MCS.preshow(unit)
    local function affiche_pres(bool)
        wesnoth.set_dialog_visible(bool, "cadre_next")
        wesnoth.set_dialog_visible(bool, "titre_pres")
        wesnoth.set_dialog_visible(bool, "text_pres_suiv")
        wesnoth.set_dialog_visible(bool, "lvl_up")
    end

    local function active_selectl(i)
        affiche_pres(false)

        local comp = MCS.skills_table[i]
        local lvl = unit.variables.special_skills[comp["name"]] or 0
        if lvl == comp.max_lvl then
            wesnoth.set_dialog_value(MAX_LVL_REACHED, "text_pres_suiv")
            wesnoth.set_dialog_value("", "titre_pres")
            wesnoth.set_dialog_value("", "lvl_up")
            affiche_pres(true)
            wesnoth.set_dialog_visible(false, "lvl_up")
            wesnoth.set_dialog_active(false, "lvl_up")
        elseif MCS.u_lvl < comp.require_lvl then
            wesnoth.set_dialog_active(false, "lvl_up")
        else
            wesnoth.set_dialog_active(true, "lvl_up")
            wesnoth.set_dialog_value(
                _ "<span style='italic' color ='#BFA63F'>Next level : </span>",
                "titre_pres")
            local formatted_desc = format_description(lvl + 1,
                MCS.skills_table[comp["name"]],
                comp.desc, comp.color)
            wesnoth.set_dialog_value(formatted_desc, "text_pres_suiv")
            if MCS.xp_dispo >= comp.costs[lvl + 1] then
                wesnoth.set_dialog_value(
                    _ "Level up : " .. comp.costs[lvl + 1] .. " points",
                    "lvl_up")
            else
                wesnoth.set_dialog_value(
                    _ "Points needed : " .. comp.costs[lvl + 1], "lvl_up")
                wesnoth.set_dialog_active(false, "lvl_up")
            end
            affiche_pres(true)
        end
    end

    local function non_active_selectl(i) affiche_pres("hidden") end

    function MCS.init()
        wesnoth.set_dialog_markup(true, "text_xp_dispo")
        wesnoth.set_dialog_markup(true, "text_xp_total")
        wesnoth.set_dialog_markup(true, "titre_pres")
        wesnoth.set_dialog_markup(true, "text_pres_suiv")
        wesnoth.set_dialog_markup(true, "help")

        affiche_pres("hidden")
        wesnoth.set_dialog_active(false, "lvl_up")

        MCS.u_lvl = unit.level
        MCS.skills_table = Conf.special_skills[unit.id]
        MCS.xp_total = unit.variables.xp
        MCS.xp_dispo = unit.variables.xp

        MCS.select_functions = {}

        MCS.to_valid = false

        --         suppression des items de la liste des competences
        wesnoth.remove_dialog_item(1, #(MCS.skills_table), "lcomp")

        --         ecriture de la liste des competences et mise à jour de l'xp
        for i, v in ipairs(MCS.skills_table) do
            local max_lvl = v["max_lvl"]
            local lvl = unit.variables.special_skills[v["name"]] or 0
            for j = 1, lvl, 1 do
                MCS.xp_dispo = MCS.xp_dispo - v.costs[j]
            end
            if MCS.u_lvl >= v.require_lvl then
                if not v.require_avancement or
                    (TableSkills(unit)[v.require_avancement.id] ~= nil) then
                    local formatted_title =
                        string.format("<span color='%s'>%s</span>", v.color,
                            v.name_aff)
                    local formatted_desc
                    if lvl == 0 then
                        formatted_desc = LVL_0_DESC
                    else
                        formatted_desc =
                            format_description(lvl, MCS.skills_table[v.name],
                                v.desc, v.color)
                    end
                    wesnoth.set_dialog_value(
                        formatted_title .. "\n" .. formatted_desc, "lcomp", i,
                        "text_comp")
                    wesnoth.set_dialog_value(v.img, "lcomp", i, "img_comp")
                    wesnoth.set_dialog_value(
                        "special_skills/" .. max_lvl .. "-" .. lvl .. ".png",
                        "lcomp", i, "img_lvl")
                    MCS.select_functions[i] = active_selectl
                else
                    wesnoth.set_dialog_value(
                        "<span style='italic'>" .. v.require_avancement.des ..
                        "</span>", "lcomp", i, "text_comp")
                    wesnoth.set_dialog_value(v.img, "lcomp", i, "img_comp")
                    MCS.select_functions[i] = non_active_selectl
                end
            else
                wesnoth.set_dialog_value(
                    _ "<span style='italic'>Require level " .. v.require_lvl ..
                    "</span>", "lcomp", i, "text_comp")
                wesnoth.set_dialog_value(v.img, "lcomp", i, "img_comp")
                MCS.select_functions[i] = non_active_selectl
            end
            wesnoth.set_dialog_markup(true, "lcomp", i, "text_comp")
        end

        --        affichage de l'xp
        wesnoth.set_dialog_value(
            _ " <span font_style='italic' ><span color ='#BFA63F'  >Points available :  </span><span font_weight ='bold' >" ..
            MCS.xp_dispo .. "</span></span>", "text_xp_dispo")
        wesnoth.set_dialog_value(
            _ " <span font_style='italic'  color ='#BFA63F'  >Total points:  " ..
            MCS.xp_total .. "</span>", "text_xp_total")
    end

    local function selectl()
        MCS.to_valid = false
        local i = wesnoth.get_dialog_value("lcomp")
        MCS.select_functions[i](i)
    end

    local function show_help()
        if UI.skills_help then
            wesnoth.set_dialog_visible(false, "help")
            wesnoth.set_dialog_visible(true, "help")

            wesnoth.set_dialog_value(MCS.skills_table.help_des ..
                "\n<span style='italic'>" ..
                MCS.skills_table.help_ratios ..
                "</span>", "help")
            wesnoth.set_dialog_value(_ "Hide info", "help_button")
            UI.skills_help = false
        else
            wesnoth.set_dialog_visible(false, "help")
            wesnoth.set_dialog_value("", "help")
            UI.skills_help = true
            wesnoth.set_dialog_value(_ "Show info", "help_button")
        end
    end

    local function select_lvlup()
        if MCS.to_valid then
            local i = wesnoth.get_dialog_value("lcomp")
            local comp = MCS.skills_table[i]
            local ss = unit.variables.special_skills
            local newlvl = (ss[comp.name] or 0) + 1
            ss[comp.name] = newlvl
            unit.variables.special_skills = ss
            SPECIAL_SKILLS[comp.name](newlvl, unit)
            AMLA.update_lvl(unit) -- needed not to loose extras LVL, removed by u:remove_modifications
            MCS.init()            -- reset graphics
        else
            wesnoth.set_dialog_value(_ "Confirm ?", "lvl_up")
            MCS.to_valid = true
        end
    end

    wesnoth.set_dialog_callback(show_help, "help_button")
    wesnoth.set_dialog_callback(selectl, "lcomp")
    wesnoth.set_dialog_callback(select_lvlup, "lvl_up")
end

return MCS
