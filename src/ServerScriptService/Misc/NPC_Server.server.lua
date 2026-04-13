local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local SSModules = SS.Modules
local npc = require(SSModules.Objects.npc)



local NPC_Folder = workspace.NPC

for i, NPC in NPC_Folder:GetDescendants() do
    if NPC:IsA("Model") then
        npc.new(NPC.Name, NPC)
        print(npc.GetNpcFromCharacter(NPC))
    end
    
end




