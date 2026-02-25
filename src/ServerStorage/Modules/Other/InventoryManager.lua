local InventoryManager = {}
local RS = game:GetService("ReplicatedStorage")

local CollectionService = game:GetService("CollectionService")



local Events = RS.Events
local InventoryEvent = Events.InventoryEvent

local ToolBox = RS.Tools
local ItemFolder = ToolBox.Items
local ActiveItemFolder = workspace.ActiveItems


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



function InventoryManager.RemoveItem(player, itemname, quantity)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        local itemsToRemove = {}
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == itemname then
                table.insert(itemsToRemove, item)
                if #itemsToRemove >= quantity then
                    break
                end
            end
        end
        
        for _, item in ipairs(itemsToRemove) do
            item:Destroy()
        end
        
        if #itemsToRemove < quantity then
            warn("Not enough '" .. itemname .. "' items to remove from player: " .. player.Name)
        end
    else
        warn("Backpack not found for player: " .. player.Name)
    end 
end


function InventoryManager.DropItem(plr,item,count)
    local character = plr.Character
    if character then
        local HRP = character:FindFirstChild("HumanoidRootPart")
        if HRP then
            local droppedItem : MeshPart = ItemFolder:FindFirstChild(item):Clone()
            local Model:Model = Instance.new("Model")
            Model.Name = item .. "_Model"
            droppedItem.Parent = Model
            Model.Parent = ActiveItemFolder
            CollectionService:AddTag(droppedItem, "Item")
            droppedItem.CustomPhysicalProperties = PhysicalProperties.new(0.3, 1, 0, 1, 0)
            droppedItem.CFrame = HRP.CFrame * CFrame.new(0, -2, 0)
            Model.ScaleTo(Model,0.25) -- This why i put the item in a model, because it easir to scale the item 
            droppedItem.CanCollide = true
            droppedItem:SetAttribute("Count", count)



            InventoryEvent:FireClient(plr, "ItemDropped", item)
            
            
        else
            warn("HumanoidRootPart not found for player: " .. plr.Name)
        end
    else
        warn("Character not found for player: " .. plr.Name)
    end 
end

    








return InventoryManager