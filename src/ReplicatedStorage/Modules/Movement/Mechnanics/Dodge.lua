local Dodge = {}
local RS = game:GetService("ReplicatedStorage")
local RSModules = RS.Modules
local MovementTypes = require(RSModules.Movement.Objects.Movement.Types)
local ClientHelpful = require(RSModules.ClientHelpfull)
local cam = workspace.CurrentCamera

local WeaponAnims = RS.Animations.Weapons

local CONFIG = {
	DEFAULT_DASH_SPEED = 85,  -- was 85
	DASH_DURATION = 0.2,
}


local DodgeCoolDowns = {}


--Z
local function CalculateDodgeSpeed(MovementObj: MovementTypes.MovementObj, isAir: boolean): number
	local baseSpeed = CONFIG.DEFAULT_DASH_SPEED
	
	return baseSpeed
end

local function Get3DMovement(MovementObj: MovementTypes.MovementObj)
	local char = MovementObj.char
	local hum = char:FindFirstChildOfClass("Humanoid") 
	if not hum then return Vector3.zero end

	local MoveInput = hum.MoveDirection 


	if MoveInput.Magnitude == 0 then
		local inAir = MovementObj.States.IsInAir
		if not inAir then
			return Vector3.zero 
		else
			return cam.CFrame.LookVector.Unit 
		end
	end

	local inAir = MovementObj.States.IsInAir
	if not inAir then
		return Vector3.new(MoveInput.X, 0, MoveInput.Z).Unit
	else
		local CamRotation = CFrame.lookAt(Vector3.zero, cam.CFrame.LookVector, cam.CFrame.UpVector)
		local rawdir = CamRotation:VectorToWorldSpace(Vector3.new(MoveInput.X, 0, MoveInput.Z))
		return rawdir.Unit
	end
end

function Dodge.Dodge(MovementObj: MovementTypes.MovementObj)
	if not MovementObj or not MovementObj.char or MovementObj.IsActing.Dodging then return end
	local char = MovementObj.char
	local HRP = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")

	if DodgeCoolDowns[MovementObj] and tick() - DodgeCoolDowns[MovementObj] < 0.7 then return end
  
	if not HRP or not hum then return end
    if ClientHelpful.CheckForAttributes(char, true, true, true, true, false, true, true, true) then return end 
    if ClientHelpful.CheckStamina(char, "Dodge") then return end 

	local dashdir = Get3DMovement(MovementObj)
	local isAir = MovementObj.States.IsInAir

	if dashdir == Vector3.zero and isAir then return end

	local HeldKey = char:GetAttribute("CurrentMoveKey")
	local CurrentWeapon = char:GetAttribute("CurrentWeapon")
	local DodgeAnim = nil


	MovementObj.IsActing.Dodging = true

	
	if isAir then
		if HeldKey == nil or HeldKey == "None" then
			HeldKey = "W"
		end
		DodgeAnim = hum.Animator:LoadAnimation(WeaponAnims[CurrentWeapon].Dodging.InAir[HeldKey])
		MovementObj.InfoTable.Dodge.Type = "AirDodge"
	else
		if dashdir == Vector3.zero then
			HeldKey = "None" -- Force Spot Dodge track execution explicitly
			MovementObj.InfoTable.Dodge.Type = "SpotDodge"
		else
			if HeldKey == nil or HeldKey == "None" then
				HeldKey = "W" -- Ground movement fallback default
			end
			MovementObj.InfoTable.Dodge.Type = "Normal"
		end
		DodgeAnim = hum.Animator:LoadAnimation(WeaponAnims[CurrentWeapon].Dodging[HeldKey])
	end

	DodgeAnim:Play()

	MovementObj.InfoTable.Dodge.Dir = dashdir
	MovementObj:ServerRequest("Dodge")

	-- If running a spot dodge on the ground, do not generate physical velocity objects
	local lv, algin
	if MovementObj.InfoTable.Dodge.Type ~= "SpotDodge" then
		local DodgeSpeed = CalculateDodgeSpeed(MovementObj, isAir)
		local att = HRP:FindFirstChild("DodgeAtt") or Instance.new("Attachment", HRP)
		att.Name = "DodgeAtt"

		lv = Instance.new("LinearVelocity")
		lv.Name = "DashForce"
		lv.Attachment0 = att
		lv.MaxForce = math.huge
		lv.VectorVelocity = dashdir * DodgeSpeed
		lv.Parent = HRP

		algin = Instance.new("AlignOrientation")
		algin.Name = "DashRotation"
		algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
		algin.Attachment0 = att
		algin.MaxTorque = math.huge
		algin.Responsiveness = 50
		algin.CFrame = CFrame.lookAlong(Vector3.zero, dashdir)
		algin.Parent = HRP
	end

	local infoTable = { Action = "Dodge" }
	MovementObj:BarTween(infoTable)

	local function Stop()
		if not MovementObj.IsActing.Dodging then return end
		
		if DodgeAnim then
			DodgeAnim:Stop()
			DodgeAnim:Destroy()
		end
		if lv then lv:Destroy() end
		if algin then algin:Destroy() end
		
		MovementObj.IsActing.Dodging = false
		MovementObj.InfoTable.Dodge.Type = "None"
		
		local Info = { Action = "Dodge" }
		MovementObj:BarTweenStop(Info)
		DodgeCoolDowns[MovementObj] = tick()
	end

	MovementObj.InfoTable.Dodge.Stop = Stop

	task.delay(CONFIG.DASH_DURATION, function()
		Stop()
	end)
end

function Dodge.DodgeCancel(MovementObj: MovementTypes.MovementObj)
	if not MovementObj or not MovementObj.IsActing.Dodging then return end
	if typeof(MovementObj.InfoTable.Dodge.Stop) == "function" then
		MovementObj.InfoTable.Dodge.Stop()
	end
end



return Dodge
