local RestingModule = {}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local RSModules = RS.Modules
local SSModules = SS.Modules
local MovementTypes = require(RSModules.Movement.Objects.Movement.Types)
local HelpfulModule = require(SSModules.Other.Helpful)
local WeaponAnimations = RS.Animations.Weapons


local function StartResting(MovementObj:MovementTypes.MovementObj)
    local elapsed = 0
    local conn = nil
    local char = MovementObj.char
    local currentWeapon = char:GetAttribute("CurrentWeapon")
    local hum = char.Humanoid
    if not char or not hum or currentWeapon or MovementObj.States.IsResting then return end 
    local restingAnim = hum.Animator:LoadAnimation(WeaponAnimations[currentWeapon].Movement.Resting)
    restingAnim:Play()
    MovementObj.States.IsResting = true
    



    local function RestStop()
        if not MovementObj.States.IsResting then return end 
        restingAnim:Stop()
        HelpfulModule.ResetMobility(char)
    end


    
    
    

end

function RestingModule.Start(MovementObj:MovementTypes.MovementObjData)
    
    
end






return RestingModule