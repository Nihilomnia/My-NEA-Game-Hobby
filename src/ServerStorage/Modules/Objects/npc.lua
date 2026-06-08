--[[
    NPC OOP Module Written by: @Æon/ Daniel Korubo

    This module is desgied to create npc objects that are simular to the plr objects that roblox creates for players.
    
    The npc object looks like this:
    npc = {
        FirstName: string, -- The NPC's First name 
		LastName: string,
		Difficulty: string,
		MobType: string,
		Character: Model,
		Element: string,
		Brain: Script,
	    talents: {},
		skills: {},
		drops: {},

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
local ServerStorage = game:GetService("ServerStorage")

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
local HelpfullModule = require(ServerStorage.Modules.Other.Helpful)

local Brain_Folder = SS.Brains
local NPCFolder = game.workspace.NPC
local NPCModels = RS.Models.NPC
local WeaponAnimations = RS.Animations.Weapons

npc.__index = npc
local CharToNPC = {}

export type NPC = typeof(setmetatable(
	{} :: {
		FirstName: string,
		LastName: string,
		Difficulty: string,
		MobType: string,
		Character: Model,
		Element: string,
		Brain: Script,
		talents: {},
		skills: {},
		drops: {},
	},
	npc
))

local function CreateModel(npcName, Difficulty, MobType)
	local TargetTemplate: Model = nil
	if Difficulty == "Boss" then
		TargetTemplate = NPCModels:FindFirstChild(npcName)
	elseif MobType == "Humanoid" or MobType == "Human" then
		TargetTemplate = NPCModels:FindFirstChild(npcName)
		-- Then i would randomise hair, skintone, face etc once i make a customastion module
	else
		TargetTemplate = NPCModels[npcName]
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








function npc.new(NpcName: string, char: Model?): NPC
	local self = setmetatable({
		FirstName = "",
		LastName = "",
		Difficulty = "",
		MobType = "",
		Character = nil :: any,
		Element = "",
		Brain = nil :: any,
		talents = {},
		skills = {},
		drops = {},
	}, npc) :: NPC

	local NPCinfo = NPC_Dictionary.getStats(NpcName)
	print(NpcName)
	print(NPCinfo)
	self.MobType = NPCinfo.Mobtype
	self.Difficulty = NPCinfo.Difficulty
	self.Character = char or CreateModel(NpcName, self.Difficulty, self.MobType)

	if self.FirstName ~= "" and self.LastName ~= "" then
		self.Character.Name = self.FirstName .. self.LastName
	end

	self.Character.Humanoid.MaxHealth = NPCinfo.Health
	self.Character.Humanoid.Health = NPCinfo.Health

	-- Check if the npc model is in the NPC folder
	if self.Character.Parent ~= NPCFolder then
		self.Character.Parent = NPCFolder
	end

	-- Load the npc's brain (script) based on its type and parent it to the npc model
	-- But first we need to see if the brain already exists in the model (Just in case for dummy npcs that are only used for testing and have the brain already in the model)
	-- The Debuging brains are always going to be called "Brain" and the rest of the brains are going to be called after the npc type (ex: "Boss", "Smallfry", ect)
	-- And because if the npc isn't a debug npc it wont have a brain we can use it as a flag for other things aswell
	if not self.Character:FindFirstChild("Brain") then
		local Brain: Script = Brain_Folder[self.Difficulty]:Clone()
		Brain.Parent = self.Character
		self.Brain = Brain
		for i, v in pairs(NPCinfo.STAT_POINTS) do
			self[i] = v
			self.Character:SetAttribute(i, v)
		end

		self.Character:SetAttribute("CurrentWeapon", "Fists")

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
		self.Brain = self.Character.Brain
		self.Element = self.Character:GetAttribute("Element")
	end

	CharToNPC[self.Character] = self

	-- This is where the npc's drops are loaded into the npc object so that they can be accessed later when the npc dies
	--self.drops = PickDrops(NpcName)

	Combat_Data.ActiveNPCs[self.Character] = self 
	 --^ fall back for getting npcs in combat data, this is incase there is a situation where i need to get an npc but i cant use the GetNpcFromCharacter function for some reason, this way i can still get the npc object from the character for example the many cyclic errors that would happen if i try to require the npc module in the combat modules, this way i can just get the npc from the combat data without having to require the npc module in the combat modules and cause cyclic errors

	-- The NPC should be ready by now
	self:Idle()
	
    
	return self
end

function npc.GetNpcFromCharacter(char): NPC?
	if CharToNPC[char] then
		return CharToNPC[char]
	end
	return nil
end


function npc:Destroy()
	CharToNPC[self.Character] = nil
	Combat_Data.ActiveNPCs[self.Character] = nil  
	self.Character:Destroy()
	table.clear(self)
	table.freeze(self)
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
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	CombatHelper.Attack(self.Character, self)
end

function npc:Idle()
	local hum = self.Character.Humanoid
	local CurrentWeapon = self.Character:GetAttribute("CurrentWeapon")
    Combat_Data.IdleAnims[self] = hum.Animator:LoadAnimation(WeaponAnimations[CurrentWeapon].Main.Idle)
	if Combat_Data.IdleAnims[self].IsPlaying then return end
    Combat_Data.IdleAnims[self]:Play()
end

function npc:Block()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	if HelpfullModule.CheckForAttributes(self.Character, true, true, true, nil, true, false, true, nil) then
		return
	end
	BlockModule.ActivateBlocking(self.Character, self)
end

function npc:Unblock()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	if HelpfullModule.CheckForAttributes(self.Character, true, true, true, nil, true, false, true, nil) then
		return
	end
	BlockModule.DeactivateBlocking(self.Character, self)
end

function npc:Dodge(Direction)
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	DodgeModule.Dodge(self.Character, Direction, self)
end

function npc:Parry()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	if HelpfullModule.CheckForAttributes(self.Character, true, true, true, true, true, false, true, true) then
		return
	end
	ParryModule.ParryAttempt(self.Character, self)
end

function npc:Phase2()
	if self.Character:GetAttribute("IsTransforming") then
		return
	end
	ModeModule.Mode2(self.Character, self)
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


