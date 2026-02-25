local SS = game:GetService("ServerStorage")
local InventoryManager = require(SS.Modules.Other.InventoryManager)
local CollectionService = game:GetService("CollectionService")


 CollectionService:GetInstanceAddedSignal("Item"):Connect(function(item)
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


