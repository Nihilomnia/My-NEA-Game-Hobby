local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules

local CombatHelperModule =require(SSModules.Combat.CombatHelper)
local ParryModule = require(SSModules.Parrying)
local BlockModule  = require(SSModules.BlockModule)
local DodgeModule = require(SSModules.DodgeModule)

local task = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

-- Any arguments passed into Tree:run(obj) can be received after the first parameter, obj
-- Example: Tree:run(obj,deltaTime) - > task.start(obj, deltaTime), task.run(obj, deltaTime), task.finish(obj, status, deltaTime)

-- Blackboards
	-- objects attached to the tree have tables injected into them called Blackboards.
	-- these can be read from and written to by the tree using the Blackboard node, and can be accessed in tasks via object.Blackboard
--

function task.start(obj)
	
	local Blackboard = obj.Blackboard
	
end
function task.finish(obj, status)
	--[[
		(optional) this function is called directly after the run method
		is completed with either success() or fail(). It allows you to clean up
		things, after you run the task.
	--]]
	
	local Blackboard = obj.Blackboard 
	
end	
function task.run(obj)
	local Blackboard = obj.Blackboard
	local Target  = obj.Target

	if not Target then
		return FAIL
	end

	local TargetHRP = Target:FindFirstChild("HumanoidRootPart")
	local TargetHum = Target:FindFirstChild("Humanoid")
	local NPC_HRP = obj.model:FindFirstChild("HumanoidRootPart")
	local NPC_Hum = obj.model:FindFirstChild("Humanoid")

	if not TargetHum or TargetHum.Health <= 0 then
		return FAIL
	end

	local dist = (NPC_HRP.Position - TargetHRP.Position).Magnitude

	if dist > obj.AttackRange then
		return FAIL
	end

	-- Reaction time (fairness)
    wait(math.random(12,30)/100)

	if Target:GetAttribute("Attacking") or Target:GetAttribute("Swing") then

		local ParryChance = 35      -- Lower = fairer
		local DodgeChance = 20
		local BlockChance = 45

		local roll = math.random(1,100)
		
		local Directions = {"W", "A", "S", "D"}
		local Direction = Directions[math.random(1,#Directions)]

		if roll <= DodgeChance then
			DodgeModule.Dodge(obj.model,nil,Direction)
			return RUNNING
		elseif roll <= DodgeChance + ParryChance then
			ParryModule.ParryAttempt(obj.model)
			return RUNNING
		else
			BlockModule.ActivateBlocking(obj.model)

			-- Auto release block
			wait(math.random(6,12)/10, function()
				if obj.model and obj.model:GetAttribute("Blocking") then
					BlockModule.DeactivateBlocking(obj.model)
				end
			end)

			return RUNNING
		end

	else
		
		if math.random(1,100) <= 85 then
			CombatHelperModule.Attack(obj.model)
			return RUNNING
		else
			-- NPC hesitates sometimes (feels human)
			return RUNNING
		end
	end
end

return task
