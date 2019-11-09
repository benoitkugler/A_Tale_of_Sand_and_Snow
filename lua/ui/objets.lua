-- Menu Object and function to add and remove objects


-- TODO: Refactor (using DB.OBJETS)
-- Librairie Objets

O = {}

--PARTIE Echange d'objets

-- Reference the objet in player owned objects
function O.nouvel_objet(objet_id)
    VAR.objets_joueur[objet_id] = 0
end

-- Remove effect of given objet, and set its owner to 0
function O.remove(unit_id, object_id)
    local u = wesnoth.get_units {id = unit_id}[1]

    u:remove_modifications({id = object_id}, "object")
    u:remove_modifications({id = object_id}, "trait")
    AMLA.update_lvl(u) -- remove_modification may delete extra lvls

    VAR.objets_joueur[object_id] = 0
end

-- Apply an object to the given unit (unit modification and owner)
function O.apply(unit_id, objet_id)
    local u = wesnoth.get_units {id = unit_id}[1]
    local obj = DB.OBJETS[objet_id]
    local modif_object = {
        id = objet_id,
        {"effect", obj.effect}
    }

    local modif_trait = {
        id = objet_id,
        name = obj.name,
        description = obj.description,
        {"effect", {}}
    }

    wesnoth.add_modification(u, "object", modif_object, false)
    wesnoth.add_modification(u, "trait", modif_trait)

    VAR.objets_joueur[objet_id] = unit_id
end

function O.donne(id_donner, id_obj, id_recev)
    O.remove(id_donner, id_obj)
    O.apply(id_recev, id_obj)
end

function O.echange(hero1, obj1, hero2, obj2)
    O.remove(hero1, obj1)
    O.remove(hero2, obj2)
    O.apply(hero1, obj2)
    O.apply(hero2, obj1)
end

-- PARTIE fenêtre de gestion des objets

-- Helpers
local function is_in_table(i, t)
    for j, k in pairs(t) do
        if i == k then
            return j
        end
    end
    return false
end

local function sorted_keys(myTable)
    local keys = {}
    for i, v in pairs(myTable) do
        table.insert(keys, i)
    end
    table.sort(keys)
    return keys
end

