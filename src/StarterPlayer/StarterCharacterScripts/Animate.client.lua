--[Services]--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local SFX = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TS = game:GetService("TweenService")

local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local Cast = require(RS.Modules.Cast)
local Movement = require(RS.Modules.Movement.Objects.Movement)
local Crouch = require(RS.Modules.Movement.Mechnanics.Crouch)
local Wallrun = require(RS.Modules.Movement.Mechnanics.Wallrun)

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
local Top_tilt = MovementUI:WaitForChild("Top_Tilt")
local Bottom_tilt = MovementUI:WaitForChild("Bottom_Tilt")

local Events = RS.Events
local MovementEvent = Events.Movement
local AccessoryEvent = Events.AccessoryEvent

-- Wait for CurrentWeapon and the movement object
local CurrentWeapon = char:GetAttribute("CurrentWeapon")
while CurrentWeapon == nil do
	CurrentWeapon = char:GetAttribute("CurrentWeapon")
	if CurrentWeapon then
		break
	end
	task.wait(0.3)
end

local object = Movement.new(plr)

--[Animation Setup]--
local WeaponAnimations = RS.Animations.Weapons
local AnimationsFolder = script.Animations
local MovementAnimationsFolder = WeaponAnimations[CurrentWeapon].Movement

local WallClimbAnim = Hum.Animator:LoadAnimation(MovementAnimationsFolder.WallClimb)
local ledgeGrab = Hum.Animator:LoadAnimation(MovementAnimationsFolder.LedgeGrab)

local R_anim = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallrunR)
local L_anim = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallrunL)

local Lanim_Jump = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallhopL)

local SprintAnim = nil
local SprintTrack = nil
local conn

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
local IsWallRunning = false
local WallrunCooldowns = nil
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

-- Offscreen positions (top slides up, bottom slides down)
local TOP_HIDDEN = UDim2.new(-0.001, 0, -0.4, 0)
local BOTTOM_HIDDEN = UDim2.new(-0.034, 0, 1.1, 0)

local Tilt_TOP_HIDDEN_LEFT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_LEFT = UDim2.new(-1.325, 0, 2, 0)

local TOP_TILT_NORMAL_LEFT = UDim2.new(-0.672, 0, -0.157, 0)
local BOTTOM_TILT_NORMAL_LEFT = UDim2.new(-1.325, 0, 0.646, 0)

local Left_TILT_ANGLE = 35

local Tilt_TOP_HIDDEN_RIGHT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_RIGHT = UDim2.new(-1.325, 0, 2, 0)

local TOP_TILT_NORMAL_RIGHT = UDim2.new(-0.954, 0, -0.671, 0)
local BOTTOM_TILT_NORMAL_RIGHT = UDim2.new(-0.992, 0, 1.058, 0)

local Right_TILT_ANGLE = -35

-- Normal (resting) positions
local TOP_NORMAL = UDim2.new(-0.001, 0, -0.187, 0)
local BOTTOM_NORMAL = UDim2.new(-0.034, 0, 0.75, 0)

-- Breathe positions
local TOP_INHALE = UDim2.new(-0.001, 0, -0.15, 0)
local BOTTOM_INHALE = UDim2.new(-0.034, 0, 0.72, 0)

local tweenSlide = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenBreathe = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- Set bars offscreen initially
top.Position = TOP_HIDDEN
bottom.Position = BOTTOM_HIDDEN

Top_tilt.Position = Tilt_TOP_HIDDEN_LEFT
Bottom_tilt.Position = Tilt_BOTTOM_HIDDEN_LEFT

Top_tilt.Rotation = 0
Bottom_tilt.Rotation = 0

-------------------------------------------------
-- WALK  Cycles
-------------------------------------------------

