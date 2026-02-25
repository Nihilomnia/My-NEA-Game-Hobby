local SimplePath = require(game:GetService("ReplicatedStorage").SimplePath)
local Players = game:GetService("Players")


local task = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3



function task.start(obj)
	print("The Hunt for", obj.Name, "'starget has begun!")
	
	if not obj.model.PrimaryPart then
		obj.model.PrimaryPart = obj.model.Human.RootPart
	end
	
	obj.path = SimplePath.new(obj.model)
	obj.path.Visualize = true
	obj.isPathRunning = false
	print(obj.path)
	
end


function task.finish(obj, status)
	if obj.path then
		if obj.path.Status == SimplePath.StatusType.Active then
			obj.path:Stop()
			obj.IsPathRunning = false
			wait(0.5)
		else
			--print("Path is already stopped") -- Debug output
		end
		
		obj.path:Destroy()
		obj.path = nil
	end
	
	obj.Blackboard.Target = nil
	
end	
function task.run(obj)
	print("Running the chase")
	wait(0.5)
	local Blackboard = obj.Blackboard
	local Target = obj.Target
	local AttackRange = obj.AttackRange
	local TargetValue = obj.Target
	
	if Target then
		local  TargetChar = Target
		local TargetHum = Target.Humanoid
		
		local NPC_HRP = obj.model.HumanoidRootPart
		local Target_HRP = TargetChar.HumanoidRootPart
		
		if not TargetHum or TargetHum.Health <= 0 then
			task.finish(obj,FAIL)
			return FAIL
		end
		
		local dist = (NPC_HRP.Position - Target_HRP.Position).Magnitude
		
		if dist <= AttackRange then
			print("The Hunt was a success")
			task.finish(obj,SUCCESS)
			return SUCCESS
		end
		
		if dist > obj.Range then
			task.finish(obj,FAIL)
			return FAIL
		end
		
		if not obj.isPathRunning then
			local success = obj.path:Run(Target_HRP.Position)
			
			if success then 
				obj.isPathRunning = true
				obj.path.Reached:Once(function()
					obj.isPathRunning = false
				end)
				
				obj.path.Blocked:Once(function()
					obj.isPathRunning = false
				end)
				
			else
				task.finish(obj,FAIL)
			end
		end
		
		if obj.human.Health <= 0 then
			task.finish(obj,FAIL)
			return FAIL
		end
		
		while obj.isPathRunning do
			wait(0.1)
			
			if obj.human.Health <=  0 then
				task.finish(obj,FAIL)
				return FAIL
			end
			
			obj.path:Run(Target_HRP.Position)
			
			dist = (NPC_HRP.Position - Target_HRP.Position).Magnitude
			
			if dist <= AttackRange then
				print("The Hunt was a success")
				task.finish(obj,SUCCESS)
				return SUCCESS
			end
			
		end
		
		return RUNNING
	else
		return FAIL
	end	
end
return task
