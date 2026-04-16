-- [Global Varilbles]
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local ServerScripts = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")


local Events = RS.Events
local SSModules = SS.Modules

local WeaponsEvent = Events.WeaponsEvent
local BlockingEvent = Events.Blocking
local TransformEvent = Events.Tranform
local DodgeEvent = Events.Dodge
local updateEvent = Events.UpdateMovement

local HelpfullModule = require(SSModules.Other.Helpful)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local Mode_Module = require(SSModules.Combat.Mode_Module)
local DataManager = require(ServerScripts.Data.Modules.DataManager)
local BlockModule = require(ServerStorage.Modules.BlockModule)
local ParryModule = require(ServerStorage.Modules.Parrying)
local DodgeModule = require(ServerStorage.Modules.DodgeModule)
local EquipModule = require(ServerStorage.Modules.Combat.EquipModule)

-- Local Tables
local Welds = Combat_Data.Welds
local EquipDebounce = Combat_Data.EquipDebounce

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local profile
		while true do
			profile = DataManager.Profiles[plr]
			if profile then
				break
			end
			task.wait(0.1)
		end

		local torso = char.Torso
		char:SetAttribute("CurrentWeapon", "Fists")
		char:SetAttribute("Element", "Astral")
		char:SetAttribute("Stamina", 100)
		char:SetAttribute("MaxStamina", 100)
		char:SetAttribute("InCombat", false)
		char:SetAttribute("Dodges", 0)
		char:SetAttribute("MF", 0)
		char.Parent = workspace.Characters
		HelpfullModule.ChangeWeapon(plr, char, torso)

		plr.CharacterAppearanceLoaded:Connect(function(char)
			for i, v in pairs(char:GetDescendants()) do
				if v.Parent:IsA("Accessory") and v:IsA("Part") then
					v.CanTouch = false
					v.CanQuery = false
				end
			end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	if Welds[plr] then
		table.remove(Welds, table.find(Welds, Welds[plr]))
	end
end)

WeaponsEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character


	if HelpfullModule.CheckForAttributes(char, true, true, true, true, nil, true, true, nil) then
		return
	end

	if action == "Equip/UnEquip" and not char:GetAttribute("Equipped") and not EquipDebounce[plr] then
		EquipModule.EquipWeapon(char)
	elseif action == "Equip/UnEquip" and char:GetAttribute("Equipped") and not EquipDebounce[plr] then
		EquipModule.UnequipWeapon(char)
	end
end)

DodgeEvent.OnServerEvent:Connect(function(plr, action, direction)
	local char = plr.Character
	if not char then
		return
	end

	local hum = char:FindFirstChild("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then
		return
	end

	if action == "Dodge" then
		DodgeModule.Dodge(char, direction)
	elseif action == "DodgeCancel" then
		DodgeModule.DodgeCancel(char)
	end
end)

BlockingEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character

	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true, false, true, nil) then
		return
	end

	if action == "Blocking" then
		BlockModule.ActivateBlocking(char)
	elseif action == "UnBlocking" and char:GetAttribute("IsBlocking") then
		BlockModule.DeactivateBlocking(char)
	elseif
		action == "Parry"
		and not char:GetAttribute("IsBlocking")
		and not char:GetAttribute("Parrying")
		and not char:GetAttribute("ParryCD")
	then
		ParryModule.ParryAttempt(char)
	end
end)

TransformEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character
	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true, true, true, nil) then
		return
	end

	if action == "Mode 1" then
		Mode_Module.Mode1(char)
	elseif action == "Mode 2" and char:GetAttribute("Mode1") then
		Mode_Module.Mode2(char)
	elseif action == "Revert" then
		Mode_Module.Revert(char)
	end
end)

updateEvent.OnServerEvent:Connect(function(player, keyName)
	local character = player.Character
	if character then
		character:SetAttribute("CurrentMoveKey", keyName)
	end
end)
