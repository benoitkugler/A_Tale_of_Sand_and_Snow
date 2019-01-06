-- Affichage personnalise du statut chilled
local old_unit_status = wesnoth.theme_items.unit_status
function wesnoth.theme_items.unit_status()
    local u = wesnoth.get_displayed_unit()
    if not u then return {} end
    local s = old_unit_status()
    if u.status.chilled then
        local lvl, cd = u.variables.status_chilled_lvl, u.variables.status_chilled_cd
        local bonus_dmg = SPECIAL_SKILLS.info.drumar.bonus_cold_mistress(lvl - 1)[1]
        table.insert(s, { "element", {
            image = "menu/chilled.png",
            tooltip = string.format(tostring(_"chilled: This unit is infoged by Cold Mistress. It will take <span color='#1ED9D0'>%d%%</span> bonus damage when hit by cold attacks. " ..
            "<span style='italic'>Last %d turn(s).</span>"), bonus_dmg, cd)
        } })
    end
    if u.status._zone_slowed then
        table.insert(s, { "element", {
            image = "menu/chilled.png",
            tooltip = _"slowing field: This unit was hit by a slowing field."
        } })
    end
    if u.id == "sword_spirit" then
        if wesnoth.eval_conditional {T.have_unit {id="sword_spirit",T.filter_adjacent{is_enemy=false}}} then
          table.insert(s, { "element", {
            image = "menu/fear_of_love.png",
            tooltip = _"endangered: Resistances reduces by <span color='red'>50%</span> !"
        } })  
        end
    end
    if wesnoth.eval_conditional {T.have_unit { id="sword_spirit",T.filter_adjacent{id=u.id}, T.fiter_side{T.allied_with{side=u.side}} }} then
         table.insert(s, { "element", {
            image = "menu/fear_of_love.png",
            tooltip = _"endangered: Resistances reduces by <span color='red'>100%</span> !"
        } })
    end
    return s
end


-- Affichage personnalise des shields
local old_unit_hp = wesnoth.theme_items.unit_hp
function wesnoth.theme_items.unit_hp()
    local u = wesnoth.get_displayed_unit()
    if not u then return {} end
    local s = old_unit_hp()
    if u.status.shielded then
        local sh = case_array(H.get_variable_array("table_status.shielded"),u.id).value
        table.insert(s, { "element", {
            text = "  <span color='#ADA5BB'>"..sh.."</span>",
            tooltip = u.name.._" shield will absorb <span color='#ADA5BB'>"..sh.."</span> damage. Last for the current turn and is only active in combat."
        } })
    end
    return s
end

-- Affichage des traits modifiés pour objets
local old_unit_traits = wesnoth.theme_items.unit_traits
function wesnoth.theme_items.unit_traits()
    local u = wesnoth.get_displayed_unit() 
    if not u then return {} end
    local traits = old_unit_traits()
    for i,v in ipairs(traits) do
        element = v[2]
        local trt,a = tostring(element.help):gsub("traits_","")
        if trt then
            local objet = obj_DB[trt]
            if objet then
                local str = (objet.code and objet.code(u)) or objet.description
                element.text = objet.name.." "
                element.tooltip = _"Artifact : <b>"..objet.name.."</b>\n"..str
            end
        end
    end
    return traits
end
