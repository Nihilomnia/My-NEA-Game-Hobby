local Effect_Info = {}
local info = {
	["Burn"] = {
        EffectType = "DamageOverTime",
		BaseDuration = 5,
        DamagePerSecond = 25,
        
    },
    
    ["Poison"] = {
        EffectType = "DamageOverTime",
        BaseDuration = 8,
        DamagePerSecond = 0.02,
        StackingBehavior = "Stack",
    },

    ["Shock"] = {
        EffectType = "Debuff",
        BaseDuration = 4,
        DamagePerSecond = 12,
        StackingBehavior = "Refresh",
    },

    ["Bleed"] = {
        EffectType = "DamageOverTime",
        BaseDuration = 20,
        DamagePerSecond = 2,
        StackingBehavior = "Stack",
    },

    ["Void"] = {
        EffectType = "Debuff",
        BaseDuration = 10,
        DamagePerSecond = 0,
        StackingBehavior = "Refresh",
    },
    








    ["CombinationTable"] = {
        Flash_Freeze = {"Wet", "Freeze"},
        Blood_Poison = {"Bleed", "Poison"},
        Overload = {"Shock", "Water"},
    }
   

}



function Effect_Info.getEffectInfo(effectName)
	return info[effectName]
end

function Effect_Info.getCombinations()
    return info["CombinationTable"]
end

-- Returns the combination name if effectA + effectB is a valid combo, else nil
function Effect_Info.checkCombination(effectA, effectB)
    local combos = info["CombinationTable"]
    for comboName, ingredients in pairs(combos) do
        if (ingredients[1] == effectA and ingredients[2] == effectB) or
           (ingredients[1] == effectB and ingredients[2] == effectA) then
            return comboName -- e.g. "Blood_Poison"
        end
    end
    return nil
end

return Effect_Info
