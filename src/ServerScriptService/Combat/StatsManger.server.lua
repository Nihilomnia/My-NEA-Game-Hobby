
local RS = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PLRModule = require(ServerStorage.Modules.Objects.plr)

local Events = RS.Events
local StatsEvent = Events.StatsEvent
local VFXEvent = Events.VFX


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







--- Player stats initialization  has been moved to the my custom PLR object  .new function




StatsEvent.OnServerEvent:Connect(function(plr,action,Stat)
	local char = plr.Character
	local PLR = PLRModule.GetPLRFromPlayer(plr)
	local EXP = PLR.Data.GeneralExp
	local FreePoints = PLR.Data.FreePoints
	local Stat_EXP = PLR.Data.AttributeExp[Stat]
	local StatPoints = PLR.Data.STAT_POINTS[Stat]
	local Totalpoints = 0

	for i, stats in pairs(PLR.Stats) do
		if stats then
			Totalpoints += stats
		end
	end



	if StatPoints < 99 and Totalpoints < 350  then return end
	if action == "Train_Item" then
		local EXP_Cost = EXP * 0.15 -- We take 15% of the players general EXP to be converted into Attribute EXP per training item use
		Stat_EXP = Stat_EXP  + EXP_Cost
		EXP = EXP - EXP_Cost
		

		local Required_EXP = 100 + (2300/(1+ math.exp(-CONFIG.EXP.k * ((StatPoints + 1) - CONFIG.EXP.MidPoint)))) 

		if Stat_EXP >= Required_EXP then
			Stat_EXP = Stat_EXP - Required_EXP
			PLR:IncreaseStat(Stat, 1)
			--VFXEvent:FireAllClients("CombatEffects", "LevelUp", char.HumanoidRootPart.CFrame, 2)
		end
	end

	if action == "Train_Free" and FreePoints > 0 then
		PLR:IncreaseStat(Stat, 1)
		PLR.Data.FreePoints = FreePoints - 1
		--VFXEvent:FireAllClients("CombatEffects", "LevelUp", char.HumanoidRootPart.CFrame, 2)
	end
end)
