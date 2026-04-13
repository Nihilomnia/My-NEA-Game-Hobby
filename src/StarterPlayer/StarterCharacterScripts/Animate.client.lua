--[Services]--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local SFX = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")



local SoundsModule = require(RS.Modules.Combat.SoundsModule)

--[Player Variables]--
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local HRP: Part = char:WaitForChild("HumanoidRootPart")
local Hum = char:WaitForChild("Humanoid")
local cam = workspace.CurrentCamera


--[UI Variables]--
local playerGui = plr:WaitForChild("PlayerGui")
local MovementUI = playerGui:WaitForChild("MovementUI")
local top = MovementUI:WaitForChild("Top")
local bottom = MovementUI:WaitForChild("Bottom")




local Events = RS.Events
local MovementEvent = Events.Movement
local AccessoryEvent = Events.AccessoryEvent

-- Wait for CurrentWeapon
local CurrentWeapon = char:GetAttribute("CurrentWeapon")
while CurrentWeapon == nil do
	CurrentWeapon = char:GetAttribute("CurrentWeapon")
	if CurrentWeapon then
		break
	end
	task.wait(0.3)
end

--[Animation Setup]--
local WeaponAnimations = RS.Animations.Weapons
local AnimationsFolder = script.Animations
local MovementAnimationsFolder = WeaponAnimations[CurrentWeapon].Movement

local WallClimbAnim = Hum.Animator:LoadAnimation(MovementAnimationsFolder.WallClimb)
local ledgeGrab = Hum.Animator:LoadAnimation(MovementAnimationsFolder.LedgeGrab)

local AnimationsTable = {}
local SprintAnim = nil
local SprintTrack = nil
local conn

--[Raycast]--
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { char }
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

--[State]--
local canClimb = false
local lastClimbState = nil
local heldKeys = {}
local isInAir = false
local grounded = true
local IsClimbing = false
local IsHoldingLedge = false
local LedgeGrabCoolDown = false
local isSprinting = false
local debounce = false

local LastKeyPressTime = 0
local doubleTapThreshold = 0.3
local velocityDecay = 0.3
local MaxClimbheight = 40

local AirBorneStates = {
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
}

-------------------------------------------------
-- WALK ANIMATION SYSTEM
-------------------------------------------------
local function UpdateWalkTracks()
	for _, track in pairs(AnimationsTable) do
		track:Stop(0.1)
		track:Destroy()
	end

	local isEquipped = char:GetAttribute("Equipped")
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local IsLow = char:GetAttribute("IsLow")
	local InCombat = char:GetAttribute("InCombat")
	local targetFolder

	if isEquipped and currentWeapon and AnimationsFolder.Weapons:FindFirstChild(currentWeapon) then
		if IsLow and InCombat then
			targetFolder = AnimationsFolder.Weapons[currentWeapon].IsLow
		else
			targetFolder = AnimationsFolder.Weapons[currentWeapon]
		end
	else
		if IsLow and InCombat then
			targetFolder = AnimationsFolder.IsLow
		else
			targetFolder = AnimationsFolder
		end
	end

	AnimationsTable.WalkForward = Hum:LoadAnimation(targetFolder.WalkForward)
	AnimationsTable.WalkRight = Hum:LoadAnimation(targetFolder.WalkRight)
	AnimationsTable.WalkLeft = Hum:LoadAnimation(targetFolder.WalkLeft)
	AnimationsTable.WalkBack = Hum:LoadAnimation(targetFolder.WalkBack)

	for _, track in pairs(AnimationsTable) do
		track:Play(0.1, 0, 0)
	end
end

char:GetAttributeChangedSignal("CurrentWeapon"):Connect(UpdateWalkTracks)
char:GetAttributeChangedSignal("Equipped"):Connect(UpdateWalkTracks)
char:GetAttributeChangedSignal("IsLow"):Connect(UpdateWalkTracks)
char:GetAttributeChangedSignal("InCombat"):Connect(UpdateWalkTracks)
AccessoryEvent.OnClientEvent:Connect(function(action)
	if action == "RefreshAnimations" then
		UpdateWalkTracks()
	end
end)

UpdateWalkTracks()

