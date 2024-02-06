-- Metadata for specials skills.
-- In descriptions, %s will be replace by the computed value, in color.
-- Warning, %d or %f won't work (since the the value will be surronded by HTML tags beforehand)
-- Name of skills we be in color as well
-- Function which compute the values are directly accesible to be used in event_combat.
local V = DB.EXP_GAIN

local info = {}

-- TODO: A implémenter
info.bunshop = {}
info.rymor = {}

-- DRUMAR
info.drumar = {
    help_des = _ "Several years of battles in Vranken company have made Frä Drümar more warlike than any other Frä. " ..
        "She excels at slowing enemies and taking advantage of their delayed reactions. " ..
        "\nShe will earn experience (scaling with enemies level) when applying " ..
        "<span  font_weight ='bold' >slows</span>, <span  font_weight ='bold' >snares</span> or " ..
        " <span  font_weight ='bold' >chilling</span> states to her targets, " ..
        "as well as using <span  font_weight ='bold' >cold</span> attacks.",
    help_ratios = Fmt(
        _ "(<span weight ='bold' >+ %.1f</span> per cold attack, <span weight ='bold' >x %.1f</span> " ..
        "per slow, <span weight ='bold' >x %.1f</span> per snare, <span weight ='bold' >x %.1f</span> per chilling state)",
        V.drumar.ATK_COLD, V.drumar.ATK_SLOW, V.drumar.ATK_SNARE,
        V.drumar.ATK_CHILLING_TOUCH),
    {
        img = "special_skills/iceball_red.png",
        max_lvl = 3,
        name = "wave_dmg",
        color = "#D02300",
        name_aff = _ "Cold Strengh :",
        require_lvl = 4,
        desc = _ "Grants %s%% additionnal bonus damage and %s bonus attack on the chilling wave.",
        costs = { 50, 50, 60 }
    },
    ---@type fun(lvl:integer): {[1]:integer, [2]:integer}
    wave_dmg = function(lvl) return lvl == 3 and { 15, 1 } or { 10, 0 } end,
    {
        img = "special_skills/forecast.png",
        max_lvl = 3,
        name = "forecast_defense",
        color = "#265690",
        name_aff = _ "Forecast :",
        require_lvl = 4,
        desc = _ "Ennemies struggle to hit : %s%% additional bonus defense.",
        costs = { 70, 70, 70 }
    },
    ---@type fun(lvl:integer): integer
    forecast_defense = function(lvl) return 7 end,
    {
        img = "special_skills/slow_zone.png",
        max_lvl = 1,
        name = "slow_zone",
        color = "#00A8A2",
        name_aff = _ "Slowing field :",
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
        name = "bonus_cold_mistress",
        color = "#1ED9D0",
        name_aff = _ "Cold Expert :",
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

-- VRANKEN
info.vranken = {
    help_des = _ "Vranken has a familly link with his sword. " ..
        "Every time <span  font_weight ='bold' >Göndhul fights</span>, Vranken earn points " ..
        "(scaling with opponents level).",
    help_ratios = Fmt(
        _ "(<span weight ='bold'>+ %.1f</span> per defense, <span weight ='bold'>x %.1f</span>per attack, " ..
        "<span weight ='bold' >x %.1f</span> per kill, <span weight ='bold' >%d</span> per level up)",
        V.sword_spirit.DEF, V.sword_spirit.ATK, V.sword_spirit.KILL,
        V.sword_spirit.LEVEL_UP),
    {
        img = "special_skills/leeches_cac.png",
        max_lvl = 3,
        name = "leeches_cac",
        color = "#24BE13",
        name_aff = _ "Leeches :",
        require_lvl = 4,
        desc = _ "Leeches %s%% of damage dealt with swords ",
        costs = { 40, 35, 40 }
    },
    ---@type fun(lvl:integer): integer
    leeches_cac = function(lvl) return 5 + lvl * 5 end,
    {
        img = "special_skills/drain.png",
        max_lvl = 3,
        name = "drain_cac",
        color = "#24BE13",
        name_aff = _ "Drain :",
        require_lvl = 4,
        desc = _ "Drains %s%% of damage dealt with swords, if Göndhul is at most <span weight ='bold'>%s</span> hexes away from Vranken",
        costs = { 50, 35, 35 }
    },
    ---@type fun(lvl:integer): {[1]:integer, [2]:integer}
    drain_cac = function(lvl) return { 20 + lvl * 10, 2 ^ (lvl + 1) } end,
    {
        img = "attacks/atk_brut.png",
        max_lvl = 3,
        name = "atk_brut",
        color = "#e7cfa9",
        name_aff = _ "Lightning sword :",
        require_lvl = 5,
        desc = _ "Grants a sword which deals <span color='#e7cfa9'>true damage</span>, but deals %s%% of your usual sword damage ",
        costs = { 100, 50, 50 }
    },
    ---@type fun(lvl:integer): integer
    atk_brut = function(lvl) return 65 + (lvl * 15) end,
    {
        img = "special_skills/transposition.png",
        max_lvl = 2,
        name = "transposition",
        color = "#9E25C7",
        name_aff = _ "<span style='italic'>War link</span>",
        require_lvl = 6,
        desc = _ "Enables Vranken and Göndhul to <span color='#9E25C7'>switch position</span>. Cooldown : <span weight='bold'>%s</span> turns.",
        costs = { 150, 100 }
    },
    ---@type fun(lvl:integer): integer
    transposition = function(lvl) return 3 - lvl end
}

-- BRINX
info.brinx = {
    help_des = _ "Brinx seeks to avenge Jödumur's death. Every time he " ..
        "<span  font_weight ='bold' >fights against muspellians</span>, " ..
        "Brinx earn points (scaling with opponents level).",
    help_ratios = Fmt(
        _ "(<span font_weight ='bold'>+ %d</span> per defense, " ..
        "<span font_weight ='bold'>x %.1f</span>per attack, <span font_weight ='bold'>x %.1f</span> per kill)",
        V.brinx.DEF_MUSPELL, V.brinx.ATK_MUSPELL, V.brinx.KILL_MUSPELL),
    {
        img = "icons/armor_leather.png",
        max_lvl = 3,
        name = "def_muspell",
        color = "#4575AE",
        name_aff = _ "Muspell Equilibrium : ",
        require_lvl = 4,
        desc = _ "Gives Brinx %s%% defense bonus against muspellians ",
        costs = { 50, 20, 30 }
    },
    ---@type fun(lvl:integer): integer
    def_muspell = function(lvl) return 5 + lvl * 5 end,
    {
        img = "icons/crossed_sword_and_hammer.png",
        max_lvl = 3,
        name = "dmg_muspell",
        color = "#D02300",
        name_aff = _ "Muspell Terror : ",
        require_lvl = 4,
        desc = _ "Gives Brinx %s%% bonus damage against Muspell troops ",
        costs = { 40, 35, 45 }
    },
    ---@type fun(lvl:integer): integer
    dmg_muspell = function(lvl) return lvl * 10 end,
    {
        img = "icons/potion_red_medium.png",
        max_lvl = 3,
        name = "fresh_blood_musp",
        color = "#24BE13",
        name_aff = _ "Muspell Strength : ",
        require_lvl = 5,
        desc = _ "Regenerates %s when killing a muspellian unit",
        costs = { 70, 50, 65 }
    },
    ---@type fun(lvl:integer): integer
    fresh_blood_musp = function(lvl) return 2 + 6 * lvl end,
    {
        img = "special_skills/bloody_sword.png",
        max_lvl = 2,
        name = "muspell_rage",
        color = "#D02300",
        name_aff = _ "<span style='italic' >Revenge </span>",
        require_lvl = 6,
        desc = _ "If a muspellian is at his sides, Brinx will take and deal %s%% bonus damage against all enemies ",
        costs = { 200, 100 }
    },
    ---@type fun(lvl:integer): integer
    muspell_rage = function(lvl) return 10 * lvl end
}

-- XAVIER
info.xavier = {
    help_des = _ "Xavier thrives in battefield strategy. Every time Xavier <span font_weight='bold'>" ..
        "helps allies</span>, he builds confidence with them (scaling level). This will eventually make Xavier stronger, when " ..
        "fighting in precise formations.",
    help_ratios = Fmt(
        _ "(<span font_weight ='bold'>x %.1f</span> per lead, <span font_weight ='bold'>x %.1f</span> per Y-formation, " ..
        "<span font_weight ='bold'>x %.1f</span> per I-formation and <span font_weight ='bold'>+ %d</span> per A-formation)",
        V.xavier.LEADERSHIP, V.xavier.Y_FORMATION, V.xavier.I_FORMATION,
        V.xavier.A_FORMATION),
    {
        img = "special_skills/Y_formation.png",
        max_lvl = 3,
        name = "Y_formation",
        color = "#f36e0a",
        name_aff = _ "Back formation : ",
        require_lvl = 4,
        desc = _ "Xavier gains %s bonus attack(s) when attacking in Y",
        costs = { 50, 20, 30 }
    },
    ---@type fun(lvl:integer): integer
    Y_formation = function(lvl) return lvl end,
    {
        img = "special_skills/A_formation.png",
        max_lvl = 3,
        name = "A_formation",
        color = "#7c9f0f",
        name_aff = _ "Wedge formation : ",
        require_lvl = 4,
        desc = _ "Xavier gains %s%% defense when fighting in A",
        costs = { 70, 40, 40 }
    },
    ---@type fun(lvl:integer): integer
    A_formation = function(lvl) return lvl * 5 end,
    {
        img = "special_skills/I_formation.png",
        max_lvl = 3,
        name = "I_formation",
        color = "#edad06",
        name_aff = _ "Spear formation : ",
        require_lvl = 5,
        desc = _ "Xavier deals %s bonus damage when attacking in I",
        costs = { 50, 20, 30 }
    },
    ---@type fun(lvl:integer): integer
    I_formation = function(lvl) return 1 + lvl * 3 end,
    {
        img = "special_skills/O_formation.png",
        max_lvl = 1,
        name = "O_formation",
        color = "#c09d1b",
        name_aff = _ "Union formation : ",
        require_lvl = 6,
        desc = _ "When attacking in O, Xavier may launch a powerful strike which removes all abilities and " ..
            "weapons specials of its target (%s turn(s) cooldown)",
        costs = { 200, 100 }
    },
    ---@type fun(lvl:integer): integer
    O_formation = function(lvl) return 3 - lvl end
}

-- MORGANE
info.morgane = {
    help_des = _ [[
Walking and fighting into the Limbes deeply changes the way Morgane see our world. With a little training, she will be able to build bridges between the two dimensions, modifying her movement and defense abilities. Her experience may also inspire his allies when fighting into the Limbes.
Every time Morgane or one of her allies fight into the Limbes, she earns points (scaling with opponents level).]],
    help_ratios = Fmt(
        _ [[(<span font_weight ='bold'>+ %d</span> per defense,<span font_weight ='bold'>x %.1f</span> per attack, <span font_weight ='bold'>x %.1f</span> per kill)]],
        V.morgane.DEF, V.morgane.ATK, V.morgane.KILL),
    {
        img = "icons/boots_elven.png",
        max_lvl = 2,
        name = "moves",
        color = "#f36e0a",
        name_aff = _ "Faster : ",
        require_lvl = 3,
        desc = _ "Morgane moves faster on all terrains.",
        costs = { 50, 20 }
    },
    ---@type fun(lvl:integer): integer
    moves = function(lvl) return lvl end,
    {
        img = "icons/tunic_elven.png",
        max_lvl = 3,
        name = "defense",
        color = "#f36e0a",
        name_aff = _ "Nimble : ",
        require_lvl = 3,
        desc = _ "Morgane gains %s%% defense on all terrains.",
        costs = { 60, 40, 40 }
    },
    ---@type fun(lvl:integer): integer
    defense = function(lvl) return lvl * 7 end
}

DB.SPECIAL_SKILLS = info
