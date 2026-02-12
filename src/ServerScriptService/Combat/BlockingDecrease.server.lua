local CONFIG = {
	BLOCKING = {
		BASE_DECREASE_TIME = 3,
		BASE_DECREASE_AMOUNT = 2
	},

	STAMINA = {
		BASE_REGEN_TIME = 5,
		BASE_REGEN_PERCENT = 9
	},

	MANA = {
		BASE_REGEN_TIME = 2,
		COMBAT_REGEN_TIME = 5,
		BASE_REGEN_PERCENT = 10, -- this is for  out of comabt
		COMBAT_REGEN_PERCENT = 5

	}
}








local connectionRunning_Blocking = {}
local connectionRunning_Stamina = {}

local function WaitForAttributes(char, attributeList, timeout)
	timeout = timeout or 5
	local start = os.clock()

	while char.Parent do
		local allReady = true

		for _, attr in ipairs(attributeList) do
			if char:GetAttribute(attr) == nil then
				allReady = false
				break
			end
		end

		if allReady then
			return true
		end

		if os.clock() - start >= timeout then
			warn("Attributes not ready:", char, attributeList)
			return false
		end

		task.wait()
	end

	return false
end


local function onBlockingChanged(char)
	if char:GetAttribute("Blocking") > 0 and connectionRunning_Blocking[char] == nil then 
		connectionRunning_Blocking[char] = true
		
		local signalConnection = nil
		signalConnection = char:GetAttributeChangedSignal("Blocking"):Connect(function()
			onBlockingChanged(char)
		end)
		
		coroutine.wrap(function()


			while char:GetAttribute("Blocking") > 0 do
				task.wait(1)
				for i, humanoids in char:GetChildren() do
					if humanoids:IsA("Humanoid") then
						local char = humanoids.Parent
						if  char then
							
							local  isBlocking = char:GetAttribute("IsBlocking")
							local  lastStopTime = char:GetAttribute("LastStopTime") or 0
							local currentTime = tick()
							local DecreaseBlockingTime = CONFIG.BLOCKING.BASE_DECREASE_TIME
							local DeccreaseAmount = CONFIG.BLOCKING.BASE_DECREASE_AMOUNT
							
							if not isBlocking and currentTime - lastStopTime >= DecreaseBlockingTime then
								char:SetAttribute("Blocking",math.max(char:GetAttribute("Blocking")-DeccreaseAmount))
							end
							
						end
					end
				end
			end
			connectionRunning_Blocking[char] = nil
			signalConnection:Disconnect()
		end)()
	end
end

local function CheckForStatus(char)
	if not char or not char.Parent then return true end

	local Swing = char:GetAttribute("Swing")
	local Dodging = char:GetAttribute("Dodging")

	if Swing or Dodging then
		char:SetAttribute("StopTime_Stam", os.clock())
		return true
	end

	return false
end


local function StartStaminaRegen(char)
	if connectionRunning_Stamina[char] then return end
	if not char or not char.Parent then return end

	local stamina = char:GetAttribute("Stamina")
	local maxStamina = char:GetAttribute("MaxStamina")

	if stamina >= maxStamina then return end

	connectionRunning_Stamina[char] = true
	char:SetAttribute("StopTime_Stam", os.clock())

	task.spawn(function()
		while char.Parent
			and char:GetAttribute("Stamina") < char:GetAttribute("MaxStamina") do

			task.wait(1)

			local stopped = CheckForStatus(char)
			local lastStop = char:GetAttribute("StopTime_Stam") or os.clock()

			if not stopped and os.clock() - lastStop >= CONFIG.STAMINA.BASE_REGEN_TIME then
				local regenAmount = math.ceil(
					char:GetAttribute("MaxStamina")
					* (CONFIG.STAMINA.BASE_REGEN_PERCENT / 100)
				)

				char:SetAttribute(
					"Stamina",
					math.min(
						char:GetAttribute("Stamina") + regenAmount,
						char:GetAttribute("MaxStamina")
					)
				)
			end
		end

		connectionRunning_Stamina[char] = nil
	end)
end

local function SetupCharacter(char)
	if not char then return end
	local ok = WaitForAttributes(
		char,
		{ "Stamina", "MaxStamina" },
		6
	)

	if not ok then return end

	char:SetAttribute("StopTime_Stam", os.clock())

	char:GetAttributeChangedSignal("Stamina"):Connect(function()
		StartStaminaRegen(char)
	end)
end



local function SetupManaRegen(char)
	--- Mana regen- Lowkey function actually like STAM but i think the rate is going to be slower in combat and the wait time wil be like 1 secs or so
end













for i,v in workspace.NPC:GetChildren() do
	if v:IsA("Model") and  v:FindFirstChild("Humanoid") then
		v:GetAttributeChangedSignal("Blocking"):Connect(function()
			onBlockingChanged(v)
			SetupCharacter(v)
		end)
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		char:GetAttributeChangedSignal("Blocking"):Connect(function()
			 onBlockingChanged(char)
			 SetupCharacter(char)
		end)
	end)
end)

workspace.NPC.ChildAdded:Connect(function(child)
	if child:IsA("Model") and  child:FindFirstChild("Humanoid") then
		child:GetAttributeChangedSignal("Blocking"):Connect(function()
			onBlockingChanged(child)
			SetupCharacter(child)
		end)
	end

end)