local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local InventoryManager = require(SS.Modules.Other.InventoryManager)
local Helper = require(SS.Modules.Other.Helpful)

local Events = RS.Events
local InventoryEvent = Events.InventoryEvent






 CS:GetInstanceAddedSignal("Item"):Connect(function(item)
    local touchConn
    if item.Parent ~= workspace.ActiveItems then return end
    touchConn = item.Touched:Connect(function(hit)
        local char = hit.Parent
        if char and char:FindFirstChildOfClass("Humanoid") then
            local plr = game.Players:GetPlayerFromCharacter(char)
            if plr then
                InventoryManager.AddItem(plr, item.Name, item:GetAttribute("Count") or 1)
                item:Destroy()
                touchConn:Disconnect()
            end
        end
    end)
end)







InventoryEvent.OnServerEvent:Connect(function(plr, action, toolName,Count,Location)
    local char:Model = plr.Character  
    if not char then return end
    if action == "Drop" then
        if Helper.CheckForAttributes(char, true, true, true, nil, false, true, true, true) then return end
        if char:GetAttribute("InCombat") then return end  -- We cant drop stuff in combat
        InventoryManager.DropItem(plr, toolName, 1,Location)
    end
end)
   





