local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local npc = require(ServerStorage.Modules.Objects.npc)


local hell:npc.NPC = npc.new("TestNPC")
local HRP = hell.Character.HumanoidRootPart 
HRP.CFrame = CFrame.new(0,10,0)


