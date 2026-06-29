local Type = require(script.Types)
local RS  = game:GetService("ReplicatedStorage")
local Types = require(script.Types)
local Events = RS.Events

local MovementEvent:RemoteEvent  = Events.Movement

local Movement = {}
Movement.__index = Movement

local AnimationsFolder = script.Animations

-- Ui Stuff
local TOP_HIDDEN = UDim2.new(-0.001, 0, -0.4, 0)
local BOTTOM_HIDDEN = UDim2.new(-0.034, 0, 1.1, 0)

local Tilt_TOP_HIDDEN_LEFT = UDim2.new(-1.325, 0, -2, 0)
local Tilt_BOTTOM_HIDDEN_LEFT = UDim2.new(-1.325, 0, 2, 0)

local Utils = require(script.Utils)

local objTable = {} -- This stores the movementobjs

local function Ui_init(movementObJ: Type.MovementObj)
    local plr = movementObJ.identifer
    if plr == nil or not plr:IsA("Player") then
        return
    end
    local UItable = movementObJ.UI
    local PlayerGui = plr:WaitForChild("PlayerGui", 5)
    if not PlayerGui then return end
    
    local MovementUI = PlayerGui:WaitForChild("MovementUI", 5)
    if not MovementUI then return end

    movementObJ.UI.top = MovementUI:WaitForChild("Top")
    UItable.bottom = MovementUI:WaitForChild("Bottom")
    UItable.top_tilt = MovementUI:WaitForChild("Top_Tilt")
    UItable.bottom_tilt = MovementUI:WaitForChild("Bottom_Tilt")

    UItable.top.Position = TOP_HIDDEN
    UItable.bottom.Position = BOTTOM_HIDDEN

    UItable.top_tilt.Position = Tilt_TOP_HIDDEN_LEFT
    UItable.bottom_tilt.Position = Tilt_BOTTOM_HIDDEN_LEFT

    UItable.top_tilt.Rotation = 0
    UItable.bottom_tilt.Rotation = 0
end

--[Module Functions]--
function Movement.new(identifer): Type.MovementObj 
    -- Clean up previous tracks if this identifier already had an object mapped to prevent memory leaks
    if objTable[identifer] then
        pcall(function()
            objTable[identifer]:ClearWalkAnims()
        end)
    end

    local self = (
        setmetatable({
            identifer = identifer,
            char = identifer.Character or (identifer:IsA("Player") and identifer.CharacterAdded:Wait()),
            IsReady = false,

            IsActing = {
                Dodging = false,
                WallRunning = false,
                Climbing = false,
                IsSprinting = false,
                IsEXSprinting = false,
            },
            States = {
                IsGrounded = false,
                IsInAir = false,
                IsOnWall = false,
                IsCrouching = false,
                ISSliding = false,
                IsResting = false,
            },

            InfoTable = { 
                Wallrun = {
                    Side = 0, 
                    Normal = Vector3.new(0, 0, 0), 
                    Stop = "",
                },

                Dodge = {
                    Dir = Vector3.zero, 
                    Type = "", 
                    Speed = 0,
                    Stop = function() end,
                },

                Climb = {
                    Stop = function() end,
                },

                Sprint = {
                    Stop = function() end,
					SprintAnim = nil,
                },

                EXSprint = {
                    Stop = function() end,
                },

                WallHold = {
                    Type = "", 
                    Stop = function() end,
                },

                Crouch = {
                    Stop = function() end,
                },

                Slide = {
                    Stop = function() end,
                }
            },

            WalkCycleAnims = {
                WalkForward = nil,
                WalkRight = nil,
                WalkLeft = nil,
                WalkBack = nil,
            },

            UI = {
                top = nil,
                bottom = nil,
                top_tilt = nil,
                bottom_tilt = nil,
            },
        }, Movement) :: any
    ) :: Type.MovementObj

    -- CRITICAL FIX: Always overwrite cache with the fresh lifecycle reference
    objTable[identifer] = self

    local plrflag = game:GetService("Players"):GetPlayerFromCharacter(self.char) 
    if plrflag then
        Ui_init(self) 
    end

    self.IsReady = true
    return self
end

function Movement.GetMovementObj(Identifer): Type.MovementObj? 
    if objTable[Identifer] ~= nil then
        return objTable[Identifer]
    else
        warn("[MovementObjects]: Identifier or the movementObj was nil")
        return nil
    end
end

function Movement:BarTween(infoTable)
    local plrflag = self.identifer
    if plrflag:IsA("Player") then plrflag = nil end 
    if plrflag then return end 
    
    local action = infoTable.Action

    if action == "Wallrun" then
        local side = self.InfoTable.Wallrun.Side
        Utils.StartWallrunBars(side, self)
    end

    if action == "Dodge" then
        local Speed = self.InfoTable.Dodge.Speed
        Utils.StartDodgeCam(Speed)
    end
end

function Movement:BarTweenStop(infoTable)
 local plrflag = self.identifer
    if plrflag:IsA("Player") then plrflag = nil end 
    if plrflag then return end 
    local action = infoTable.Action

    if action == "Wallrun" then
        local side = self.InfoTable.Wallrun.Side
        Utils.StopWallrunBars(side, self, nil)
    end

    if action == "Dodge" then 
        Utils.RestDodgeCam()
    end
