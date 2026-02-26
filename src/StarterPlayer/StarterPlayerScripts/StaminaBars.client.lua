local RS = game:GetService("ReplicatedStorage")
local plr = game.Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local StatusBars = PlayerGui:WaitForChild("StatusBars")
local MDBar = StatusBars:WaitForChild("MentalBar")

local UIFolder = RS.UI.StatusBar

local Events = RS.Events
local UI_Update_Event = Events.UI_Update


UI_Update_Event.OnClientEvent:Connect(function(action,...)
    if action == "StatusEffectAdded" then
        local effectName, stacks = ...
        
        local Icon = UIFolder:FindFirstChild(effectName):Clone()
        Icon.Parent = StatusBars.Frame.StatusEffectsFRame
        Icon.Stacks.Text = stacks
        Icon.Name = effectName
    elseif action == "StatusEffectRemoved" then
        local effectName = ...
        local icon = StatusBars.Frame.StatusEffectsFRame:FindFirstChild(effectName)
        if icon then
            icon:Destroy()
        end
    end
end)


local char = plr.Character or plr.CharacterAdded:Wait()

char:GetAttributeChangedSignal("MF"):Connect(function()
  MDBar:TweenSize(
    UDim2.new(1,0,char:GetAttribute("MF")/char:GetAttribute("MaxMF"),0),
     "Out", 
     "Quint", 
     1, 
     true
    )
end)



plr.CharacterAdded:Connect(function(char)
   
    local torso = char:WaitForChild("Torso")

    
    StatusBars.Adornee = torso
    StatusBars.Parent = torso

    -- Move it right & slightly downward
    StatusBars.StudsOffset = Vector3.new(4.5, 0, 0) 
end)






