local module = {}

local players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")





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


local VFX_Event = Events.VFX


local SoundsModule = require(RSModules.Combat.SoundsModule)
local ServerCombatModule = require(SSModule.CombatModule)
local WeaponStatsModule =require(SSModule.Dictionaries.WeaponStats)
local StunHandler = require(SSModule.Other.StunHandlerV2)



local function ResetMobility(char)
	local hum = char.Humanoid
	if char:GetAttribute("IsLow") and char:GetAttribute("InCombat") then
		if char:GetAttribute("Sprinting") then
			hum.WalkSpeed = (StarterPlayer.CharacterWalkSpeed) * 1.25
			
		else
            hum.WalkSpeed = (StarterPlayer.CharacterWalkSpeed) / 2
		    hum.JumpHeight = (StarterPlayer.CharacterJumpHeight) / 2
			
		end
		
	else 
		if char:GetAttribute("Sprinting") then
			hum.WalkSpeed = (StarterPlayer.CharacterWalkSpeed) * 2
			hum.JumpHeight = StarterPlayer.CharacterJumpHeight
			
		else
            hum.WalkSpeed = StarterPlayer.CharacterWalkSpeed
		    hum.JumpHeight = StarterPlayer.CharacterJumpHeight
			
			
		end
	end
end



function module.Parrying(char,eChar,hitPos,npc)
	local identifier = players:GetPlayerFromCharacter(eChar) or npc
	SucessfulParry[identifier] = true
	ParryAnims[identifier]:Stop()
	-- Kill the parry anims to prevent the rest of the parry process from being ran so cooldowns are not triggered

	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local BlockDmg = WeaponStatsModule.getStats(currentWeapon).BlockDmg
	char:SetAttribute("Blocking",char:GetAttribute("Blocking")+ BlockDmg)
	eChar:SetAttribute("Blocking",eChar:GetAttribute("Blocking")- BlockDmg)
	eChar:SetAttribute("InCombat",true)
	
	if eChar:GetAttribute("Blocking") < 0 then eChar:SetAttribute("Blocking",0) end

	if	char:GetAttribute("Blocking")>= 100 then
		module.GuardBreak(char)
		return
	end

	VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Parry, hitPos,3)
	SoundsModule.PlaySound(WeaponSounds[eChar:GetAttribute("CurrentWeapon")].Blocking.Parry,eChar.Torso)
	
	ServerCombatModule.stopAnims(char.Humanoid)
	
	char.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[char:GetAttribute("CurrentWeapon")].Blocking.GotParried):Play()
	local plr = players:GetPlayerFromCharacter(char)
	if plr then VFX_Event:FireClient(plr, "CustomShake", 4,8,0,1.2) end
	
	StunHandler.Stun(char.Humanoid,0.45,5,0)
	

end





function module.GuardBreak(char)
	VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.GuardBreak, char.HumanoidRootPart.CFrame,3)
	
	VFX_Event:FireAllClients("Highlight",char,2,Color3.fromRGB(255, 255, 0),Color3.fromRGB(170, 170, 0))
	
	ServerCombatModule.stopAnims(char.Humanoid)
	
	char.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[char:GetAttribute("CurrentWeapon")].Blocking.GuardBreak):Play()
	
	SoundsModule.PlaySound(WeaponSounds[char:GetAttribute("CurrentWeapon")].Blocking.GuardBreak,char.Torso)
	
	char:SetAttribute("Blocking",0)
	char:SetAttribute("IsBlocking",false)
	
	
	local plr = players:GetPlayerFromCharacter(char)
	if plr then VFX_Event:FireClient(plr, "CustomShake", 6,12,0,2) end
	
	StunHandler.Stun(char.Humanoid,2.5)
end


function module.ActivateBlocking(char,npc)
	local hum = char.Humanoid
	local plr = players:GetPlayerFromCharacter(char) 
	local Identifier = plr or npc

	

    SoundsModule.PlaySound(WeaponSounds[char:GetAttribute("CurrentWeapon")].Blocking.BlockingStart, char.Torso)

	BlockingAnims[Identifier] = hum:LoadAnimation(WeaponAnimsFolder[char:GetAttribute("CurrentWeapon")].Blocking.Blocking)
	BlockingAnims[Identifier]:Play()

	char:SetAttribute("IsBlocking", true)

	local walkSpeed = WeaponStatsModule.getStats(char:GetAttribute("CurrentWeapon")).BlockingWalkSpeed

	hum.WalkSpeed = walkSpeed
	hum.JumpHeight = 0
	
end


function module.DeactivateBlocking(char,npc)
	local plr = players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc

	SoundsModule.PlaySound(WeaponSounds[char:GetAttribute("CurrentWeapon")].Blocking.BlockingStop, char.Torso)
	BlockingAnims[Identifier]:Stop()
	char:SetAttribute("IsBlocking", false)
	char:SetAttribute("LastStopTime", tick())


	ResetMobility(char)
	
end


function module.Blocking(char, enemyChar,damage,hitPos)
	if enemyChar:GetAttribute("Blocking") <= 100 then
		local currentWeapon = char:GetAttribute("CurrentWeapon")
		local BlockDmg = WeaponStatsModule.getStats(currentWeapon).BlockDmg
		local data = WeaponStatsModule.getStats(currentWeapon)
		local ChipDmgPercent = data.ChipDamage
		print(data)
		print(ChipDmgPercent)

		

		local ChipDmg = damage * (ChipDmgPercent / 100)

		enemyChar:SetAttribute("Blocking", enemyChar:GetAttribute("Blocking") + BlockDmg)
		enemyChar:SetAttribute("InCombat",true)
		enemyChar.Humanoid:TakeDamage(ChipDmg)

		print(ChipDmg)
		
		if enemyChar:GetAttribute("Blocking") >= 100 then
			module.GuardBreak(enemyChar)
			return
		end
		
		VFX_Event:FireAllClients("Highlight",enemyChar,.5,Color3.fromRGB(255, 255, 0),Color3.fromRGB(255, 255, 0))
		
		VFX_Event:FireAllClients("CombatEffects", RS.Effects.Combat.Block, hitPos,3)
		
		SoundsModule.PlaySound(WeaponSounds[enemyChar:GetAttribute("CurrentWeapon")].Blocking.Blocked,enemyChar.Torso)
		
		enemyChar.Humanoid.Animator:LoadAnimation(WeaponAnimsFolder[enemyChar:GetAttribute("CurrentWeapon")].Blocking.Blocked):Play()
		
	end
end



return module
