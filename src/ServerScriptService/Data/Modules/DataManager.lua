local DataManager = {}


-- Store profiles from  ProfileStore
DataManager.Profiles = {}




--[[
 This is the rules for handeling player data
 1. Always access player data through DataManager.Profiles[player]
 2. Do not store player data locally in other modules, always access it when needed
 3. When modifying player data, ensure you are modifying the correct slot by checking the "Current_Slot" attribute on the player's character
 4. Modify data here only, do not create new data stores in other modules
]]





return DataManager