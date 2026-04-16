local NPC_Info = {}
local info = {
	["TestNPC"] = {
		Difficulty = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["ShootingStar"] = {
		Difficulty = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["FracturedKunai"] = {
		Difficulty = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},



	["TestNPC2"] = {
		Difficulty = "Elite",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	

	["Bandit"] = {
		Difficulty = "Elite",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Chest = false,
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["Asmondaios"] = {
		Difficulty = "Boss",
		Race = "Celestial",
		MobType = "Humanoid",
		Element = "Bone",
		Chest = true,
		ChestType = "...",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			Stamina = 255,
			MaxStamina = 255,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	}

	








}



function NPC_Info.getStats(npc)
	return info[npc]
end

return NPC_Info
