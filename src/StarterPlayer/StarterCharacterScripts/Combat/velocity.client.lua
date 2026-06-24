local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Events = RS.Events
local MovementEvent: RemoteEvent = Events.Movement

MovementEvent.OnClientEvent:Connect(function(action)
    local localPlayer = Players.LocalPlayer
    local char = localPlayer.Character
    if not char then return end

    if action == "HyprParry" then
        local HRP: BasePart = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not HRP or not hum then return end

        hum.AutoRotate = false

        local att = HRP:FindFirstChild("HyprAtt") or Instance.new("Attachment")
        att.Name = "HyprAtt"
        att.Parent = HRP

        local ao = Instance.new("AlignOrientation")
        ao.Name = "HyprAlign"
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.Attachment0 = att
        ao.CFrame = HRP.CFrame
        ao.MaxTorque = math.huge
        ao.Responsiveness = 200 
        ao.Parent = HRP

        local backwardDirection = -HRP.CFrame.LookVector

        local popUpwardForce = 22.6
        local popBackwardForce = 36.1
        local impulseVector = (backwardDirection * popBackwardForce) + Vector3.new(0, popUpwardForce, 0)
        HRP:ApplyImpulse(impulseVector * HRP:GetMass())

        local slideSpeed = 56.7
        local lv = Instance.new("LinearVelocity")
        lv.Name = "HyprForce"
        lv.Attachment0 = att
        lv.MaxForce = math.huge
        lv.VectorVelocity = backwardDirection * slideSpeed
        lv.Parent = HRP

        game:GetService("Debris"):AddItem(lv, 0.25)
        game:GetService("Debris"):AddItem(ao, 0.25)
        game:GetService("Debris"):AddItem(att, 0.25)

        task.delay(0.25, function()
            if hum and hum.Parent then
                hum.AutoRotate = true
            end
        end)
    end

    if action == "RevengeCounter" then
        local tag = char:FindFirstChild("RevengeTarget")
        if not tag or not tag.Value then return end
        
        local echar = tag.Value
        
        local HRP = char:FindFirstChild("HumanoidRootPart")
        local EHRP = echar:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not HRP or not EHRP or not hum then return end

        local conn
        local startTime = os.clock()
        
        hum.AutoRotate = false

        for _, item in ipairs(char:GetDescendants()) do
            if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
                item.CanCollide = false
            end
        end

        HRP.AssemblyLinearVelocity = Vector3.zero
        HRP.AssemblyAngularVelocity = Vector3.zero

        for _, oldForce in ipairs(HRP:GetChildren()) do
            if oldForce:IsA("LinearVelocity") or oldForce:IsA("VectorForce") or oldForce:IsA("AlignOrientation") then
                oldForce:Destroy()
            end
        end

        local att = HRP:FindFirstChild("RevengeAtt") or Instance.new("Attachment")
        att.Name = "RevengeAtt"
        att.Parent = HRP

        local ao = Instance.new("AlignOrientation")
        ao.Name = "RevengeAlign"
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.Attachment0 = att
        ao.MaxTorque = math.huge
        ao.Responsiveness = 200
        ao.Parent = HRP

        local lv = Instance.new("LinearVelocity")
        lv.Name = "RevengeVelocity"
        lv.Attachment0 = att
        lv.MaxForce = math.huge
        lv.Parent = HRP

        conn = RunService.RenderStepped:Connect(function()
            if not echar.Parent or not EHRP.Parent or not char.Parent or not HRP.Parent then
                conn:Disconnect()
                lv:Destroy()
                ao:Destroy()
                hum.AutoRotate = true
                return
            end

            local distanceVector: Vector3 = EHRP.Position - HRP.Position
            local dist = distanceVector.Magnitude

            if dist <= 3.5 or (os.clock() - startTime) >= 0.2 then
                conn:Disconnect()
                lv:Destroy()
                ao:Destroy()
                att:Destroy()

                HRP.AssemblyLinearVelocity = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero

                local flatEnemyPos = Vector3.new(EHRP.Position.X, HRP.Position.Y, EHRP.Position.Z)
                local targetPosition = flatEnemyPos - (distanceVector.Unit * 3)
                HRP.CFrame = CFrame.lookAt(targetPosition, flatEnemyPos)

                for _, item in ipairs(char:GetDescendants()) do
                    if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
                        item.CanCollide = true
                    end
                end

                hum.AutoRotate = true
                return
            end

            local direction = distanceVector.Unit
            lv.VectorVelocity = direction * 180
            
            local flatEnemyPos = Vector3.new(EHRP.Position.X, HRP.Position.Y, EHRP.Position.Z)
            ao.CFrame = CFrame.lookAt(HRP.Position, flatEnemyPos)
        end)
    end
end)