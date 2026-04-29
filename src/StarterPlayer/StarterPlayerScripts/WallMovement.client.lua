--[Services and Modules]--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local SFX = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local SoundsModule = require(RS.Modules.Combat.SoundsModule)


--[Player Varibles]--
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local HRP:Part = char.HumanoidRootPart
local hum = char.Humanoid
local CurrentWeapon = char:GetAttribute("CurrentWeapon")
print(char)

while CurrentWeapon == nil do
    CurrentWeapon = char:GetAttribute("CurrentWeapon")
    if CurrentWeapon then break end
    task.wait(0.3)
end


--[Asset Variables]--
local WeaponAnimations = RS.Animations.Weapons
print(WeaponAnimations,CurrentWeapon)
local MovementAnimationsFolder = WeaponAnimations[CurrentWeapon].Movement
local WallClimbAnim = hum.Animator:LoadAnimation(MovementAnimationsFolder.WallClimb)
local ledgeGrab = hum.Animator:LoadAnimation(MovementAnimationsFolder.LedgeGrab)

local Events = RS.Events
local MovementEvent = Events.Movement




local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {char}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local canClimb = false
local lastClimbState = nil
local heldKeys = {}
local isInAir = nil
local grounded = true
local IsClimbing = false
local IsHoldingLedge = false
local LedgeGrabCoolDown = false

local velocityDecay = .3
local MaxClimbheight = 40

local function triggerWallClimb()
    grounded = false
    IsClimbing = true
    char:SetAttribute("IsClimbing",true)

    WallClimbAnim:Play()

   -- SFX_Event:FireServer(SFX)

   local bv = Instance.new("BodyVelocity")
   bv.Velocity = HRP.CFrame.lookVector + Vector3.new(0,MaxClimbheight,0)
   bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
   bv.Parent = HRP
   Debris:AddItem(bv,velocityDecay)

   task.delay(.2, function()
     SoundsModule.PlaySound(SFX.SFX.Movement.ClimbSound)
   end)

   task.delay(1, function()
    IsClimbing = false
     char:SetAttribute("IsClimbing",false)
   end)
    
end

RunService.Heartbeat:Connect(function()
    local result = workspace:Raycast(
        HRP.Position,
        HRP.CFrame.lookVector * 1, 
        raycastParams
    )

    if result then 
        local Wall = result.Instance
        local Climable = Wall:GetAttribute("Climable") == true
         canClimb = Climable

         if Climable ~= lastClimbState then
            print("wall can be climbed", Climable)
            lastClimbState = Climable
         end
    else
        canClimb = false

        if lastClimbState ~= false then
            print("There is no wall to climb")
            lastClimbState = false
         end

    end

    
end)

UIS.InputBegan:Connect(function(input, isTyping)
    if isTyping then return end 
     local key = input.KeyCode
    if key == Enum.KeyCode.W then
        heldKeys.W = true

    elseif key == Enum.KeyCode.S then
        if IsHoldingLedge then
            IsHoldingLedge = false
            char:SetAttribute("LedgeHold",false)
            MovementEvent:FireServer("ReleaseLedge", false)
            return
        end
        
    end

    if key == Enum.KeyCode.Space then
        if IsHoldingLedge then
            IsHoldingLedge = false
            char:SetAttribute("LedgeHold",true)
            MovementEvent:FireServer("ReleaseLedge", true)
            return
        end

        if isInAir and heldKeys.W and canClimb and not IsClimbing and grounded then
            triggerWallClimb()
            print("Climb Start now!!!")
        else
            print(isInAir,heldKeys.W, IsClimbing ,grounded)

        end
    end
    
end)


UIS.InputChanged:Connect(function(input, istyping)
    if istyping then return end 
    if input.KeyCode == Enum.KeyCode.W then
        heldKeys.W = nil
    end

end)

 hum.StateChanged:Connect(function(state,newstate)
    if newstate == Enum.HumanoidStateType.Freefall or newstate == Enum.HumanoidStateType.Jumping then 
        isInAir = true
    elseif state ==  Enum.HumanoidStateType.Landed then
        isInAir = false
        grounded = true
    end

 end)

 task.wait(3)
 local ledges = workspace.ParkorTeststuff.Ledges:GetChildren()

 for i, ledge in ledges do 
    ledge.Touched:Connect(function(part)
        if LedgeGrabCoolDown or IsHoldingLedge or not IsClimbing then return end
        if not part:IsDescendantOf(char) then return end

        LedgeGrabCoolDown = true
        IsHoldingLedge = true
        IsClimbing = false
        MovementEvent:FireServer("LedgeHold",ledge)

        task.wait(.4)
        LedgeGrabCoolDown = false

    end)
 end
