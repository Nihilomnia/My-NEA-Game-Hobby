local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local SFX = game:GetService("SoundService")

local Events = RS.Events
local MovementEvent: RemoteEvent = Events.Movement
local VFX_Event: RemoteEvent = Events.VFX

local WeaponAnims = RS.Animations.Weapons

MovementEvent.OnServerEvent:Connect(function(plr, action, ...)
	local char = plr.Character
	local Humanoid = char.Humanoid
	local CurrentWeapon  = char:GetAttribute("CurrentWeapon")
	local HRP: Part = char.HumanoidRootPart
	if action == "LedgeHold" then
		if not Humanoid or not HRP then return end
        local ledge :Part = ...
		local LedgeHoldAnimation = Humanoid.Animator:loadAnimation(WeaponAnims[CurrentWeapon].Movement.LedgeGrab)

		HRP.Anchored = true
		Humanoid.AutoRotate = false
		local yOffset = -1.5
		local LedgeDistance = 0.4

		local ledgeForward = -ledge.CFrame.LookVector
        local HorizontalLedgeFoward = Vector3.new(ledgeForward.X,0,ledgeForward.Z).unit
        

        local currentXZ = Vector3.new(HRP.Position.X, 0, HRP.Position.Z)
        local LedgeY = ledge.Position.Y
        local offset = currentXZ + HorizontalLedgeFoward * -LedgeDistance
		local finalPostion = Vector3.new(offset.X, LedgeY +yOffset,offset.Z)

		local lookat = finalPostion + HorizontalLedgeFoward
		HRP.CFrame = CFrame.new(finalPostion,lookat)

		LedgeHoldAnimation:Play(.3)
	end


	if action == "ReleaseLedge" then
		local Vault = ...
		for i, anim in Humanoid:GetPlayingAnimationTracks() do 
			if anim.Name == "LedgeGrab" then 
				anim:Stop()
			end
		end

		if Vault then 
			local jumpAnim = Humanoid.Animator:LoadAnimation(WeaponAnims[CurrentWeapon].Movement.Vault)
			jumpAnim:Play()
			HRP.Anchored = false
			Humanoid.AutoRotate = true

			local bv = Instance.new("BodyVelocity")
			bv.Velocity = HRP.CFrame.LookVector * 35 + Vector3.new(0,25,0)
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.P = 1250
			bv.Parent = HRP
			Debris:AddItem(bv, .3)

			local sound = SFX.SFX.Movement.LeapSound:Clone()
			sound.Parent = HRP
			sound:Play()
			Debris:AddItem(sound, 1.5)

			VFX_Event:FireAllClients("Highlight",char,.9,Color3.fromRGB(173, 173, 173),Color3.fromRGB(176, 175, 175))
		else
			HRP.Anchored = false
			Humanoid.AutoRotate = true
		end
	   
	end
end)
