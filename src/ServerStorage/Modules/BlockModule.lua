local module = {}

local players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local Debris = game:GetService("Debris")

local Events = RS.Events
local RSModules = RS.Modules
local SSModule = SS.Modules
local WeaponSounds = SoundService.SFX.Weapons
local WeaponAnimsFolder = RS.Animations.Weapons

local Combat_Data = require(SSModule.Combat.Data.CombatData)

-- Tables
local BlockingAnims = Combat_Data.BlockingAnims
local ParryAnims = Combat_Data.ParryAnims
local SucessfulParry = Combat_Data.SuccessfulParry
local SuccssfulHypr = Combat_Data.SuccessfulHyprParry

local VFX_Event: RemoteEvent = Events.VFX

local SoundsModule = require(RSModules.Combat.SoundsModule)
local ServerCombatModule = require(SSModule.CombatModule)
local WeaponStatsModule = require(SSModule.Dictionaries.WeaponStats)
local PassiveManger = require(SSModule.Combat.PassiveManger)
local StunHandler = require(SSModule.Other.StunHandlerV2)

local function ResetMobility(char)
	local hum = char.Humanoid
	if char:GetAttribute("IsLow") and char:GetAttribute("InCombat") then
		if char:GetAttribute("Sprinting") then
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed * 1.25
		else
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed / 2
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight / 2
		end
	else
		if char:GetAttribute("Sprinting") then
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed * 2
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight
		else
			hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight
		end
	end
end


local function HyprKnockback(Char)
	if not Char then
		return
	end
	local HRP: BasePart = Char:FindFirstChild("HumanoidRootPart")
	local hum = Char:FindFirstChildOfClass("Humanoid")
	if not HRP or not hum then
		return
	end

	local att = HRP:FindFirstChild("HyprAtt") or Instance.new("Attachment")
	att.Name = "HyprAtt"
	att.Parent = HRP

	local backwardDirection = -HRP.CFrame.LookVector

	local popUpwardForce = 22.6
	local popBackwardForce = 36.1
	local impulseVector = (backwardDirection * popBackwardForce) + Vector3.new(0, popUpwardForce, 0)
	
	HRP:ApplyImpulse(impulseVector * HRP:GetMass())

	local slideSpeed = 56.7
	local lv = Instance.new("LinearVelocity")
	lv.Name = "HyprForce"
	lv.Attachment0 = att
	lv.MaxForce = math.huge
	lv.VectorVelocity = backwardDirection * slideSpeed
	lv.Parent = HRP

	Debris:AddItem(lv, 0.25)
	Debris:AddItem(att,0.25)
end



function module.HyprParrying(char, eChar, hitpos, npc)
	if not char or not eChar then
		return
	end
	local EHRP: BasePart = eChar:FindFirstChild("HumanoidRootPart")
	local HRP: BasePart = char:FindFirstChild("HumanoidRootPart")

	if not EHRP or not HRP then
		return
	end

	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local EcurrentWeapon = char:GetAttribute("CurrentWeapon")

	local hum : Humanoid = char.Humanoid
	local Ehum : Humanoid = char.Humanoid
	

	local identifer = players:GetPlayerFromCharacter(eChar) or npc
	local Result = "Hitlanded"
	SuccssfulHypr[identifer] = true

	local DistOffset = CFrame.new(0, 0, -3.5) -- this is the pffset for how far apart the attack (char) would be from defnder(echar)
	local rotation = CFrame.Angles(0, math.rad(180), 0) -- same as above but for raotion

	HRP.CFrame = EHRP.CFrame * DistOffset * rotation

	
	local HyprSound = WeaponSounds[EcurrentWeapon].Blocking.HyprParrySFX

	local Defenderhitstop =
		eChar.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[EcurrentWeapon].Blocking.HyprParryLanded) --- Its a a one frame animation for hitstop
	local AttackerHitstop -- wait i need created something i need to find out to check what kind of attack is being hypr-parried  so i can grab the approte hitdtop frame

	VFX_Event:FireAllClients("HyprParry", char, eChar)

	Defenderhitstop:Play()
	--AttackerHitstop:Play()
	Ehum.AutoRotate = false
	hum.AutoRotate = false





	task.wait(0.2) -- change to how long the hitstop is was 0.2
	Defenderhitstop:Stop()
	--AttackerHitstop:Stop()



	if char:GetAttribute("BreakMeter") then
		local currentBreak = char:GetAttribute("BreakMeter")
		local breakDamage = 50 -- Adjust based on weapon data
		local newbreak = math.max(0, currentBreak - breakDamage)

		char:GetAtrribute("BreakMeter", newbreak)

		if newbreak <= 0 then
			-- trigger the Weapon Breaking Logic Here
		end
	end

	local recover = eChar.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[EcurrentWeapon].Blocking.Hypr_Recover)
	HyprKnockback(eChar)
