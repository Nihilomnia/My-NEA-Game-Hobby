local Players = game:GetService("Players")

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
	wait(0.5)
	local Blackboard = obj.Blackboard
	local closestPlayer = nil
	local closestDistance = math.huge
	for i,player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local PlayerPostion = player.Character.HumanoidRootPart.Position
			local distancetoPlayer = (obj.model.HumanoidRootPart.Position - PlayerPostion).Magnitude
			
			if distancetoPlayer <= obj.Range and distancetoPlayer < closestDistance then
				closestPlayer = player
				closestDistance = distancetoPlayer
			end
		end
	end
	
	if closestPlayer then
		obj.Target = closestPlayer.Character
		return SUCCESS
	else
		return FAIL
	end
end
return task
