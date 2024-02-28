-- Metadata for specials skills.
-- In descriptions, %s will be replace by the computed value, in color.
-- Warning, %d or %f won't work (since the the value will be surronded by HTML tags beforehand)
-- Name of skills we be in color as well
-- Function which compute the values are directly accesible to be used in event_combat.
local V = Conf.special_xp_gain

Conf.special_skills = {}

---@class special_skill_config
---@field img string
---@field max_lvl integer
---@field id string
---@field color string
---@field name tstring
---@field require_lvl integer
---@field require_avancement {id:string, des:string}?
---@field desc tstring
---@field costs integer[]

---@class hero_skills
---@field help_des tstring
---@field help_ratios tstring
---@field [integer] special_skill_config


Conf.special_skills.mark = {}
Conf.special_skills.sword_spirit = {}

Conf.special_skills.drumar = {
    help_des = _ "Several years of battles in Vranken company have made Frä Drümar more warlike than any other Frä. \z
        She excels at slowing enemies and taking advantage of their delayed reactions. \z
        \nShe will earn experience (scaling with enemies level) when applying \z
        <b>slows</b>, <b>snares</b> or \z
         <b>chilling</b> states to her targets, \z
        as well as using <b>cold</b> attacks.",
    help_ratios = Fmt(
        _ "(<b>+ %.1f<b> per cold attack, <b>x %.1f<b> " ..
        "per slow, <b>x %.1f<b> per snare, <b>x %.1f<b> per chilling state)",
        V.drumar.ATK_COLD, V.drumar.ATK_SLOW, V.drumar.ATK_SNARE,
        V.drumar.ATK_CHILLING_TOUCH),
    {
        img = "special_skills/iceball_red.png",
        max_lvl = 3,
        id = "wave_dmg",
        color = "#D02300",
        name = _ "Cold Strengh :",
        require_lvl = 4,
        desc = _ "Grants %s%% additionnal bonus damage and %s bonus attack on the chilling wave.",
        costs = { 50, 50, 60 }
    },
    ---@type fun(lvl:integer): {[1]:integer, [2]:integer}
    wave_dmg = function(lvl) return lvl == 3 and { 15, 1 } or { 10, 0 } end,
    {
        img = "special_skills/forecast.png",
        max_lvl = 3,
        id = "forecast_defense",
        color = "#265690",
        name = _ "Forecast :",
        require_lvl = 4,
        desc = _ "Ennemies struggle to hit : %s%% additional bonus defense.",
        costs = { 70, 70, 70 }
    },
    ---@type fun(lvl:integer): integer
    forecast_defense = function(lvl) return lvl * 6 end,
    {
        img = "special_skills/slow_zone.png",
        max_lvl = 1,
        id = "slow_zone",
        color = "#00A8A2",
        name = _ "Slowing field :",
        require_avancement = {
            id = "toile_atk",
            des = _ "Requires <span weight='bold' color='#919191'>faster entangle</span> "
        },
        require_lvl = 4,
        desc = _ "Entangle now <span color='#00A8A2'>permanetly slows all enemies</span> near the target. Intensity : %s%%",
        costs = { 150, 100 }
    },
    ---@type fun(lvl:integer): integer
    slow_zone = function(lvl) return 10 + (10 * lvl) end,
    {
        img = "attacks/chilling_touch_master.png",
        max_lvl = 3,
        id = "bonus_cold_mistress",
        color = "#1ED9D0",
        name = _ "Cold Expert :",
        require_avancement = {
            id = "attack_chilled",
            des = _ "Requires <span weight='bold' color='#1ED9D0'>Chilling touch</span> object"
        },
        require_lvl = 6,
        desc = _ "Increases Chilling bonus damage to %s%% and %s turns duration.",
        costs = { 40, 40, 60 }
    },
    ---@type fun(lvl:integer): {[1]:integer, [2]:integer}
    bonus_cold_mistress = function(lvl)
        return lvl == 3 and { 60, 3 } or { 30 + 10 * lvl, 2 }
    end
}

