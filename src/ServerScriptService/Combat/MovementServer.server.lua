local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local SFX = game:GetService("SoundService")
local ServerStorage = game:GetService("ServerStorage")

local RSModules = RS.Modules
local Helpful = require(ServerStorage.Modules.Other.Helpful)
local Movement = require(RSModules.Movement.Objects.Movement)
local SoundsModule = require(RSModules.Combat.SoundsModule)

local Events = RS.Events
local MovementEvent: RemoteEvent = Events.Movement
local VFX_Event: RemoteEvent = Events.VFX

local WeaponAnims = RS.Animations.Weapons

local ActiveDodges = {}

MovementEvent.OnServerEvent:Connect(function(plr, action, ...)
	local char = plr.Character
	local Humanoid = char:FindFirstChildOfClass("Humanoid")
	local CurrentWeapon  = char:GetAttribute("CurrentWeapon")
	local HRP: Part = char.HumanoidRootPart
	local Torso = char.Torso
	local MovementObj = Movement.GetMovementObj(plr)

	if action == "LedgeHold" then
		if not Humanoid or not HRP then return end
        local ledge :Part = ...
		local LedgeHoldAnimation = Humanoid.Animator:loadAnimation(WeaponAnims[CurrentWeapon].Movement.LedgeGrab)

		HRP.Anchored = true
		Humanoid.AutoRotate = false
		local yOffset = -1.5
		local LedgeDistance = 0.4

		local ledgeForward = -ledge.CFrame.LookVector
        local HorizontalLedgeFoward = Vector3.new(ledgeForward.X,0,ledgeForward.Z).Unit
        

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


			SoundsModule.PlaySound(SFX.SFX.Movement.LeapSound,HRP)

	

			VFX_Event:FireAllClients("Highlight",char,.9,Color3.fromRGB(173, 173, 173),Color3.fromRGB(176, 175, 175))
		else
			HRP.Anchored = false
			Humanoid.AutoRotate = true
		end
	   
	end

	if action == "CrouchStart" then
		print("Server has gotton crouch request")
		print(MovementObj.States)
		if MovementObj.States.IsCrouching then return end 
		print("SOundPLAyes?")
		SoundsModule.PlaySound(SFX.SFX.Movement.Crouch, Torso)
		MovementObj.States.IsCrouching = true
	end

	if action == "CrouchEnd" then
		print(MovementObj.States)
		if not  MovementObj.States.IsCrouching then return end 
		SoundsModule.PlaySound(SFX.SFX.Movement.Crouch, Torso)
		MovementObj.States.IsCrouching = false
	end

	if action == "Dodge" then
		local Config = {
			DashDur = 0.2,
			Buffer_distance = 5,
			Speed = 85
		}

		if char:GetAttribute("Dodging") == true then return end 

		if Helpful.CheckForAttributes(char, true, true, true, true, false, true, false, true) then return end 
        
		
		char:SetAttribute("Dodging",true)

		local StartTime = workspace:GetServerTimeNow()
		local StartPostion = HRP.Position

		local function CalcSpeed()
			local Speed = Config.Speed -- here i was use the same formula as the client 
			return Speed
		end

		ActiveDodges[plr] = {
			StartTime =StartTime,
			StartPos = StartPostion,
			Speed = CalcSpeed()
		}

		task.delay(Config.DashDur,function()
			if not char or not HRP then 
				ActiveDodges[plr] = nil
				return
			end

			char:SetAttribute("Dodging",false)
			
			local TrackedVictim = ActiveDodges[plr]

			if TrackedVictim then
				local endpos = HRP.Position
				local Travel = (endpos-TrackedVictim.StartPos).Magnitude

				local MaxDistance = (TrackedVictim.Speed * Config.DashDur) + Config.Buffer_distance

				if  Travel >  MaxDistance then
					warn(plr.Name .. " You cheater you failed dodge validation! Your Dist: " .. Travel .. " | The Real Dist you should have moved: " .. MaxDistance)
                    
					Humanoid.Health = 0

					plr:Kick("You Cheat")
					

				end


				ActiveDodges[plr] = nil

			end


		end)
		
		
	end

	if action == "WallRunStart" then
	  --- Stuff
	end

	if action == "WallRunEnd" then
	 -- end stuff
	end
end)
