local ParryModule = {}
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Events = RS.Events
local SSModule = SS.Modules
local WeaponAnimsFolder = RS.Animations.Weapons
local VFX_Event = Events.VFX

local HelpfullModule = require(SSModule.Other.Helpful)
local Combat_Data = require(SSModule.Combat.Data.CombatData)

-- Tables
local ParryAnims = Combat_Data.ParryAnims
local Success = Combat_Data.SuccessfulParry


function ParryModule.ParryAttempt(char, npc)
	local Identifer = Players:GetPlayerFromCharacter(char) or npc
	local hum = char.Humanoid
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	if char:GetAttribute("ParryCD") then return end

	if HelpfullModule.CheckForAttributes(char, true, true, true, true, true, true, true) then
		return
	end
	char:SetAttribute("Parrying", true)
	char:SetAttribute("Stunned", true)
	hum.WalkSpeed = (StarterPlayer.CharacterWalkSpeed / 3)
	hum.JumpHeight = 0

	ParryAnims[Identifer] = hum:LoadAnimation(WeaponAnimsFolder[currentWeapon].Blocking.TryParry)
	ParryAnims[Identifer]:Play()

	VFX_Event:FireAllClients("Highlight", char, 1, Color3.new(1, 1, 0), Color3.new(0.894118, 0.607843, 0.0588235))

	ParryAnims[Identifer]:GetMarkerReachedSignal("ParryOver"):Connect(function()
		char:SetAttribute("Parrying", false)
	end)


	ParryAnims[Identifer].Ended:Connect(function()
		if Success[Identifer] then
			HelpfullModule.ResetMobility(char)
			char:SetAttribute("Parrying", false)
			char:SetAttribute("Stunned", false)
			char:SetAttribute("ParryCD", false)
			Success[Identifer] = nil
			return
		end

		HelpfullModule.ResetMobility(char)
		char:SetAttribute("Stunned", false)
		char:SetAttribute("ParryCD", true)
		task.wait(1.2)
		char:SetAttribute("ParryCD", false)
	end)
end

return ParryModule
