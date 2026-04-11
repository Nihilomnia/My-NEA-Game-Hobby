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
	}

	








}



function NPC_Info.getStats(npc)
	return info[npc]
end

return NPC_Info
