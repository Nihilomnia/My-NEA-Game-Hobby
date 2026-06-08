local module = {}
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService") 

local Events = RS.Events
local WeaponEffects = RS.Effects.Weapons
local WeaponSounds = SoundService.SFX.Weapons
local SSModules = SS.Modules
local AnimationsFolder = RS.Animations
local WeaponsAnimations = AnimationsFolder.Weapons

local SoundsModule = require(RS.Modules.Combat.SoundsModule)
local ServerCombatModule = require(SSModules.CombatModule)
local HitServiceModule = require(SSModules.HitService)
local VFX_Event = Events.VFX
local VolumeHitbox = require(SSModules.Hitboxes.VolumeHitboxes)
local WeaponsStatsModule = require(SSModules.Dictionaries.WeaponStats)
local HelpfullModule = require(SSModules.Other.Helpful)

local Connections = {}

local MaxCombo = 4

local FeintFlags = {}
local BlinkCooldowns = {}


function module.Attack(char, npc)
	if not char or not char:FindFirstChild("Humanoid") then return end
	local hum = char.Humanoid
	local HRP = char:FindFirstChild("HumanoidRootPart")
	local torso = char:FindFirstChild("Torso")
	local plr = Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc

	if not HRP or not torso then return end

	if HelpfullModule.CheckForAttributes(char, true, true, true, true, true, true, true, nil) then return end
	if HelpfullModule.ManageStamina(char, "Swing") then return end

	local currentWeapon = char:GetAttribute("CurrentWeapon")

	-- Begin swing
	char:SetAttribute("Attacking", true)
	char:SetAttribute("Swing", true)

	ServerCombatModule.ChangeCombo(char)
	ServerCombatModule.stopAnims(hum)

	hum.WalkSpeed = 16
	hum.JumpHeight = 0

	local WeaponStats = WeaponsStatsModule.getStats(currentWeapon)
	local HitAnim = WeaponsAnimations[currentWeapon].Hit["Hit" .. char:GetAttribute("Combo")]
	local SwingEffect = WeaponEffects[currentWeapon].Swing["Swing" .. char:GetAttribute("Combo")]
	local SwingAnim = ServerCombatModule.getSwingAnims(char, currentWeapon)
	local playSwingAnimation = hum.Animator:LoadAnimation(SwingAnim)
	local swingReset = WeaponStats.SwingReset

	-- Disconnect any lingering connections from a previous swing
	if Connections[Identifier] then
		for _, conn in pairs(Connections[Identifier]) do
			if conn then conn:Disconnect() end
		end
	end

	Connections[Identifier] = {}

	-- Capture connections in locals so each handler always disconnects itself,
	-- not whatever the shared table holds at the time of firing (stale closure fix)
	local hitStartConn, hitEndConn

	-- Shared cleanup: called by Stopped if HitEnd never fired (e.g. interrupted by a transformation).
	-- If HitEnd already ran the locals will already be nil, making this a safe no-op for those paths.
	local function cleanupSwing()
		if hitStartConn then
			hitStartConn:Disconnect()
			hitStartConn = nil
			Connections[Identifier].HitStart = nil
		end
		if hitEndConn then
			hitEndConn:Disconnect()
			hitEndConn = nil
			Connections[Identifier].HitEnd = nil
		end
		VolumeHitbox.DestroyHitboxes(char, npc)
		HelpfullModule.ResetMobility(char)
		char:SetAttribute("Attacking", false)
		char:SetAttribute("Swing", false)
		FeintFlags[Identifier] = false
	end

	hitStartConn = playSwingAnimation
		:GetMarkerReachedSignal("HitStart")
		:Connect(function()
			local HitBoxSize = WeaponStats.HitboxSize
			local HitBoxOffset = WeaponStats.HitboxOffset
			local Attachment = Instance.new("Attachment")
			Attachment.Parent = HRP
			Attachment.Name = "LightAttackHitbox"
			Attachment.WorldCFrame = HRP.CFrame * HitBoxOffset

			VolumeHitbox.NormalHitBox(HitBoxSize, Attachment, char, npc, function(Ehum, Hit)
				local Result = HitServiceModule.Normal_Hitbox(char, currentWeapon, Ehum, npc, Hit, HitAnim)
				print(Result)
				return Result
			end)

			Attachment:Destroy()

			hitStartConn:Disconnect()
			hitStartConn = nil
			Connections[Identifier].HitStart = nil
			FeintFlags[Identifier] = true
		end)

	hitEndConn = playSwingAnimation
		:GetMarkerReachedSignal("HitEnd")
		:Connect(function()
			VolumeHitbox.DestroyHitboxes(char)

			char:SetAttribute("Swing", false)
			print("stopped hitend")

			if char:GetAttribute("Combo") == MaxCombo then
				task.wait(0.5)
			else
				task.wait(swingReset)
			end

			char:SetAttribute("Attacking", false)

			hitEndConn:Disconnect()
			hitEndConn = nil
			Connections[Identifier].HitEnd = nil
			FeintFlags[Identifier] = false
		end)

	Connections[Identifier].HitStart = hitStartConn
	Connections[Identifier].HitEnd = hitEndConn

	-- Stopped fires whenever the animation ends for ANY reason (natural finish, stopAnims,
	-- or a transformation interrupting mid-swing). cleanupSwing safely no-ops the parts
	-- that HitEnd already handled.
	playSwingAnimation.Stopped:Connect(function()
		print("stopped")
		cleanupSwing()
	end)

	playSwingAnimation:Play()
	VFX_Event:FireAllClients("SwingEffect", SwingEffect, char)
	SoundsModule.PlaySound(WeaponSounds[currentWeapon].Combat.Swing, torso)

	if plr then VFX_Event:FireClient(plr, "CustomShake", 1, 2, 0, .7) end