char:GetAttributeChangedSignal("CurrentWeapon"):Connect(function()
	object:UpdateWalkTracks()
end)
char:GetAttributeChangedSignal("Equipped"):Connect(function()
	object:UpdateWalkTracks()
end)
char:GetAttributeChangedSignal("IsLow"):Connect(function()
	object:UpdateWalkTracks()
end)
char:GetAttributeChangedSignal("InCombat"):Connect(function()
	object:UpdateWalkTracks()
end)
AccessoryEvent.OnClientEvent:Connect(function(action)
	if action == "RefreshAnimations" then
		object:UpdateWalkTracks()
	end
end)

object:UpdateWalkTracks()

-------------------------------------------------
-- WALL CLIMB
-------------------------------------------------
local function triggerWallClimb()
	if IsWallRunning then
		return
	end
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
local baseSpeed = StarterPlayer.CharacterWalkSpeed

local function canSprint()
	return not (
		char:GetAttribute("Stunned")
		or char:GetAttribute("IsRagdoll")
		or char:GetAttribute("IsBlocking")
		or char:GetAttribute("Attacking")
		or char:GetAttribute("IsCrouching")
		or IsClimbing
		or IsWallRunning
		or object.States.IsCrouching
	)
end

local function ResetSpeedCheck()
	return not (
		char:GetAttribute("Stunned")
		and not char:GetAttribute("IsBlocking")
		and not char:GetAttribute("Attacking")
		and not char:GetAttribute("IsCrouching")
		and not IsClimbing
		and not IsWallRunning

	)
end

local function selectSprintAnim()
	if SprintAnim then
		SprintAnim:Stop()
	end

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
	if isSprinting and not debounce  then
		debounce = true

		if ResetSpeedCheck() then
			Hum.WalkSpeed = baseSpeed
		end

		TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 70 })
			:Play()
		isSprinting = false

		if SprintAnim then
			SprintAnim:Stop()
		end
		if conn then
			conn:Disconnect()
		end

		object:UpdateWalkTracks()
		char:SetAttribute("Sprinting", false)
		task.wait(0.1)
		debounce = false
	elseif not isSprinting and not debounce then
		char:SetAttribute("Sprinting", true)

		if char:GetAttribute("InCombat") and char:GetAttribute("IsLow") then
			Hum.WalkSpeed = baseSpeed * 1.25
		else
			Hum.WalkSpeed = baseSpeed * 2
		end

		TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 80 })
			:Play()
		isSprinting = true

		selectSprintAnim()

		conn = RunService.Heartbeat:Connect(function()
			if AirBorneStates[Hum:GetState()] then
				SprintAnim:AdjustSpeed(0.25)
			else
				SprintAnim:AdjustSpeed(1)
			end
		end)

		object:ClearWalkAnims()
	end
end

local function OnCharStateChanged()
	if not canSprint() or HRP.Anchored then
		if isSprinting then
			toggleSprintState()
		end
	end
end

MovementEvent.OnClientEvent:Connect(function(action)
	if action == "AstralDodge" then
		local PastState = false
		if isSprinting then
			PastState = true
			toggleSprintState()
		end

		local dodgeSpeed = baseSpeed * 5
		Hum.WalkSpeed = dodgeSpeed
		TS:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { FieldOfView = 160 })
			:Play()

		task.delay(5, function()
			if not isSprinting then
				Hum.WalkSpeed = baseSpeed
				TS:Create(
					cam,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{ FieldOfView = 70 }
				):Play()

				if PastState == true then
					toggleSprintState()
				end
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
	object:WalkCycle()
end)

local function StartWallRunBars(side, hum)
	TS:Create(cam, TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = 250 }):Play()
	if side == 1 then
		TS:Create(Top_tilt, tweenSlide, { Position = TOP_TILT_NORMAL_RIGHT, Rotation = Right_TILT_ANGLE }):Play()
		TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_TILT_NORMAL_RIGHT, Rotation = Right_TILT_ANGLE }):Play()
	elseif side == -1 then
		TS:Create(Top_tilt, tweenSlide, { Position = TOP_TILT_NORMAL_LEFT, Rotation = Left_TILT_ANGLE }):Play()
		TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_TILT_NORMAL_LEFT, Rotation = Left_TILT_ANGLE }):Play()
	end
end

