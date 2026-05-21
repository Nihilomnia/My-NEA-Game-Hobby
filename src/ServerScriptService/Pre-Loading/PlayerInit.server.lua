local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local SSModules = SS.Modules
local PLRModule = require(SSModules.Objects.plr)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.01)
		PLRModule.new(plr, "SLOT_1")
		print("created plr", plr)
	end)
end)


Players.PlayerRemoving:Connect(function(plr)
	local PLR = PLRModule.GetPLRFromPlayer(plr)
	if PLR then
		PLR:Destroy()
	end
end)