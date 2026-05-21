local ServerScriptService = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PLRModule = require(ServerStorage.Modules.Objects.plr)

local Events = RS.Events
local StatsEvent = Events.StatsEvent
local VFXEvent = Events.VFX


local Helpful = require(ServerStorage.Modules.Other.Helpful)

--- Data Constants  DO NOT TOUCH THIS WILL NUKE THE PLAYERS DATA IF HANDLED WRONG
local DataManager = require(ServerScriptService.Data.Modules.DataManager)

-- Configs
local CONFIG = {
	VIT = {
		BASE_HEALTH = 250,
		VIT_HEALTH_MULTIPLIER = 1,
		LOW_HEALTH_THRESHOLD = 0.25,
	},

	END = {
		BASE_HIGH_STAMINA = 25,
		BASE_LOW_STAMINA = 15,
	},

	SPT = {

		BASE_MANA = 250,
		BASE_HIGH_MANA = 50,
		BASE_LOW_MANA = 30,

		BASE_MF = 120,
		BASE_HIGH_MF = 25,
		BASE_LOW_MF = 15,

	},


	EXP = {
		k = 0.08,
		MidPoint = 50,


	}


	
	
}

--- Functions
local function updatePlayerStats(plr, char, Stat)
	DataManager.IncreaseStat(plr, Stat)
end

local function setupHealth(char)
	local hum = char:WaitForChild("Humanoid")

	local VIT = char:GetAttribute("VIT") or 0
	hum.MaxHealth = CONFIG.VIT.BASE_HEALTH + (VIT * CONFIG.VIT.VIT_HEALTH_MULTIPLIER)
	hum.Health = hum.MaxHealth

	-- Update max health when VIT changes
	char:GetAttributeChangedSignal("VIT"):Connect(function()
		local VIT = char:GetAttribute("VIT") or 0
		hum.MaxHealth = CONFIG.VIT.BASE_HEALTH + (VIT * CONFIG.VIT.VIT_HEALTH_MULTIPLIER)
	end)

	-- Monitor low health state
	hum.HealthChanged:Connect(function()
		if hum.Health <= hum.MaxHealth * CONFIG.VIT.LOW_HEALTH_THRESHOLD then
			char:SetAttribute("IsLow", true)
			Helpful.ResetMobility(char)
		else
			char:SetAttribute("IsLow", false)
			Helpful.ResetMobility(char)
		end
	end)
end

local function setupStamina(char)
	local MaxStamina = 0

	local function sync(char)
		local END = char:GetAttribute("END") or 0
	
		if END >= 1 and END <= 15 then
			MaxStamina = math.ceil(80 + CONFIG.END.BASE_HIGH_STAMINA * ((END - 1) / 14))
			char:SetAttribute("MaxStamina", MaxStamina)
			char:SetAttribute("Stamina", MaxStamina)
			print("MaxSet")
		elseif END >= 16 and END <= 35 then
			MaxStamina = math.ceil(105 + CONFIG.END.BASE_HIGH_STAMINA * ((END - 15) / 15))
			char:SetAttribute("MaxStamina", MaxStamina)
			char:SetAttribute("Stamina", MaxStamina)
		elseif END >= 36 and END <= 60 then
			MaxStamina = math.ceil(130 + CONFIG.END.BASE_HIGH_STAMINA * ((END - 30) / 20))
			char:SetAttribute("MaxStamina", MaxStamina)
			char:SetAttribute("Stamina", MaxStamina)
		elseif END >= 61 and END <= 99 then
			MaxStamina = math.ceil(155 + CONFIG.END.BASE_LOW_STAMINA * ((END - 50) / 49))
			char:SetAttribute("MaxStamina", MaxStamina)
			char:SetAttribute("Stamina", MaxStamina)

		end
	end
	sync(char)

	char:GetAttributeChangedSignal("END"):Connect(function()
		local Orginal = char:GetAttribute("Stamina")
		sync(char)
		if char:GetAttribute("InCombat") then
			char:SetAttribute("Stamina", Orginal)
		end

		print("New Target for STM = {", MaxStamina, "}")
		
	end)
