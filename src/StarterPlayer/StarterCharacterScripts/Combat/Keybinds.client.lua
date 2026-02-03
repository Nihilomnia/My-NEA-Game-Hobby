local RS = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")

local DodgeVelocity = require(RS.Modules.Combat.DodgeVelocity)


local Events = RS.Events

local blockingEvent =  Events.Blocking
local Transform = Events.Tranform
local WeaponsEvent= Events.WeaponsEvent
local combatEvent = Events.Combat
local Moves_Event = Events.SkillEvent
local DodgeEvent = Events.Dodge
local updateEvent = Events.UpdateMovement

local debounce = false 

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character


local MOVE_KEYS = {
	[Enum.KeyCode.W] = "W",
	[Enum.KeyCode.A] = "A",
	[Enum.KeyCode.S] = "S",
	[Enum.KeyCode.D] = "D"
}

local heldKeys = {} -- This acts as our "Stack"
local lastSentKey = "None"


local function isActuallyTyping()
	return uis:GetFocusedTextBox() ~= nil
end

local function updateMovementAttribute()
	local currentKey = "None"
	
	if #heldKeys > 0 then
		currentKey = heldKeys[1]
	end

	if currentKey ~= lastSentKey then
		lastSentKey = currentKey
		-- We fire the server instead of setting the attribute locally
		updateEvent:FireServer(currentKey)
	end
end

--------------------------------------------------------------------------------------
-- Movement  Tracking
--------------------------------------------------------------------------------------
uis.InputBegan:Connect(function(input, processed)
	if processed then return end -- Ignore if typing in chat
	
	local keyName = MOVE_KEYS[input.KeyCode]
	if keyName then
		-- Check if key is already in table (to prevent duplicates from key-repeat)
		for _, v in ipairs(heldKeys) do
			if v == keyName then return end
		end
		
		table.insert(heldKeys, keyName)
		updateMovementAttribute()
	end
end)

-- Detect Key Releases
uis.InputEnded:Connect(function(input)
	local keyName = MOVE_KEYS[input.KeyCode]
	if keyName then
		-- Remove the key from the table
		for i, v in ipairs(heldKeys) do
			if v == keyName then
				table.remove(heldKeys, i)
				break
			end
		end
		updateMovementAttribute()
	end
end)


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




DodgeEvent.OnClientEvent:Connect(function(action)
    if action == "DodgeCancelConfirmed" then
        DodgeVelocity.resetVelocity(char,plr)
    end

	if action == "Dodge" then
		DodgeVelocity.dodge(char,plr,lastSentKey)
	end
end)



uis.InputBegan:Connect(function(input, gp)
    if isActuallyTyping() then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if char:GetAttribute("Dodging") then
            DodgeEvent:FireServer("DodgeCancel")
        else
            blockingEvent:FireServer("Parry")
        end
    end
end)



uis.InputBegan:Connect(function(input, gp)
    if gp or isActuallyTyping() then return end

    if input.KeyCode == Enum.KeyCode.Q then
        DodgeEvent:FireServer("Dodge",lastSentKey)
		if lastSentKey == "None" then 
			lastSentKey = "S"
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





uis.InputBegan:Connect(function(input, gameProcessed)
	if isActuallyTyping() then return end
	if char:GetAttribute("IsTransforming") then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		combatEvent:FireServer("Swing")
	end
end)


-- R Z X C V  Skills (Theese can be changed to any keys you want later on)
---Comments indicate which move each key corresponds to so I dont get confused when add key rebind options later on

uis.InputEnded:Connect(function(input,isTyping)
	if isTyping then return end 

	if input.keyCode == Enum.KeyCode.R then
		Moves_Event:FireServer("R Move") --- This is the moveset's Special Move
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





