local DodgeModule = {}
local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local SSModules = SS.Modules
local HelpfullModule = require(SSModules.Other.Helpful)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local ServerCombatModule = require(SSModules.CombatModule)
local StatusEffects = require(SSModules.StatusEffectsModule)
local PassiveManger = require(SSModules.Combat.PassiveManger)


local Events = RS.Events

local DodgeEvent = Events.Dodge
local VFX_Event = Events.VFX

local WeaponsAnimations = RS.Animations.Weapons



local DodgeDebounce = Combat_Data.DodgeDebounce
local DodgeAnims = Combat_Data.DodgeAnims
local DodgeCancelCooldown = {}
local DodgeCanCancel = {}
local DodgeIsCancelling = {}
local currentDodgeForce = {}


local DODGE_SPEED = 30
local DODGE_TIME = 0.5

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

    if TargetDirection == "None" then return end  -- No velcoity for spot dodges
    
    local dodgeAttachment = hrp:FindFirstChild("DodgeAttachment") or Instance.new("Attachment", hrp)
    local lv = Instance.new("LinearVelocity")
    lv.Attachment0 = dodgeAttachment
    lv.MaxForce = 1e6
    local mass = hrp.AssemblyMass * 1500
    lv.MaxAxesForce = Vector3.new(mass,mass,mass)
    

    local direction = Vector3.new()
    local multiplier = 1


    if TargetDirection == "W" then
        -- Forward
        direction = hrp.CFrame.LookVector
        multiplier = 1
    elseif TargetDirection == "S"  then
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

    local algin = Instance.new("AlignOrientation")
    algin.Attachment0 = dodgeAttachment
    algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
    algin.Responsiveness = 50
    algin.Parent = hrp

    local Hum:Humanoid = char.Humanoid
    Hum.AutoRotate = false
    

    currentDodgeForce[Identifier] = lv


        game.Debris:AddItem(lv, DODGE_TIME)
        game.Debris:AddItem(algin, DODGE_TIME)
        task.wait(DODGE_TIME)
        Hum.AutoRotate = false

    
  
   
end







function DodgeModule.Dodge(char,direction,npc)
    local Identifier = Players:GetPlayerFromCharacter(char) or npc
    local plr = Players:GetPlayerFromCharacter(char)
    if HelpfullModule.CheckForAttributes(char, true, true, true, true, nil, true, true,nil) then return end
    if HelpfullModule.ManageStamina(char, "Dodge") then return end
   	if DodgeIsCancelling[Identifier] then return end
	if DodgeDebounce[Identifier] and DodgeCancelCooldown[Identifier] then return end

    local hum = char.Humanoid
    local currentweapon = char:GetAttribute("CurrentWeapon")

    local dodgeDoneFlag = PassiveManger.DodgePassive(char)

    if dodgeDoneFlag then return end
 
    DodgeDebounce[Identifier] = true
    DodgeCanCancel[Identifier] = false
    char:SetAttribute("Dodging", true)

   
    
   
    ServerCombatModule.stopAnims(hum)
    
    local animName = direction
    
	if direction == nil then
		animName = "None" -- For npcs that can't buffer directions  fall back to Spot Dodge
	end

	
    local dodgeFolder = WeaponsAnimations[currentweapon].Dodging
    local animToPlay = dodgeFolder[animName] or dodgeFolder["None"] -- fallback to spot dodge anim if the specific direction anim doesn't exist

    local anim = hum.Animator:LoadAnimation(animToPlay)
	DodgeAnims[Identifier] = anim
	anim:Play()
    StatusEffects.RemoveStatusEffect(char,npc, "Burn")
  


    if plr then
        DodgeEvent:FireClient(plr, "Dodge")
    else
        dodge(char,Identifier, direction)
    end

    if direction == "None" then
        VFX_Event:FireAllClients("AfterImage",char,animToPlay,nil)
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


function DodgeModule.DodgeCancel(char,npc)
    local plr = Players:GetPlayerFromCharacter(char)
    local Identifier = plr or npc
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

    if DodgeAnims[Identifier] == "None" then return end -- This means that they were perfoming a spot dodge so they can't cancel it 

    DodgeCancelCooldown[Identifier] = true
    DodgeCanCancel[Identifier] = false
    DodgeIsCancelling[Identifier] = true

    -- STOP DODGE ANIM
    if DodgeAnims[Identifier] then
        DodgeAnims[Identifier]:Stop(0.1)
    end

    local weapon = char:GetAttribute("CurrentWeapon")
    local cancelAnim = hum.Animator:LoadAnimation(WeaponsAnimations[weapon].Dodging.DodgeCancel)
    cancelAnim:Play()
    HelpfullModule.RefundStamina(char, "Dodge")
  

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