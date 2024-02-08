---------------------------------------------------------------------
----------------------------- Amlas tree ----------------------------
---------------------------------------------------------------------

local amlas_dialog = {
    -- T.row { T.column{ T.label { label = _ "These are the posible AMLAs for the unit."}}}, -- no room left
    T.row { T.column { T.image { id = "img1" } } }
}

---@param skill_table table<string, integer>
---@param unit_id string
---@return string
local function image_path(skill_table, unit_id)
    local s = "arbres/" .. unit_id .. "/layer_fond.png"
    for i, v in pairs(skill_table) do
        s = s .. string.format("~BLIT(arbres/%s/%s-%d.png)", unit_id, i, v)
    end
    return s
end

---@param u unit
---@param widget widget
local function amlas_preshow(u, widget)
    local img1 = widget:find("img1") --[[@as image]]
    local table_skill = u:skills_level()
    if filesystem.have_file("~add-ons/A_Tale_of_Sand_and_Snow/images/arbres/" ..
            u.id .. "/layer_fond.png") then
        img1.label = image_path(table_skill, u.id)
    else
        img1.label = "image_campagne.png" -- fallback
    end
    img1.visible = false
    img1.visible = true
end

---------------------------------------------------------------------
-------------------------- Special skills ---------------------------
---------------------------------------------------------------------



local LVL_0_DESC = _ "<span style='italic'>Skill not learned yet</span>"
local MAX_LVL_REACHED = _ "<span style='italic'>Max level reached </span>"

---@param lvl integer
---@param callable fun(lvl:integer):integer|integer[]
---@param description tstring
---@param str_color string
local function format_description(lvl, callable, description, str_color)
    if callable == nil then return description end
    local description = tostring(description) -- translation here
    local values = callable(lvl)
    if type(values) ~= "table" then
        values = { values }
    end

    local coloreds = {}
    for i, int_value in ipairs(values) do
        table.insert(coloreds, string.format("<span color='%s'>%d</span>",
            str_color, int_value))
    end
    return _(string.format(description, table.unpack(coloreds)))
end


