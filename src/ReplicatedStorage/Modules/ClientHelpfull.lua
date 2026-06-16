local module = {}
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")







function module.CheckInFront(char, enemyChar)
	local enemyHRP = enemyChar.HumanoidRootPart
	local attackDirection = (char.HumanoidRootPart.Position - enemyHRP.Position).Unit
	local frontDirection = enemyHRP.CFrame.LookVector
	local direction = math.acos(attackDirection:Dot(frontDirection)) < math.rad(90)

	if not direction then
		print("Not infront")
		return false
	else
		print("infront")
		return true
	end
end



function module.CheckForAttributes(char, attack, swing, stun, ragdoll, equipped, blocking, Dodging, Sprinting)
	local attacking = char:GetAttribute("Attacking")
	local swinging = char:GetAttribute("Swing")
	local stunned = char:GetAttribute("Stunned")
	local isEquipped = char:GetAttribute("Equipped")
	local isRagdoll = char:GetAttribute("IsRagdoll")
	local isBlocking = char:GetAttribute("isBlocking")
	local isDodging = char:GetAttribute("Dodging")
	local isSprinting = char:GetAttribute("Sprinting")

	local stop = false

	if attacking and attack then
		stop = true
	end
	if swinging and swing then
		stop = true
	end
	if stunned and stun then
		stop = true
	end
	if isRagdoll and ragdoll then
		stop = true
	end
	if equipped and not isEquipped then
		stop = true
	end
	if blocking and isBlocking then
		stop = true
	end
	if Dodging and isDodging then
		stop = true
	end
	if Sprinting and isSprinting then
		stop = true
	end
	return stop
end










return module
