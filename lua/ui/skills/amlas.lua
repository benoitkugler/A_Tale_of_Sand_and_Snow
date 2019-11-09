-- Displaying of almas tree.
local A = {}

A.dialog = {
    -- T.row { T.column{ T.label { label = _ "These are the posible AMLAs for the unit."}}}, -- no room left
    T.row {T.column {T.image {id = "img1"}}}
}

local function construit_img(tableau, unit_id)
    local s = "arbres/" .. unit_id .. "/layer_fond.png"
    for i, v in pairs(tableau) do
        s = s .. "~BLIT(arbres/" .. unit_id .. "/" .. i .. "-" .. v .. ".png)"
    end
    return s
end

function A.preshow(u)
    wesnoth.set_dialog_value(1, "pages")
    local table_skill = TableSkills(u)
    if wesnoth.have_file("~add-ons/A_Tale_of_Sand_and_Snow/images/arbres/" .. u.id .. "/layer_fond.png") then
        local im = construit_img(table_skill, u.id)
        wesnoth.set_dialog_value(im, "img1")
    else
        wesnoth.set_dialog_value("image_campagne.png", "img1") -- fallback
    end
    wesnoth.set_dialog_visible(false, "img1")
    wesnoth.set_dialog_visible(true, "img1")
end
return A