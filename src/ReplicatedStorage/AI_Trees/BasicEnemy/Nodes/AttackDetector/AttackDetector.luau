local task = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

-- This checks if the target is attacking



function task.start(obj)
	print("Starting AttackDetector for",obj.Name)
	print(obj.Target.Name, "Is the attacker")
	
	local Blackboard = obj.Blackboard
	
end
function task.finish(obj, status)
	
	
	local Blackboard = obj.Blackboard 
	
end	
function task.run(obj)
	if obj.Target then
		local TargetChar = obj.Target
		
		if TargetChar:GetAttribute("Attacking") == true and TargetChar:GetAttribute("Swing") == true then
			print("The target is fighting back!")
			return SUCCESS
		else
			print("Attack Now!")
			return SUCCESS
		end
	end
end
return task