end

function Movement:UpdateWalkTracks()
    local AnimationsTable = self.WalkCycleAnims

    for i, track in pairs(AnimationsTable) do
        if track ~= nil then
            track:Stop(0.1)
            track:Destroy()
        end
    end

    local char = self.char
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local isEquipped = char:GetAttribute("Equipped")
    local currentWeapon = char:GetAttribute("CurrentWeapon")
    local IsLow = char:GetAttribute("IsLow")
    local HasCombatTag = char:GetAttribute("InCombat")
    local TargetFolder

    if isEquipped and currentWeapon and not self.States.IsCrouching and AnimationsFolder.Weapons:FindFirstChild(currentWeapon) then
        if IsLow and HasCombatTag then
            TargetFolder = AnimationsFolder.Weapons[currentWeapon].IsLow
        else
            TargetFolder = AnimationsFolder.Weapons[currentWeapon]
        end
    else
        if IsLow and HasCombatTag then
            TargetFolder = AnimationsFolder.IsLow
        else
            TargetFolder = AnimationsFolder
        end
    end

    AnimationsTable.WalkForward = hum:LoadAnimation(TargetFolder.WalkForward)
    AnimationsTable.WalkRight = hum:LoadAnimation(TargetFolder.WalkRight)
    AnimationsTable.WalkLeft = hum:LoadAnimation(TargetFolder.WalkLeft)
    AnimationsTable.WalkBack = hum:LoadAnimation(TargetFolder.WalkBack)

    for i, track in pairs(AnimationsTable) do
        if track then track:Play(0.1, 0, 0) end
    end
end

function Movement:WalkCycle()
    local char = self.char
    local HRP = char:FindFirstChild("HumanoidRootPart")
    local Hum = char:FindFirstChildOfClass("Humanoid")
    local AnimationsTable = self.WalkCycleAnims
    
    if not HRP or not Hum or not AnimationsTable.WalkForward then
        return
    end

    local DirectionOfMovement = HRP.CFrame:VectorToObjectSpace(HRP.AssemblyLinearVelocity)
    local walkSpeed = Hum.WalkSpeed

    local Forward = math.abs(math.clamp(DirectionOfMovement.Z / walkSpeed, -1, -0.001))
    local Backwards = math.abs(math.clamp(DirectionOfMovement.Z / walkSpeed, 0.001, 1))
    local Right = math.abs(math.clamp(DirectionOfMovement.X / walkSpeed, 0.001, 1))
    local Left = math.abs(math.clamp(DirectionOfMovement.X / walkSpeed, -1, -0.001))
    local SpeedUnit = DirectionOfMovement.Magnitude / walkSpeed

    if DirectionOfMovement.Z / walkSpeed < 0.1 then
        AnimationsTable.WalkForward:AdjustWeight(Forward)
        AnimationsTable.WalkBack:AdjustWeight(Backwards)
        AnimationsTable.WalkRight:AdjustWeight(Right)
        AnimationsTable.WalkLeft:AdjustWeight(Left)

        local playbackSpeed = (DirectionOfMovement.Z > 0) and SpeedUnit or -SpeedUnit
        AnimationsTable.WalkForward:AdjustSpeed(playbackSpeed)
        AnimationsTable.WalkBack:AdjustSpeed(SpeedUnit)
        AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit)
        AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit)
    else
        AnimationsTable.WalkForward:AdjustWeight(Forward)
        AnimationsTable.WalkBack:AdjustWeight(Backwards)
        AnimationsTable.WalkRight:AdjustWeight(Left)
        AnimationsTable.WalkLeft:AdjustWeight(Right)

        AnimationsTable.WalkForward:AdjustSpeed(SpeedUnit * -1)
        AnimationsTable.WalkBack:AdjustSpeed(SpeedUnit * -1)
        AnimationsTable.WalkRight:AdjustSpeed(SpeedUnit * -1)
        AnimationsTable.WalkLeft:AdjustSpeed(SpeedUnit * -1)
    end
end

function Movement:ClearWalkAnims()
    local AnimationsTable = self.WalkCycleAnims

    for i, track in pairs(AnimationsTable) do
        if track ~= nil then
            track:Stop(0.1)
            track:Destroy()
            AnimationsTable[i] = nil
        end
    end
end

function Movement:ServerRequest(action)
    if action == "CrouchStart" then MovementEvent:FireServer(action) end
    if action == "CrouchEnd" then MovementEvent:FireServer(action) end
    if action == "Dodge" then MovementEvent:FireServer(action) end
    if action == "DodgeCancel" then MovementEvent:FireServer(action) end 
	if action == "ExSprintStart" then MovementEvent:FireServer(action) end
	if action == "ExSprintEnd" then MovementEvent:FireServer(action) end 
end

function Movement:StateChecker(self:Types.MovementObj, action, Ignore)  
    local Fail = false
    if not action then 
        warn("["..script.Name.."] - You forgot to add the action for a StateChecker") 
        return true 
    end

    if action == "Dodge" then 
        if self.IsActing.Climbing then return true end 
        if self.IsActing.WallRunning then return true end
        if self.States.IsResting then return true end 
        if not Ignore and self.IsActing.Dodging then return true end 
    end

    return Fail
end

return Movement