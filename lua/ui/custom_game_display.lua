local COLOR_SHIELD = "#ADA5BB"
local COLOR_CHILLED = "#1ED9D0"
local IMAGE_SPECIAL_SKILL = "special_skills/star.png"
local IMAGE_FEAR_OF_LOVE = "menu/fear_of_love.png"

-- TODO: better Limbes icon !

-- Customs status
---@param unit unit
---@return WMLTag?
local function show_special_skill_cd(unit)
    ---@type actif_skill?
    local skill_data = Conf.heroes.actif_skills[unit.id]
    if not skill_data then return end
    local vars = unit:custom_variables()
    local level = (vars.special_skills or {})[skill_data.id]
    if not level then return end
    local cd = vars.special_skill_cd or 0
    local tooltip = (cd > 0) and
        Fmt(_ "Special skill (%s) cooldown : <b>%d</b> turn%s", skill_data.name, cd, cd == 1 and "" or "s")
        or Fmt(_ "Special skill %s <b>ready</b> !", skill_data.name)
    return T.element { image = IMAGE_SPECIAL_SKILL, tooltip = tooltip }
end

---@param unit unit
---@return WMLTag?
local function show_fear_of_love(unit)
    local tooltip ---@type string
    if unit.id == "sword_spirit" and unit:ability("fearlove_self") then
        tooltip =
            _ "endangered: Resistances reduces by <span color='red'>50%</span> !"
    elseif unit:ability("fearlove") then
        tooltip =
            _ "endangered: Resistances reduces by <span color='red'>100%</span> !"
    else
        return
    end
    return T.element { image = IMAGE_FEAR_OF_LOVE, tooltip = tooltip }
end

---@param unit unit
---@return WMLTag?
local function show_chilled(unit)
    if not (unit.status.chilled) then return end

    local lvl, cd = unit:custom_variables().status_chilled_lvl,
        unit:custom_variables().status_chilled_cd
    local bonus_dmg = Conf.special_skills.drumar.bonus_cold_mistress(lvl - 1)[1]
    return T.element {
        image = "menu/chilled.png",
        tooltip = Fmt(
            _ "chilled: This unit is infoged by Cold Mistress. It will take <span color='%s'>%d%%</span> bonus damage when hit by cold attacks. " ..
            "<span style='italic'>Last %d turn(s).</span>",
            COLOR_CHILLED, bonus_dmg, cd)
    }
end

---@param unit unit
local function show_may_enter_limbes(unit)
    if unit.id ~= "morgane" then return end
    if Limbes.is_allowed_entrance() == true then
        return T.element { image = "special_skills/forecast.png", tooltip = _ "Morgäne senses nearby ennemies and may enter the Limbes !" }
    end
end


local old_unit_status = wesnoth.interface.game_display.unit_status
function wesnoth.interface.game_display.unit_status()
    local u = wesnoth.interface.get_displayed_unit()
    if not u then return {} end

    local s = old_unit_status()

    local ch = show_chilled(u)
    if ch then table.insert(s, ch) end


    if u.status._zone_slowed then
        table.insert(s, {
            "element", {
            image = "menu/chilled.png",
            tooltip = _ "slowing field: This unit was hit by a slowing field."
        }
        })
    end
    local fl = show_fear_of_love(u)
    if fl then table.insert(s, fl) end

    local el = show_special_skill_cd(u)
    if el then table.insert(s, el) end

    local li = show_may_enter_limbes(u)
    if li then table.insert(s, li) end

    return s
end

-- Shield custom display
local old_unit_hp = wesnoth.interface.game_display.unit_hp
function wesnoth.interface.game_display.unit_hp()
    local u = wesnoth.interface.get_displayed_unit()
    if not u then return {} end
    local s = old_unit_hp()
    if u.status.shielded then
        local sh = u:custom_variables().status_shielded_hp
        local desc =
            _ "%s's shield will absorb <span color='%s'>%d</span> damage (active in combat). Only last for the current turn."
        table.insert(s, T.element {
            text = Fmt("  <span color='%s'>+<b>%d</b></span>", COLOR_SHIELD, sh),
            tooltip = Fmt(desc, u.name, COLOR_SHIELD, sh)
        })
    end
    return s
end

local old_unit_weapons = wesnoth.interface.game_display.unit_weapons
function wesnoth.interface.game_display.unit_weapons()
    local u = wesnoth.interface.get_displayed_unit()
    if not u then return {} end


    local tooltips = {}
    for attack in wml.child_range(u.__cfg, "attack") do
        ---@cast attack weapon

        local specials = {}
        for _, special_tag in ipairs(wml.get_child(attack, "specials") or {}) do
            local special = special_tag[2]
            ---@cast special special
            table.insert(specials, string.format("\t<b>%s</b> : %s", special.name, special.description))
        end

        local tooltip = string.format("<b>%d x %d</b> %s\n%s\n",
            attack.damage, attack.number, attack.description,
            stringx.join(specials, "\n")
        )

        table.insert(tooltips, tooltip)
    end


    local elements = old_unit_weapons()
    --- replace the first element to add a tooltip with all attacks
    elements[1] = T.element {
        text = "<span color='#c4b093'>" .. _ "Attacks" .. "</span>\n",
        tooltip = stringx.join(tooltips, "\n"),
    }



    return elements
end

-- Display objects
local old_unit_traits = wesnoth.interface.game_display.unit_traits
function wesnoth.interface.game_display.unit_traits()
    local u = wesnoth.interface.get_displayed_unit()
    if not u then return {} end
    local traits = old_unit_traits()
    for __, v in ipairs(traits) do
        local element = v[2]
        local trt, _ = tostring(element.help):gsub("traits_", "")
        if trt then
            local object = Conf.objects[trt]
            if object then
                local str = (object.code and object.code(u)) or object.description
                element.text = object.name .. " "
                element.tooltip = Fmt(_ "Artifact : <b>%s</b>\n %s", object.name,
                    str)
            end
        end
    end
    return traits
end
