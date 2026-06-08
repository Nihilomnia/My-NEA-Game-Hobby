local module = {}

local Debris = game:GetService("Debris")
RS = game:GetService("ReplicatedStorage")
TS = game:GetService("TweenService")

local AnimationsFolder = RS.Animations
local ElementAnims = AnimationsFolder.Element

function module.EmitEffect(effect, cframe, destroytime)
	local effect = effect:Clone()
	effect.Parent = workspace.VFX
	effect.CFrame = cframe

	for i, v in pairs(effect:GetDescendants()) do
		if v:isA("ParticleEmitter") then
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end

	Debris:AddItem(effect, destroytime)
end

local targetObject = nil

function module.triggerEffects(parentObject, char)
	local HRP = char:FindFirstChild("HumanoidRootPart")
	if not HRP then
		warn("No HRP found!")
		return
	end

	-- Clone the whole effect object
	local EffectPart = parentObject:Clone()
	EffectPart.Parent = workspace.VFX

	EffectPart.CFrame = HRP.CFrame * CFrame.new(0, 0, -0.894) * (parentObject.CFrame - parentObject.Position)

	local cleanupTime = 0 -- track longest effect duration

	-- Process all child effects
	for _, instance in ipairs(EffectPart:GetDescendants()) do
		if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Sound") then
			task.spawn(function()
				if not instance.Parent then
					return
				end

				local delay = instance:GetAttribute("EmitDelay") or 0
				local duration = instance:GetAttribute("EmitDuration")

				-- Track cleanup time
				if delay + (duration or 0) > cleanupTime then
					cleanupTime = delay + (duration or 0)
				end

				if delay > 0 then
					task.wait(delay)
				end
				if not instance.Parent then
					return
				end

				-- SOUND
				if instance:IsA("Sound") then
					instance:Play()
					if instance.TimeLength > cleanupTime then
						cleanupTime = instance.TimeLength
					end

					-- PARTICLES
				elseif instance:IsA("ParticleEmitter") then
					local count = instance:GetAttribute("EmitCount")

					if duration and duration > 0 then
						instance.Enabled = true
						task.wait(duration)
						if instance.Parent then
							instance.Enabled = false
						end
					elseif count and count > 0 then
						instance:Emit(count)
					else
						instance:Emit(1)
					end

					-- BEAMS
				elseif instance:IsA("Beam") then
					local beamClone = instance:Clone()
					beamClone.Parent = instance.Parent
					beamClone.Enabled = true

					local beamDuration = duration and duration > 0 and duration or 0.03
					task.wait(beamDuration)

					if beamClone then
						beamClone:Destroy()
					end
				end
			end)
		end
	end

	-- Destroy effect object after all child effects finish
	task.delay(cleanupTime + 1, function()
		if EffectPart then
			EffectPart:Destroy()
		end
	end)
end

