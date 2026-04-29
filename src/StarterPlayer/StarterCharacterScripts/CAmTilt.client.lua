--[Services]--
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")


--[Player]--
local plr = Players.LocalPlayer
local char = script.Parent
local Hum:Humanoid? = char:WaitForChild("Humanoid",8)
local HRP = char:WaitForChild("HumanoidRootPart",8)
local Torso = char:WaitForChild("Torso",8)
local cam = workspace.CurrentCamera


local RootJoint = HRP.RootJoint
local LeftHipJoint = Torso["Left Hip"]
local RightHipJoint = Torso["Right Hip"]

local Data = require(RS.Modules.Movement.Data)


local Tilt = 0
local MaxCamTilt = 2
local maxJointTilt = Data.Data.MaxTilt


local RootJointC0 = RootJoint.C0
local LeftHipJointC0 = LeftHipJoint.C0
local RightHipJointC0 = RightHipJoint.C0

--[State]--
local Val1 = 0
local Val2 = 0


local function GetMoveMentVal(): (number,number)
    local force = HRP.Velocity * Vector3.new(1,0,1)

    if force.Magnitude <= 2 then
       return 0,0
    end

    local Dir = force.Unit
    local right = HRP.CFrame.RightVector:Dot(Dir)
    local forward = HRP.CFrame.LookVector:Dot(Dir)

    return right,forward

end


local function updateJoints(deltaTime,right,foward)
    RootJoint.C0 = RootJoint.C0:Lerp(
        RootJointC0 * CFrame.Angles(
            math.rad(foward* maxJointTilt),
            math.rad(-right * maxJointTilt),
            0
        ),
        6 * deltaTime
        
    )

    LeftHipJoint.C0 = LeftHipJoint.C0:Lerp(
        LeftHipJointC0 * CFrame.Angles(math.rad(right*maxJointTilt),0,0),
        6 * deltaTime
    )

    RightHipJoint.C0 = right
end


local function UpdateCamOffset()
    
end


RunService.RenderStepped:Connect(function(dt)
  Val1,Val2 = GetMoveMentVal()
  updateJoints(dt, Val1, Val2)
end)
