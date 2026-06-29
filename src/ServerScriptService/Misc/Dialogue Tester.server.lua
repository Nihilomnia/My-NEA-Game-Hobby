local RS= game:GetService("ReplicatedStorage")
local Prox:ProximityPrompt = workspace.Tester.STart

local DialogueParams ={
	Range = 1000000,
	Position = Vector3.new(0,0,0),
	Speaker ="Tutorial",
	Font = "MinecraftFont"
}

local DialogueParams2 ={
	Range = 1000000,
	Position = Vector3.new(0,0,0),
	Speaker ="Tutorial",
	Font = "ComicSans"
}


task.wait(10)
print("Yo Bro Dialouge InComing")
RS:FindFirstChild("DialogueRemote",true):FireAllClients(RS.Dialogues.Dialogue_Configs.Tutorial,DialogueParams)


Prox.Triggered:Connect(function()
RS:FindFirstChild("DialogueRemote",true):FireAllClients(RS.Dialogues.Dialogue_Configs.TestDialogue,DialogueParams2)
end)

--[[
This is the gist of everything
Mkae dialogue Node tree in studio 
Make Dialogue Params as seen above 




-- Later Stuff
Turn this into a module that can automatic go through dictionaries with all the dialogue params
The Module should also be able to so all the remote firing
Yeah thats about it for now

]]