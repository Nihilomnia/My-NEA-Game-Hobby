local ServerScriptService = game:GetService("ServerScriptService")
local Template = require(ServerScriptService.Data.Template)


local DataManager = {}


type ProfileData = Template.ProfileData

-- Store profiles from  ProfileStore
export type Profile = {
    Data: ProfileData,
    AddUserId: (self: Profile, userId: number) -> (),
    Reconcile: (self: Profile) -> (),
    EndSession: (self: Profile) -> (),
    OnSessionEnd: RBXScriptSignal,
}

DataManager.Profiles = {} :: { [Player]: Profile }

function DataManager.IncreaseStat(plr,statName) -- This function handles the increase of stats,
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        local currentValue = profile.Data[currentSlot][statName]

        if currentValue < 99 then 
            profile.Data[currentSlot][statName] = currentValue + 1
        else
            print("You can't invest anymore into", statName)
        end
    end
end



function DataManager.IncreaseSkillPoints(plr,amount)
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        profile.Data[currentSlot].SkillPoints = profile.Data[currentSlot].SkillPoints + amount
    end
end

function DataManager.ChangeElemment(plr,newValue) -- This function will handle the changing of the player's moveset
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        profile.Data[currentSlot].Element = newValue
    end
    
end

function DataManager.AddExperience(plr,amount)
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        profile.Data[currentSlot].Experience = profile.Data[currentSlot].Experience + amount
    end
end

function DataManager.UpdateAccessories(plr,accessoryType,accessoryName)
    local profile = DataManager.Profiles[plr]
    if profile then
        local char = plr.Character
        local currentSlot = char:GetAttribute("CurrentSlot")
        profile.Data[currentSlot].Accessories[accessoryType] = accessoryName
    end
end

function DataManager.UpdateInventory(plr, Goal :string, Item : Tool, count:number)
    local profile = DataManager.Profiles[plr]
    if not profile then return end

    local char: Model = plr.Character
    if not char then return end

    local currentSlot = char:GetAttribute("CurrentSlot")
    if not currentSlot then return end

    local inventory = profile.Data[currentSlot].Inventory

    if Goal == "Add" then
        
        -- First try to stack with existing item
        for i, v in pairs(inventory) do
            if v.Name == Item then
                v.Count += count
                return
            end
        end

        
        -- If not found, insert new item
        table.insert(inventory, {
            Name = Item,
            Count = count
        })

    -- =====================
    -- REMOVE ITEMS
    -- =====================
    elseif Goal == "Remove" then
        
        for i, v in pairs(inventory) do
            if v.Name == Item then
                if v.Count >= count then
                    v.Count -= count

                    -- Optional: remove entry if count hits 0
                    if v.Count <= 0 then
                        table.remove(inventory, i)
                    end
                else
                    warn("Not enough items to remove")
                end
                return
            end
        end
    end
end



function DataManager.UpdateHotbar(plr, Goal :string, Item : Tool, slot:number)
    local profile = DataManager.Profiles[plr]
    if not profile then return end

    local char: Model = plr.Character
    if not char then return end

    local currentSlot = char:GetAttribute("CurrentSlot")
    if not currentSlot then return end

    local hotbar = profile.Data[currentSlot].Hotbar

    if Goal == "Add" then
        hotbar[slot] = {
            Name = Item,
            Count = 1
        }
    elseif Goal == "Remove" then
        hotbar[slot] = nil
    end
end

            


    

   



--[[
 This is the rules for handeling player data
 1. Always access player data through DataManager.Profiles[player]
 2. Do not store player data locally in other modules, always access it when needed
 3. When modifying player data, ensure you are modifying the correct slot by checking the "Current_Slot" attribute on the player's character
 4. Modify data here only, do not create new data stores in other modules
]]





return DataManager