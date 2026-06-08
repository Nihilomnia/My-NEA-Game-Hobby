local Effect_Info = {}
local info = {
	["Burn"] = {
        EffectType = "DamageOverTime",
		BaseDuration = 5,
        DamagePerSecond = 25,
        HighlightColor = Color3.new(1, 0.5, 0),
        
    },
    
    ["Poison"] = {
        EffectType = "DamageOverTime",
        BaseDuration = 8,
        DamagePerSecond = 0.02,
        StackingBehavior = "Stack",
        HighlightColor = Color3.new(0.027451, 0.337255, 0.027451),
    },

    ["Shock"] = {
        EffectType = "Debuff",
        BaseDuration = 10,
        StunDuration = 0.25,
        StackingBehavior = "Refresh",
        HighlightColor = Color3.new(0.92549, 0.92549, 0.019608),
    },

    ["Bleed"] = {
        EffectType = "DamageOverTime",
        BaseDuration = 20,
        DamagePerSecond = 2,
        StackingBehavior = "Stack",
        HighlightColor = Color3.new(0.5, 0, 0),
    },

    ["Void"] = {
        EffectType = "Debuff",
        BaseDuration = 10,
        DamagePerSecond = 0,
        StackingBehavior = "Refresh",
        HighlightColor = Color3.new(0.5, 0, 0.5),
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
