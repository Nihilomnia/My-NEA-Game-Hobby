local Effect_Info = {}
local info = {
	["Burn"] = {
        EffectType = "DamageOverTime",
		BaseDuration = 5,
        DamagePerSecond = 10,
        
    },
    
    ["Poison"] = {
        EffectType = "DamageOverTime",
        BaseDuration = 8,
        DamagePerSecond = 7,
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
        BaseDuration = 6,
        DamagePerSecond = 5,
        StackingBehavior = "Stack",
    },

    ["Void"] = {
        EffectType = "Debuff",
        BaseDuration = 10,
        DamagePerSecond = 0,
        StackingBehavior = "Refresh",
    },
    
   

}



function Effect_Info.getEffectInfo(effectName)
	return info[effectName]
end

return Effect_Info