local function JumpBars(side, hum)
	local TOP = UDim2.new(-0.001, 0, -0.987, 0)
	local BOTTOM = UDim2.new(-0.034, 0, 0.95, 0)

	local FOVChange: Tween =
		TS:Create(cam, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = 280 })
	FOVChange:Play()
	local camreturn = Vector3.new(0, 0, 0)
	TS:Create(hum, TweenInfo.new(0.40, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { CameraOffset = camreturn })
		:Play()
	local top: Tween = TS:Create(Top_tilt, tweenSlide, { Position = TOP, Rotation = 0 })
	print(FOVChange)
	local bottom: Tween = TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM, Rotation = 0 })
	top:Play()
	bottom:Play()
	FOVChange.Completed:Connect(function()
		TS:Create(cam, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
	end)

	top.Completed:Connect(function()
		local finalbarTween: Tween = TS:Create(Top_tilt, tweenSlide, { Position = TOP_HIDDEN, Rotation = 0 })
		finalbarTween:Play()
		TS:Create(Bottom_tilt, tweenSlide, { Position = BOTTOM_HIDDEN, Rotation = 0 }):Play()
		finalbarTween.Completed:Connect(function()
			Top_tilt.Position = Tilt_TOP_HIDDEN_LEFT
			Bottom_tilt.Position = Tilt_BOTTOM_HIDDEN_LEFT
		end)
	end)
end

local function StopWallRunBars(side, hum, action)
	if not action then
		action = "Stop"
	end

	if action == "Stop" then
		local camreturn = Vector3.new(0, 0, 0)

		TS
			:Create(
				hum,
				TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ CameraOffset = camreturn }
			)
			:Play()
		TS:Create(cam, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
		if side == 1 then
			TS:Create(Top_tilt, tweenSlide, { Position = Tilt_TOP_HIDDEN_RIGHT, Rotation = 15 }):Play()
			TS:Create(Bottom_tilt, tweenSlide, { Position = Tilt_BOTTOM_HIDDEN_RIGHT, Rotation = 15 }):Play()
		elseif side == -1 then
			TS:Create(Top_tilt, tweenSlide, { Position = Tilt_TOP_HIDDEN_LEFT, Rotation = -15 }):Play()
			TS:Create(Bottom_tilt, tweenSlide, { Position = Tilt_BOTTOM_HIDDEN_LEFT, Rotation = -15 }):Play()
		end
	elseif action == "Jump" then
		JumpBars(side, hum)
	end
end

local function FindFowardwall(char)
	local HRP = char.HumanoidRootPart
	if not HRP then
		return
	end

	local hitClimable = false

	local offsets = {
		Vector3.new(0, 0, 0), -- Center
		Vector3.new(0, 1.5, 0), -- Upper
		Vector3.new(0, -1.5, 0), -- Lower
	}

	for _, offset in ipairs(offsets) do
		local origin = HRP.Position + offset

		local result = Cast.Ray({
			Origin = origin,
			Direction = HRP.CFrame.LookVector,
			Range = 5,
			FilterList = { char },
		})

		if result and result.Instance:GetAttribute("Climable") == true then
			hitClimable = true
			break
		end
	end

	canClimb = hitClimable
	if hitClimable ~= lastClimbState then
		lastClimbState = hitClimable
	end
end

local function FindSideWalls(char)
	local HRP = char.HumanoidRootPart
	if not HRP then
		return
	end

	local LeftResult = Cast.Ray({
		Origin = HRP.Position,
		Direction = -HRP.CFrame.RightVector,
		Range = 3,
		FilterList = { char },
	})

	local RightResult = Cast.Ray({
		Origin = HRP.Position,
		Direction = HRP.CFrame.RightVector,
		Range = 3,
		FilterList = { char },
	})

	if LeftResult and math.abs(LeftResult.Normal.Y) < 0.2 then
		return LeftResult, -1
	elseif RightResult and math.abs(RightResult.Normal.Y) < 0.2 then
		return RightResult, 1
	end
end

local function StartWallRun(char, hit: RaycastResult, side)
	if not char then
		return
	end

	local hum = char.Humanoid
	local HRP = char.HumanoidRootPart

	if not hum or not HRP then
		return
	end
	if IsWallRunning then
		print("Already wall running")
		return
	end

	Lanim_Jump:Stop()

	local WallRunSpeed = 50

	local IsSprinting = char:GetAttribute("Sprinting")
	if IsSprinting then
		WallRunSpeed = 80
	end

	local CamOffset

	if side == 1 then
		CamOffset = Vector3.new(-5, -4, 0)
	else
		CamOffset = Vector3.new(5, -4, 0)
	end

	local conn

	Normal = hit.Normal.Unit
	Side = side

	if math.abs(Normal.Y) > 0.2 then
		print("Normal Y failed")
		return
	end

	local WallDir = Normal:Cross(Vector3.new(0, 1, 0)).Unit

	if WallDir:Dot(HRP.CFrame.LookVector) < 0 then
		WallDir = -WallDir
	end

	local entryvel = HRP.AssemblyLinearVelocity

	StartWallRunBars(side)
	TS:Create(hum, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { CameraOffset = CamOffset })
		:Play()

	local Attacment = HRP:FindFirstChild("WallRunAttachment")
	if not Attacment then
		Attacment = Instance.new("Attachment")
		Attacment.Name = "WallRunAttachment"
		Attacment.Parent = HRP
	end

	local vel = Instance.new("LinearVelocity")
	vel.Attachment0 = Attacment
	vel.RelativeTo = Enum.ActuatorRelativeTo.World
	vel.Parent = HRP
	vel.ForceLimitsEnabled = true
	vel.ForceLimitMode = Enum.ForceLimitMode.PerAxis

	local mass = HRP.AssemblyMass * 1500
	vel.MaxAxesForce = Vector3.new(mass, mass, mass)

	local algin = Instance.new("AlignOrientation")
	algin.Attachment0 = Attacment
	algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
	algin.Responsiveness = 50
	algin.Parent = HRP

	hum.AutoRotate = false

	IsWallRunning = true

	if side == 1 then
		R_anim:Play()
	elseif side == -1 then
		L_anim:Play()
	end

	local duration = 20
	local Speed = 50

	local elapsed = 0

	function stopWallRun(action)
		conn:Disconnect()
		if not IsWallRunning then
			return
		end
		WallrunCooldowns = tick()
		HRP.AssemblyLinearVelocity += Normal * 15
		vel:Destroy()
		algin:Destroy()
		Attacment:Destroy()

		hum.AutoRotate = true
		IsWallRunning = false

		R_anim:Stop()
		L_anim:Stop()

		object:UpdateWalkTracks()
		StopWallRunBars(side, hum, action)
	end

	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt

		if elapsed >= duration then
			stopWallRun()
			return
		end

		if hum.FloorMaterial ~= Enum.Material.Air then
			stopWallRun()
			return
		end

		local check = Cast.Ray({
			Origin = HRP.Position,
			Direction = -Normal,
			Range = 5,
			FilterList = { char },
		})

		if not check then
			local physicsFPS = workspace:GetRealPhysicsFPS()
			local CoyoteSecs = (1 / physicsFPS) * 5
			local frozenNormal = Normal -- capture current normal before delay

			task.delay(CoyoteSecs, function()
				if not IsWallRunning then
					return
				end

				local check2 = Cast.Ray({
					Origin = HRP.Position,
					Direction = -frozenNormal, -- use frozen value
					Range = 5,
					FilterList = { char },
				})

				if not check2 then
					stopWallRun()
				end
			end)
			return
		end

		local gforce = Vector3.new(0, -workspace.Gravity * 0.5, 0)

		vel.VectorVelocity = WallDir * Speed + gforce * dt + entryvel * 0.15
		algin.CFrame = CFrame.lookAt(HRP.Position, HRP.Position + WallDir, Vector3.new(0, 1, 0))
	end)
