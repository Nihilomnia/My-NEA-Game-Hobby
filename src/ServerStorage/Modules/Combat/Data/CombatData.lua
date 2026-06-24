local CombatData = {}
CombatData.Welds = {}
CombatData.EquipAnims = {}
CombatData.UnEquipAnims = {}
CombatData.IdleAnims = {}
CombatData.BlockingAnims = {}
CombatData.TransformAnims = {}
CombatData.ParryAnims = {}
CombatData.DodgeAnims = {}
CombatData.EquipDebounce = {}
CombatData.DodgeDebounce = {}
CombatData.ActiveStatusEffects = {}



CombatData.SuccessfulParry = {}
CombatData.SuccessfulHyprParry = {}
CombatData.ActiveRecoveryTracks = {}


CombatData.ActiveNPCs = {} -- Last resort for getting npcs


function CombatData.LastResortNPC(char)
    if CombatData.ActiveNPCs[char] then
        return CombatData.ActiveNPCs[char]
    end
    return nil
   
end
return CombatData
