local Sprinting = {}
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local RSModules = RS.Modules
local Types = require(RSModules.Movement.Objects.Movement.Types)
local AnimationsFolder = RSModules.Movement.Objects.Movement.Animations

local Debounce = {}
local EX_Debounce = {}
local SprintConns = {}
local BaseSpeed = game:GetService("StarterPlayer").CharacterWalkSpeed
local cam = workspace.CurrentCamera

function Sprinting.CanSprint(MovementObj: Types.MovementObj)
	local char = MovementObj.char
	return not (
		char:GetAttribute("Stunned")
		or char:GetAttribute("IsRagdoll")
		or char:GetAttribute("IsBlocking")
		or char:GetAttribute("Attacking")
		or char:GetAttribute("IsCrouching")
		or MovementObj.IsActing.Climbing
		or MovementObj.IsActing.WallRunning
		or MovementObj.States.IsCrouching
	)
end

local function ResetSpeedCheck(MovementObj: Types.MovementObj)
	local char = MovementObj.char
	return not (
		char:GetAttribute("Stunned")
		or char:GetAttribute("IsBlocking")
		or char:GetAttribute("Attacking")
		or char:GetAttribute("IsCrouching")
		or MovementObj.IsActing.Climbing
		or MovementObj.IsActing.WallRunning
	)
end

local function selectionSprintAnim(MovementObj: Types.MovementObj)
	local Target = nil
	local char = MovementObj.char
	local Hum = char:FindFirstChildOfClass("Humanoid")

	if not char or not Hum then
		return
	end

	-- Safely clean up previous sprint animation tracks before loading a new one
	if MovementObj.InfoTable.Sprint.SprintAnim then
		MovementObj.InfoTable.Sprint.SprintAnim:Stop(0.1)
		MovementObj.InfoTable.Sprint.SprintAnim:Destroy()
		MovementObj.InfoTable.Sprint.SprintAnim = nil
	end

	if char:GetAttribute("Equipped") == true then
		if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
			Target = AnimationsFolder.Weapons[char:GetAttribute("CurrentWeapon")].IsLow.Sprint
		else
			Target = AnimationsFolder.Weapons[char:GetAttribute("CurrentWeapon")].Sprint
		end
	elseif char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
		Target = AnimationsFolder.IsLow.Sprint
	else
		Target = AnimationsFolder.Sprint
	end

	MovementObj.InfoTable.Sprint.SprintAnim = Hum.Animator:LoadAnimation(Target)
	MovementObj.InfoTable.Sprint.SprintAnim:Play(0.25)
end

-- Helper to completely clean up and reset all sprinting states safely
function Sprinting.ForceStopAllSprinting(MovementObj: Types.MovementObj)
	local char = MovementObj.char
	local Hum = char:FindFirstChildOfClass("Humanoid")

	MovementObj.IsActing.IsSprinting = false
	MovementObj.IsActing.IsEXSprinting = false

	if Hum and ResetSpeedCheck(MovementObj) then
		Hum.WalkSpeed = BaseSpeed
	end

	TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 70 }):Play()

	if MovementObj.InfoTable.Sprint.SprintAnim then
		MovementObj.InfoTable.Sprint.SprintAnim:Stop(0.2)
	end

	if SprintConns[MovementObj] then
		SprintConns[MovementObj]:Disconnect()
		SprintConns[MovementObj] = nil
	end

	MovementObj:ServerRequest("SprintEnd")
	MovementObj:ServerRequest("ExSprintEnd")
	MovementObj:UpdateWalkTracks()
end

function Sprinting.NormalToggle(MovementObj: Types.MovementObj)
	local char = MovementObj.char
	local Hum = char:FindFirstChildOfClass("Humanoid")

	if not Hum or not char or Debounce[MovementObj] then
		return
	end
	Debounce[MovementObj] = true

	-- IF SPRINTING: Stop everything
	if MovementObj.IsActing.IsSprinting or MovementObj.IsActing.IsEXSprinting then
		Sprinting.ForceStopAllSprinting(MovementObj)
		task.wait(0.1)
		Debounce[MovementObj] = false
	else
		-- IF NOT SPRINTING: Start normal sprint
		if not Sprinting.CanSprint(MovementObj) then
			Debounce[MovementObj] = false
			return
		end

		MovementObj.IsActing.IsSprinting = true
		MovementObj:ServerRequest("SprintStart")

		if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
			Hum.WalkSpeed = BaseSpeed * 1.25
		else
			Hum.WalkSpeed = BaseSpeed * 2
		end

		TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 80 })
			:Play()
		selectionSprintAnim(MovementObj)

		SprintConns[MovementObj] = RunService.Heartbeat:Connect(function()
			if not MovementObj.InfoTable.Sprint.SprintAnim then
				return
			end
			if MovementObj.States.IsInAir then
				MovementObj.InfoTable.Sprint.SprintAnim:AdjustSpeed(0.25)
			else
				MovementObj.InfoTable.Sprint.SprintAnim:AdjustSpeed(1)
			end
		end)

		MovementObj:ClearWalkAnims()
		task.wait(0.1)
		Debounce[MovementObj] = false
	end