-------------------------------------------------
-- WALL CLIMB
-------------------------------------------------
local function triggerWallClimb()
	grounded = false
	IsClimbing = true
	char:SetAttribute("IsClimbing", true)

	WallClimbAnim:Play()

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = HRP.CFrame.lookVector + Vector3.new(0, MaxClimbheight, 0)
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Parent = HRP
	Debris:AddItem(bv, velocityDecay)

	task.delay(0.2, function()
		SoundsModule.PlaySound(SFX.SFX.Movement.ClimbSound)
	end)

	task.delay(1, function()
		IsClimbing = false
		char:SetAttribute("IsClimbing", false)
	end)
end

-------------------------------------------------
-- SPRINT SYSTEM
-------------------------------------------------
local baseSpeed = 16 -- Single source of truth for default speed

local function canSprint()
    return not (
        char:GetAttribute("Stunned")
        or char:GetAttribute("IsRagdoll")
        or char:GetAttribute("IsBlocking")
        or char:GetAttribute("Attacking")
        or char:GetAttribute("IsCrouching")
    )
end

local function ResetSpeedCheck()
    return not (
        char:GetAttribute("Stunned")
        and not char:GetAttribute("IsBlocking")
        and not char:GetAttribute("Attacking")
        and not char:GetAttribute("IsCrouching")
    )
end

local function selectSprintAnim()
    if SprintAnim then SprintAnim:Stop() end

    if char:GetAttribute("Equipped") == true then
        if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
            SprintTrack = AnimationsFolder.Weapons[char:GetAttribute("CurrentWeapon")].IsLow.Sprint
        else
            SprintTrack = AnimationsFolder.Weapons[char:GetAttribute("CurrentWeapon")].Sprint
        end
    elseif char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
        SprintTrack = AnimationsFolder.IsLow.Sprint
    else
        SprintTrack = AnimationsFolder.Sprint
    end

    if char:GetAttribute("Sprinting") then
        SprintAnim = Hum.Animator:LoadAnimation(SprintTrack)
        SprintAnim:Play(0.25)
    end
end

local function toggleSprintState()
    if isSprinting and not debounce then
        debounce = true

        if ResetSpeedCheck() then
            Hum.WalkSpeed = baseSpeed -- Always restore to base, not a divided value
        end

        TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 70 }):Play()
        isSprinting = false

        if SprintAnim then SprintAnim:Stop() end
        if conn then conn:Disconnect() end

        UpdateWalkTracks()
        char:SetAttribute("Sprinting", false)
        task.wait(0.1)
        debounce = false

    elseif not isSprinting and not debounce then
        char:SetAttribute("Sprinting", true)

        -- Always multiply from baseSpeed, never from current WalkSpeed
        if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
            Hum.WalkSpeed = baseSpeed * 1.25
        else
            Hum.WalkSpeed = baseSpeed * 2
        end

        TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 80 }):Play()
        isSprinting = true

        selectSprintAnim()

        conn = RunService.Heartbeat:Connect(function()
            if AirBorneStates[Hum:GetState()] then
                SprintAnim:AdjustSpeed(0.25)
            else
                SprintAnim:AdjustSpeed(1)
            end
        end)

        for _, track in pairs(AnimationsTable) do
            track:Stop(0.1)
            track:Destroy()
        end
    end
end

local function OnCharStateChanged()
    if not canSprint() or HRP.Anchored then
        if isSprinting then toggleSprintState() end
    end
end

-- AstralDodge: stop sprint, apply speed boost on top of baseSpeed, then restore
MovementEvent.OnClientEvent:Connect(function(action)
    if action == "AstralDodge" then
		print("Speed START")
        -- Stop sprint cleanly first
        if isSprinting then toggleSprintState() end

        -- Apply dodge speed boost from baseSpeed, not current WalkSpeed
        local dodgeSpeed = baseSpeed * 5
        Hum.WalkSpeed = dodgeSpeed
		TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 160 }):Play()

        task.delay(5, function()
            -- Only restore if nothing else took over speed
            if not isSprinting then
                Hum.WalkSpeed = baseSpeed
				TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 70 }):Play()
            end
        end)
    end
end)

