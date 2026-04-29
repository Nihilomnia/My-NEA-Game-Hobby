local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
 

local Events = RS.Events


local SSModules = SS.Modules

local CombatEvent = Events.Combat


local CombatHelperModule =require(SSModules.Combat.CombatHelper)

local function ToolEquipped(char:Model)
	local stop = false
	for _, thing in pairs(char:GetChildren()) do
		if thing:IsA("Tool") then
			stop = true
			print("You are using a tool so no action done")
			return stop
		end
	end
	
	return stop
end




CombatEvent.OnServerEvent:Connect(function(plr,action)
	if action == "Swing" then
		if ToolEquipped(plr.Character) then return end
		CombatHelperModule.Attack(plr.Character)
	end

	if action == "Feint" then 
		CombatHelperModule.CancelAttack(plr.Character)
	end
	
end)