local dialog = {
    T.tooltip {id = "tooltip"},
    T.helptip {id = "tooltip_large"},
    T.grid {
        T.row {T.column {T.label {tooltip = _ "Equipped artefacts are shown in red font", id = "titre"}}},
        T.row {T.column {T.spacer {id = "space", height = 10}}},
        T.row {
            T.column {
                T.horizontal_listbox {
                    id = "lobjets",
                    tooltip = _ "Equipped artefacts are shown in red font",
                    T.list_definition {
                        T.row {
                            T.column {
                                T.toggle_panel {
                                    T.grid {
                                        T.row {T.column {border_size = 5, border = "all", T.image {id = "icone"}}},
                                        T.row {
                                            T.column {
                                                border_size = 5,
                                                border = "left,right,bottom",
                                                T.label {id = "name"}
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
        T.row {T.column {T.spacer {id = "space2", height = 10}}},
        T.row {
            T.column {
                T.grid {
                    T.row {
                        T.column {
                            T.grid {
                                T.row {T.column {T.image {id = "owner_img"}}},
                                T.row {T.column {T.label {id = "owner_name"}}}
                            }
                        },
                        T.column {T.spacer {id = "space3", width = 10}},
                        T.column {
                            T.grid {
                                T.row {T.column {T.label {id = "objet_pres"}}},
                                T.row {T.column {T.image {id = "objet_img"}}},
                                T.row {
                                    T.column {
                                        border_size = 5,
                                        border = "all",
                                        T.label {characters_per_line = 80, id = "objet_des"}
                                    }
                                }
                            }
                        },
                        T.column {
                            T.button {id = "equip", tooltip = _ "Click to change the object's owner", label = _ "Equip"}
                        }
                    }
                }
            }
        },
        T.row {T.column {T.spacer {height = 7}}},
        T.row {T.column {T.label {id = "titre_heroes"}}},
        T.row {T.column {T.spacer {height = 5}}},
        T.row {
            T.column {
                T.horizontal_listbox {
                    id = "lheroes",
                    has_minimum = false,
                    T.list_definition {
                        T.row {
                            T.column {
                                T.toggle_panel {
                                    T.grid {
                                        T.row {T.column {border_size = 5, border = "all", T.image {id = "icone"}}},
                                        T.row {
                                            T.column {
                                                border_size = 5,
                                                border = "left,right,bottom",
                                                T.label {id = "name"}
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
        T.row {T.column {T.spacer {id = "space4", height = 10}}},
        T.row {T.column {T.button {id = "ok", label = _ "Return"}}}
    }
}

local function preshow()
    wesnoth.set_dialog_markup(true, "titre")
    wesnoth.set_dialog_value(
        "<span font_size = 'large' color ='#BFA63F' font_weight ='bold' >" .. _ " Artifacts collected" .. "</span>",
        "titre"
    )

    wesnoth.set_dialog_markup(true, "titre_heroes")
    wesnoth.set_dialog_value(
        "<span color ='#BFA63F' font_weight ='bold' >" .. _ " Choose your hero" .. " :   </span>",
        "titre_heroes"
    )

    wesnoth.set_dialog_markup(true, "objet_des")
    wesnoth.set_dialog_markup(true, "objet_pres")
    wesnoth.set_dialog_markup(true, "owner_name")

    local function affiche_middle(bool)
        wesnoth.set_dialog_visible(bool, "owner_img")
        wesnoth.set_dialog_visible(bool, "owner_name")
        wesnoth.set_dialog_visible(bool, "objet_img")
        wesnoth.set_dialog_visible(bool, "objet_des")
        wesnoth.set_dialog_visible(bool, "objet_pres")
    end

    local function affiche_bottom(bool)
        wesnoth.set_dialog_visible(bool, "lheroes")
        wesnoth.set_dialog_visible(bool, "titre_heroes")
    end

    local function onSelect_objet()
        local obj_id = O.position_objets[wesnoth.get_dialog_value("lobjets")]
        local objet = DB.OBJETS[obj_id]

        wesnoth.set_dialog_active(true, "equip")
        if O.is_unfolded then
            affiche_bottom(false)
            O.is_unfolded = false
        else
            affiche_bottom(false)
        end

        affiche_middle(false)
        affiche_middle(true)
        wesnoth.set_dialog_visible(true, "equip")
        wesnoth.set_dialog_value(objet.presentation, "objet_pres")
        wesnoth.set_dialog_value(objet.image .. ".png", "objet_img")

        O.to_unequip = false

        if O.objets[obj_id] == 0 then
            wesnoth.set_dialog_visible(false, "owner_img")
            wesnoth.set_dialog_value("<span style='italic'>Not equipped yet</span>", "owner_name")
            wesnoth.set_dialog_value(_ "Equip", "equip")
        else
            local owner = wesnoth.get_unit(O.objets[obj_id])
            wesnoth.set_dialog_value(owner.__cfg.image, "owner_img")
            wesnoth.set_dialog_value("Owned by <span weight='bold'>" .. owner.name .. "</span>", "owner_name")
            wesnoth.set_dialog_value(_ "Assign to", "equip")
        end

        --   Animation de transitions
        local long_string = string.len(tostring(objet.description))
        wesnoth.set_dialog_value(objet.description, "objet_des")
        wesnoth.set_dialog_visible(true, "objet_des")
    end

    local function affiche_list_heroes()
        wesnoth.remove_dialog_item(1, #(O.heroes), "lheroes")
        for i, v in pairs(O.heroes) do
            local hero = wesnoth.get_unit(v)
            if is_in_table(hero.id, O.objets) then
                wesnoth.set_dialog_value("<span color='#F4673E'>" .. hero.name .. "</span>", "lheroes", i, "name")
                wesnoth.set_dialog_markup(true, "lheroes", i, "name")
            else
                wesnoth.set_dialog_value(hero.name, "lheroes", i, "name")
            end
            wesnoth.set_dialog_value(hero.__cfg.image, "lheroes", i, "icone")
        end
    end

    local function onEquip()
        local objet_id = O.position_objets[wesnoth.get_dialog_value("lobjets")]
        local is_equipped = not (O.objets[objet_id] == 0)
        if O.to_unequip then
            O.remove(O.objets[objet_id], objet_id)
            wesnoth.set_dialog_visible(false, "lheroes")
            O.init()
            onSelect_objet()
        else
            affiche_bottom(false)
            affiche_bottom(true)
            affiche_list_heroes()
            O.is_unfolded = true
            if is_equipped then
                O.to_unequip = true
                wesnoth.set_dialog_value(_ "To inventory", "equip")
            else
                wesnoth.set_dialog_active(false, "equip")
                wesnoth.set_dialog_value(_ "Equip", "equip")
            end
        end
    end

    local function onSelect_hero()
        local objet_id = O.position_objets[wesnoth.get_dialog_value("lobjets")]
        local i = wesnoth.get_dialog_value("lheroes")
        local hero_id = O.heroes[i]
        if O.objets[objet_id] == 0 then
            local old_obj = is_in_table(hero_id, O.objets)
            if old_obj then
                O.remove(hero_id, old_obj)
                O.apply(hero_id, objet_id)
            else
                O.apply(hero_id, objet_id)
            end
        else
            local old_obj = is_in_table(hero_id, O.objets)
            if old_obj then
                O.remove(hero_id, old_obj)
                O.donne(O.objets[objet_id], objet_id, hero_id)
            else
                O.donne(O.objets[objet_id], objet_id, hero_id)
            end
        end
        wesnoth.set_dialog_visible(false, "lheroes")
        O.is_unfolded = false
        O.init()
        onSelect_objet()
    end

    function O.init()
        local vari = wesnoth.get_variable("heros_joueur")
        O.heroes = vari:to_field(",")
        table.sort(O.heroes)
        O.objets = wesnoth.get_variable("objets_joueur")
        O.position_objets = {}
        O.is_unfolded = false

        O.min_length_description = 100000
        for i, v in pairs(O.objets) do
            O.min_length_description =
                (O.min_length_description > string.len(tostring(DB.OBJETS[i]["description"])) and
                string.len(tostring(DB.OBJETS[i]["description"]))) or
                O.min_length_description
        end

        for k, i in ipairs(sorted_keys(O.objets)) do
            local v = O.objets[i]
            table.insert(O.position_objets, i)
            local objet = DB.OBJETS[i]
            wesnoth.set_dialog_value(objet.image .. "mini.png", "lobjets", #(O.position_objets), "icone")
            if v == 0 then
                wesnoth.set_dialog_value(objet.name, "lobjets", #(O.position_objets), "name")
            else
                wesnoth.set_dialog_value(
                    "<span color='#F4673E'>" .. objet.name .. "</span>",
                    "lobjets",
                    #(O.position_objets),
                    "name"
                )
                wesnoth.set_dialog_markup(true, "lobjets", #(O.position_objets), "name")
            end
        end
        wesnoth.set_dialog_value("objets/blank.png", "objet_img")
        wesnoth.set_dialog_value("  ", "objet_pres")
        wesnoth.set_dialog_value("  ", "objet_des")
        affiche_middle("hidden")
        affiche_bottom(false)
        wesnoth.set_dialog_visible(false, "equip")
    end

    wesnoth.set_dialog_callback(onSelect_objet, "lobjets")
    wesnoth.set_dialog_callback(onEquip, "equip")
    wesnoth.set_dialog_callback(onSelect_hero, "lheroes")
    O.init()
end

local function postshow()
    O.init = nil
    O.heroes = nil
    O.objets = nil
    O.position_objets = nil
    O.is_unfolded = nil
end

function O.menuObj()
    local obj_poss = wesnoth.get_variable("objets_joueur")
    if next(obj_poss) == nil then
        Popup(_ "Note", _ "You still have to collect artifacts...")
    else
        wesnoth.show_dialog(dialog, preshow, postshow)
    end
end
