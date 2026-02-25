local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

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

	},
	
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


local function setupMF(char) -- MF stands for Mental Fatigue its shorter here for ease of typing 
	-- What should Mental Fatigue Scale with? Prob SPT(Spirit)
	

	
	
end

local function setupMana(char)
	local MaxMana = 0

	local function sync(char)
		local SPT = char:GetAttribute("SPT") or 0

		if SPT == 0 then
			MaxMana = CONFIG.SPT.BASE_MANA
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)
		end
	
		if SPT >= 1 and SPT <= 15 then
			MaxMana = math.ceil(80 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 1) / 14))
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)
			print("MaxSet")
		elseif SPT >= 16 and SPT <= 35 then
			MaxMana = math.ceil(105 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 15) / 15))
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)
		elseif SPT >= 36 and SPT <= 60 then
			MaxMana = math.ceil(130 + CONFIG.SPT.BASE_HIGH_MANA * ((SPT - 30) / 20))
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)
		elseif SPT >= 61 and SPT <= 99 then
			MaxMana = math.ceil(155 + CONFIG.SPT.BASE_LOW_MANA * ((SPT - 50) / 49))
			char:SetAttribute("MaxMana", MaxMana)
			char:SetAttribute("Mana", MaxMana)

		end
	end
	sync(char)

	char:GetAttributeChangedSignal("END"):Connect(function()
		local Orginal = char:GetAttribute("Stamina")
		sync(char)
		if char:GetAttribute("InCombat") then
			char:SetAttribute("Stamina", Orginal)
		end

		print("New Target for MANA = {", MaxMana, "}")
		
	end)
end





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

		char:SetAttribute("CurrentSlot", "SLOT_1") -- This is more of a placeholder in case we want to add multiple save slots later on
		local CurrentSlot = char:GetAttribute("CurrentSlot")
		for statName, value in pairs(profile.Data[CurrentSlot].STAT_POINTS) do
			char:SetAttribute(statName, value)
		end
		setupHealth(char)
		setupStamina(char)
		setupMana(char)
	end)
end)