Conf.special_skills.vranken = {
    help_des = _ "Vranken has a familly link with his sword. \z
        Every time <b>Göndhul fights</b>, Vranken earn points \z
        (scaling with opponents level).",
    help_ratios = Fmt(
        _ "(<b>+ %.1f</b> per defense, <b>x %.1f</b> per attack, " ..
        "<b>x %.1f</b> per kill, <b>%d</b> per level up)",
        V.sword_spirit.DEF, V.sword_spirit.ATK, V.sword_spirit.KILL,
        V.sword_spirit.LEVEL_UP),
    {
        img = "special_skills/leeches_cac.png",
        max_lvl = 3,
        id = "leeches_cac",
        color = "#24BE13",
        name = _ "Leeches :",
        require_lvl = 4,
        desc = _ "Leeches %s%% of damage dealt with swords ",
        costs = { 40, 35, 40 }
    },
    ---@type fun(lvl:integer): integer
    leeches_cac = function(lvl) return 5 + lvl * 5 end,
    {
        img = "special_skills/drain.png",
        max_lvl = 3,
        id = "drain_cac",
        color = "#24BE13",
        name = _ "Drain :",
        require_lvl = 4,
        desc = _ "Drains %s%% of damage dealt with swords, if Göndhul is at most <b>%s</b> hexes away from Vranken",
        costs = { 50, 35, 35 }
    },
    ---@type fun(lvl:integer): {[1]:integer, [2]:integer}
    drain_cac = function(lvl) return { 20 + lvl * 10, 2 ^ (lvl + 1) } end,
    {
        img = "attacks/atk_brut.png",
        max_lvl = 3,
        id = "atk_brut",
        color = "#e7cfa9",
        name = _ "Lightning sword :",
        require_lvl = 5,
        desc = _ "Grants a sword which deals <span color='#e7cfa9'>true damage</span>, but deals %s%% of your usual sword damage ",
        costs = { 100, 50, 50 }
    },
    ---@param lvl integer
    atk_brut = function(lvl) return 60 + (lvl * 10) end,
    {
        img = "special_skills/transposition.png",
        max_lvl = 2,
        id = "transposition",
        color = "#9E25C7",
        name = _ "<span style='italic'>War link</span>",
        require_lvl = 6,
        desc = _ "Enables Vranken and Göndhul to <span color='#9E25C7'>switch position</span>. Cooldown : <b>%s</b> turns.",
        costs = { 150, 100 }
    },
    ---@type fun(lvl:integer): integer
    transposition = function(lvl) return 3 - lvl end
}

Conf.special_skills.brinx = {
    help_des = _ "Brinx seeks to avenge Jödumur's death. Every time he \z
        <b>fights against muspellians</b>, \z
        Brinx earn points (scaling with opponents level).",
    help_ratios = Fmt(
        _ "(<b>+ %d</b> per defense, " ..
        "<b>x %.1f</b> per attack, <b>x %.1f</b> per kill)",
        V.brinx.DEF_MUSPELL, V.brinx.ATK_MUSPELL, V.brinx.KILL_MUSPELL),
    {
        img = "icons/armor_leather.png",
        max_lvl = 3,
        id = "def_muspell",
        color = "#4575AE",
        name = _ "Muspell Equilibrium : ",
        require_lvl = 4,
        desc = _ "Gives Brinx %s%% defense bonus against muspellians ",
        costs = { 50, 20, 30 }
    },
    ---@type fun(lvl:integer): integer
    def_muspell = function(lvl) return 5 + lvl * 5 end,
    {
        img = "icons/crossed_sword_and_hammer.png",
        max_lvl = 3,
        id = "dmg_muspell",
        color = "#D02300",
        name = _ "Muspell Terror : ",
        require_lvl = 4,
        desc = _ "Gives Brinx %s%% bonus damage against Muspell troops ",
        costs = { 40, 35, 45 }
    },
    ---@type fun(lvl:integer): integer
    dmg_muspell = function(lvl) return lvl * 10 end,
    {
        img = "icons/potion_red_medium.png",
        max_lvl = 3,
        id = "fresh_blood_musp",
        color = "#24BE13",
        name = _ "Muspell Strength : ",
        require_lvl = 5,
        desc = _ "Regenerates %s when killing a muspellian unit",
        costs = { 70, 50, 65 }
    },
    ---@type fun(lvl:integer): integer
    fresh_blood_musp = function(lvl) return 2 + 6 * lvl end,
    {
        img = "special_skills/bloody_sword.png",
        max_lvl = 2,
        id = "muspell_rage",
        color = "#D02300",
        name = _ "<span style='italic' >Revenge </span>",
        require_lvl = 6,
        desc = _ "If a muspellian is at his sides, Brinx will take and deal %s%% bonus damage against all enemies ",
        costs = { 200, 100 }
    },
    ---@type fun(lvl:integer): integer
    muspell_rage = function(lvl) return 10 * lvl end
}