--	local stagger = char.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[EcurrentWeapon].Blocking.HyprParryStagger)
	recover:Play()
	--stagger:Play()
	eChar:SetAttribute("CanRevenge", true)
	SoundsModule.PlaySound(HyprSound,EHRP)

	task.delay(0.6, function()
		if eChar and eChar.Parent then
			eChar:SetAttribute("CanRevenge", nil)
			Ehum.AutoRotate = true
			hum.AutoRotate = true
		end
	end)
	-- Stun = hitstop + the actual stun
	-- Stun = 0.2 + 1.5 = 1.7

	StunHandler.Stun(char.Humanoid, 1.7, 2, 0)

	Result = "Hypr-Parried"

	return Result
end

function module.Parrying(char, eChar, hitPos, npc)
	local identifier = players:GetPlayerFromCharacter(eChar) or npc
	local Result = "HitLanded"
	SucessfulParry[identifier] = true
	ParryAnims[identifier]:Stop()
	-- Kill the parry anims to prevent the rest of the parry process from being ran so cooldowns are not triggered

	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local BlockDmg = WeaponStatsModule.getStats(currentWeapon).BlockDmg

	char:SetAttribute("Blocking", char:GetAttribute("Blocking") + BlockDmg)
	eChar:SetAttribute("Blocking", eChar:GetAttribute("Blocking") - BlockDmg)
	eChar:SetAttribute("InCombat", true)

	if eChar:GetAttribute("Blocking") < 0 then
		eChar:SetAttribute("Blocking", 0)
	end

	VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Parry, hitPos, 3)
	SoundsModule.PlaySound(WeaponSounds[eChar:GetAttribute("CurrentWeapon")].Blocking.Parry, eChar.Torso)

	ServerCombatModule.stopAnims(char.Humanoid)

	char.Humanoid.Animator
		:LoadAnimation(WeaponAnimsFolder[char:GetAttribute("CurrentWeapon")].Blocking.GotParried)
		:Play()
	eChar.Humanoid.Animator
		:LoadAnimation(WeaponAnimsFolder[eChar:GetAttribute("CurrentWeapon")].Blocking.ParryLanded)
		:Play()
	local plr = players:GetPlayerFromCharacter(char)
	if plr then
		VFX_Event:FireClient(plr, "CustomShake", 4, 8, 0, 1.2)
	end
	VFX_Event:FireAllClients("Highlight", eChar, 1, Color3.new(1, 1, 0), Color3.new(0.894118, 0.607843, 0.0588235))

	StunHandler.Stun(char.Humanoid, 1.25, 10, 0)

	Result = "Parried"

	return Result
end

