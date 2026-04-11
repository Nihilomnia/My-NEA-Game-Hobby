--[[
    NPC OOP Module Written by: @Æon/ Daniel Korubo

    This module is desgied to create npc objects that are simular to the plr objects that roblox creates for players.
    
    The npc object looks like this:
    npc = {
        Type = "...", -- This is the type of npc it is (Passive, SmallFry, Elite, Boss)
        Character = Model, -- This is the npc model that is in the worksspace
        Brain = Script, -- This is the script thats starts the npc's behavior tree
        npc.talents = {},
        npc.skills = {},
        npc.drops = {},
    }


    The npc functions will be :

    npc.new(NpcName, char) -- This is the constructor for the npc object it takes in the npc's name and an optional model if you want to use a custom model instead of the default one
    npc.GetNpcFromCharacter(char) -- This would allow me to get the npc object from anywhere in the game as long as i have the chater
    npc:Start() -- This will start the npc's brain 
    npc:Destroy() -- This will destroy the npc and clean up any connections or data related to the npc
    npc:Attack() -- This will make the npc perform an attack using the attack module
    npc:Block() -- This will make the npc perform a block using the block module
    npc:Unblock() -- This will make the npc perform an unblock using the block module
    npc:Dodge() -- This will make the npc perform a dodge using the dodge module
 
]]







local npc = {}
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")


local SSModules = SS.Modules
local Dictionaries = SSModules.Dictionaries

local NPC_Dictionary  = require(Dictionaries.NPC_Info)
local BlockModule = require(SSModules.BlockModule)
local ParryModule = require(SSModules.Parrying)
local DodgeModule = require(SSModules.DodgeModule)
local ModeModule = require(SSModules.Combat.Mode_Module)


local Brain_Folder = SS.Brains
local NPCFolder = game.workspace.NPC
local NPCModels = RS.Models.NPC 
local Humanoid_NPC_TEMPLATE = NPCModels.NPC_Template


npc.__index = npc
local CharToNPC = {}

local function CreateModel(npcType)
    local TargetTemplate : Model = nil
    if npcType == "Boss" then 
        TargetTemplate = NPCModels:FindFirstChild(npcType)  
    elseif  npcType == "Humanoid" or npcType == "Human" then
        TargetTemplate = Humanoid_NPC_TEMPLATE
        -- process to load the npc appearnace will go here 
        -- Most likely be randomly generating the npc's appearnace based on the npc's type
        -- or might divde the non-boss humanoids into thier respective types like bandits, knights, ect and then have a folder for each type with different templates in them and then randomly pick one of those templates to be the npc's model
    else
        TargetTemplate = NPCModels[npcType]
    end    
    
    return TargetTemplate:Clone()
end



local function PickDrops(npcName)
    local npcInfo = NPC_Dictionary.getStats(npcName)
    local LootTable = npcInfo.Drops
    local ChosenDrops = {}
    -- Logic to randomly pick drops from the npc's drop table will go here

    return ChosenDrops
end



function npc.new(NpcName,char)
    local self = setmetatable({}, npc)
    local NPCinfo = NPC_Dictionary.getStats(NpcName)
    self.Type = NPCinfo.Type
    self.Character = char or CreateModel(self.Type)

    -- Check if the npc model is in the NPC folder
    if self.Character.Parent ~= NPCFolder then
        self.Character.Parent = NPCFolder
    end


    -- Load the npc's brain (script) based on its type and parent it to the npc model
    local Brain: Script = Brain_Folder[self.Type]:Clone()
    Brain.Parent = self.Character
    CharToNPC[self.Character] = self
    self.Brain = Brain

    -- This is where the npc's drops are loaded into the npc object so that they can be accessed later when the npc dies
    self.drops = PickDrops(NpcName)

    self.info = NPCinfo 
    

    
    return self
end


function npc.GetNpcFromCharacter(char)
    return CharToNPC[char] 
end


function npc:Start()
    
end


function npc:Destroy()
    self.Character:Destroy()
    CharToNPC[self.Character] = nil
end


function npc:Attack()
    -- My wrap round to use the already made attack module but i dont want to require it each time so i put it here
end


function npc:Block()
    -- My wrap round to use the already made block module but i dont want to require it each time so i put it here
end

function npc:Unblock()
    -- My wrap round to use the already made unblock module but i dont want to require it each time so i put it here
end

function npc:Dodge()
    -- My wrap round to use the already made dodge module but i dont want to require it each time so i put it here
end

function npc:Parry()
    -- My wrap round to use the already made parry module but i dont want to require it each time so i put it here
end

function npc:CastAblity()
    -- My wrap round to use the already made cast ability module but i dont want to require it each time so i put it here
end

function npc:Climb()
    -- My wrap round to use the already made wall jump module but i dont want to require it each time so i put it here
end

function npc:WallRun()
    -- My wrap round to use the already made wall run module but i dont want to require it each time so i put it here
end


function npc:Phase2()
    -- this will be used for bosses to start the second phase of the fight
end




























return npc