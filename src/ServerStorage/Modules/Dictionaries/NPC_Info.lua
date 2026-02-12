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

	[""] = {
		Type = "SmallFry",
		Race = "Anomaly",
		MobType = "Humanoid",
		Element = "Astral",
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
