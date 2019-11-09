-- Track special experience gains
local V = {
    rymor = {
        ADJ_NEXT = 2, -- + atk.level
        DEF = 2 -- * atk.level
    },
    brinx = {
        DEF_MUSPELL = 1, -- + ath.level
        ATK_MUSPELL = 3, -- * def.level
        KILL_MUSPELL = 5 -- * dying.level
    },
    sword_spirit = {
        -- xp goes to vranken
        LEVEL_UP = 60, -- on level up
        ATK = 2, -- * def.level
        DEF = 1, -- + def.level
        KILL = 3 -- * dying.level
    },
    drumar = {
        DEF_COLD = 1, -- + atk.level
        DEF_SLOW = 1.45, -- * atk.level
        ATK_COLD = 2, -- + def.level
        ATK_SLOW = 1.45, -- * def.level
        ATK_SNARE = 2, -- * def.level
        ATK_CHILLING_TOUCH = 2.4 -- * def.level
    },
    bunshop = {
        ATK_BACKSTAB = 2, -- * def.level
        ONE_SHOT = 4 -- * dying.level
    },
    xavier = {
        LEADERSHIP = 1, -- * ally level
        Y_FORMATION = 4, -- * def level
        I_FORMATION = 5, -- * def level
        A_FORMATION = 5 -- + atk level
    }
}
DB.EXP_GAIN = V