end
function Sprinting.OnCharStateChanged(MovementObj: Types.MovementObj)
    local char = MovementObj.char
    local HRP = char:FindFirstChild("HumanoidRootPart")
    
    if not HRP or not char.Parent then return end

    -- If the character transitions into an illegal state or gets physically anchored
    if not Sprinting.CanSprint(MovementObj) or HRP.Anchored then
        
        -- Check if they are actively using any tier of sprint
        if MovementObj.IsActing.IsSprinting or MovementObj.IsActing.IsEXSprinting then
            
            -- Use a clean, single-frame force shutdown rather than fighting toggle debounces
            MovementObj.IsActing.IsSprinting = false
            MovementObj.IsActing.IsEXSprinting = false

            local Hum = char:FindFirstChildOfClass("Humanoid")
            if Hum and not (
                char:GetAttribute("Stunned")
                or char:GetAttribute("IsBlocking")
                or char:GetAttribute("Attacking")
                or char:GetAttribute("IsCrouching")
                or MovementObj.IsActing.Climbing
                or MovementObj.IsActing.WallRunning
            ) then
                Hum.WalkSpeed = BaseSpeed
            end

            -- Reset Camera FOV back down smoothly
            TS:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 70 }):Play()

            -- Clean up the animation tracks safely
            if MovementObj.InfoTable.Sprint.SprintAnim then
                MovementObj.InfoTable.Sprint.SprintAnim:Stop(0.1)
                MovementObj.InfoTable.Sprint.SprintAnim:Destroy()
                MovementObj.InfoTable.Sprint.SprintAnim = nil
            end

            -- Disconnect loop signals
            if SprintConns[MovementObj] then
                SprintConns[MovementObj]:Disconnect()
                SprintConns[MovementObj] = nil
            end

            -- Notify server of the forced cancellation state
            MovementObj:ServerRequest("SprintEnd")
            MovementObj:ServerRequest("ExSprintEnd")
            
            MovementObj:UpdateWalkTracks()
        end
    end
end

function Sprinting.ExToggle(MovementObj: Types.MovementObj)
	local char = MovementObj.char
	local Hum = char:FindFirstChildOfClass("Humanoid")

	if not Hum or not char or EX_Debounce[MovementObj] then
		return
	end
	EX_Debounce[MovementObj] = true

	-- IF ACTIVELY EX SPRINTING: Drop back down to normal sprint tier
	if MovementObj.IsActing.IsEXSprinting then
		MovementObj.IsActing.IsEXSprinting = false
		MovementObj:ServerRequest("ExSprintEnd")

		-- Reset speed and FOV back down to standard sprint tiers smoothly
		if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
			Hum.WalkSpeed = BaseSpeed * 1.25
		else
			Hum.WalkSpeed = BaseSpeed * 2
		end
        selectionSprintAnim(MovementObj) 
		TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 80 })
			:Play()

		task.wait(0.1)
		EX_Debounce[MovementObj] = false
	else
		-- IF NOT EX SPRINTING: Upgrade to ExSprint tier (must already be basic sprinting)
		if not MovementObj.IsActing.IsSprinting or not Sprinting.CanSprint(MovementObj) then
			EX_Debounce[MovementObj] = false
			return
		end

		MovementObj.IsActing.IsEXSprinting = true

		if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
			Hum.WalkSpeed = BaseSpeed * 1.5
		else
			Hum.WalkSpeed = BaseSpeed * 2.8
		end

		TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 90 })
			:Play()
		selectionSprintAnim(MovementObj)

		-- Ticking Validation Thread: Fires and evaluates server responses
		task.spawn(function()
			while MovementObj.IsActing.IsEXSprinting and char.Parent do
				-- Simply fire the server request tick
				MovementObj:ServerRequest("ExSprintStart")

				task.wait(0.5)

				-- Check if the server turned off our state because we ran out of stamina
				if char:GetAttribute("IsEXSprinting") == false then
					Sprinting.ForceStopAllSprinting(MovementObj)
					break
				end
			end
		end)

		task.wait(0.1)
		EX_Debounce[MovementObj] = false
	end
end

return Sprinting
