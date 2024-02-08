-- Menu Object and function to add and remove objects


-- TODO: Refactor (using Conf.objects)
-- Librairie Objets



-- object swap


-- Remove effect of given objet, and set its owner to ""
---@param unit_id string
---@param object_id string
local function remove(unit_id, object_id)
    local u = wesnoth.units.get(unit_id)

    u:remove_modifications({ id = object_id }, "object")
    u:remove_modifications({ id = object_id }, "trait")
    AMLA.update_lvl(u) -- remove_modification may delete extra lvls

    local m = CustomVariables().player_objects
    m[object_id] = ""
    CustomVariables().player_objects = m
end

-- Apply an object to the given unit (unit modification and owner)
---@param unit_id string
---@param object_id string
local function apply(unit_id, object_id)
    local u = wesnoth.units.get(unit_id)
    local obj = Conf.objects[object_id]
    local modif_object = {
        id = object_id,
        { "effect", obj.effect }
    }

    local modif_trait = {
        id = object_id,
        name = obj.name,
        description = obj.description,
        { "effect", {} }
    }

    u:add_modification("object", modif_object, false)
    u:add_modification("trait", modif_trait)

    local m = CustomVariables().player_objects
    m[object_id] = unit_id
    CustomVariables().player_objects = m
end

---@param id_donner string
---@param id_obj string
---@param id_recev string
local function giveTo(id_donner, id_obj, id_recev)
    remove(id_donner, id_obj)
    apply(id_recev, id_obj)
end

local function echange(hero1, obj1, hero2, obj2)
    remove(hero1, obj1)
    remove(hero2, obj2)
    apply(hero1, obj2)
    apply(hero2, obj1)
end

-- Object inventory GUI

---returns the first object owned by i,
---or nil
---@param hero string # hero id
---@param t table<string, string>
---@return string?
local function hero_first_obj(hero, t)
    for obj_id, hero_id in pairs(t) do
        if hero == hero_id then
            return obj_id
        end
    end
    return nil
end

---@param myTable table
---@return string[]
local function sorted_keys(myTable)
    local keys = table.keys(myTable)
    table.sort(keys)
    return keys
end

