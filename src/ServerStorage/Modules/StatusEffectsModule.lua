local StatusEffectsModule = {}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules
local Dictionaries = SSModules.Dictionaries
local Effect_Dictionary = require(Dictionaries.Effect_Info)
local Combat_Data = require(SSModules.Combat.Data.CombatData)


local Events = RS.Events
local UI_Update_Event = Events.UI_Update
local VFX_Event = Events.VFX_Event

-- Tables
local ActiveStatusEffects = Combat_Data.ActiveStatusEffects






function StatusEffectsModule.ApplyStatusEffect(char, effectName, stacks, Duration)
    local plr = game.Players:GetPlayerFromCharacter(char)
    local effectInfo = Effect_Dictionary.getEffectInfo(effectName)
    if not effectInfo then
        warn("Status effect '" .. effectName .. "' does not exist in the Effect Dictionary.")
        return
    end
    
    local newEffect = {
        Name = effectName,
        Stacks = stacks or 1,
        Duration = Duration or effectInfo.BaseDuration,
        TimeApplied = tick(),
    }
    
    if not ActiveStatusEffects[char] then
        ActiveStatusEffects[char] = {}
    end
    
    table.insert(ActiveStatusEffects[char], newEffect) 
    if plr then
        UI_Update_Event:FireClient(plr, "StatusEffectAdded", effectName,stacks)
    end
    VFX_Event:FireAllClients("CombatEffects", effectInfo.VFX, char.HumanoidRootPart.Position)

end


function StatusEffectsModule.RemoveStatusEffect(char, effectName)
    local plr = game.Players:GetPlayerFromCharacter(char)
    if not ActiveStatusEffects[char] then return end
    
    for i, effect in ipairs(ActiveStatusEffects[char]) do
        if effect.Name == effectName then
            table.remove(ActiveStatusEffects[char], i)
            if plr then  UI_Update_Event:FireClient(plr, "StatusEffectRemoved", effectName) end
            break
        end
    end
end





return StatusEffectsModule