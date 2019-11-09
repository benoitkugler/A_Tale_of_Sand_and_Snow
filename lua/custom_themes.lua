local COLOR_SHIELD = "#ADA5BB"
local COLOR_CHILLED = "#1ED9D0"
local IMAGE_SPECIAL_SKILL = "special_skills/star.png"
local IMAGE_FEAR_OF_LOVE = "menu/fear_of_love.png"

--Customs status
local function _show_special_skill_cd(unit)
    local cd = unit.variables.special_skill_cd or 0
    local tooltip
    if cd > 0 then
        tooltip = fmt(_ "Special skill cooldown : <b>%d</b> turn%s", cd, cd == 1 and "" or "s")
    else
        tooltip = _ "Special skill <b>ready</b> !"
    end
    return T.element {image = IMAGE_SPECIAL_SKILL, tooltip = tooltip}
end

local function _show_fear_of_love(unit)
    local tooltip
    if unit.id == "sword_spirit" and unit:ability("fearlove_self") then
        tooltip = _ "endangered: Resistances reduces by <span color='red'>50%</span> !"
    elseif unit:ability("fearlove") then
        tooltip = _ "endangered: Resistances reduces by <span color='red'>100%</span> !"
    else
        return
    end
    return T.element {image = IMAGE_FEAR_OF_LOVE, tooltip = tooltip}
end

local old_unit_status = wesnoth.theme_items.unit_status
function wesnoth.theme_items.unit_status()
    local u = wesnoth.get_displayed_unit()
    if not u then return {} end

    local s = old_unit_status()
    if u.status.chilled then
        local lvl, cd = u.variables.status_chilled_lvl, u.variables.status_chilled_cd
        local bonus_dmg = SPECIAL_SKILLS.info.drumar.bonus_cold_mistress(lvl - 1)[1]
        table.insert(
            s,
            {
                T.element {
                    image = "menu/chilled.png",
                    tooltip = fmt(
                        _ "chilled: This unit is infoged by Cold Mistress. It will take <span color='%s'>%d%%</span> bonus damage when hit by cold attacks. " ..
                            "<span style='italic'>Last %d turn(s).</span>",
                        COLOR_CHILLED,
                        bonus_dmg,
                        cd
                    )
                }
            }
        )
    end
    if u.status._zone_slowed then
        table.insert(
            s,
            {
                "element",
                {
                    image = "menu/chilled.png",
                    tooltip = _ "slowing field: This unit was hit by a slowing field."
                }
            }
        )
    end
    local el = _show_fear_of_love(u)
    if not (el == nil) then table.insert(s, el) end

    if u.id == "xavier" or u.id == "vranken" then
        table.insert(s, _show_special_skill_cd(u))
    end

    return s
end

-- Shield custom display
local old_unit_hp = wesnoth.theme_items.unit_hp
function wesnoth.theme_items.unit_hp()
    local u = wesnoth.get_displayed_unit()
    if not u then
        return {}
    end
    local s = old_unit_hp()
    if u.status.shielded then
        local sh = u.variables.status_shielded_hp
        local desc =
            _ "%s's shield will absorb <span color='%s'>%d</span> damage (active in combat). Only last for the current turn."
        table.insert(
            s,
            T.element {
                text = fmt("  <span color='%s'>+<b>%d</b></span>", COLOR_SHIELD, sh),
                tooltip = fmt(desc, u.name, COLOR_SHIELD, sh)
            }
        )
    end
    return s
end

-- Affichage des traits modifiés pour objets
local old_unit_traits = wesnoth.theme_items.unit_traits
function wesnoth.theme_items.unit_traits()
    local u = wesnoth.get_displayed_unit()
    if not u then
        return {}
    end
    local traits = old_unit_traits()
    for _, v in ipairs(traits) do
        local element = v[2]
        local trt, _ = tostring(element.help):gsub("traits_", "")
        if trt then
            local objet = DB.OBJETS[trt]
            if objet then
                local str = (objet.code and objet.code(u)) or objet.description
                element.text = objet.name .. " "
                element.tooltip = fmt(_ "Artifact : <b>%s</b>\n %s", objet.name, str)
            end
        end
    end
    return traits
end
