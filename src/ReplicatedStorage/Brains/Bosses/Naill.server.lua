local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")


local Events = RS.Events

local RSModules = RS.Modules
local SSModules = SS.Modules

local CombatEvent = Events.Combat
local WeaponsModels = RS.Models.Weapons
local WeaponsWeld = RS.Welds.Weapons
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons


local BehaviourTreeCreator = require(RS.BehaviorTreeCreator)


local CombatHelperModule =require(SSModules.Combat.CombatHelper)
local HelpfullModule = require(SSModules.Other.Helpful)
local Mode_Module =require(SSModules.Combat.Mode_Module)
local Combat_Data = require(SSModules.Combat.Data.CombatData)
local AI_TREE = BehaviourTreeCreator:_createTree(RS.AI_Trees.BasicEnemy)

local char = script.Parent
local HRP = char.HumanoidRootPart
local Humanoid = char.Humanoid

char:SetAttribute("Equipped", true)
char:SetAttribute("Combo", 1)
char:SetAttribute("Stunned", false)
char:SetAttribute("Swing", false)
char:SetAttribute("Attacking", false)
char:SetAttribute("iframes",false)
char:SetAttribute("IsBlocking",false)
char:SetAttribute("Blocking",0)
char:SetAttribute("Karma",0)


char:SetAttribute("Mode1", false)
char:SetAttribute("Mode2", false)
char:SetAttribute("Parrying",false)

char:SetAttribute("Dodges",0)
char:SetAttribute("Sprinting",false)
char:SetAttribute("IsCrouching",false)

local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local BlockingAnims = Combat_Data.BlockingAnims
local TransformAnims = Combat_Data.TransformAnims
local ParryAnims = Combat_Data.ParryAnims
local DodgeAnims = Combat_Data.DodgeAnims
local EquipDebounce = Combat_Data.EquipDebounce
local DodgeDebounce = Combat_Data.DodgeDebounce

local Race = "SoulReaper"

local function getUniqueId(char:Model)
	local uid = char.Humanoid:FindFirstChild("UniqueId")
	local UID_Value = uid.Value
	return UID_Value
end


local Object = {
	Name = char.Name,
	model = char,
	human = Humanoid,
	Range = 30,
	isPathRunning = false,
	AttackRange = 10,
	Target = nil,
	
}


local function Update()
	if char and Humanoid.Health > 0 then
		task.wait()
		AI_TREE:Run(Object)
	end
end

RunService.Stepped:Connect(Update)