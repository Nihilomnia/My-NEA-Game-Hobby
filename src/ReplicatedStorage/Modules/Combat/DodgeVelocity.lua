local DodgeVelocity = {}
local currentDodgeForce = {}


local DODGE_SPEED = 30
local DODGE_TIME = 0.5


function DodgeVelocity.resetVelocity(char,Identifier)
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if currentDodgeForce[Identifier] then
        currentDodgeForce[Identifier]:Destroy()
        currentDodgeForce[Identifier] = nil
    end
    -- Stop the momentum so they don't slide after cancelling
    hrp.AssemblyLinearVelocity = Vector3.zero 
end


function DodgeVelocity.dodge(char,Identifier,TargetDirection)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if currentDodgeForce[Identifier] then
        currentDodgeForce[Identifier]:Destroy()
    end

    if TargetDirection == "None" then return end  -- No velcoity for spot dodges
    
    local dodgeAttachment = hrp:FindFirstChild("DodgeAttachment") or Instance.new("Attachment", hrp)
    local lv = Instance.new("LinearVelocity")
    lv.Attachment0 = dodgeAttachment
    lv.MaxForce = 1e6
    local mass = hrp.AssemblyMass * 1500
    lv.MaxAxesForce = Vector3.new(mass,mass,mass)
    

    local direction = Vector3.new()
    local multiplier = 1


    if TargetDirection == "W" then
        -- Forward
        direction = hrp.CFrame.LookVector
        multiplier = 1
    elseif TargetDirection == "S"  then
        -- Back (or Q on its own)
        direction = -hrp.CFrame.LookVector
        multiplier = 0.75
    elseif TargetDirection == "A" then
        -- Left
        direction = -hrp.CFrame.RightVector
        multiplier = 0.75
    elseif TargetDirection == "D" then
        -- Right
        direction = hrp.CFrame.RightVector
        multiplier = 0.75
    end

	
    lv.VectorVelocity = direction * (DODGE_SPEED * multiplier)
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = hrp

    local algin = Instance.new("AlignOrientation")
    algin.Attachment0 = dodgeAttachment
    algin.Mode = Enum.OrientationAlignmentMode.OneAttachment
    algin.Responsiveness = 50
    algin.Parent = hrp

    local Hum:Humanoid = char.Humanoid
    Hum.AutoRotate = false
    

    currentDodgeForce[Identifier] = lv

    game.Debris:AddItem(lv, DODGE_TIME)
    game.Debris:AddItem(algin, DODGE_TIME)
    task.wait(DODGE_TIME)
    Hum.AutoRotate = false

  
  
    
end






return DodgeVelocity