end

local function WallRunStart(char)
	if not char then
		return
	end
	local hum = char.Humanoid
	if not hum then
		return
	end

	if hum.FloorMaterial ~= Enum.Material.Air then
		return
	end
	if IsWallRunning or IsClimbing or IsHoldingLedge then
		return
	end

	if WallrunCooldowns and tick() - WallrunCooldowns < 0.2 then
		return
	end

	local hit, side = FindSideWalls(char)
	if not hit then
		return
	end

	object:UpdateWalkTracks()

	StartWallRun(char, hit, side)
end

local function WallRunJump()
	if not IsWallRunning then
		return
	end
	local HRP: BasePart = char.HumanoidRootPart
	if not HRP then
		return
	end

	stopWallRun("Jump")
	local Jumppower = 50
	local uppower = Jumppower * 2
	local Lateral = (Side == -1 and HRP.CFrame.RightVector or -HRP.CFrame.RightVector)

	local jumpVect = (Normal * Jumppower) + (Lateral * 0.5) + Vector3.new(0, uppower, 0) -- The wall jump should go the side then up a little
	if Side == 1 then
		--Animation for Right when done
	elseif Side == -1 then
		Lanim_Jump:Play()
	end

	HRP.AssemblyLinearVelocity = jumpVect + HRP.AssemblyLinearVelocity * 0.2
