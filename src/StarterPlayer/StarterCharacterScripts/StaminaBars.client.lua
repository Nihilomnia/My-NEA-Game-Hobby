
local RS = game:GetService("ReplicatedStorage")
local plr = game.Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local StatusBars = PlayerGui:WaitForChild("StatusBars")
local MDBar = StatusBars.Frame.MFBar.Mental_Fill

local UIFolder = RS.UI.StatusBar

local Events = RS.Events
local UI_Update_Event = Events.UI_Update


local CONFIG = {
    IconText = {
        [1] = "I",
        [2] = "II",
        [3] = "III",
        [4] = "IV",
        [5] = "V",
    },

}


UI_Update_Event.OnClientEvent:Connect(function(action,...)
    if action == "StatusEffectAdded" then
        local effectName, stacks = ...

        local icon = StatusBars.Frame.StatusEffectsFRame:FindFirstChild(effectName)

        if icon then
            icon.Stacks.Text = stacks
        else
            local newIcon = UIFolder:FindFirstChild(effectName)
            if newIcon then
                local clonedIcon = newIcon:Clone()
                clonedIcon.Parent = StatusBars.Frame.StatusEffectsFRame
                clonedIcon.Stacks.Text = CONFIG.IconText[stacks] or tostring(stacks)
                clonedIcon.Name = effectName
            else
                warn("No icon found in UIFolder for effect:", effectName)
            end
        end
        
       
    elseif action == "StatusEffectRemoved" then
        local effectName = ...
        local icon = StatusBars.Frame.StatusEffectsFRame:FindFirstChild(effectName)
        if icon then
            icon:Destroy()
        end
    end
end)


local char = plr.Character or plr.CharacterAdded:Wait()
local torso = char:WaitForChild("HumanoidRootPart")
print(char,torso,StatusBars)

char:GetAttributeChangedSignal("MF"):Connect(function()
  MDBar:TweenSize(
    UDim2.new(1,0,char:GetAttribute("MF")/char:GetAttribute("MaxMF"),0),
     "Out", 
     "Quint", 
     1, 
     true
    )
end)



    StatusBars.Adornee = torso
    StatusBars.Parent = torso
    StatusBars.StudsOffset = Vector3.new(4.5, 0, 0) 
    print("WHY ARENT YOU WORKING?")




