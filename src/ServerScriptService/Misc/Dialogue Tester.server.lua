local RS= game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DialogueParams ={
	Range = 10,
	Position = Vector3.new(0,0,0),
	Speaker ="Nigga Killer"
}

task.wait(5)
print("Yo Bro Dialouge InComing")
RS:FindFirstChild("DialogueRemote",true):FireAllClients(RS.Dialogues.Dialogue_Configs.TestDialogue,DialogueParams)

--[[
This is the gist of everything
Mkae dialogue Node tree in studio 
Make Dialogue Params as seen above 




-- Later Stuff
Turn this into a module that can automatic go through dictionaries with all the dialogue params
The Module should also be able to so all the remote firing
Yeah thats about it for now

]]