function module.AfterImage(char, anim, type)
	if type == nil then
		local clone = RS.Effects.AfterImage:Clone()
		clone.Parent = workspace.VFX
		clone.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
	

		task.delay(0.09, function()
			local humanoid = clone:FindFirstChildOfClass("Humanoid")
			if not humanoid or not humanoid.Animator then
				return
			end

			local animTrack = clone.Humanoid.Animator:LoadAnimation(anim)
			animTrack:Play()
			animTrack:AdjustSpeed(0) -- Freeze on first frame immediately
			animTrack.TimePosition = 0

			-- Fade out all parts
			local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
			local tweensLeft = 0

			for _, part in ipairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					tweensLeft += 1
					local t = TS:Create(part, fadeInfo, { Transparency = 1 })
					t.Completed:Connect(function()
						tweensLeft -= 1
						if tweensLeft <= 0 then
							clone:Destroy()
						end
					end)
					t:Play()
				end
			end

			-- Fade highlight outline too
			local highlight = clone:FindFirstChildOfClass("Highlight")
			if highlight then
				TS:Create(highlight, fadeInfo, {
					FillTransparency = 1,
					OutlineTransparency = 1,
				}):Play()
			end
		end)
	else
		if type == "AstralDodge" then
			local PoseTable = {
				[0] = ElementAnims.Astral.AstralDodge0,
				[1] = ElementAnims.Astral.AstralDodge1,
				[2] = ElementAnims.Astral.AstralDodge2,
				[3] = ElementAnims.Astral.AstralDodge3,
				[4] = ElementAnims.Astral.AstralDodge4,
				[5] = ElementAnims.Astral.AstralDodge5,
				[6] = ElementAnims.Astral.AstralDodge6,
				[7] = ElementAnims.Astral.AstralDodge7,
			}
			char.Archivable = true
			coroutine.wrap(function()
				while char:GetAttribute("AstralDodgeActive") do
					task.wait(0.1) -- intermission for clones
					if not char then
						break
					end
					local clone = char:Clone()
					clone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					clone.Name = "AfterImage"
					local Highlight = Instance.new("Highlight")
					Highlight.Parent = clone
					Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					Highlight.FillTransparency = 0.4
					Highlight.FillColor = Color3.fromRGB(119, 0, 255)
					Highlight.OutlineTransparency = 0.5
					Highlight.OutlineColor = Color3.fromRGB(113, 5, 255)
					local PointLight = Instance.new("PointLight",clone.HumanoidRootPart)
					PointLight.Brightness = 2.5
					PointLight.Color = Color3.fromRGB(119, 0, 255)
					PointLight.Range = 6
					PointLight.Shadows = false
					for i, part in pairs(clone:GetDescendants()) do
						if part.Name == "ShootingStar" then -- We dont need to pose weapons
							part:Destroy()
						end

						if
							part:IsA("Script")
							or part:IsA("LocalScript")
							or part:IsA("ModuleScript")
							or part:IsA("BillboardGui")
						then
							part:Destroy()
						end

						if part:IsA("BasePart") or part:IsA("MeshPart") and part.Name ~= "HumanoidRootPart" then
							if part:IsA("MeshPart") then
								part.TextureID = ""
								local sa = part:FindFirstChildOfClass("SurfaceAppearance")
								if sa then
									--sa.ColorMap = ""
									--sa.MetalnessMap = ""
									--sa.RoughnessMap = ""
								end
							end

							part.Transparency = 0.5
							part.CollisionGroup = "VFX_Models"
							part.Color = Color3.fromRGB(170, 170, 255)
						end
					end
					clone.Parent = workspace.VFX
					clone.HumanoidRootPart.Transparency = 1
					clone.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame
					clone.HumanoidRootPart.Anchored = true

					local animTrack = clone.Humanoid.Animator:LoadAnimation(PoseTable[math.random(0, 7)])
					animTrack:Play(0) -- 0 fade time = instant
					animTrack:AdjustSpeed(0) -- Freeze on first frame immediately
					animTrack.TimePosition = 0

					task.delay(1.2, function()
						-- Fade out all parts
						local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
						local tweensLeft = 0

						for _, part in ipairs(clone:GetDescendants()) do
							if part:IsA("BasePart") then
								tweensLeft += 1
								local t = TS:Create(part, fadeInfo, { Transparency = 1 })
								t.Completed:Connect(function()
									tweensLeft -= 1
									if tweensLeft <= 0 then
										clone:Destroy()
										PointLight:Destroy()
									end
								end)
								t:Play()
							end
						end

						TS:Create(Highlight, fadeInfo, {
							FillTransparency = 1,
							OutlineTransparency = 1,
						}):Play()
					end)
				end
			end)()
		end
	end
end

function module.HighlightBlink(target, fillcolor, duration,blinkSpeed)
	print("Started highlight", target)
	local hl = Instance.new("Highlight")
	hl.FillColor = fillcolor
	hl.OutlineColor = fillcolor
	hl.FillTransparency = 0
	hl.OutlineTransparency = 0
	hl.Parent = target
	hl.DepthMode = Enum.HighlightDepthMode.Occluded

	local elapsed = 0
	local blinkTime = blinkSpeed or 0.5 -- Total time for one full blink cycle (0.25 out + 0.25 back)

	while elapsed < duration do
		print(duration)
		-- Fade out
		local blinkTween = TS:Create(hl, TweenInfo.new(0.25, Enum.EasingStyle.Linear), { FillTransparency = 0.5, OutlineTransparency = 0.5 })
		blinkTween:Play()
		blinkTween.Completed:Wait() -- Wait for fade out to finish

		-- Fade back in
		local resetTween = TS:Create(hl, TweenInfo.new(0.25, Enum.EasingStyle.Linear), { FillTransparency = 0, OutlineTransparency = 0 })
		resetTween:Play()
		resetTween.Completed:Wait() -- Wait for fade in to finish

		elapsed += blinkTime
	end

	hl:Destroy()
	print("Finished highlight")
end


module.DestroyEffects = function(char, effect)
	for i, v in pairs(workspace.VFX:GetChildren()) do
		if v.Name == effect.Name then
			v:Destroy()
		end
	end
end

-- Run the function.

return module