Conf.special_skills.xavier = {
    help_des = _ "Xavier thrives in battefield strategy. Every time Xavier <b>\z
        helps allies</b>, he builds confidence with them (scaling with level). This will eventually make Xavier stronger, when \z
        fighting in precise formations.",
    help_ratios = Fmt(
        _ "(<b>x %.1f</b> per lead, <b>x %.1f</b> per back formation, " ..
        "<b>x %.1f</b> per spear formation and <b>+ %d</b> per wedge formation)",
        V.xavier.LEADERSHIP, V.xavier.Y_FORMATION, V.xavier.I_FORMATION,
        V.xavier.A_FORMATION),
    {
        img = "special_skills/Y_formation.png",
        max_lvl = 3,
        id = "Y_formation",
        color = "#f36e0a",
        name = _ "Back formation : ",
        require_lvl = 4,
        desc = _ "Xavier gains %s bonus attack(s) when attacking in Y",
        costs = { 50, 20, 30 }
    },
    ---@type fun(lvl:integer): integer
    Y_formation = function(lvl) return lvl end,
    {
        img = "special_skills/A_formation.png",
        max_lvl = 3,
        id = "A_formation",
        color = "#7c9f0f",
        name = _ "Wedge formation : ",
        require_lvl = 4,
        desc = _ "Xavier gains %s%% defense when fighting in A",
        costs = { 70, 40, 40 }
    },
    ---@type fun(lvl:integer): integer
    A_formation = function(lvl) return lvl * 5 end,
    {
        img = "special_skills/I_formation.png",
        max_lvl = 3,
        id = "I_formation",
        color = "#edad06",
        name = _ "Spear formation : ",
        require_lvl = 5,
        desc = _ "Xavier deals %s bonus damage when attacking in I",
        costs = { 50, 20, 30 }
    },
    ---@type fun(lvl:integer): integer
    I_formation = function(lvl) return 1 + lvl * 3 end,
    {
        img = "special_skills/O_formation.png",
        max_lvl = 1,
        id = "O_formation",
        color = "#c09d1b",
        name = _ "Union formation : ",
        require_lvl = 6,
        desc = _ "When attacking in O, Xavier may launch a powerful strike which removes all abilities and \z
            weapons specials of its target (%s turn(s) cooldown)",
        costs = { 200, 100 }
    },
    ---@type fun(lvl:integer): integer
    O_formation = function(lvl) return 3 - lvl end
}

Conf.special_skills.morgane = {
    help_des = _ "Walking and fighting into the Limbes deeply changes the way Morgane sees our world. \z
    With a little training, she will be able to build bridges between the two dimensions, \z
    modifying her movement and defense abilities. Her experience may also inspire his allies \z
    when fighting into the Limbes. \z
    Every time Morgane or one of her allies fight into the Limbes, she earns points (scaling with opponents level).",
    help_ratios = Fmt(
        _ "(<b>+ %d</b> per defense,<b>x %.1f</b> per attack, <b>x %.1f</b> per kill)",
        V.morgane.DEF, V.morgane.ATK, V.morgane.KILL),
    {
        img = "icons/boots_elven.png",
        max_lvl = 2,
        id = "moves",
        color = "#f36e0a",
        name = _ "Faster : ",
        require_lvl = 3,
        desc = _ "Morgane moves faster on all terrains.",
        costs = { 50, 20 }
    },
    ---@type fun(lvl:integer): integer
    moves = function(lvl) return lvl end,
    {
        img = "icons/tunic_elven.png",
        max_lvl = 3,
        id = "limbes_defense",
        color = "#f36e0a",
        name = _ "Nimble : ",
        require_lvl = 3,
        desc = _ "Morgane gains %s%% defense on all terrains.",
        costs = { 60, 40, 40 }
    },
    ---@type fun(lvl:integer): integer
    limbes_defense = function(lvl) return lvl * 7 end
}

