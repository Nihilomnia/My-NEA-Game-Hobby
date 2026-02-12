local NPC  = {}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules

local AcessoryModule = require(SSModules.Other.AccessoriesManager)-- I would most likely use this to actually add the npc's gear
local Dictionaries = SSModules.Dictionaries
local NPC_Dictionary  = require(Dictionaries.NPC_Info)
local Signal = require(SSModules.Packages.Signal) -- I think using signl to send to message to "Brains" to inform them the NPC is ready will be a good choice as it will prevent the script from racing


local NPCFolder = game.workspace.NPC
local NPCModels = RS.Models.NPC 
local Humanoid_NPC_TEMPLATE = NPCModels.NPC_Template
local NPC_Brainfolder = ... -- This the folder will store all the brain scripts that call their respective behavior treee




function NPC.SpwanNPC(NPC_Name,Amount,Location) -- this function will be called when a player enters a zone because ratther then having every npc with a setspwan spwan to save resoruces in a serverscript i will make a sone 
    local NPCinfo = NPC_Dictionary.getStats(NPC_Name)
    local NPCMobType = NPCinfo.MobType
    local NPCType = NPCinfo.Type
    local TargetTemplate : Model = nil
    local npc : Model = nil
    local Brain: Script = nil

    if NPCType == "Boss" then 
           TargetTemplate = NPCModels:FindFirstChild(NPC_Name)  
           npc = TargetTemplate:Clone()
           Brain = NPC_Brainfolder[NPCType]:Clone()
           Brain.Parent = npc
           npc.Parent = NPCFolder
           npc:MoveTo(Location)
           -- Signal logic to start the brain will go here
           
    elseif  NPCMobType == "Humanoid" or "Human" then
        TargetTemplate = Humanoid_NPC_TEMPLATE
        npc = TargetTemplate.Clone()
        Brain = NPC_Brainfolder[NPCType]:Clone()
        Brain.Parent = npc
        npc.Parent = NPCFolder
        npc:MoveTo(Location)
        -- process to load the npc appearnace will go here
        -- Signal logic to start the brain will go here

    else
        TargetTemplate = NPCModels[NPC_Name]
        npc = TargetTemplate:Clone()
        Brain = NPC_Brainfolder[NPCType]:Clone()
        Brain.Parent = npc
        npc.Parent = NPCFolder
        npc:MoveTo(Location)
        -- Signal logic to start the brain will go here
    end    
end


function NPC.CleanupNPC(npc:Model)
    npc:Destroy()
end




--[[
NPC.SpwanNPC() 
this function will be called when a player enters a zone because ratther then having every npc with a setspwan spwan to save resoruces in a serverscript I will make it check for when a player get near the spwan point before spawing the npc
IF the player leaves said zone and no other player enters i will despwan all NPCs in the area isong NPC.CleanupNPC()
]] 






return NPC