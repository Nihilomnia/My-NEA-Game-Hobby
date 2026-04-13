local NPC_Info = {}
local info = {
	["TestNPC"] = {
		Type = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10,000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			END = 10,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["ShootingStar"] = {
		Type = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10,000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			END = 10,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["FracturedKunai"] = {
		Type = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10,000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			END = 10,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},



	["TestNPC2"] = {
		Type = "Elite",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Health = 10,000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			END = 10,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	

	["Bandit"] = {
		Type = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Chest = false,
		Health = 10,000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			END = 10,
			STR = 10,
			SPT = 10,
			DEX = 10,
			AGL = 10,
			WPN = 10,
		},
	},

	["Asmondaios"] = {
		Type = "Boss",
		Race = "Celestial",
		MobType = "Humanoid",
		Element = "Bone",
		Chest = true,
		ChestType = "...",
		Health = 10,000,
		Skills = {},
		Talents = {},
		Drops = {},
		STAT_POINTS = {
			VIT = 10,
			END = 10,
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
