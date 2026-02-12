local InventoryManager = {}
local RS = game:GetService("ReplicatedStorage")
local ToolBox = RS.Tools
local ItemFolder = ToolBox.Items


function InventoryManager.AddItem(player, itemname, quantity)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        local itemTemplate = ItemFolder:FindFirstChild(itemname)
        if itemTemplate then
            for i = 1, quantity do
                local newItem = itemTemplate:Clone()
                newItem.Parent = backpack
            end
        else
            warn("Item '" .. itemname .. "' does not exist in the Items folder.")
        end
    else
        warn("Backpack not found for player: " .. player.Name)
    end 
end








return InventoryManager