char:GetAttributeChangedSignal("Equipped"):Connect(selectSprintAnim)
char:GetAttributeChangedSignal("Attacking"):Connect(OnCharStateChanged)
char:GetAttributeChangedSignal("Stunned"):Connect(OnCharStateChanged)
char:GetAttributeChangedSignal("IsBlocking"):Connect(OnCharStateChanged)

-------------------------------------------------
-- RENDER STEPPED — Walk weights
-------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not AnimationsTable.WalkForward then
		return
	end

	local DirectionOfMovement = HRP.CFrame:VectorToObjectSpace(HRP.AssemblyLinearVelocity)
	local walkSpeed = Hum.WalkSpeed

	local Forward = math.abs(math.clamp(DirectionOfMovement.Z / walkSpeed, -1, -0.001))
	local Backwards = math.abs(math.clamp(DirectionOfMovement.Z / walkSpeed, 0.001, 1))
	local Right = math.abs(math.clamp(DirectionOfMovement.X / walkSpeed, 0.001, 1))
	local Left = math.abs(math.clamp(DirectionOfMovement.X / walkSpeed, -1, -0.001))
	local SpeedUnit = DirectionOfMovement.Magnitude / walkSpeed

	if DirectionOfMovement.Z / walkSpeed < 0.1 then
		AnimationsTable.WalkForward:AdjustWeight(math.max(Forward, Backwards))
		AnimationsTable.WalkRight:AdjustWeight(Right)
		AnimationsTable.WalkLeft:AdjustWeight(Left)

		local playbackSpeed = (DirectionOfMovement.Z > 0) and -SpeedUnit or SpeedUnit
		AnimationsTable.WalkForward:AdjustSpeed(playbackSpeed)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit)
	else
		AnimationsTable.WalkForward:AdjustWeight(Forward)
		AnimationsTable.WalkRight:AdjustWeight(Left)
		AnimationsTable.WalkLeft:AdjustWeight(Right)

		AnimationsTable.WalkForward:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit * -1)
	end
end)

-------------------------------------------------
-- HEARTBEAT — Wall raycast
-------------------------------------------------
RunService.Heartbeat:Connect(function()
	local rayLength = 3
	local look = HRP.CFrame.lookVector
	local offsets = {
		Vector3.new(0, 0, 0), -- Center
		Vector3.new(0, 1.5, 0), -- Upper
		Vector3.new(0, -1.5, 0), -- Lower
	}

	local hitClimable = false
	for _, offset in ipairs(offsets) do
		local origin = HRP.Position + offset
		local result = workspace:Raycast(origin, look * rayLength, raycastParams)
		if result and result.Instance:GetAttribute("Climable") == true then
			hitClimable = true
			break
		end
	end

	canClimb = hitClimable
	if hitClimable ~= lastClimbState then
		lastClimbState = hitClimable
	end
end)

-------------------------------------------------
-- INPUT
-------------------------------------------------
UIS.InputBegan:Connect(function(input, isTyping)
	if isTyping then
		return
	end
	local key = input.KeyCode

	if key == Enum.KeyCode.W then
		heldKeys.W = true

		if canSprint() then
			local currentTime = tick()
			if currentTime - LastKeyPressTime <= doubleTapThreshold then
				toggleSprintState()
			end
			LastKeyPressTime = currentTime
		end
	elseif key == Enum.KeyCode.S then
		if IsHoldingLedge then
			IsHoldingLedge = false
			char:SetAttribute("LedgeHold", false)
			MovementEvent:FireServer("ReleaseLedge", false)
			TS:Create(cam, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = 70 })
				:Play()
			return
		end
	end

	if key == Enum.KeyCode.Space then
		if IsHoldingLedge then
			IsHoldingLedge = false
			char:SetAttribute("LedgeHold", true)
			MovementEvent:FireServer("ReleaseLedge", true)
			-- Jump off ledge — big overshoot then settle
			TS:Create(cam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = 95 })
				:Play()
			task.delay(0.15, function()
				TS
					:Create(
						cam,
						TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{ FieldOfView = 70 }
					)
					:Play()
			end)
			return
		end

		if isInAir and heldKeys.W and canClimb and not IsClimbing then
			if isSprinting then
				toggleSprintState()
				task.wait(0.15)
			end
			triggerWallClimb()
		end
	end
