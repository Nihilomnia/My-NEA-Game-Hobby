local ParryModule = {}
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
local ConfirmParry = {}

local function getUniqueId(char)
	local uid = char.Humanoid:FindFirstChild("UniqueId")
	return uid.Value or nil
end

function ParryModule.ParryAttempt(char,plr)
	if plr == nil then
		plr = getUniqueId(char) -- This is for NPCS
	end
	local hum = char.Humanoid
	local currentWeapon = char:GetAttribute("CurrentWeapon")

	if HelpfullModule.CheckForAttributes(char, true, true, true, true, true, true, true) then return end
	char:SetAttribute("Parrying", true)
	ConfirmParry[plr] = true
	char:SetAttribute("Stunned", true)
	hum.WalkSpeed = (StarterPlayer.CharacterWalkSpeed / 3)
	hum.JumpHeight = 0

	ParryAnims[plr] = hum:LoadAnimation(WeaponAnimsFolder[currentWeapon].Blocking.TryParry)
	ParryAnims[plr]:Play()

	VFX_Event:FireAllClients("Highlight", char, 1, Color3.new(1, 1, 0), Color3.new(0.894118, 0.607843, 0.0588235))

	ParryAnims[plr]:GetMarkerReachedSignal("ParryOver"):Connect(function()
		char:SetAttribute("Parrying", false)
		ConfirmParry[plr] = false
		char:SetAttribute("ParryCD", true)
		task.wait(1.2)
		char:SetAttribute("ParryCD", false)
	end)


	ParryAnims[plr].Stopped:Connect(function()
		HelpfullModule.ResetMobility(char)
		char:SetAttribute("Parrying", false)
		char:SetAttribute("Stunned", false)
	end)
end





return ParryModule
