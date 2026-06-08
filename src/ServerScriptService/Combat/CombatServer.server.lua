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

local function ServerEnemyCheck(char)
	if char and char:GetAttribute("IswallRunning") then return true end
	if char and char:GetAttribute("IsClimbing") then return true end
	if char and char:GetAttribute("Dodging") and char:GetAttribute("DodgeType") == "Airdodge" then return true end
	return false
end




CombatEvent.OnServerEvent:Connect(function(plr,action, target)
	if action == "Swing" then
		if ToolEquipped(plr.Character) then return end
		CombatHelperModule.Attack(plr.Character)
	end

	if action == "Feint" then 
		CombatHelperModule.CancelAttack(plr.Character)
	end

	if action == "Blink" then
		if ToolEquipped(plr.Character) then return end
		if target and not ServerEnemyCheck(target) then return end
		CombatHelperModule.Blink(plr.Character,nil,target)
		
		
	end
	
end)
