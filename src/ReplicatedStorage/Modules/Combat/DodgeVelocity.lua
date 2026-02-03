local DodgeVelocity = {}
local currentDodgeForce = {}


local DODGE_SPEED = 35
local DODGE_TIME = 0.73


local function getUniqueId(char)
    local uid = char.Humanoid:FindFirstChild("UniqueId")
    return uid.Value or nil
end

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

    local lv = Instance.new("LinearVelocity")
    lv.Attachment0 = hrp:FindFirstChild("DodgeAttachment") or Instance.new("Attachment", hrp)
    lv.MaxForce = 1e6
    
    -- Default direction and multipliers
    local direction = Vector3.new()
    local multiplier = 1

    -- Logic for Direction and Force (3/4 = 0.75, 2/4 = 0.5)
    if TargetDirection == "W" then
        -- Forward
        direction = hrp.CFrame.LookVector
        multiplier = 1
    elseif TargetDirection == "S" or TargetDirection == "None" then
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

    currentDodgeForce[Identifier] = lv
    game.Debris:AddItem(lv, DODGE_TIME)
end






return DodgeVelocity