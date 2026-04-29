local module = {}
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSModules = SS.Modules



-- Module references
local ElementInfo = require(SSModules.Dictionaries.ElementInfo)
local HelpfulModule = require(SSModules.Other.Helpful)
local Textmod = require(SSModules.text)
local Combat_Data= require(SSModules.Combat.Data.CombatData)




--Tables
local Welds = Combat_Data.Welds
local EquipAnims = Combat_Data.EquipAnims
local UnEquipAnims = Combat_Data.UnEquipAnims
local IdleAnims = Combat_Data.IdleAnims
local TransformAnims = Combat_Data.TransformAnims
local EquipDebounce = Combat_Data.EquipDebounce


-- Folders
local Models = RS.Models
local WeaponsModels = Models.Weapons
local WeaponsWeld = RS.Welds.Weapons
local WeaponsAnimations = RS.Animations.Weapons
local TransformConnections = {}





local function MakeWeaponInvisible(char,Weapon)
	if not Weapon and char then return end

    Weapon.transparency = 0.011
	Weapon.Reflectance = -0.4 -- this is a bit of a bug to make the when invisble to certain parts 

	local HRP = char:FindFirstChild("HumanoidRootPart")
	local InviblePart = RS.Effects.InvisiblePart:Clone()
	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = HRP
	Weld.Part1 = InviblePart
	Weld.Parent = HRP
	InviblePart.Size = Weapon.Size + Vector3.new(0.5,0.5,0.5)
	InviblePart.CFrame = Weapon.CFrame
	InviblePart.Parent = HRP
end

local function RemoveInvisibleParts(char,Weapon)
	if not char then return end
	local HRP = char:FindFirstChild("HumanoidRootPart")
	if not HRP then return end
	for _,part in ipairs(HRP:GetChildren()) do
		if part.Name == "InvisiblePart" then
			part:Destroy()
		end
	end
end
---------------------------------------------------------------------
-- MODE 1 TRANSFORMATION
---------------------------------------------------------------------
function module.Mode1(char,npc)
	if not char or not char:FindFirstChild("Humanoid") then return end

	local hum = char.Humanoid
	local rootPart = char:WaitForChild("HumanoidRootPart")

	local plr = game.Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc
	if not Identifier then return end
	if EquipDebounce[Identifier] then return end -- Prevent duplicate calls

	-- Debounce & state
	EquipDebounce[Identifier] = true
	char:SetAttribute("iframes", true)
	char:SetAttribute("IsTransforming", true)
	

	local element = char:GetAttribute("Element")
	if element == nil or element == "..." then  
		warn("[Mode_Module] Element attribute is invalid for character: "..char.Name)
		return
	end
	local elementStats = ElementInfo.getStats(element)
	local newWeapon = elementStats.Mode1

	-- Load and play transformation animation
	TransformAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations.Transformations[element].Mode1)
	rootPart.Anchored = true
	TransformAnims[Identifier]:Play()

	-- Disconnect any previous connection for this character
	if TransformConnections[Identifier] then
		TransformConnections[Identifier]:Disconnect()
	end

	-- Connect new transform signal
	TransformConnections[Identifier] = TransformAnims[Identifier]
		:GetMarkerReachedSignal("Transform")
		:Connect(function()
			-- Ensure single execution
			TransformConnections[Identifier]:Disconnect()

			-- Prevent transformation if swings or invalid state
			for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
				if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
					return
				end
			end

			if HelpfulModule.CheckForAttributes(char, true, true, true, true, nil, true,true,nil) then return end

			char:SetAttribute("CurrentWeapon", newWeapon)

			local torso = char:FindFirstChild("Torso")
			local rightArm = char:FindFirstChild("Right Arm")

			-- Remove existing weapon models
			for _, weapon in ipairs(WeaponsModels:GetChildren()) do
				local existing = char:FindFirstChild(weapon.Name)
				if existing then
					existing:Destroy()
				end
			end

			-- Change to new weapon
			HelpfulModule.ChangeWeapon(Identifier, char, torso)

			
			-- Setup weld
			if Welds[Identifier] then
				Welds[Identifier].Part0 = rightArm
				Welds[Identifier].C0 = WeaponsWeld[newWeapon].HoldingWeaponWeld.C0
			end

			-- Load idle/equip animations
			IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Idle)
			EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Equip)


			-- Restore states
			rootPart.Anchored = false
			char:SetAttribute("IsTransforming", false)
			char:SetAttribute("Equipped", true)
			char:SetAttribute("iframes", false)
			char:SetAttribute("Mode1", true)
			EquipDebounce[Identifier] = false


			if IdleAnims[Identifier] then
				IdleAnims[Identifier]:Play()
			end
		end)
end