Conf.special_skills.porthos = {
    help_des = _ "Battlefield has hardened Porthos beyond reason. Taking damage doesn't bother him anymore. \z
        In fact, Porthos is eager to protect his allies by taking the focus of ennemy fire.\z
        \nHe will earn experience every time he is <b>directly hit</b> in combat.",
    help_ratios = Fmt(_ "(<b>+ %.1f%%</b> of the damage taken)",
        V.porthos.DMG_TAKEN_RATIO * 100),
    ---return the % of hit points converted to bonus damage
    ---@param lvl integer
    pain_adept = function(lvl) return 10 + lvl * 5 end,
    {
        img = "icons/helmet_frogmouth.png",
        max_lvl = 3,
        id = "pain_adept",
        color = "#f36e0a",
        name = _ "Pain adept : ",
        require_lvl = 4,
        desc = _ "Porthos gains %s%% of his missing health as bonus damage.",
        costs = { 70, 30, 30 }
    },
    ---return the melee and distant ratios (as percentages)
    ---@type fun(lvl:integer): {[1]: integer, [2]:integer}
    sacrifice = function(lvl) return lvl == 3 and { 60, 30 } or { 30 + lvl * 10, 0 } end,
    {
        img = "attacks/transfusion.png",
        max_lvl = 3,
        id = "sacrifice",
        color = "#f36e0a",
        name = _ "Sacrifice : ",
        require_lvl = 4,
        desc = _ "Porthos shares %s%% of the damage inflicted to adjacent allies (%s%% at 2 tiles).",
        costs = { 70, 30, 30 }
    },
}

Conf.special_skills.bunshop = {
    help_des = _ "Bunshop is a fierce creature, taking ennemies by surprise and not letting them rest. \z
    He earns experience for every <b>backstab attack</b> and when taking down a <b>fully rested</b> ennemy.",
    help_ratios = Fmt(
        _ "(<b>+ %d</b> per backstab attack,<b>+ %d</b> per one shot, scaling with opponent level)",
        V.bunshop.ATK_BACKSTAB, V.bunshop.ONE_SHOT),
    {
        img = "attacks/fangs_heal.png",
        max_lvl = 3,
        id = "fangs_heal",
        color = "#f36e0a",
        name = _ "Healing fangs : ",
        require_lvl = 3,
        desc = _ "Bunshop heals himself by %s hp on every hit.",
        costs = { 50, 30, 30 }
    },
    ---@param lvl integer
    fangs_heal = function(lvl) return 2 + lvl * 2 end
}

Conf.special_skills.rymor = {
    help_des = _ "Rymôr excels in defense, and his aura makes nearby allies fight better as well. \z
    Rymôr earns experience everytime he or an adjacent ally is under attack.",
    help_ratios = Fmt(
        _ "(<b>+ %d</b> per self defense, <b>+ %d</b> per ally defense, scaling with opponent level)",
        V.rymor.DEF, V.rymor.ADJ_NEXT),
    {
        img = "attacks/heater-shield.png",
        max_lvl = 3,
        id = "combat_shield",
        color = "#f36e0a",
        name = _ "Shield : ",
        require_lvl = 3,
        desc = _ "At each new turn, Rymôr grants himself and adjacent allies a shield of %s%% of his maximum hitpoints.",
        costs = { 60, 30, 30 }
    },
    ---@param lvl integer # the percentage of rymor max hp
    combat_shield = function(lvl) return 5 + lvl * 5 end
}
