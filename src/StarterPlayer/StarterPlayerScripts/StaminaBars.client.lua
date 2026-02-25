local plr = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local PlayerGui = plr:WaitForChild("PlayerGui")
local StatusBars = PlayerGui:WaitForChild("StatusBars")



local function ManageMDBar(char)
    
end




plr.CharacterAdded:Connect(function(char)
   
    local torso = char:WaitForChild("Torso")

    
    StatusBars.Adornee = torso
    StatusBars.Parent = torso

    -- Move it right & slightly downward
    StatusBars.StudsOffset = Vector3.new(4.5, 0, 0) 
end)