end
RunService.Heartbeat:Connect(function(dt)
	WallRunStart(char)
end)

local function slideOutBars()
	TS:Create(top, tweenSlide, { Position = TOP_HIDDEN }):Play()
	TS:Create(bottom, tweenSlide, { Position = BOTTOM_HIDDEN }):Play()
end

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
			TS:Create(cam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = 95 })
				:Play()

			if top.Position ~= TOP_HIDDEN then
				slideOutBars()
			end
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

		FindFowardwall(char)

		if isInAir and heldKeys.W and canClimb and not IsClimbing then
			if isSprinting then
				toggleSprintState()
				task.wait(0.15)
			end
			triggerWallClimb()
		end

		if IsWallRunning then
			--stopWallRun()
			WallRunJump()
		end
	end

	if key == Enum.KeyCode.LeftControl then
		Crouch.Start(object)
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
Hum.StateChanged:Connect(function(_, newState) -- other state stuff
	if newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Jumping then
		isInAir = true
		grounded = false
	elseif newState == Enum.HumanoidStateType.Landed then
		isInAir = false
		grounded = true
	end
end)

function CrouchStatesChecker(_, Newstates)
	if object.States.IsCrouching then
		if
			Newstates == Enum.HumanoidStateType.Dead
			or Newstates == Enum.HumanoidStateType.Climbing
			or Newstates == Enum.HumanoidStateType.Swimming
			or Newstates == Enum.HumanoidStateType.Seated
			or Newstates == Enum.HumanoidStateType.Physics
		then
			object.InfoTable.Crouch.Stop()
		end
	end
end

Hum.StateChanged:Connect(CrouchStatesChecker)
-------------------------------------------------
-- LEDGES
-------------------------------------------------
task.wait(3)
local ledges = workspace.ParkorTeststuff.Ledges:GetChildren()

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
	local barsInhale_Top = TS:Create(top, tweenBreathe, { Position = TOP_INHALE })
	local barsInhale_Bottom = TS:Create(bottom, tweenBreathe, { Position = BOTTOM_INHALE })
	local barsExhale_Top = TS:Create(top, tweenBreathe, { Position = TOP_NORMAL })
	local barsExhale_Bottom = TS:Create(bottom, tweenBreathe, { Position = BOTTOM_NORMAL })

	inhale:Play()
	barsInhale_Top:Play()
	barsInhale_Bottom:Play()

	inhale.Completed:Connect(function()
		if not IsHoldingLedge then
			TS:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = 70 })
				:Play()
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
	TS:Create(top, tweenSlide, { Position = TOP_NORMAL }):Play()
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

		task.delay(0.1, function()
			if IsHoldingLedge then
				startBreath()
			end
		end)

		task.wait(0.4)
		LedgeGrabCoolDown = false
	end)
end
