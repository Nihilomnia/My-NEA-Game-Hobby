export type MovementObjData = {
    identifer: any,
    char: Model,
    IsReady: boolean,

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
			IsCrouching:boolean, -- Is crouching
			IsSliding:boolean, -- Is sliding 
		},



		InfoTable:{ -- Table for storing important info for the movement system (like wallrun dir, climb dir, etc.)
			Wallrun: {
				Side : number, -- Side of the wall (1 is right, -1 is left)
				Normal: Vector3, -- Normal of the wall
				Stop : (reason: string) -> (),
			},

			Dodge: {
				Dir :  string, -- Direction of the dodge (forward, back, left, right and spot)
				Type : string, -- Type of dodge (standard, airdash,)
				Stop : () -> (),
			},

			Climb: {
				Stop : () -> (),
			},

			Sprint: {
				Stop : () -> (),
			},

			EXSprint: {
				Stop : () -> (),
			},

			WallHold: {
				Type : string, -- Type of wall hold (Ledge, Parallel, etc.)
				Stop : () -> (),
			},


			Crouch: {
				Stop : () -> (),
			},

			Slide: {
				Stop : () -> (),
			}


			


		},

		

		WalkCycleAnims: {
			WalkForward: Animation,
			WalkRight: Animation,
			WalkLeft: Animation,
			WalkBack: Animation,
		},

		UI: {
			top: Frame,
			bottom: Frame,
			top_tilt: Frame,
			bottom_tilt: Frame,
		},
}


export type MovementObjMethods = {
    BarTween: (self: MovementObj, infoTable: {[string]: any}) -> (),
    BarTweenStop: (self: MovementObj, infoTable: {[string]: any}) -> (),
    UpdateWalkTracks: (self:MovementObj) -> (),
    WalkCycle: (self:MovementObj) -> (),
    ClearWalkAnims: (self:MovementObj) -> (),
}


export type MovementObj = MovementObjData & MovementObjMethods


return {}