local Wallrun = {}
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RSModules = RS.Modules

local Cast = require(RSModules.Cast)
local MovementTypes = require(RSModules.Movement.Objects.Movement.Types)

local WeaponAnimations = RS.Animations.Weapons

local WallrunCooldowns = {}






local function WallChecker(char)
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

	return nil
end

local function StartWallRun(MovementObj: MovementTypes.MovementObj, hit: RaycastResult, side)
	if not MovementObj or not MovementObj.char or not MovementObj.identifer then
		return
	end
	local char = MovementObj.char
	local CurrentWeapon = char:GetAttribute("CurrentWeapon")
	local Hum = char.Humanoid
	local HRP: Part = char.HumanoidRootPart
	local WallrunSpeed = 50

	if not Hum or not HRP then
		return
	end

	if MovementObj.IsActing.WallRunning then
		return
	end

	if MovementObj.IsActing.IsSprinting then
		WallrunSpeed = 80
	elseif MovementObj.IsActing.IsEXSprinting then
		WallrunSpeed = 90
	end

	local conn

	local Normal = hit.Normal.Unit
	

	local R_anim = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallrunR)
	local L_anim = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallrunL)

	if math.abs(Normal.Y) > 0.2 then
		warn("[Wallrun Module] = Normal Y failed to be in range")
	end

	local WallDir = Normal:Cross(Vector3.new(0, 1, 0)).Unit

	if WallDir:Dot(HRP.CFrame.LookVector) < 0 then
		WallDir = -WallDir
	end

	local entryvel = HRP.AssemblyLinearVelocity

	local playerFlag = MovementObj.identifer
	if playerFlag:IsA("Player") then
		local infotable = {
			Action = "Wallrun",
			side = side,
		}


		MovementObj:BarTween(infotable)
	end

	char:SetAttribute("IsWallRunning", true) -- for server to tell clients
	MovementObj.IsActing.WallRunning = true  -- for the client to know they are wallrunning 

	local Att = HRP:FindFirstChild("WallRunAttachment")

	if not Att then
		Att = Instance.new("Attachment")
		Att.Name = "WallRunAttachment"
		Att.Parent = HRP
	end

	local vel = Instance.new("LinearVelocity")
	vel.Attachment0 = Att
	vel.RelativeTo = Enum.ActuatorRelativeTo.World
	vel.Parent = HRP
	vel.ForceLimitsEnabled = true
	vel.ForceLimitMode = Enum.ForceLimitMode.PerAxis

	local mass = HRP.AssemblyMass * 1500
	vel.MaxAxesForce = Vector3.new(mass, mass, mass)

	local algin = Instance.new("AlignOrientation")
	algin.Attachment0 = Att
	algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
	algin.Responsiveness = 50
	algin.Parent = HRP

	Hum.AutoRotate = false
	


	

	if side == 1 then
		R_anim:Play()
	elseif side == -1 then
		L_anim:Play()
	end

	local duration = 20
	local elapsed = 0

	local function StopWallRun()
		conn:Disconnect()

		if not MovementObj.IsActing.WallRunning then
			return
		end

		WallrunCooldowns[MovementObj.identifer] = tick()
		HRP.AssemblyLinearVelocity += Normal * 15
		vel:Destroy()
		algin:Destroy()
		Att:Destroy()

		Hum.AutoRotate = true
		MovementObj.IsActing.WallRunning = false
		char:SetAttribute("IsWallRunning", false)

		R_anim:Stop()
		L_anim:Stop()

		MovementObj:UpdateWalkTracks()
		MovementObj:BarTweenStop({
			Action = "Wallrun",
			side = side,
		})
	end

	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt

		if elapsed >= duration then
			StopWallRun()
			return
		end

		if Hum.FloorMaterial ~= Enum.Material.Air then
			StopWallRun()
			return
		end

		local check = Cast.Ray({
			Origin = HRP.Position,
			Direction = -Normal,
			Range = 5,
			FilterList = { char },
		})

		if not check then
			local FPS = workspace:GetRealPhysicsFPS()
			local coyotetime = (1 / FPS) * 5
			local frozenNormal = Normal

			task.delay(coyotetime, function()
				if not MovementObj.IsActing.WallRunning then
					return
				end

				local checkv2 = Cast.Ray({
					Origin = HRP.Position,
					Direction = -frozenNormal,
					Range = 5,
					FilterList = { char },
				})

				if not checkv2 then
					StopWallRun()
				end
			end)
			return
		end

		local gforce = Vector3.new(0, -workspace.Gravity, 0)

		vel.VectorVelocity = WallDir * WallrunSpeed * gforce * dt + entryvel * 0.15
		algin.CFrame = CFrame.lookAt(HRP.Position, HRP.Position + WallDir, Vector3.new(0, 1, 0))
		MovementObj.InfoTable.Wallrun.Stop = StopWallRun
		MovementObj.InfoTable.Wallrun.Side = side
		MovementObj.InfoTable.Wallrun.Normal = Normal
	end)
end


function Wallrun.Start(MovementObj: MovementTypes.MovementObj)
   local char = MovementObj.char
   if not char then return end
   local hum = char.Humanoid
   if not hum then return end

   if hum.FloorMaterial ~= Enum.Material.Air then
      return
   end

   if MovementObj.IsActing.WallRunning  or MovementObj.IsActing.Climbing or MovementObj.States.IsOnWall then
      return
   end

   if WallrunCooldowns and tick() - WallrunCooldowns[MovementObj.identifer] < 0.2 then
      return
   end

   local hit, side = WallChecker(char)
   if not hit then return end

   MovementObj:UpdateWalkTracks()

   StartWallRun(MovementObj, hit,side)
end

function Wallrun.Jump(MovementObj: MovementTypes.MovementObj)
	if not MovementObj or not MovementObj.IsActing.WallRunning then
		return
	end

	local char = MovementObj.char
	local Hum = char.Humanoid
	local HRP = char.HumanoidRootPart
	local CurrentWeapon = char:GetAttribute("CurrentWeapon")
	if not HRP then return end
	local R_animJump = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallrunJumpR)
	local L_animJump = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallrunJumpL)

	MovementObj.InfoTable.Wallrun.Stop("Jump")
	if not MovementObj.InfoTable.Wallrun.Side or not MovementObj.InfoTable.Wallrun.Normal then return end
	local side = MovementObj.InfoTable.Wallrun.Side
	local Normal = MovementObj.InfoTable.Wallrun.Normal	
	local Jumppower = 50
	local uppower = Jumppower * 2
	local Lateral = (side== 1 and HRP.CFrame.RightVector or -HRP.CFrame.RightVector)

	local jumpVect = (Normal * Jumppower) + (Lateral * 0.5) + Vector3.new(0, uppower, 0)
	if side == 1 then
		R_animJump:Play()
	elseif side == -1 then
	    L_animJump:Play()
	end

	HRP.AssemblyLinearVelocity = jumpVect + HRP.AssemblyLinearVelocity * 0.2
end

return Wallrun
