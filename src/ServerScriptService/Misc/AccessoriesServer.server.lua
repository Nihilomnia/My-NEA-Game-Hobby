local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local DataManager = require(script.Parent.Parent.Data.Modules.DataManager)
local AccessoriesModule = require(SS.Modules.Other.AccessoriesManager)

local Events = RS.Events
local AccessoryEvent = Events.AccessoryEvent


-- Player Acessory Initialization has been moved to the my custom PLR object  .new function



AccessoryEvent.OnServerEvent:Connect(function(plr, action, accessoryName, accessoryType)
	if action == "EquipAccessory" then
		local char = plr.Character
		if char:GetAttribute("InCombat") then
			return
		end -- Cant change accessories in combat

		AccessoriesModule.EquipAccessory(char, accessoryName)
		DataManager.UpdateAccessories(plr, accessoryType, accessoryName)
	end
end)

-- Player accessory cleanup  on remove has been moved to the my custom PLR object :Destroy function	