end)
UIS.InputEnded:Connect(function(input, isTyping)
	if isTyping then
		return
	end
	local key = input.KeyCode

	if key == Enum.KeyCode.W then
		heldKeys.W = nil
		if isSprinting then
			toggleSprintState()
		end
	end
end)

-------------------------------------------------
-- HUMANOID STATE
-------------------------------------------------
Hum.StateChanged:Connect(function(_, newState)
	if newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Jumping then
		isInAir = true
		grounded = false
	elseif newState == Enum.HumanoidStateType.Landed then
		isInAir = false
		grounded = true
	end
end)

-------------------------------------------------
-- LEDGES
-------------------------------------------------
task.wait(3)
local ledges = workspace.ParkorTeststuff.Ledges:GetChildren()

-- Offscreen positions (top slides up, bottom slides down)
local TOP_HIDDEN = UDim2.new(-0.001, 0, -0.4, 0)
local BOTTOM_HIDDEN = UDim2.new(-0.034, 0, 1.1, 0)

-- Normal (resting) positions
local TOP_NORMAL = UDim2.new(-0.001, 0, -0.187, 0)
local BOTTOM_NORMAL = UDim2.new(-0.034, 0, 0.75, 0)

-- Breathe positions (top creeps down, bottom creeps up)
local TOP_INHALE = UDim2.new(-0.001, 0, -0.15, 0)
local BOTTOM_INHALE = UDim2.new(-0.034, 0, 0.72, 0)

local tweenSlide = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenBreathe = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- Set bars offscreen initially
top.Position = TOP_HIDDEN
bottom.Position = BOTTOM_HIDDEN

local function slideOutBars()
    TS:Create(top, tweenSlide, { Position = TOP_HIDDEN }):Play()
    TS:Create(bottom, tweenSlide, { Position = BOTTOM_HIDDEN }):Play()
end

local function breatheFOV()
    if not IsHoldingLedge then
        TS:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
        slideOutBars()
        return
    end

    -- FOV tweens
    local inhale = TS:Create(cam, tweenBreathe, { FieldOfView = 63 })
    local exhale = TS:Create(cam, tweenBreathe, { FieldOfView = 65 })

    -- Bar tweens (inhale = bars close in, exhale = bars open back)
    local barsInhale_Top    = TS:Create(top,    tweenBreathe, { Position = TOP_INHALE })
    local barsInhale_Bottom = TS:Create(bottom, tweenBreathe, { Position = BOTTOM_INHALE })
    local barsExhale_Top    = TS:Create(top,    tweenBreathe, { Position = TOP_NORMAL })
    local barsExhale_Bottom = TS:Create(bottom, tweenBreathe, { Position = BOTTOM_NORMAL })

    inhale:Play()
    barsInhale_Top:Play()
    barsInhale_Bottom:Play()

    inhale.Completed:Connect(function()
        if not IsHoldingLedge then
            TS:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
            slideOutBars()
            return
        end

        exhale:Play()
        barsExhale_Top:Play()
        barsExhale_Bottom:Play()

        exhale.Completed:Connect(function()
            breatheFOV()
        end)
    end)
end

local function startBreath()
    -- Slide bars in first, then start breathing once they arrive
    TS:Create(top,    tweenSlide, { Position = TOP_NORMAL }):Play()
    local slideIn = TS:Create(bottom, tweenSlide, { Position = BOTTOM_NORMAL })
    slideIn:Play()
    slideIn.Completed:Connect(function()
        if IsHoldingLedge then
            breatheFOV()
        end
    end)
end

for _, ledge in ledges do
	ledge.Touched:Connect(function(part)
		if LedgeGrabCoolDown or IsHoldingLedge or not IsClimbing then
			return
		end
		if not part:IsDescendantOf(char) then
			return
		end

		LedgeGrabCoolDown = true
		IsHoldingLedge = true
		IsClimbing = false
		MovementEvent:FireServer("LedgeHold", ledge)

		startBreath() -- Start breathing effect

		task.wait(0.4)
		LedgeGrabCoolDown = false
	end)
end