end

function module.CancelAttack(char, npc)
	local plr = Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc
	local hum = char.Humanoid
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	local SwingEffect = WeaponEffects[currentWeapon].Swing["Swing" .. char:GetAttribute("Combo")]

	if FeintFlags[Identifier] or char:GetAttribute("Swing") == false then return end

	char:SetAttribute("Attacking", false)
	char:SetAttribute("Swing", false)
	ServerCombatModule.stopAnims(hum)
	VolumeHitbox.DestroyHitboxes(char)
	HelpfullModule.ResetMobility(char)
	VFX_Event:FireAllClients("DestroyVFX", char, SwingEffect)
end

function module.Blink(char,npc,target)
	local plr = Players:GetPlayerFromCharacter(char)
	local Identifier = plr or npc
	if BlinkCooldowns[Identifier] and tick() - BlinkCooldowns[Identifier] < 0.5 then return end
	BlinkCooldowns[Identifier] = tick()

	local HRP = char:FindFirstChild("HumanoidRootPart")
	local Hum = char.Humanoid
	local currentWeapon = char:GetAttribute("CurrentWeapon")
	if not HRP or not Hum then return end
	local HitAnim = WeaponsAnimations[currentWeapon].Hit["Hit" .. char:GetAttribute("Combo")]

	HRP.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0,2,0)

	--local BlinkAnim = Hum.Animator:LoadAnimation(WeaponsAnimations[currentWeapon].Blink):Play()
	--SoundsModule.PlaySound(WeaponSounds[currentWeapon].Combat.Blink, HRP) will uncomment when blink sound is added
	local Size = Vector3.new(5,5,5)
	local Attachment = Instance.new("Attachment")
	Attachment.Parent = HRP
	Attachment.Name = "BlinkEffectAttachment"
	Attachment.WorldCFrame = HRP.CFrame * CFrame.new(0,-2,0)

	VolumeHitbox.NormalHitBox(Size, Attachment, char, npc, function(Ehum,hit)
		HitServiceModule.Blink_Hitbox(char, currentWeapon, Ehum, npc, hit,hit)
	end)

	task.delay(0.5, function() -- would replace with anim event when added so its actually possbile to parry it
		VolumeHitbox.DestroyHitboxes(char)
	end)


end


return module