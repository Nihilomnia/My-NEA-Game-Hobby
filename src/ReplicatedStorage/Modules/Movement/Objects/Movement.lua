local Movement = {}
Movement.__index = Movement


local AnimationsTable = {}



export type MovementObj = typeof(setmetatable( -- My type for the MovementObj  this actually servees ZERO purpose but to make indexing easier :P
	{} :: {
        identifer: any,
        char: Model,


		IsActing: { -- Flags for if they are using the movement system
            Dodging: boolean,
            WallRunning: boolean,
            Climbing: boolean,
            IsSprinting: boolean,
            IsEXSprinting: boolean,
        }, 

        States: {
            IsGrounded: boolean, -- Standard is on ground
            IsInAir: boolean, -- In the air
            IsOnWall: boolean, -- Is holding onto a wall
        },

        StopFunctions: { -- Functions for stopping each system when needed (they are automatically supplied with the paramaters)
            StopDodge: () -> (),
            StopWallRun: () -> (),
            StopClimb: () -> (),
            StopSprint: () -> (),
            StopEXSprint: () -> (),
            StopWallHold: () -> (),
        }
	},
	Movement
))

local ObjTable = {}



function Movement.new(identifer):MovementObj -- Creates the new movement object for the player/ npc
    local self = setmetatable({
        identifer = nil,
        char = identifer.Character, 

		IsActing ={
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
        },

        StopFunctions = {
            StopDodge = nil,
            StopWallRun =  nil,
            StopClimb = nil,
            StopSprint = nil,
            StopEXSprint = nil,
            StopWallHold = nil
        }
    }, Movement) :: MovementObj
    self.identifer = identifer
    ObjTable[identifer] = self




    return self
end


function Movement:GetMovementObj(Identifer):MovementObj?
    if ObjTable[Identifer] ~= nil and Identifer ~= nil then
        return ObjTable[Identifer]
    else
        print("[MovementObjects]: Identifer or the movementObj was nil")
        return nil
    end
end



function Movement:BarTween(StartStop,acion)
    if self.identifer.Player ~= nil then return end -- This means that it wasn't a player so we can ignore it
    local plr:Player = self.identifer.Player
    local MovementUI = plr:WaitForChild("PlayerGui"):WaitForChild("MovementUi")
    local top = MovementUI:WaitForChild("Top")
    local bottom = MovementUI:WaitForChild("Bottom")
    local Top_tilt = MovementUI:WaitForChild("Top_Tilt")
    local Bottom_tilt = MovementUI:WaitForChild("Bottom_Tilt") 

    if acion == "Wallrun" then
        
    end

end


function Movement:UpdateWalkTracks()
    
end






return Movement