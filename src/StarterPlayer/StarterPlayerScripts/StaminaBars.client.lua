local player = game.Players.LocalPlayer

player.CharacterAdded:Connect(function(char)
   
    local torso = char:WaitForChild("Torso")

    local gui = script:WaitForChild("BillboardGui"):Clone()
    gui.Adornee = torso
    gui.Parent = torso

    -- Move it right & slightly downward
    gui.StudsOffset = Vector3.new(4.5, 0, 0) 
end)
