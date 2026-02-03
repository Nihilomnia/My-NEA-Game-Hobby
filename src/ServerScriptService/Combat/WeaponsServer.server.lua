-- [Global Varilbles]
local LocalStorageService = game:GetService("LocalStorageService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local ServerScripts = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")

local WeaponsWeld = RS.Welds.Weapons
local Events = RS.Events
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons
local WeaponsSounds = SoundService.SFX.Weapons
local SSModules = SS.Modules

local WeaponsEvent = Events.WeaponsEvent
local BlockingEvent = Events.Blocking
local TransformEvent = Events.Tranform
local DodgeEvent = Events.Dodge
local VFX_Event = Events.VFX
local updateEvent = Events.UpdateMovement

local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local HelpfullModule = require(SSModules.Other.Helpful)
local WeaponsStatsModule = require(SSModules.Dictionaries.WeaponStats)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local Mode_Module = require(SSModules.Combat.Mode_Module)
local ServerCombatModule = require(SSModules.CombatModule)
local DataManager = require(ServerScripts.Data.Modules.DataManager)
local BlockModule = require(ServerStorage.Modules.BlockModule)
local ParryModule = require(ServerStorage.Modules.Parrying)
local DodgeModule = require(ServerStorage.Modules.DodgeModule)

-- Local Tables
local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local BlockingAnims = Combat_Data.BlockingAnims
local TransformAnims = Combat_Data.TransformAnims
local ParryAnims = Combat_Data.ParryAnims
local DodgeAnims = Combat_Data.DodgeAnims
local EquipDebounce = Combat_Data.EquipDebounce
local DodgeDebounce = Combat_Data.DodgeDebounce
local DodgeCancelCooldown = {}
local DodgeCanCancel = {}
local DodgeIsCancelling = {}

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local profile
			while true do
				profile = DataManager.Profiles[plr]
				if profile then break end
				task.wait(0.1)
			end
		
		
			local torso = char.Torso
			char:SetAttribute("CurrentWeapon", "Fists")
			char:SetAttribute("Element", "Astral")
			char:SetAttribute("Stamina", 100)
			char:SetAttribute("MaxStamina", 100)
			char:SetAttribute("InCombat", false)
			char:SetAttribute("Dodges", 0)
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
	local hum = char:WaitForChild("Humanoid")
	local torso = char.Torso
	local rightArm = char["Right Arm"]

	local currentWeapon = char:GetAttribute("CurrentWeapon")


	if HelpfullModule.CheckForAttributes(char,true,true,true,true,nil,true,true,nil) then return end 
	

	if action == "Equip/UnEquip" and not char:GetAttribute("Equipped") and not EquipDebounce[plr] then
		if char:GetAttribute("Mode1", true) then
			return
		end
		EquipDebounce[plr] = true

		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Main.Equip, torso)

		IdleAnims[plr] = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Main.Idle)
		EquipAnims[plr] = hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Main.Equip)
		EquipAnims[plr]:Play()

		EquipAnims[plr]:GetMarkerReachedSignal("weld"):Connect(function()
			Welds[plr].Part0 = rightArm
			Welds[plr].C1 = WeaponsWeld[currentWeapon].HoldingWeaponWeld.C1
		end)

		EquipAnims[plr]:GetMarkerReachedSignal("Equipped"):Connect(function()
			IdleAnims[plr]:Play()
			char:SetAttribute("Equipped", true)
			EquipDebounce[plr] = false
		end)
		EquipAnims[plr].Stopped:Connect(function()
			if char:GetAttribute("Stunned") then
				Welds[plr].Part0 = rightArm
				Welds[plr].C1 = WeaponsWeld[currentWeapon].HoldingWeaponWeld.C1
				IdleAnims[plr]:Play()
				char:SetAttribute("Equipped", true)
				EquipDebounce[plr] = false
			end
		end)
	elseif action == "Equip/UnEquip" and char:GetAttribute("Equipped") and not EquipDebounce[plr] then
		if char:GetAttribute("Mode1", true) then
			return
		end
		if char:GetAttribute("Mode2", true) then
			return
		end
		EquipDebounce[plr] = true

		char:SetAttribute("Equipped", false)

		SoundsModule.PlaySound(WeaponsSounds[currentWeapon].Main.UnEquip, torso)

		IdleAnims[plr]:Stop()

		UnEquipAnims[plr] = hum:LoadAnimation(WeaponsAnimations[currentWeapon].Main.UnEquip)
		UnEquipAnims[plr]:Play()

		UnEquipAnims[plr]:GetMarkerReachedSignal("Weld"):Connect(function()
			Welds[plr].Part0 = torso
			Welds[plr].C1 = WeaponsWeld[currentWeapon].IdleWeaponWeld.C1
		end)

		UnEquipAnims[plr]:GetMarkerReachedSignal("UnEquipped"):Connect(function()
			EquipDebounce[plr] = false
		end)

		UnEquipAnims[plr].Stopped:Connect(function()
			if char:GetAttribute("Stunned") then
				Welds[plr].Part0 = torso
				Welds[plr].C1 = WeaponsWeld[currentWeapon].IdleWeaponWeld.C1
				char:SetAttribute("Equipped", false)
				EquipDebounce[plr] = false
			end
		end)
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
		DodgeModule.Dodge(char,plr,direction)
	elseif action == "DodgeCancel" then
		DodgeModule.DodgeCancel(char,plr)
	end
end)

BlockingEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character

	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true, false, true,nil) then
		return
	end

	if action == "Blocking" then
		BlockModule.ActivateBlocking(char)
	elseif action == "UnBlocking" and char:GetAttribute("IsBlocking") then
		BlockModule.DeactivateBlocking(char)
	elseif
		action == "Parry" and not char:GetAttribute("IsBlocking") and not char:GetAttribute("Parrying") and not char:GetAttribute("ParryCD")
	then
		ParryModule.ParryAttempt(char,plr)
	end
end)

TransformEvent.OnServerEvent:Connect(function(plr, action)
	local char = plr.Character
	local Race = char:GetAttribute("Race")
	if HelpfullModule.CheckForAttributes(char, true, true, true, nil, true, true, true) then
		return
	end

	if action == "Mode 1" then
		Mode_Module.Mode1(
			char,
			WeaponsAnimations,
			Race,
			EquipDebounce,
			Welds,
			TransformAnims,
			EquipAnims,
			IdleAnims,
			WeaponsWeld
		)
	elseif action == "Mode 2" and char:GetAttribute("Mode1") and char:GetAttribute("ModeEnergy", 100) then
		Mode_Module.Mode2(
			char,
			WeaponsAnimations,
			Race,
			EquipDebounce,
			Welds,
			TransformAnims,
			EquipAnims,
			IdleAnims,
			WeaponsWeld
		)
	end
end)



updateEvent.OnServerEvent:Connect(function(player, keyName)
    
    print(player.Name .. " pressed the " .. keyName .. " key")
    
    local character = player.Character
    if character then
        character:SetAttribute("CurrentMoveKey", keyName)
    end
end)
