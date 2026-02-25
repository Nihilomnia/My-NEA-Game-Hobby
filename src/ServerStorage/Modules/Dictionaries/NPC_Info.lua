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

	["Bandit"] = {
		Type = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
		Chest = false,
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
	},

	["Boss"] = {
		Type = "Boss",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "...",
		Chest = true,
		ChestType = "...",
		Health = 10000,
		Skills = {},
		Talents = {},
		Drops = {},
	}








}



function NPC_Info.getStats(npc)
	return info[npc]
end

return NPC_Info
