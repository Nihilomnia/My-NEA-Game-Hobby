--[[
    NPC OOP Module Written by: @Æon/ Daniel Korubo

    This module is desgied to create npc objects that are simular to the plr objects that roblox creates for players.
    
    The npc object looks like this:
    npc = {
        Type = "...", -- This is the type of npc it is (Passive, SmallFry, Elite, Boss)
        Character = Model, -- This is the npc model that is in the workspace
        Element = "...",-- This is the npc's moveset if present
        Brain = Script, -- This is the script thats starts the npc's behavior tree
        talents = {},
        skills = {},
        drops = {},

    }


    The npc functions will be :

    npc.new(NpcName, char) -- This is the constructor for the npc object it takes in the npc's name and an optional model if you want to use a custom model instead of the default one
    npc.GetNpcFromCharacter(char) -- This would allow me to get the npc object from anywhere in the game as long as i have the chater
    npc:Destroy() -- This will destroy the npc and clean up any connections or data related to the npc
    npc:Attack() -- This will make the npc perform an attack using the attack module
    npc:Block() -- This will make the npc perform a block using the block module
    npc:Unblock() -- This will make the npc perform an unblock using the block module
    npc:Dodge() -- This will make the npc perform a dodge using the dodge module
	npc:Parry() -- This will make the npc perform a parry using the parry module
	npc:Phase2() -- This will make the npc perform a phase 2 transformation using the mode module
	npc:CastAblity() -- This will make the npc perform a cast ability using the cast ability module
	npc:Climb() -- This will make the npc perform a climb using the movement module
	npc:WallRun() -- This will make the npc perform a wall run using the movement module
	npc:Start() -- This will start the npc's behavior tree and make it active in the game
 
]]

local npc = {}
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local SSModules = SS.Modules
local Dictionaries = SSModules.Dictionaries

local NPC_Dictionary = require(Dictionaries.NPC_Info)
local BlockModule = require(SSModules.BlockModule)
local ParryModule = require(SSModules.Parrying)
local DodgeModule = require(SSModules.DodgeModule)
local ModeModule = require(SSModules.Combat.Mode_Module)
local CombatHelper = require(SSModules.Combat.CombatHelper)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local EquipModule = require(SSModules.Combat.EquipModule)

local Brain_Folder = SS.Brains
local NPCFolder = game.workspace.NPC
local NPCModels = RS.Models.NPC


npc.__index = npc
local CharToNPC = {}


local function CreateModel(npcType)
	local TargetTemplate: Model = nil
	if npcType == "Boss" then
		TargetTemplate = NPCModels:FindFirstChild(npcType)
	elseif npcType == "Humanoid" or npcType == "Human" then
		TargetTemplate = NPCModels:FindFirstChild(npcType)
        -- Then i would randomise hair, skintone, face etc once i make a customastion module	
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

function npc.new(NpcName, char)
	local self = setmetatable({}, npc)
	local NPCinfo = NPC_Dictionary.getStats(NpcName)
	self.Type = NPCinfo.Type
	self.Character = char or CreateModel(self.Type)

	-- Check if the npc model is in the NPC folder
	if self.Character.Parent ~= NPCFolder then
		self.Character.Parent = NPCFolder
	end

	-- Load the npc's brain (script) based on its type and parent it to the npc model
	-- But first we need to see if the brain already exists in the model (Just in case for dummy npcs that are only used for testing and have the brain already in the model)
	-- The Debuging brains are always going to be called "Brain" and the rest of the brains are going to be called after the npc type (ex: "Boss", "Smallfry", ect)
    -- And because if the npc isn't a debug npc it wont have a brain we can use it as a flag for other things aswell
    if not self.Character:FindFirstChild("Brain") then
		local Brain: Script = Brain_Folder[self.Type]:Clone()
		Brain.Parent = self.Character
		self.Brain = Brain
		for i, v in pairs(NPCinfo.STAT_POINTS) do
			self[i] = v
		end

		if self.Type == "Boss" then
			self.Element = NPCinfo.Element
			self.Character:SetAttribute("Element", self.Element)
		elseif self.Type == "Humanoid" then
			-- Handle humanoid-specific initialization will be random from a table of movesets in the npc info
			-- But for now
			self.Element = NPCinfo.Element
			self.Character:SetAttribute("Element", self.Element)
		else
			-- These are non-humanoids that dont use an element 
			self.Element = "None"
			self.Character:SetAttribute("Element", "None")
		end
        
    else
        self.Brain = self.Character:FindFirstChild("Brain")
        self.Element = self.Character:GetAttribute("Element")
	end

    CharToNPC[self.Character] = self

	-- This is where the npc's drops are loaded into the npc object so that they can be accessed later when the npc dies
	--self.drops = PickDrops(NpcName)



	return self
end

function npc.GetNpcFromCharacter(char)
	if CharToNPC[char] then
		return CharToNPC[char]
	end
	return nil
end

function npc:Destroy()
	self.Character:Destroy()
	table.clear(self)
	table.freeze(self)
	table.remove(CharToNPC, table.find(CharToNPC, CharToNPC[self.Character]))
	for k, v in pairs(Combat_Data) do
		if type(v) == "table" then
			table.remove(v, table.find(v, self))
		end
	end
end
function npc:EquipWeapon()
	EquipModule.EquipWeapon(self.Character, self)
end

function npc:UnequipWeapon()
	EquipModule.UnequipWeapon(self.Character, self)
end

function npc:Start()
	if self.Brain and self.Brain:IsA("Script") then
		self.Brain.Disabled = false
	end
end

function npc:Attack()
	CombatHelper.Attack(self.Character,self)
end

function npc:Block()
	BlockModule.ActivateBlocking(self.Character,self)
end

function npc:Unblock()
	BlockModule.DeactivateBlocking(self.Character,self)
end

function npc:Dodge(Direction)
	DodgeModule.Dodge(self.Character,Direction,self)
end

function npc:Parry()
	ParryModule.ParryAttempt(self.Character,npc)
end

function npc:Phase2()
	ModeModule.Mode2(self.Character,npc)
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

return npc
