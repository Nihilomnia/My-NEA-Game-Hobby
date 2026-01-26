local ContentProvider = game:GetService("ContentProvider")
local RS = game:GetService("ReplicatedStorage")
local char = game.Players.LocalPlayer.Character  or game.Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = char:FindFirstChild("Humanoid")

local allAnims = {}

task.wait()


for i,anim in pairs(char:GetDescendants()) do
	if anim:IsA("Animation") then
		table.insert(allAnims,anim)
	end
end

local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	-- Preload each animation as an AnimationTrack
	for _, anim in ipairs(allAnims) do
		local success, track = pcall(function()
			return animator:LoadAnimation(anim)
		end)

		if success and track then
			-- Immediately stop the track so it doesn’t play
			track:Stop(0)
			-- Optional: destroy after compiling to save memory
			track:Destroy()
		end
	end

ContentProvider:PreloadAsync(allAnims)