end


local function setupSPT(char)
	local MaxMana = 0
	local MaxMF = 0

	local function sync(char)
		local SPT = char:GetAttribute("SPT") or 0

		if SPT == 0 then
			MaxMana = CONFIG.SPT.BASE_MANA
			MaxMF = CONFIG.SPT.BASE_MF
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)
			char:SetAttribute("MaxMF", MaxMF)
			char:SetAttribute("MF", MaxMF)
		end
	
		if SPT >= 1 and SPT <= 15 then
			MaxMana = math.ceil(80 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 1) / 14))
			MaxMF = math.ceil(40 + CONFIG.SPT.BASE_HIGH_MF * ((SPT - 1) / 28))
			char:SetAttribute("MaxMF", MaxMF)
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)
			print("MaxSet")
		elseif SPT >= 16 and SPT <= 35 then
			MaxMana = math.ceil(105 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 15) / 15))
			MaxMF = math.ceil(53 + CONFIG.SPT.BASE_HIGH_MF * ((SPT - 15) / 30))
			char:SetAttribute("MaxMF", MaxMF)
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)
		elseif SPT >= 36 and SPT <= 60 then
			MaxMana = math.ceil(130 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 30) / 20))
			MaxMF = math.ceil(65 + CONFIG.SPT.BASE_HIGH_MF * ((SPT - 30) / 40))
			char:SetAttribute("MaxMF", MaxMF)
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)
		elseif SPT >= 61 and SPT <= 99 then
			MaxMana = math.ceil(155 + CONFIG.SPT.BASE_LOW_MANA * ((SPT - 50) / 49))
			MaxMF = math.ceil(78 + CONFIG.SPT.BASE_LOW_MF * ((SPT - 50) / 80))
			char:SetAttribute("MaxMF", MaxMF)
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)

		end
	end
	sync(char)

	char:GetAttributeChangedSignal("SPT"):Connect(function()
		local Orginal_Mana = char:GetAttribute("Mana")
		local Orginal_MF = char:GetAttribute("MF")
		sync(char)
		if char:GetAttribute("InCombat") then
			char:SetAttribute("Mana", Orginal_Mana)
			char:SetAttribute("MF", Orginal_MF)
		end

		print("New Target for MANA = {", MaxMana, "}")
		print("New Target for MF = {", MaxMF, "}")
		
	end)
end




--- Player stats initialization  has been moved to the my custom PLR object  .new function



StatsEvent.OnServerEvent:Connect(function(plr,action,Stat)
	local char = plr.Character
	local PLR = PLRModule.GetPLRFromPlayer(plr)
	local EXP = PLR.Data.GeneralExp
	local FreePoints = PLR.Data.FreePoints
	local Stat_EXP = PLR.Data.AttributeExp[Stat]
	local StatPoints = PLR.Data.STAT_POINTS[Stat]
	if StatPoints >= 99 then return end
	if action == "Train_Item" then
		local EXP_Cost = EXP * 0.15 -- We take 15% of the players general EXP to be converted into Attribute EXP per training item use
		Stat_EXP = Stat_EXP  + EXP_Cost
		EXP = EXP - EXP_Cost
		

		local Required_EXP = 100 + (2300/(1+ math.exp(-CONFIG.EXP.k * ((StatPoints + 1) - CONFIG.EXP.MidPoint)))) 

		if Stat_EXP >= Required_EXP then
			Stat_EXP = Stat_EXP - Required_EXP
			PLR:IncreaseStat(Stat, 1)
			VFXEvent:FireAllClients("CombatEffects", "LevelUp", char.HumanoidRootPart.CFrame, 2)
		end
	end

	if action == "Train_Free" and FreePoints > 0 then
		PLR:IncreaseStat(Stat, 1)
		PLR.Data.FreePoints = FreePoints - 1
		VFXEvent:FireAllClients("CombatEffects", "LevelUp", char.HumanoidRootPart.CFrame, 2)
	end
end)