local dialog = {
    T.tooltip { id = "tooltip" },
    T.helptip { id = "tooltip_large" },
    T.grid {
        T.row { T.column { T.label { tooltip = _ "Equipped artefacts are shown in red font", id = "title" } } },
        T.row { T.column { T.spacer { id = "space", height = 10 } } },
        T.row {
            T.column {
                T.horizontal_listbox {
                    id = "obj_list",
                    tooltip = _ "Equipped artefacts are shown in red font",
                    T.list_definition {
                        T.row {
                            T.column {
                                T.toggle_panel {
                                    T.grid {
                                        T.row { T.column { border_size = 5, border = "all", T.image { id = "icone" } } },
                                        T.row {
                                            T.column {
                                                border_size = 5,
                                                border = "left,right,bottom",
                                                T.label { id = "name" }
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
        T.row { T.column { T.spacer { id = "space2", height = 10 } } },
        T.row {
            T.column {
                T.grid {
                    T.row {
                        T.column {
                            T.grid {
                                T.row { T.column { T.image { id = "owner_img" } } },
                                T.row { T.column { T.label { id = "owner_name" } } }
                            }
                        },
                        T.column { T.spacer { id = "space3", width = 10 } },
                        T.column {
                            T.grid {
                                T.row { T.column { T.label { id = "obj_presentation" } } },
                                T.row { T.column { T.image { id = "obj_image" } } },
                                T.row {
                                    T.column {
                                        border_size = 5,
                                        border = "all",
                                        T.label { characters_per_line = 80, id = "obj_description" }
                                    }
                                }
                            }
                        },
                        T.column {
                            T.button { id = "equip", tooltip = _ "Click to change the object's owner", label = _ "Equip" }
                        }
                    }
                }
            }
        },
        T.row { T.column { T.spacer { height = 7 } } },
        T.row { T.column { T.label { id = "hero_title" } } },
        T.row { T.column { T.spacer { height = 5 } } },
        T.row {
            T.column {
                T.horizontal_listbox {
                    id = "hero_list",
                    has_minimum = false,
                    T.list_definition {
                        T.row {
                            T.column {
                                T.toggle_panel {
                                    T.grid {
                                        T.row { T.column { border_size = 5, border = "all", T.image { id = "icone" } } },
                                        T.row {
                                            T.column {
                                                border_size = 5,
                                                border = "left,right,bottom",
                                                T.label { id = "name" }
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
        T.row { T.column { T.spacer { id = "space4", height = 10 } } },
        T.row { T.column { T.button { id = "ok", label = _ "Return" } } }
    }
}


-- local ti = window:find("the_title") --[[@as simple_widget]]
-- ti.use_markup = true
-- ti.marked_up_text = _ "<span size='large' color ='#BFA63F' font_weight ='bold'>" .. title ..
-- "</span>"
-- local me = window:find("the_message") --[[@as simple_widget]]
-- me.use_markup = true
--     me.marked_up_text = message
-- end

---@param window window
local function preshow(window)
    --- widgets
    local title            = window:find("title") --[[@as label]]
    local hero_title       = window:find("hero_title") --[[@as label]]
    local owner_img        = window:find("owner_img") --[[@as image]]
    local owner_name       = window:find("owner_name") --[[@as label]]
    local obj_image        = window:find("obj_image") --[[@as image]]
    local obj_description  = window:find("obj_description") --[[@as label]]
    local obj_presentation = window:find("obj_presentation") --[[@as label]]
    local obj_list         = window:find("obj_list") --[[@as listbox]]
    local hero_list        = window:find("hero_list") --[[@as listbox]]
    local equip            = window:find("equip") --[[@as button]]


    local heroes = CustomVariables().heros_joueur:split(",")
    table.sort(heroes)

    --- state
    local state = {
        is_unfolded = false,
        to_unequip = false,
        ---@type string[]
        position_objets = {}, -- object id
        min_length_description = 100
    }


    title.marked_up_text      = "<span font_size = 'large' color ='#BFA63F' font_weight ='bold' >" ..
        _ " Artifacts collected" .. "</span>"

    hero_title.marked_up_text = "<span color ='#BFA63F' font_weight ='bold' >" ..
        _ " Choose your hero" .. " :   </span>"


    obj_description.use_markup = true
    obj_presentation.use_markup = true
    owner_name.use_markup = true

    ---@param bool boolean| 'hidden'
    local function show_middle(bool)
        owner_img.visible = bool
        owner_name.visible = bool
        obj_image.visible = bool
        obj_description.visible = bool
        obj_presentation.visible = bool
    end

    local function show_bottom(bool)
        hero_list.visible = bool
        hero_title.visible = bool
    end

    local function on_select_object()
        local objects = CustomVariables().player_objects

        local obj_id = state.position_objets[obj_list.selected_index]
        local objet = Conf.objects[obj_id]

        if state.is_unfolded then
            show_bottom(false)
            state.is_unfolded = false
        else
            show_bottom(false)
        end

        show_middle(false)
        show_middle(true)

        equip.enabled = true
        equip.visible = true
        obj_presentation.marked_up_text = objet.presentation
        obj_image.label = objet.image .. ".png"

        state.to_unequip = false

        if objects[obj_id] == "" then
            owner_img.visible = false
            owner_name.marked_up_text = "<span style='italic'>Not equipped yet</span>"
            equip.label = _ "Equip"
        else
            local owner = wesnoth.units.get(objects[obj_id])
            owner_img.label = owner.__cfg.image --[[@as tstring]]
            owner_name.marked_up_text = "Owned by <span weight='bold'>" .. owner.name .. "</span>"
            equip.label = _ "Assign to"
        end

        obj_description.label = objet.description
        obj_description.visible = true
    end

    local function show_hero_list()
        local objects = CustomVariables().player_objects

        hero_list:remove_items_at(1, #(heroes))
        for i, v in ipairs(heroes) do
            local hero = wesnoth.units.get(v)
            local name_widget = (hero_list:find(i, "name") --[[@as label]])
            if hero_first_obj(hero.id, objects) ~= nil then
                name_widget.marked_up_text = "<span color='#F4673E'>" ..
                    hero.name .. "</span>"
            else
                name_widget.marked_up_text = hero.name
            end
            local img_widget = (hero_list:find(i, "icone") --[[@as image]])
            img_widget.label = hero.__cfg.image --[[@as tstring]]
        end
    end

    local function init()
        local objects = CustomVariables().player_objects

        state.position_objets = {}
        state.is_unfolded = false

        state.min_length_description = 100000


        for idObject, idOwner in pairs(objects) do
            local len = string.len(tostring(Conf.objects[idObject].description))
            state.min_length_description = (state.min_length_description > len and
                len) or state.min_length_description
        end

        for k, idObj in ipairs(sorted_keys(objects)) do
            local v = objects[idObj]
            table.insert(state.position_objets, idObj)
            local objet = Conf.objects[idObj];

            (obj_list:find(k, "icone") --[[@as image]]).label = objet.image .. "mini.png" --[[@as tstring]]
            local name = obj_list:find(k, "name") --[[@as label]]
            if v == "" then
                name.label = objet.name --[[@as tstring]]
            else
                name.marked_up_text = _ "<span color='#34eb34'>" .. objet.name .. "</span>"
            end
        end
        obj_image.label = "objets/blank.png"
        obj_presentation.label = "  "
        obj_description.label = "  "
        show_middle("hidden")
        show_bottom(false)
        equip.visible = false
    end

    local function on_equip()
        local objects = CustomVariables().player_objects

        local obj_id = state.position_objets[obj_list.selected_index]
        local is_equipped = not not (objects[obj_id])
        if state.to_unequip then
            remove(objects[obj_id], obj_id)
            hero_list.visible = false
            init()
            on_select_object()
        else
            show_bottom(false)
            show_bottom(true)
            show_hero_list()
            state.is_unfolded = true
            if is_equipped then
                state.to_unequip = true
                equip.label = _ "To inventory"
            else
                equip.enabled = false
                equip.label = _ "Equip"
            end
        end
    end

    local function on_select_hero()
        local objects = CustomVariables().player_objects

        local objet_id = state.position_objets[obj_list.selected_index]
        local i = hero_list.selected_index
        local hero_id = heroes[i]
        if objects[objet_id] == "" then
            local old_obj = hero_first_obj(hero_id, objects)
            if old_obj ~= nil then
                remove(hero_id, old_obj)
                apply(hero_id, objet_id)
            else
                apply(hero_id, objet_id)
            end
        else
            local old_obj = hero_first_obj(hero_id, objects)
            if old_obj ~= nil then
                remove(hero_id, old_obj)
                giveTo(objects[objet_id], objet_id, hero_id)
            else
                giveTo(objects[objet_id], objet_id, hero_id)
            end
        end
        hero_list.visible = false
        state.is_unfolded = false
        init()
        on_select_object()
    end


    obj_list.on_modified = on_select_object
    equip.on_button_click = on_equip
    hero_list.on_modified = on_select_hero
    init()
end

O = {}

function O.showObjectsDialog()
    local obj_poss = CustomVariables().player_objects
    if next(obj_poss) == nil then
        Popup(_ "Note", _ "You still have to collect artifacts...")
    else
        gui.show_dialog(dialog, preshow)
    end
end
