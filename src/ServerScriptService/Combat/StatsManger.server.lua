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
		sync(char)
		if char:GetAttribute("InCombat") then
			local Orginal = char:GetAttribute("Stamina")
			char:SetAttribute("Stamina", Orginal)
		end

		print("New Target for STM = {", MaxStamina, "}")
		
	end)
end


local function setupMF(char) -- MF stands for Mental Fortitude its shorter here for ease of typing 
	-- What should Mental FOritdude Scale with? Prob SPT(Spirit)
	
end


local function SetupMana(char)
	-- Mana should definately scale with SPT
	-- A good idea might be to use the Stamina scaling forulua as a base
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
	end)
end)