function module.GuardBreak(char)
	VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.GuardBreak, char.HumanoidRootPart.CFrame, 3)

	VFX_Event:FireAllClients("Highlight", char, 2, Color3.fromRGB(255, 255, 0), Color3.fromRGB(170, 170, 0))

	ServerCombatModule.stopAnims(char.Humanoid)

	char.Humanoid.Animator
		:LoadAnimation(WeaponAnimsFolder[char:GetAttribute("CurrentWeapon")].Blocking.GuardBreak)
		:Play()

	SoundsModule.PlaySound(WeaponSounds[char:GetAttribute("CurrentWeapon")].Blocking.GuardBreak, char.Torso)

	char:SetAttribute("Blocking", 0)
	char:SetAttribute("IsBlocking", false)

	local plr = players:GetPlayerFromCharacter(char)
	if plr then
		VFX_Event:FireClient(plr, "CustomShake", 6, 12, 0, 2)
	end

	StunHandler.Stun(char.Humanoid, 5)
end

function module.ActivateBlocking(char, npc)
	local hum = char.Humanoid
	local plr = players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc

	SoundsModule.PlaySound(WeaponSounds[char:GetAttribute("CurrentWeapon")].Blocking.BlockingStart, char.Torso)

	BlockingAnims[Identifier] =
		hum:LoadAnimation(WeaponAnimsFolder[char:GetAttribute("CurrentWeapon")].Blocking.Blocking)
	BlockingAnims[Identifier]:Play()

	char:SetAttribute("IsBlocking", true)

	local walkSpeed = WeaponStatsModule.getStats(char:GetAttribute("CurrentWeapon")).BlockingWalkSpeed

	hum.WalkSpeed = walkSpeed
	hum.JumpHeight = 0
end

function module.DeactivateBlocking(char, npc)
	local plr = players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc

	SoundsModule.PlaySound(WeaponSounds[char:GetAttribute("CurrentWeapon")].Blocking.BlockingStop, char.Torso)
	BlockingAnims[Identifier]:Stop()
	char:SetAttribute("IsBlocking", false)
	char:SetAttribute("LastStopTime", tick())

	ResetMobility(char)
end

function module.Dodging(char, eChar, hitpos)
	if not char or not eChar then
		return
	end
	local currentWeapon = eChar:GetAttribute("CurrentWeapon")
	local dir = eChar:GetAttribute("CurrentMoveKey")

	if dir == "None" then
		local Anim = WeaponAnimsFolder[currentWeapon].Dodging.None
		VFX_Event:FireAllClients("AfterImage", char, Anim, nil)
	else
		-- Once i make the dodge landed vfx it would go here play the vfx at hitpos
	end

	PassiveManger.DodgeLanded(char)
	-- SoundsModule.PlaySound() this would be used once i made a dodge landed sound
end

function module.Blocking(char, enemyChar, damage, hitPos)
	if enemyChar:GetAttribute("Blocking") <= 100 then
		local currentWeapon = char:GetAttribute("CurrentWeapon")
		local BlockDmg = WeaponStatsModule.getStats(currentWeapon).BlockDmg
		local data = WeaponStatsModule.getStats(currentWeapon)
		local ChipDmgPercent = data.ChipDamage
		local Result = "HitLanded"

		local ChipDmg = damage * (ChipDmgPercent / 100)

		enemyChar:SetAttribute("Blocking", enemyChar:GetAttribute("Blocking") + BlockDmg)
		enemyChar:SetAttribute("InCombat", true)
		enemyChar.Humanoid:TakeDamage(ChipDmg)

		print(ChipDmg)

		if enemyChar:GetAttribute("Blocking") >= 100 then
			module.GuardBreak(enemyChar)
			Result = "GuardBroken"
			return Result
		end

		VFX_Event:FireAllClients("Highlight", enemyChar, 0.5, Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 0))

		VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Block, hitPos, 3)

		SoundsModule.PlaySound(WeaponSounds[enemyChar:GetAttribute("CurrentWeapon")].Blocking.Blocked, enemyChar.Torso)

		enemyChar.Humanoid.Animator
			:LoadAnimation(WeaponAnimsFolder[enemyChar:GetAttribute("CurrentWeapon")].Blocking.Blocked)
			:Play()

		Result = "Blocked"
		return Result
	end

	return "WasHit"
end

return module
