local RS = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local Events = RS.Events

local blockingEvent =  Events.Blocking
local Transform = Events.Tranform
local WeaponsEvent= Events.WeaponsEvent
local combatEvent = Events.Combat
local Moves_Event = Events.SkillEvent
local DodgeEvent = Events.Dodge

local debounce = false 

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local CurrentWeapon = char:GetAttribute("CurrentWeapon")

local DODGE_SPEED = 80
local DODGE_TIME = 0.25
local DODGE_ANIM_ID = RS.Animations.Weapons[CurrentWeapon].Dodging.Dodge.AnimationId	
local currentDodgeForce



--------------------------------------------------------------------------------------
-- Defence Mechanics
--------------------------------------------------------------------------------------
local function startBlocking()

	debounce = true
	blockingEvent:FireServer("Blocking")
	task.wait(1)
	debounce =false
	
end


local function stopBlocking()
	blockingEvent:FireServer("UnBlocking")
end

local function resetVelocity()
    if currentDodgeForce then
        currentDodgeForce:Destroy()
        currentDodgeForce = nil
    end

    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

    print("Velocity Reset")
end


local function doDodge()
    if currentDodgeForce then
        currentDodgeForce:Destroy()
        currentDodgeForce = nil
    end

    local lv = Instance.new("LinearVelocity")
    lv.Attachment0 = hrp:FindFirstChild("DodgeAttachment") or Instance.new("Attachment", hrp)
    lv.MaxForce = 1e6
    lv.VectorVelocity = hrp.CFrame.LookVector * DODGE_SPEED
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = hrp

    currentDodgeForce = lv
    game.Debris:AddItem(lv, DODGE_TIME)
end




uis.InputBegan:Connect(function(input,isTyping)
	if isTyping then return end
	if char:GetAttribute("IsTransforming") then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		if char:GetAttribute("Dodging") then  
			resetVelocity()
			DodgeEvent:FireServer("DodgeCancel")
			
			
		else 
			blockingEvent:FireServer("Parry")
		end
		
	end
end)




uis.InputBegan:Connect(function(input, isTyping)
    if isTyping then return end
    if input.KeyCode == Enum.KeyCode.Q then
        
        DodgeEvent:FireServer("Dodge")

        for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
            if anim.Animation 
               and anim.Animation.AnimationId == DODGE_ANIM_ID then
                
                anim:GetMarkerReachedSignal("Dodge"):Connect(function()
                    doDodge()
                end)
            end
        end
    end
end)




uis.InputBegan:Connect(function(key,istyping)
	if istyping or debounce then return end
	if char:GetAttribute("IsTransforming") then return end
	
	if key.KeyCode == Enum.KeyCode.F then
		startBlocking()
	end
end)

uis.InputEnded:Connect(function(key,IsTyping)
	if IsTyping then return end
	if char:GetAttribute("IsTransforming") then return end
	if key.KeyCode == Enum.KeyCode.F then
		stopBlocking()
	end
	
end)


char:GetAttributeChangedSignal("Blocking"):Connect(function()
	if char:GetAttribute("Blocking") > 100 then
		stopBlocking()
	end
end)

---------------------------------------------------------------------------------------
-- Transform Mechanics
---------------------------------------------------------------------------------------


uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.G and not char:GetAttribute("Mode1") then
		if char:GetAttribute("Mode1",true) or char:GetAttribute("Mode2",true)  then return end
		Transform:FireServer("Mode 1")


	end
	
	if input.keyCode == Enum.KeyCode.G and char:GetAttribute("Mode1",true)  then
		if char:GetAttribute("ModeEnergy") >=100 then
			if char:GetAttribute("Mode2",true) then return end
			Transform:FireServer("Mode 2")
		end
		


	end
	
	if input.KeyCode == Enum.KeyCode.E and char:GetAttribute("Mode1",true) then
		WeaponsEvent:FireServer("Revert")

	end

end)
-----------------------------------------------------------------------------------------
--- Attack Mechanics (Swinging and Skills)
-----------------------------------------------------------------------------------------
--- Swinging
uis.InputBegan:Connect(function(input,isTyping)
	if isTyping then return end
	if char:GetAttribute("IsTransforming") then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		combatEvent:FireServer("Swing")
	end
end)


-- Z X C Skills (Theese can be changed to any keys you want later on)
---Comments indicate which move each key corresponds to so I dont get confused when add key rebind options later on

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.R then
		Moves_Event:FireServer("R Move") --- This is the moveset's Sepcial Move
	end

end)

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.Z then
		Moves_Event:FireServer("Z Move") -- This is the moveset's First Move
	end

end)


uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.X then
		Moves_Event:FireServer("X Move") -- This is the moveset's Second Move
	end

end)

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.C then
		Moves_Event:FireServer("C Move")-- This is the moveset's Third Move
	end

end)

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.V then
		Moves_Event:FireServer("V Move") --This is the moveset's ultimate Move
	end

end)
------------------------------------------------------------------------------------------
-- Weapon Equip/Unequip
------------------------------------------------------------------------------------------

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 
	
	if input.keyCode == Enum.KeyCode.E then
		WeaponsEvent:FireServer("Equip/UnEquip")
	end
end)