---------------------------------------------------------------------
-- MODE 2 TRANSFORMATION
---------------------------------------------------------------------
function module.Mode2(char,npc)
	if not char or not char:FindFirstChild("Humanoid") then return end

	local hum = char.Humanoid
	local rootPart = char:WaitForChild("HumanoidRootPart")

	local plr = game.Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc
	if not Identifier then return end
	if EquipDebounce[Identifier] then return end

	-- Debounce & state
	EquipDebounce[Identifier] = true
	char:SetAttribute("iframes", true)
	char:SetAttribute("IsTransforming", true)
	char:SetAttribute("Mode2", true)

	local element = char:GetAttribute("Element")
	if element == nil or element == "..." then  
		warn("[Mode_Module] Element attribute is invalid for character: "..char.Name)
		return
	end
	local elementStats = ElementInfo.getStats(element)
	local newWeapon = elementStats.Mode2
	local dialogue = elementStats.Text

	hum.Health += 100
	rootPart.Anchored = true

	-- Load animation (placeholder until Mode2 animation is made)
	TransformAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations.Transformations[element].Mode1)

	if plr then
		-- Textmod.feed(dialogue, plr)  freezing this for now
	end

	TransformAnims[Identifier]:Play()

	-- Disconnect any previous connection
	if TransformConnections[Identifier] then
		TransformConnections[Identifier]:Disconnect()
	end

	-- Connect transform event
	TransformConnections[Identifier] = TransformAnims[Identifier]
		:GetMarkerReachedSignal("Transform")
		:Connect(function()
			TransformConnections[Identifier]:Disconnect()

			-- Prevent transformation if swings or invalid state
			for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
				if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
					return
				end
			end

			if HelpfulModule.CheckForAttributes(char, true, true, true, true, nil, true,true,nil) then return end

			char:SetAttribute("CurrentWeapon", newWeapon)

			local torso = char:FindFirstChild("Torso")
			local rightArm = char:FindFirstChild("Right Arm")

			-- Remove all existing weapon models
			for _, weapon in ipairs(WeaponsModels:GetChildren()) do
				local existing = char:FindFirstChild(weapon.Name)
				if existing then
					existing:Destroy()
				end
			end

			-- Change weapon
			HelpfulModule.ChangeWeapon(Identifier, char, torso)

			-- Setup weld
			if Welds[Identifier] then
				Welds[Identifier].Part0 = rightArm
				Welds[Identifier].C0 = WeaponsWeld[newWeapon].HoldingWeaponWeld.C0
				if Welds[Identifier].C1 then
					Welds[Identifier].C1 = WeaponsWeld[newWeapon].HoldingWeaponWeld.C1
				end
			end

			-- Load animations
			IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Idle)
			EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Equip)

			rootPart.Anchored = false
			char:SetAttribute("IsTransforming", false)
			char:SetAttribute("Equipped", true)
			char:SetAttribute("iframes", false)
			char:SetAttribute("Mode2", true) 
			EquipDebounce[Identifier] = false


			if IdleAnims[Identifier] then
				IdleAnims[Identifier]:Play()
			end

			if npc == nil then -- This means that its a player transformation, so we start the MF gain coroutine, if its an npc transformation we dont want to do this
				coroutine.wrap(function()
				local mf = char:GetAttribute("MF")
				local maxMF = char:GetAttribute("MaxMF")
				print("hello starting MF gain")
				while char:GetAttribute("Mode2") do
					task.wait(1)
					mf = char:GetAttribute("MF")
					maxMF = char:GetAttribute("MaxMF")
					if mf and mf < maxMF then
						while char:GetAttribute("AstralDodgeActive") do
							task.wait(0.1)
						end
						
						char:SetAttribute("MF", mf + 2.5)

					else
						module.Revert(char)
						return
					end
				end

			end)()
			end

			
		end)
end



function module.Revert(char,npc)
if not char or not char:FindFirstChild("Humanoid") then return end

local hum = char:FindFirstChild("Humanoid")
local torso = char:FindFirstChild("Torso")
local rightArm = char:FindFirstChild("Right Arm")
local plr = game.Players:GetPlayerFromCharacter(char)
local Identifier = plr or npc
if not Identifier then return end
if EquipDebounce[Identifier] then return end -- Prevent duplicate calls

if char:GetAttribute("Mode1") then 
	EquipDebounce[Identifier] = true
	char:SetAttribute("iframes", true)
	char:SetAttribute("IsTransforming", true)
	

	local newWeapon = "Fists" -- This will be a placeholder untill I add non elsement weapons
	TransformAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations.Transformations.Revert)
	hum.WalkSpeed = 8
	TransformAnims[Identifier]:Play()



	if TransformConnections[Identifier] then
		TransformConnections[Identifier]:Disconnect()
	end


	TransformConnections[Identifier] = TransformAnims[Identifier]
		:GetMarkerReachedSignal("Transform")
		:Connect(function()
			TransformConnections[Identifier]:Disconnect()

			for _, anim in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
				if anim.Name == "Swing1" or anim.Name == "Swing2" or anim.Name == "Swing3" or anim.Name == "Swing4" then
					return
				end
			end

			if HelpfulModule.CheckForAttributes(char, true, true, true, true, nil, true,true,nil) then return end
			
			char:SetAttribute("CurrentWeapon", newWeapon)

			for _, weapon in ipairs(WeaponsModels:GetChildren()) do
				local existing = char:FindFirstChild(weapon.Name)
				if existing then
					existing:Destroy()
				end
			end

			HelpfulModule.ChangeWeapon(Identifier, char, torso)

			if Welds[Identifier] then
				Welds[Identifier].Part0 = rightArm
				Welds[Identifier].C0 = WeaponsWeld[newWeapon].HoldingWeaponWeld.C0
			end

			-- Load idle/equip animations
			IdleAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Idle)
			EquipAnims[Identifier] = hum.Animator:LoadAnimation(WeaponsAnimations[newWeapon].Main.Equip)

			HelpfulModule.ResetMobility(char)
			char:SetAttribute("IsTransforming", false)
			char:SetAttribute("Equipped", true)
			char:SetAttribute("iframes", false)
			char:SetAttribute("Mode1", false)
			EquipDebounce[Identifier] = false


			if IdleAnims[Identifier] then
				IdleAnims[Identifier]:Play()
			end

		end)
		

elseif char:GetAttribute("Mode2") then
	module.Mode1(char)
else
warn(char,"Is perfoming a false revert")
end





	
end
	

return module




