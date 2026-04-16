--[Services]--
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")


--[Player]--
local plr = Players.LocalPlayer
local char = script.Parent
local Hum:Humanoid? = char:WaitForChild("Humanoid",8)
local HRP : BasePart? = char:WaitForChild("HumanoidRootPart",8)
local Torso = char:WaitForChild("Torso",8)
local cam = workspace.CurrentCamera


local RootJoint = HRP.RootJoint
local LeftHipJoint = Torso["Left Hip"]
local RightHipJoint = Torso["Right Hip"]