local special_skills_dialog = {
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

---@param unit unit
---@param widget widget
local function special_skills_preshow(unit, widget)
    local cadre_next = widget:find("cadre_next") --[[@as label]]
    local titre_pres = widget:find("titre_pres") --[[@as label]]
    local text_xp_dispo = widget:find("text_xp_dispo") --[[@as label]]
    local text_xp_total = widget:find("text_xp_total") --[[@as label]]
    local text_pres_suiv = widget:find("text_pres_suiv") --[[@as label]]
    local help = widget:find("help") --[[@as label]]
    local lcomp = widget:find("lcomp") --[[@as listbox]]
    local lvl_up = widget:find("lvl_up") --[[@as button]]
    local help_button = widget:find("help_button") --[[@as button]]

    ---@type hero_skills
    local skills_table = Conf.special_skills[unit.id]

    -- state
    local state = {
        xp_total = unit:custom_variables().xp,
        xp_dispo = unit:custom_variables().xp,
        ---@type boolean[]
        is_skill_active = {},
        to_valid = false,
    }

    ---@param bool boolean|'hidden'
    local function affiche_pres(bool)
        cadre_next.visible = bool
        titre_pres.visible = bool
        text_pres_suiv.visible = bool
        lvl_up.visible = bool
    end

    local function on_select_skill()
        state.to_valid = false
        local i = lcomp.selected_index
        if not state.is_skill_active[i] then
            affiche_pres("hidden")
            return
        end

        affiche_pres(false)

        ---@type special_skill_config
        local comp = skills_table[i]
        local lvl = unit:custom_variables().special_skills[comp.name] or 0
        if lvl == comp.max_lvl then
            text_pres_suiv.label = MAX_LVL_REACHED
            titre_pres.label = ""
            lvl_up.label = ""
            affiche_pres(true)
            lvl_up.visible = false
            lvl_up.enabled = false
        elseif unit.level < comp.require_lvl then
            lvl_up.enabled = false
        else
            lvl_up.enabled = true
            titre_pres.marked_up_text = _ "<span style='italic' color ='#BFA63F'>Next level : </span>"

            local formatted_desc = format_description(lvl + 1,
                skills_table[comp.name],
                comp.desc, comp.color)
            text_pres_suiv.marked_up_text = formatted_desc
            if state.xp_dispo >= comp.costs[lvl + 1] then
                lvl_up.label = _ "Level up : " .. comp.costs[lvl + 1] .. " points"
            else
                lvl_up.label = _ "Points needed : " .. comp.costs[lvl + 1]
                lvl_up.enabled = false
            end
            affiche_pres(true)
        end
    end


    local function special_skills_reset()
        affiche_pres("hidden")
        lvl_up.enabled = false

        unit.level = unit.level
        state.xp_total = unit:custom_variables().xp
        state.xp_dispo = unit:custom_variables().xp
        state.select_functions = {}
        state.to_valid = false

        -- reset skill list
        lcomp:remove_items_at(1, #(skills_table))

        -- ecriture de la liste des competences et mise à jour de l'xp
        for i, v in ipairs(skills_table) do
            local text_comp = lcomp:find(i, "text_comp") --[[@as label]]
            local img_comp = lcomp:find(i, "img_comp") --[[@as image]]
            local img_lvl = lcomp:find(i, "img_lvl") --[[@as image]]

            local max_lvl = v["max_lvl"]
            local lvl = unit:custom_variables().special_skills[v.name] or 0
            for j = 1, lvl, 1 do
                state.xp_dispo = state.xp_dispo - v.costs[j]
            end
            if unit.level >= v.require_lvl then
                if not v.require_avancement or
                    (unit:skills_level()[v.require_avancement.id] ~= nil) then
                    local formatted_title =
                        string.format("<span color='%s'>%s</span>", v.color, v.name_aff)
                    local formatted_desc = lvl == 0
                        and LVL_0_DESC
                        or format_description(lvl, skills_table[v.name],
                            v.desc, v.color)
                    text_comp.marked_up_text = formatted_title .. "\n" .. formatted_desc
                    img_comp.label = v.img
                    img_lvl.label = "special_skills/" .. max_lvl .. "-" .. lvl .. ".png"
                    state.is_skill_active[i] = true
                else
                    text_comp.marked_up_text = _ "<span style='italic'>" .. v.require_avancement.des ..
                        "</span>"
                    img_comp.label = v.img
                    state.is_skill_active[i] = false
                end
            else
                text_comp.marked_up_text = _ "<span style='italic'>Require level " .. v.require_lvl ..
                    "</span>"
                img_comp.label = v.img
                state.is_skill_active[i] = false
            end
        end

        -- show xp amount
        text_xp_dispo.marked_up_text = _ " <span font_style='italic' ><span color ='#BFA63F'  >Available points  :  </span><span font_weight ='bold' >" ..
            state.xp_dispo .. "</span></span>"
        text_xp_total.marked_up_text = _ " <span font_style='italic'  color ='#BFA63F'  >Total points:  " ..
            state.xp_total .. "</span>"
    end

    local function show_help()
        if UI.skills_help then
            help.visible = false
            help.visible = true
            help.marked_up_text = skills_table.help_des ..
                "\n<span style='italic'>" ..
                skills_table.help_ratios ..
                "</span>"
            help_button.label = _ "Hide info"
            UI.skills_help = false
        else
            help.visible = false
            help.label = ""
            help_button.label = _ "Show info"
            UI.skills_help = true
        end
    end

    local function select_lvlup()
        if state.to_valid then
            local i = lcomp.selected_index
            local comp = skills_table[i]
            local ss = unit:custom_variables().special_skills
            local newlvl = (ss[comp.name] or 0) + 1
            ss[comp.name] = newlvl
            unit:custom_variables().special_skills = ss
            SPECIAL_SKILLS[comp.name](newlvl, unit)
            AMLA.update_lvl(unit)  -- needed not to loose extras LVL, removed by u:remove_modifications
            special_skills_reset() -- reset graphics
        else
            lvl_up.label = _ "Confirm ?"
            state.to_valid = true
        end
    end

    help_button.on_button_click = show_help
    lcomp.on_modified = on_select_skill
    lvl_up.on_button_click = select_lvlup

    special_skills_reset()
end



-- SKILLS dialog (wrapper around special skills and amla tree)
local dialog = {
    automatic_placement = true,
    vertical_placement = "center",
    horizontal_placement = "center",
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
                    { "layer", amlas_dialog },
                    { "layer", special_skills_dialog },
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

---@param window window
local function preshow(window)
    local unit = PrimaryUnit()

    local titre = window:find("titre") --[[@as label]]
    local tabs = window:find("tabs") --[[@as listbox]]
    local pages = window:find("pages") --[[@as stacked_widget]]
    local cache = window:find("cache") --[[@as label]]

    UI.skills_help = true
    titre.marked_up_text =
        _ "<span font_size = 'large' font_weight ='bold' ><span  color ='#BFA63F' >Skills of your unit </span>" ..
        unit.name .. "</span>"

    local onglet1 = tabs:find(1, "onglet") --[[@as label]]
    local onglet2 = tabs:find(2, "onglet") --[[@as label]]
    onglet1.label = _ "Advancements"
    onglet2.label = _ "Special skills"

    local content1 = pages:find(1) --[[@as widget]]
    local content2 = pages:find(2) --[[@as widget]]


    local function onTab()
        local i = tabs.selected_index
        pages.selected_index = i
        if i == 1 then --advancements
            if unit.__cfg.advances_to == "" then
                amlas_preshow(unit, content1)
            else
                pages.selected_index = 3
                cache.label = unit.name .. _ " has yet to reach its maximum level..."
                cache.visible = false
                cache.visible = true
            end
        else --special_skills
            if Conf.special_skills[unit.id] then
                if unit.__cfg.advances_to == "" then
                    special_skills_preshow(unit, content2)
                else
                    pages.selected_index = 3
                    cache.label =
                        _ "It's a bit early to show you the amazing skills " .. unit.name .. " will get..."
                    cache.visible = false
                    cache.visible = true
                end
            else
                pages.selected_index = 3
                cache.label =
                    _ "Sadly, " .. unit.name .. " won't get specials skills in this campaign..."
                cache.visible = false
                cache.visible = true
            end
        end
    end

    tabs.on_modified = onTab

    -- starts with amlas tree
    pages.selected_index = 1
    amlas_preshow(unit, content1)


    onTab()
end


local function show_skills()
    gui.show_dialog(dialog, preshow)
end

return show_skills
