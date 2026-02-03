local DodgeModule = {}
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local SSModules = SS.Modules
local RSModules = RS.Modules
local HelpfullModule = require(SSModules.Other.Helpful)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local ServerCombatModule = require(SSModules.CombatModule)
local DodgeVelocity = require(RSModules.Combat.DodgeVelocity)

local Events = RS.Events

local DodgeEvent = Events.Dodge

local WeaponsAnimations = RS.Animations.Weapons



local DodgeDebounce = Combat_Data.DodgeDebounce
local DodgeAnims = Combat_Data.DodgeAnims
local DodgeCancelCooldown = {}
local DodgeCanCancel = {}
local DodgeIsCancelling = {}


local function getUniqueId(char)
    local uid = char.Humanoid:FindFirstChild("UniqueId")
    return uid.Value or nil
end



function DodgeModule.Dodge(char,plr,direction)
    local Identifier = plr or getUniqueId(char)
    if HelpfullModule.CheckForAttributes(char, true, true, true, true, nil, true, true,nil) then return end
   	if DodgeIsCancelling[plr] then return end
	if DodgeDebounce[plr] and DodgeCancelCooldown[plr] then return end

    local hum = char.Humanoid
    local Currentweapon = char:GetAttribute("CurrentWeapon")
 
    DodgeDebounce[Identifier] = true
    DodgeCanCancel[Identifier] = false
    char:SetAttribute("Dodging", true)
    
   
    ServerCombatModule.stopAnims(hum)
    
    local animName = direction
    
	if direction == nil then
		animName = "W" -- For npcs that can't buffer directions  fall back to foward dodge
	end

	if direction == "None" or direction == "S" then
		animName = "S" -- Default back dodge
	end

    local dodgeFolder = WeaponsAnimations[Currentweapon].Dodging
    local animToPlay = dodgeFolder[animName] or dodgeFolder.S

    local anim = hum:LoadAnimation(animToPlay)
	DodgeAnims[Identifier] = anim
	anim:Play()
    if plr then
        DodgeEvent:FireClient(plr, "Dodge")
    else
        DodgeVelocity.dodge(char,Identifier, direction)
    end

	anim:GetMarkerReachedSignal("CancelStart"):Connect(function()
		DodgeCanCancel[Identifier] = true
	end)

	anim:GetMarkerReachedSignal("CancelEnd"):Connect(function()
		DodgeCanCancel[Identifier] = false
	end)
    
	task.delay(anim.Length + 0.25, function()
		if DodgeAnims[Identifier] == anim then
			char:SetAttribute("Dodging", false)
			DodgeCanCancel[Identifier] = false
		end
	end)

	task.delay(2.5, function()
		DodgeDebounce[Identifier] = false
	end)
    
end


function DodgeModule.DodgeCancel(char,plr)
    local Identifier = plr or getUniqueId(char)
    if not char:GetAttribute("Dodging") then return  end
    if DodgeCancelCooldown[Identifier] then
        return
    end
    if not DodgeCanCancel[Identifier] then
        return
    end
    if DodgeIsCancelling[Identifier] then
        return
    end

    DodgeCancelCooldown[Identifier] = true
    DodgeCanCancel[Identifier] = false
    DodgeIsCancelling[Identifier] = true

    -- STOP DODGE ANIM
    if DodgeAnims[Identifier] then
        DodgeAnims[Identifier]:Stop(0.1)
    end

    -- CONFIRM CANCEL (CLIENT VELOCITY RESET)
    if plr then
        DodgeEvent:FireClient(plr, "DodgeCancelConfirmed")
    else
        DodgeVelocity.resetVelocity(char,Identifier)
    end
    

    -- RELEASE LOCK AFTER CANCEL ANIM
    task.delay(0.5, function()
        DodgeIsCancelling[Identifier] = false
        DodgeDebounce[Identifier] = false -- allow re-roll
    end)

    -- CANCEL COOLDOWN
    task.delay(0.3, function()
        DodgeCancelCooldown[Identifier] = nil
    end)
end

















return DodgeModule