local Movement = {}
Movement.__index = Movement
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local MechcanicsFolder = RS.Mechanics


export type MovementObj = typeof(setmetatable(
	{} :: {
        identifer: any,

		IsActing: {
            Dodging: boolean,
            WallRunning: boolean,
            Climbing: boolean,
            IsSprinting: boolean,
            IsEXSprinting: boolean,
        }, 

        States: {
            IsGrounded: boolean,
            IsInAir: boolean,
            IsOnWall: boolean,
            IsClimbing: boolean,
        }
	},
	Movement
))



function Movement.new(identifer):MovementObj -- Creates the new movement object for the player/ npc
    local self = setmetatable({
        identifer = nil,

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
            IsClimbing = false,
        }
    }, Movement) :: MovementObj
    self.identifer = identifer

    return self
end










return Movement