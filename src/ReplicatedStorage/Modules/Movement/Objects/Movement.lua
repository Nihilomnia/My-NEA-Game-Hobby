local Movement = {}
Movement.__index = Movement

local ServerStorage = game:GetService("ServerStorage")
local TS = game:GetService("TweenService")


local AnimationsFolder = script.Animations

-- Ui Stuff
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

export type MovementObj = typeof(setmetatable( -- My type for the MovementObj  this actually servees ZERO purpose but to make indexing easier :P
	{} :: {
		identifer: any,
		char: Model,
		IsReady: boolean,

		IsActing: { -- Flags for if they are using the movement system
			Dodging: boolean,
			WallRunning: boolean,
			Climbing: boolean,
			IsSprinting: boolean,
			IsEXSprinting: boolean,
		},

		States: {
			IsGrounded: boolean, -- Standard is on ground
			IsInAir: boolean, -- In the air
			IsOnWall: boolean, -- Is holding onto a wall
		},

		StopFunctions: { -- Functions for stopping each system when needed (they are automatically supplied with the paramaters)
			StopDodge: () -> (),
			StopWallRun: () -> (),
			StopClimb: () -> (),
			StopSprint: () -> (),
			StopEXSprint: () -> (),
			StopWallHold: () -> (),
		},

		WalkCycleAnims: {
			WalkForward: Animation,
			WalkRight: Animation,
			WalkLeft: Animation,
			WalkBack: Animation,
		},

		UI: {
			top: Frame,
			bottom: Frame,
			top_tilt: Frame,
			bottom_tilt: Frame,
		},
	},
	Movement
))

local objTable = {} -- This sotres the movementobjs

local function Ui_init(movementObJ: MovementObj)
	local plr = movementObJ.identifer
	if plr == nil then
		return
	end
	local UItable = movementObJ.UI
	local MovementUI = plr:WaitForChild("PlayerGui"):WaitForChild("MovementUI")
	UItable.top = MovementUI:WaitForChild("Top")
	UItable.bottom = MovementUI:WaitForChild("Bottom")
	UItable.top_tilt = MovementUI:WaitForChild("Top_Tilt")
	UItable.bottom_tilt = MovementUI:WaitForChild("Bottom_Tilt")

	UItable.top.Position = TOP_HIDDEN
	UItable.bottom.Position = BOTTOM_HIDDEN

	UItable.top_tilt.Position = Tilt_TOP_HIDDEN_LEFT
	UItable.bottom_tilt.Position = Tilt_BOTTOM_HIDDEN_LEFT

	UItable.top_tilt.Rotation = 0
	UItable.bottom_tilt.Rotation = 0
end








--[Module Functions]--
function Movement.new(identifer): MovementObj -- Creates the new movement object for the player/ npc
	local self = setmetatable({
		identifer = nil,
		char = identifer.Character,
		IsReady = false,

		IsActing = {
			Dodging = false,
			WallRunning = false,
			Climbing = false,
			IsSprinting = false,
			IsEXSprinting = false,
		},
		States = {
			IsGrounded = false,
			IsInAir = false,
			IsOnWall = false,
		},

		StopFunctions = {
			StopDodge = nil,
			StopWallRun = nil,
			StopClimb = nil,
			StopSprint = nil,
			StopEXSprint = nil,
			StopWallHold = nil,
		},

		WalkCycleAnims = {
			WalkForward = nil,
			WalkRight = nil,
			WalkLeft = nil,
			WalkBack = nil,
		},

		UI = {
			top = nil,
			bottom = nil,
			top_tilt = nil,
			bottom_tilt = nil,
		},
	}, Movement) :: MovementObj
	self.identifer = identifer

	if objTable[identifer] == nil then
		objTable[identifer] = self
		print(objTable)
    end

    Ui_init(self) -- Set up the Ui for players

    
	
	self.IsReady = true

	return self
end

function Movement.GetMovementObj(Identifer): MovementObj? -- this function lowkey might be useless but oh well :P
	if objTable[Identifer] ~= nil then
		return objTable[Identifer]
	else
		print("[MovementObjects]: Identifer or the movementObj was nil")
		print(objTable)
		print(Identifer)
		return nil
	end
end

function Movement:BarTween(StartStop, acion)
	if self.identifer.Player == nil then
		return
	end -- This means that it wasn't a player so we can ignore it

	if acion == "Wallrun" then
	end
end




function Movement:UpdateWalkTracks()
	local AnimationsTable = self.WalkCycleAnims

	for i, track in pairs(AnimationsTable) do
		if track ~= nil then
			track:Stop(0.1)
			track:Destroy()
		end
	end

	local char = self.char
	local hum = char.Humanoid
	local isEquipped = char:GetAttribute("Equipped")
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local IsLow = char:GetAttribute("IsLow")
	local HasCombatTag = char:GetAttribute("InCombat")
	local TargetFolder

	if isEquipped and currentWeapon and AnimationsFolder.Weapons:FindFirstChild(currentWeapon) then
		if IsLow and HasCombatTag then
			TargetFolder = AnimationsFolder.Weapons[currentWeapon].IsLow
		else
			TargetFolder = AnimationsFolder.Weapons[currentWeapon]
		end
	else
		if IsLow and HasCombatTag then
			TargetFolder = AnimationsFolder.IsLow
		else
			TargetFolder = AnimationsFolder
		end
	end

	AnimationsTable.WalkForward = hum:LoadAnimation(TargetFolder.WalkForward)
	AnimationsTable.WalkRight = hum:LoadAnimation(TargetFolder.WalkRight)
	AnimationsTable.WalkLeft = hum:LoadAnimation(TargetFolder.WalkLeft)
	AnimationsTable.WalkBack = hum:LoadAnimation(TargetFolder.WalkBack)

	for i, track in pairs(AnimationsTable) do
		track:Play(0.1, 0, 0)
	end
end



function Movement:WalkCycle()
	local char = self.char
	local HRP = char.HumanoidRootPart
	local Hum = char.Humanoid
	local AnimationsTable = self.WalkCycleAnims
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
		AnimationsTable.WalkForward:AdjustWeight(Forward)
		AnimationsTable.WalkBack:AdjustWeight(Backwards)
		AnimationsTable.WalkRight:AdjustWeight(Right)
		AnimationsTable.WalkLeft:AdjustWeight(Left)

		local playbackSpeed = (DirectionOfMovement.Z > 0) and  SpeedUnit or -SpeedUnit
		AnimationsTable.WalkForward:AdjustSpeed(playbackSpeed)
		AnimationsTable.WalkBack:AdjustSpeed(SpeedUnit)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit)
	else
		AnimationsTable.WalkForward:AdjustWeight(Forward)
		AnimationsTable.WalkBack:AdjustWeight(Backwards)
		AnimationsTable.WalkRight:AdjustWeight(Left)
		AnimationsTable.WalkLeft:AdjustWeight(Right)
          
		AnimationsTable.WalkForward:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkBack:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit * -1)
		AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit * -1)
	end
	
end

function Movement:ClearWalkAnims()
	local AnimationsTable = self.WalkCycleAnims

	for i, track in pairs(AnimationsTable) do
		if track ~= nil then
			track:Stop(0.1)
			track:Destroy()
			AnimationsTable[i] = nil
		end
	end
end

return Movement
