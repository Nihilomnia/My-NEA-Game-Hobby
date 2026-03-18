local ItemInfo = {}
local info = {
    ["Hat"] = {
        Type = "Accessory",
        StackType = "Non-Stackable",
        Stats = {
            Crit_RateBonus = 0.05,
            Crit_DamageBonus = 0.1,
            PEN = 0,
            Flat_HP_Bonus = 50,
            Percent_HP_Bonus = 0.1,
        },

        Skills = {
            ["Swift"] = {
                Description = "5% faster movement speed for 5 seconds after using a skill.",
                Cooldown = 10,
            },
            ["Resilient"] = {
                Description = "Reduces incoming damage by 15% for 3 seconds after taking damage.",
                Cooldown = 45,
            },
        }
    },

    ["Halo"] = {
        Type = "Accessory",
        StackType = "Non-Stackable",

        Stats = {
            Crit_RateBonus = 0.05,
            Crit_DamageBonus = 0.1,
            PEN = 0,
            Flat_HP_Bonus = 50,
            Percent_HP_Bonus = 0.1,
        },

         Skills = {
            ["Swift"] = {
                Description = "5% faster movement speed for 5 seconds after using a skill.",
                Cooldown = 10,
            },
            ["Resilient"] = {
                Description = "Reduces incoming damage by 15% for 3 seconds after taking damage.",
                Cooldown = 45,
            },
        }


    },


    ["Dumbbell"] = {
        Type = "TrainingItem",
        StackType = "Non-Stackable",
    },

    ["Glock"] = {
        Type = "Material",
        StackType = "Stackable",
        MaxStack = 20,
    },

    ["Modifers"] = {

        ["Template"] = {
            Bonus_Stats = {
                Crit_RateBonus = 0,
                Crit_DamageBonus = 0,
                PEN = 0,
                Flat_HP_Bonus = 0,
                Percent_HP_Bonus = 0,
                Phyiscal_Resistance = 0,
                Magical_Resistance = 0,
                Speed_Bonus = 0,
            }

        },
        ["Warding"] = {
            Bonus_Stats = {
                Crit_RateBonus = 0,
                Crit_DamageBonus = 0,
                PEN = 0,
                Flat_HP_Bonus = 10,
                Percent_HP_Bonus = 0,
                Phyiscal_Resistance = 0.05,
                Magical_Resistance = 0.05,
                Speed_Bonus = 0.05,
            }

        },

        ["Agile"] = {
            Bonus_Stats = {
                Crit_RateBonus = 0.05,
                Crit_DamageBonus = 0.1,
                PEN = 0,
                Flat_HP_Bonus = 0,
                Percent_HP_Bonus = 0,
                Phyiscal_Resistance = 0,
                Magical_Resistance = 0,
                Speed_Bonus = 0.05,
            }

        },





    }


}







function ItemInfo.getStats(item)
    return info[item]
end


return ItemInfo