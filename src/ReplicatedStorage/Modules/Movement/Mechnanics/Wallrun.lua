local Wallrun = {}
local RS  = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RSModules = RS.Modules

local Cast = require(RSModules.Cast)
local MovementObjects = require(RSModules.Movement.Objects.Movement)

local WeaponAnimations = RS.Animations.Weapons



local function WallChecker(char)
   local HRP = char.HumanoidRootPart
   if not HRP then return end

   local LeftResult = Cast.Ray({
    Origin = HRP.Position,
    Direction = -HRP.CFrame.RightVector,
    Range = 3,
    FilterList = {char},
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




function Wallrun.StartWallRun(MovementObj:MovementObjects.MovementObj, hit:RaycastResult,side)
    if not MovementObj or not MovementObj.char or not MovementObj.identifer then return end 
    local char = MovementObj.char
    local CurrentWeapon = char:GetAttribute("CurrentWeapon")
    local Hum = char.Humanoid
    local HRP:Part = char.HumanoidRootPart
    local WallrunSpeed = 50
    local WallrunCooldowns = nil 

    if not Hum or  not HRP then return end 

    if MovementObj.IsActing.WallRunning then return end 

    if MovementObj.IsActing.IsSprinting then
        WallrunSpeed = 80
    elseif MovementObj.IsActing.IsEXSprinting then
       WallrunSpeed = 90
    end

    
    local conn 


    local Normal = hit.Normal.Unit
    local side = side

    local R_anim = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallrunR)
    local L_anim = Hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Movement.WallrunL)

    if math.abs(Normal.Y) > 0.2 then
        warn("[Wallrun Module] = Normal Y failed to be in range")
    end

   	local WallDir = Normal:Cross(Vector3.new(0, 1, 0)).Unit

    if WallDir:Dot(HRP.CFrame.LookVector) <  0  then WallDir = -WallDir end
    
   	local entryvel = HRP.AssemblyLinearVelocity

    local playerFlag = MovementObj.identifer
    if playerFlag:IsA("Player") then
        -- MovementObj:BarTween("Wallrun")
    end


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
    vel.MaxAxesForce = Vector3.new(mass,mass,mass)

    local algin = Instance.new("AlignOrientation")
    algin.Attachment0 = Att
    algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
    algin.Responsiveness = 50
    algin.Parent = HRP

    Hum.AutoRotate = false

    MovementObj.IsActing.WallRunning = true

    if side == 1 then
        R_anim:Play()
    elseif side ==-1 then 
        L_anim:Play()
    end


    local duration = 20
    local elapsed = 0

    local function StopWallRun()
       conn:Disconnect()

       if not MovementObj.IsActing.WallRunning  then return end 

       WallrunCooldowns = tick()
       HRP.AssemblyLinearVelocity += Normal * 15
       vel:Destroy()
       algin:Destroy()
       Att:Destroy()

       Hum.AutoRotate = true
       MovementObj.IsActing.WallRunning = false

       R_anim:Stop()
       L_anim:Stop()

       MovementObj:UpdateWalkTracks()
       

    end



   


end
















return Wallrun