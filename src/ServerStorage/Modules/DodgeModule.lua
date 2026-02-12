local DodgeModule = {}
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local SSModules = SS.Modules
local HelpfullModule = require(SSModules.Other.Helpful)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local ServerCombatModule = require(SSModules.CombatModule)


local Events = RS.Events

local DodgeEvent = Events.Dodge

local WeaponsAnimations = RS.Animations.Weapons



local DodgeDebounce = Combat_Data.DodgeDebounce
local DodgeAnims = Combat_Data.DodgeAnims
local DodgeCancelCooldown = {}
local DodgeCanCancel = {}
local DodgeIsCancelling = {}
local currentDodgeForce = {}


local DODGE_SPEED = 35
local DODGE_TIME = 0.73

local function resetVelocity(char,Identifier)
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if currentDodgeForce[Identifier] then
        currentDodgeForce[Identifier]:Destroy()
        currentDodgeForce[Identifier] = nil
    end
    -- Stop the momentum so they don't slide after cancelling
    hrp.AssemblyLinearVelocity = Vector3.zero 
end


local function dodge(char,Identifier,TargetDirection)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if currentDodgeForce[Identifier] then
        currentDodgeForce[Identifier]:Destroy()
    end

    local lv = Instance.new("LinearVelocity")
    lv.Attachment0 = hrp:FindFirstChild("DodgeAttachment") or Instance.new("Attachment", hrp)
    lv.MaxForce = 1e6
    
    -- Default direction and multipliers
    local direction = Vector3.new()
    local multiplier = 1

    -- Logic for Direction and Force (3/4 = 0.75, 2/4 = 0.5)
    if TargetDirection == "W" then
        -- Forward
        direction = hrp.CFrame.LookVector
        multiplier = 1
    elseif TargetDirection == "S" or TargetDirection == "None" then
        -- Back (or Q on its own)
        direction = -hrp.CFrame.LookVector
        multiplier = 0.75
    elseif TargetDirection == "A" then
        -- Left
        direction = -hrp.CFrame.RightVector
        multiplier = 0.75
    elseif TargetDirection == "D" then
        -- Right
        direction = hrp.CFrame.RightVector
        multiplier = 0.75
    end

	
    lv.VectorVelocity = direction * (DODGE_SPEED * multiplier)
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = hrp

    currentDodgeForce[Identifier] = lv
    game.Debris:AddItem(lv, DODGE_TIME)
end



local function getUniqueId(char)
    local uid = char.Humanoid:FindFirstChild("UniqueId")
    return uid.Value or nil
end



function DodgeModule.Dodge(char,plr,direction)
    local Identifier = plr or getUniqueId(char)
    if HelpfullModule.CheckForAttributes(char, true, true, true, true, nil, true, true,nil) then return end
    if HelpfullModule.ManageStamina(char, "Dodge") then return end
   	if DodgeIsCancelling[plr] then return end
	if DodgeDebounce[plr] and DodgeCancelCooldown[plr] then return end

    local hum = char.Humanoid
    local currentweapon = char:GetAttribute("CurrentWeapon")
 
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

    local dodgeFolder = WeaponsAnimations[currentweapon].Dodging
    local animToPlay = dodgeFolder[animName] or dodgeFolder.S

    local anim = hum:LoadAnimation(animToPlay)
	DodgeAnims[Identifier] = anim
	anim:Play()
    if plr then
        DodgeEvent:FireClient(plr, "Dodge")
    else
        dodge(char,Identifier, direction)
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
    local hum = char.Humanoid
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

    local weapon = char:GetAttribute("CurrentWeapon")
    local cancelAnim = hum:LoadAnimation(WeaponsAnimations[weapon].Dodging.DodgeCancel)
    cancelAnim:Play()

    -- CONFIRM CANCEL (CLIENT VELOCITY RESET)
    if plr then
        DodgeEvent:FireClient(plr, "DodgeCancelConfirmed")
    else
       resetVelocity(char,Identifier)
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